#!/bin/bash
# iSparto Process Observer — PreToolUse Hook
#
# This script is invoked by Claude Code before each tool execution.
# It reads a JSON payload from stdin containing tool_name and tool_input,
# checks operations against dangerous-operations.json (Bash) and
# workflow-rules.json (Edit/Write/Codex) to enforce role boundaries
# and block high-risk operations.
#
# Exit codes:
#   0 — allow (no output)
#   2 — block (outputs JSON with decision and reason)
#
# Dependencies: bash, grep, sed, awk (no jq required)
# Note: All regex patterns use POSIX ERE (grep -E compatible on macOS)

set -euo pipefail

# ── Locate rules file relative to this script ────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RULES_FILE="$SCRIPT_DIR/../rules/dangerous-operations.json"
WORKFLOW_RULES_FILE="$SCRIPT_DIR/../rules/workflow-rules.json"

# ── Read JSON from stdin ─────────────────────────────────────
INPUT=$(cat)

# ── Canary: detect tool_input schema drift ───────────────────
# If Claude Code evolves tool_input to use nested objects/arrays for
# fields we currently treat as flat strings (command / file_path / prompt),
# our parsers silently return empty and hooks fail-open invisibly. This
# canary logs a stderr warning when drift is detected. It never blocks.
# Python-internal errors (missing tool_input, parse failure) stay silent;
# the try/except inside the script ensures no traceback reaches stderr.
python3 - "$INPUT" <<'PYEOF' || true
import json, sys
try:
    raw = sys.argv[1] if len(sys.argv) > 1 else ""
    if not raw:
        sys.exit(0)
    try:
        payload = json.loads(raw)
    except Exception:
        sys.exit(0)
    if not isinstance(payload, dict):
        sys.exit(0)
    tool_input = payload.get("tool_input")
    if tool_input is None:
        sys.exit(0)
    tool_name = payload.get("tool_name", "unknown")
    script_ref = "hooks/process-observer/scripts/pre-tool-check.sh"
    def warn(field, value):
        t = type(value).__name__
        sys.stderr.write(
            f"iSparto canary: tool_input schema drift detected "
            f"(tool={tool_name}, field={field}, type={t}) — see {script_ref}\n"
        )
    if not isinstance(tool_input, dict):
        warn("tool_input", tool_input)
        sys.exit(0)
    for field in ("command", "file_path", "prompt"):
        if field in tool_input and not isinstance(tool_input[field], str):
            warn(field, tool_input[field])
except Exception:
    # Defensive: never let the canary crash or surface a traceback.
    sys.exit(0)
PYEOF
# If python3 is not installed, bash emits "python3: command not found" on
# stderr; hide that specific failure mode without silencing the canary body.
# (We rely on install.sh's python3 dependency check to make this rare.)

# ── Extract tool_name ────────────────────────────────────────
# Parse tool_name from JSON without jq
TOOL_NAME=$(echo "$INPUT" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*:.*"\([^"]*\)"/\1/')

# Extract a JSON string field value from the payload.
# Signature: extract_json_field <input_json_string> <field_name> [unescape_newlines]
# - Third arg defaults to "false".
# - Lookup order: (1) payload["tool_input"][field] if tool_input is an object,
#   (2) payload[field] (top-level fallback). Matches prior awk behavior where
#   a flat regex found the field wherever it appeared.
# - Nested objects are not recursed into beyond the two levels above.
# - When unescape_newlines == "true", JSON escapes (\n, \t, \uXXXX, ...) are
#   decoded naturally by python3's json module.
# - When "false" (default), escape sequences are preserved as literal two-char
#   sequences (e.g., "\n" stays as backslash + 'n'), matching prior awk behavior.
# - On any failure (missing field, non-string value, parse error), emit empty
#   and exit 0 (fail-open, matching prior semantics).
extract_json_field() {
    local input="$1"
    local field="$2"
    local unescape_newlines="${3:-false}"
    python3 - "$input" "$field" "$unescape_newlines" <<'PYEOF' 2>/dev/null || true
import json, sys
raw = sys.argv[1]
field = sys.argv[2]
unescape = sys.argv[3] == "true"
try:
    payload = json.loads(raw)
except Exception:
    sys.exit(0)
if not isinstance(payload, dict):
    sys.exit(0)
value = None
tool_input = payload.get("tool_input")
if isinstance(tool_input, dict):
    v = tool_input.get(field)
    if isinstance(v, str):
        value = v
if value is None:
    v = payload.get(field)
    if isinstance(v, str):
        value = v
if value is None:
    sys.exit(0)
if unescape:
    # json.loads already decoded all JSON escapes (including \uXXXX); emit as-is.
    sys.stdout.write(value)
else:
    # Preserve literal escape sequences: re-encode the string via json.dumps
    # with ensure_ascii=True so \n, \t, \uXXXX, etc. come back as their
    # two-character literal forms (matching the old awk parser, which never
    # decoded them). Strip surrounding quotes and unescape only \" sequences
    # (which were actual embedded quotes in the source).
    reencoded = json.dumps(value, ensure_ascii=True)[1:-1]
    sys.stdout.write(reencoded.replace('\\"', '"'))
PYEOF
}

