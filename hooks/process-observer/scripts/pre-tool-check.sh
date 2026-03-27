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

# ── Extract tool_name ────────────────────────────────────────
# Parse tool_name from JSON without jq
TOOL_NAME=$(echo "$INPUT" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*:.*"\([^"]*\)"/\1/')

# Extract a JSON string field value, handling escaped quotes
extract_json_field() {
    local input="$1"
    local field="$2"
    local unescape_newlines="${3:-false}"
    echo "$input" | awk -v field="$field" -v unescape="$unescape_newlines" '
        BEGIN { RS="\0" }
        {
            pattern = "\"" field "\"[[:space:]]*:[[:space:]]*\""
            if (match($0, pattern)) {
                s = substr($0, RSTART + RLENGTH)
                result = ""
                for (i = 1; i <= length(s); i++) {
                    c = substr(s, i, 1)
                    if (c == "\\" && substr(s, i+1, 1) == "\"") {
                        result = result "\""
                        i++
                    } else if (c == "\\" && unescape == "true") {
                        nc = substr(s, i+1, 1)
                        if (nc == "n") { result = result "\n"; i++ }
                        else if (nc == "t") { result = result "\t"; i++ }
                        else { result = result c }
                    } else if (c == "\"") {
                        break
                    } else {
                        result = result c
                    }
                }
                print result
            }
        }
    '
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

        # ── Check a single rule against COMMAND ──────────────────────
        check_rule() {
            local rule_id="$1"
            local pattern="$2"
            local reason="$3"

            # Special handling for commit-on-main: only block if on main branch
            if [ "$rule_id" = "commit-on-main" ]; then
                if echo "$COMMAND" | grep -qE -- "$pattern" 2>/dev/null; then
                    local current_branch
                    current_branch=$(git branch --show-current 2>/dev/null || echo "")
                    if [ "$current_branch" = "main" ] || [ "$current_branch" = "master" ]; then
                        printf '{"decision": "block", "reason": "[%s] %s (current branch: %s)"}\n' \
                            "$rule_id" "$reason" "$current_branch"
                        exit 2
                    fi
                fi
                return
            fi

            # Special handling for commit-env-file-bulk: only block if .env exists
            if [ "$rule_id" = "commit-env-file-bulk" ]; then
                if echo "$COMMAND" | grep -qE -- "$pattern" 2>/dev/null; then
                    # Check if .env file exists in the working directory or subdirectories
                    local env_found=false
                    if ls .env .env.* 2>/dev/null | grep -q . 2>/dev/null; then
                        env_found=true
                    elif find . -maxdepth 10 \( -name ".env" -o -name ".env.*" \) -print -quit 2>/dev/null | grep -q . 2>/dev/null; then
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
            block "direct-code-${TOOL_NAME_LOWER}" "代码变更必须通过 Developer (Codex) 实现，不可直接编辑 ($FILE_PATH)"
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
            exit 0
        fi

        # Not in allowed list — block as code file
        TOOL_NAME_LOWER=$(echo "$TOOL_NAME" | tr '[:upper:]' '[:lower:]')
        block "direct-code-${TOOL_NAME_LOWER}" "代码变更必须通过 Developer (Codex) 实现，不可直接编辑 ($FILE_PATH)"
        ;;

    mcp__codex-reviewer__codex)
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

        block "codex-unstructured-prompt" "调用 Developer 必须使用结构化 prompt（需包含 ## 标题描述任务）"
        ;;

    *)
        # All other tools — allow
        exit 0
        ;;
esac