# ── Helper: block and exit ───────────────────────────────────
block() {
    local rule_id="$1"
    local reason="$2"
    printf '{"decision": "block", "reason": "[%s] %s"}\n' "$rule_id" "$reason"
    exit 2
}

# Route by tool type
case "$TOOL_NAME" in
    Bash)
        # ── Bash: check against dangerous-operations.json ──────────
        if [ ! -f "$RULES_FILE" ]; then
            # Rules file missing — allow all operations (fail open)
            exit 0
        fi

        # ── Extract command from tool_input ──────────────────────────
        COMMAND=$(extract_json_field "$INPUT" "command")

        if [ -z "$COMMAND" ]; then
            exit 0
        fi

        # ── Git-rule helper: check pattern outside quoted strings ───
        # Returns 0 if pattern matches outside quotes, 1 otherwise.
        # Used by git rules to avoid false positives from text in arguments
        # (e.g., gh pr create --body "...git push origin main...").
        # Not applied to filesystem rules where quoted paths are real targets.
        matches_outside_quotes() {
            local cmd="$1" pat="$2"
            local stripped
            stripped=$(printf '%s' "$cmd" | sed "s/\"[^\"]*\"//g; s/'[^']*'//g")
            printf '%s' "$stripped" | grep -qE -- "$pat" 2>/dev/null
        }

        # ── Check a single rule against COMMAND ──────────────────────
        check_rule() {
            local rule_id="$1"
            local pattern="$2"
            local reason="$3"

            # Git rules with special handling (quote-aware + conditional logic)
            case "$rule_id" in
                commit-on-main|merge-on-main|push-on-main)
                    if echo "$COMMAND" | grep -qE -- "$pattern" 2>/dev/null; then
                        # Skip if pattern only appears inside quoted strings
                        if ! matches_outside_quotes "$COMMAND" "$pattern"; then
                            return
                        fi
                        local current_branch
                        current_branch=$(git branch --show-current 2>/dev/null || echo "")
                        if [ "$current_branch" = "main" ] || [ "$current_branch" = "master" ]; then
                            # Compound command safety: if git checkout -b / git switch -c
                            # appears in the same command, the branch will change before
                            # the matched operation executes — allow it through.
                            # TODO: reverse order (e.g., git commit && git checkout -b) is not
                            # handled — extremely rare in practice, and Branch Protocol entrance
                            # defense prevents working on main in the first place.
                            if printf '%s' "$COMMAND" | grep -qE 'git[[:space:]]+(checkout[[:space:]]+-[bB]|switch[[:space:]]+-c)' 2>/dev/null; then
                                return
                            fi
                            # Bootstrap: allow push when remote has no main/master yet (initial repo setup)
                            if [ "$rule_id" = "push-on-main" ]; then
                                if ! git rev-parse --verify origin/main >/dev/null 2>&1 && \
                                   ! git rev-parse --verify origin/master >/dev/null 2>&1; then
                                    return
                                fi
                            fi
                            local action_desc
                            case "$rule_id" in
                                commit-on-main) action_desc="commit" ;;
                                merge-on-main)  action_desc="merge" ;;
                                push-on-main)   action_desc="push" ;;
                                *)              action_desc="operate" ;;
                            esac
                            printf '{"decision": "block", "reason": "[%s] Cannot %s on main branch. Run `git checkout -b <type>/<name>` first to create a branch (type = feat/fix/hotfix/docs/release), then retry. Any existing working-tree changes will be carried over to the new branch. (current branch: %s)"}\n' \
                                "$rule_id" "$action_desc" "$current_branch"
                            exit 2
                        fi
                    fi
                    return
                    ;;
                git-push-main-direct|git-force-push-protected)
                    if echo "$COMMAND" | grep -qE -- "$pattern" 2>/dev/null; then
                        # Skip if pattern only appears inside quoted strings
                        if ! matches_outside_quotes "$COMMAND" "$pattern"; then
                            return
                        fi
                        # Bootstrap: allow when remote has no main/master yet (git-push-main-direct only)
                        if [ "$rule_id" = "git-push-main-direct" ]; then
                            if ! git rev-parse --verify origin/main >/dev/null 2>&1 && \
                               ! git rev-parse --verify origin/master >/dev/null 2>&1; then
                                return
                            fi
                        fi
                        block "$rule_id" "$reason"
                    fi
                    return
                    ;;
            esac

            # Special handling for commit-env-file-bulk: only block if .env exists
            if [ "$rule_id" = "commit-env-file-bulk" ]; then
                if echo "$COMMAND" | grep -qE -- "$pattern" 2>/dev/null; then
                    # Check if .env file exists via git index (fast, skips node_modules etc.)
                    # --cached = tracked files, --others --exclude-standard = untracked minus gitignored
                    # Non-git repos: git ls-files fails → grep returns 1 → env_found stays false (correct fail-open)
                    local env_found=false
                    if git ls-files --cached --others --exclude-standard 2>/dev/null | grep -qE '(^|/)\.env(\.|$)'; then
                        env_found=true
                    fi
                    if $env_found; then
                        printf '{"decision": "block", "reason": "[%s] %s (.env file detected in working directory)"}\n' \
                            "$rule_id" "$reason"
                        exit 2
                    fi
                fi
                return
            fi

            # Standard pattern matching
            # Use grep -e to prevent patterns starting with -- from being treated as options
            if echo "$COMMAND" | grep -qE -e "$pattern" 2>/dev/null; then
                block "$rule_id" "$reason"
            fi
        }

        # ── Parse rules from JSON using awk ──────────────────────────
        # Extracts fields from JSON and un-escapes JSON backslashes in patterns.
        # Output format: id<TAB>pattern<TAB>severity<TAB>reason (one line per rule)
        # Using TAB as delimiter since patterns may contain | characters.
        PARSED_RULES=$(awk -F'"' '
            /"id"/ { id = $4 }
            /"pattern"/ {
                # Extract pattern value — everything between the 3rd and 4th quote
                p = $4
                # Un-escape JSON: \\\\ -> \\  (JSON encodes \ as \\)
                gsub(/\\\\/, "\\", p)
                pattern = p
            }
            /"severity"/ { severity = $4 }
            /"reason"/ {
                reason = $4
                print id "\t" pattern "\t" severity "\t" reason
            }
        ' "$RULES_FILE")

        # Iterate over parsed rules and check each one
        while IFS=$'\t' read -r rule_id rule_pattern _rule_severity rule_reason; do
            [ -z "$rule_id" ] && continue
            check_rule "$rule_id" "$rule_pattern" "$rule_reason"
        done <<< "$PARSED_RULES"

        exit 0
        ;;

    Edit|Write)
        # ── Edit/Write: check file extension against workflow rules ──
        if [ ! -f "$WORKFLOW_RULES_FILE" ]; then
            exit 0
        fi

        # Extract file_path from tool_input
        FILE_PATH=$(extract_json_field "$INPUT" "file_path")

        if [ -z "$FILE_PATH" ]; then
            exit 0
        fi

        # Extract file extension
        BASENAME=$(basename "$FILE_PATH")
        if [[ "$BASENAME" == *.* ]]; then
            EXT=".${BASENAME##*.}"
        else
            # No extension (e.g., Makefile, Dockerfile) — treat as code (fail-safe)
            TOOL_NAME_LOWER=$(echo "$TOOL_NAME" | tr '[:upper:]' '[:lower:]')
            block "direct-code-${TOOL_NAME_LOWER}" "Code changes must go through Developer (Codex) — direct editing of ($FILE_PATH) is not allowed. Use the mcp__codex-dev__codex tool to call Developer, and assemble a structured prompt per the Implementation prompt template in docs/roles.md."
        fi

        # Parse allowed_extensions from workflow-rules.json
        ALLOWED_EXTS=$(awk '
            /"allowed_extensions"/ { in_list=1; next }
            in_list && /\]/ { in_list=0; next }
            in_list {
                n = split($0, arr, "\"")
                for (i = 1; i <= n; i++) {
                    if (arr[i] ~ /^\./) print arr[i]
                }
            }
        ' "$WORKFLOW_RULES_FILE")

        # Check if extension is in allowed list
        if echo "$ALLOWED_EXTS" | grep -qxF "$EXT"; then
            # ── Security: scan content for critical secrets ──
            SECURITY_PATTERNS_FILE="$SCRIPT_DIR/../rules/security-patterns.json"
            if [ -f "$SECURITY_PATTERNS_FILE" ]; then
                if [ "$TOOL_NAME" = "Write" ]; then
                    CONTENT_TO_SCAN=$(extract_json_field "$INPUT" "content" "true")
                else
                    CONTENT_TO_SCAN=$(extract_json_field "$INPUT" "new_string" "true")
                fi

                if [ -n "$CONTENT_TO_SCAN" ]; then
                    CRITICAL_PATTERN_IDS=$(awk '
                        /"realtime_critical"/ { in_rt=1; next }
                        in_rt && /"pattern_ids"/ { in_ids=1; next }
                        in_ids && /\]/ { in_ids=0; next }
                        in_ids {
                            n = split($0, arr, "\"")
                            for (i = 1; i <= n; i++) {
                                if (arr[i] ~ /^[A-Za-z0-9][A-Za-z0-9_-]*$/) print arr[i]
                            }
                        }
                        in_rt && /\}/ { if (!in_ids) in_rt=0 }
                    ' "$SECURITY_PATTERNS_FILE")

                    while IFS= read -r PATTERN_ID; do
                        [ -z "$PATTERN_ID" ] && continue

                        PATTERN_INFO=$(awk -F'"' -v target_id="$PATTERN_ID" '
                            /"secrets"/ { in_secrets=1; next }
                            in_secrets && /"pii"/ { in_secrets=0 }
                            in_secrets && /"patterns"/ { in_patterns=1; next }
                            in_patterns && /"id"/ { current_id=$4; next }
                            in_patterns && current_id == target_id && /"name"/ { name=$4; next }
                            in_patterns && current_id == target_id && /"regex"/ {
                                regex = $4
                                gsub(/\\\\/, "\\", regex)
                                if (name == "") name = target_id
                                print name "\t" regex
                                exit
                            }
                        ' "$SECURITY_PATTERNS_FILE")

                        [ -z "$PATTERN_INFO" ] && continue
                        MATCHED_NAME=${PATTERN_INFO%%$'\t'*}
                        MATCHED_REGEX=${PATTERN_INFO#*$'\t'}

                        if [ -n "$MATCHED_REGEX" ] && printf '%s' "$CONTENT_TO_SCAN" | grep -qE -e "$MATCHED_REGEX" 2>/dev/null; then
                            block "security-secret-in-content" "Possible $MATCHED_NAME detected — writing a secret into a file ($FILE_PATH) is not allowed. Use an environment variable or configuration reference instead."
                        fi
                    done <<< "$CRITICAL_PATTERN_IDS"
                fi
            fi

            exit 0
        fi

        # Not in allowed list — block as code file
        TOOL_NAME_LOWER=$(echo "$TOOL_NAME" | tr '[:upper:]' '[:lower:]')
        block "direct-code-${TOOL_NAME_LOWER}" "Code changes must go through Developer (Codex) — direct editing of ($FILE_PATH) is not allowed. Use the mcp__codex-dev__codex tool to call Developer, and assemble a structured prompt per the Implementation prompt template in docs/roles.md."
        ;;

    mcp__codex-dev__codex)
        # ── Codex MCP: check prompt structure ──────────────────────
        if [ ! -f "$WORKFLOW_RULES_FILE" ]; then
            exit 0
        fi

        # Extract prompt from tool_input
        PROMPT_TEXT=$(extract_json_field "$INPUT" "prompt" "true")

        if [ -z "$PROMPT_TEXT" ]; then
            exit 0
        fi

        # Check for structured prompt: must contain "## " (markdown heading level 2+)
        if echo "$PROMPT_TEXT" | grep -q '## '; then
            exit 0
        fi

        block "codex-unstructured-prompt" "Calling Developer requires a structured prompt (must contain a ## heading). Assemble the prompt per the Implementation prompt template in docs/roles.md, ensuring it contains sections such as Product context, Technical context, Implementation task, File scope, Constraints, and Expected output."
        ;;

    *)
        # All other tools — allow
        exit 0
        ;;
esac
