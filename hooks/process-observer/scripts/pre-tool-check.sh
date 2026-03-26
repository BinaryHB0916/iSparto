#!/bin/bash
# iSparto Process Observer — PreToolUse Hook
#
# This script is invoked by Claude Code before each tool execution.
# It reads a JSON payload from stdin containing tool_name and tool_input,
# checks Bash commands against dangerous-operations.json rules, and
# blocks high-risk operations.
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

if [ ! -f "$RULES_FILE" ]; then
    # Rules file missing — allow all operations (fail open)
    exit 0
fi

# ── Read JSON from stdin ─────────────────────────────────────
INPUT=$(cat)

# ── Extract tool_name ────────────────────────────────────────
# Parse tool_name from JSON without jq
TOOL_NAME=$(echo "$INPUT" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*:.*"\([^"]*\)"/\1/')

# Only check Bash tool invocations
if [ "$TOOL_NAME" != "Bash" ]; then
    exit 0
fi

# ── Extract command from tool_input ──────────────────────────
# The command field may contain escaped quotes (\") inside the JSON string.
# We use awk to correctly parse the full value, handling \" sequences.
COMMAND=$(echo "$INPUT" | awk '
    BEGIN { RS="\0" }
    {
        # Find "command" : "..." handling escaped quotes
        if (match($0, /"command"[[:space:]]*:[[:space:]]*"/)) {
            s = substr($0, RSTART + RLENGTH)
            result = ""
            for (i = 1; i <= length(s); i++) {
                c = substr(s, i, 1)
                if (c == "\\" && substr(s, i+1, 1) == "\"") {
                    result = result "\""
                    i++
                } else if (c == "\"") {
                    break
                } else {
                    result = result c
                }
            }
            print result
        }
    }
')

if [ -z "$COMMAND" ]; then
    exit 0
fi

# ── Helper: block and exit ───────────────────────────────────
block() {
    local rule_id="$1"
    local reason="$2"
    printf '{"decision": "block", "reason": "[%s] %s"}\n' "$rule_id" "$reason"
    exit 2
}

# ── Check a single rule against COMMAND ──────────────────────
check_rule() {
    local rule_id="$1"
    local pattern="$2"
    local severity="$3"
    local reason="$4"

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
            elif find . -maxdepth 2 \( -name ".env" -o -name ".env.*" \) -print -quit 2>/dev/null | grep -q . 2>/dev/null; then
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
while IFS=$'\t' read -r rule_id rule_pattern rule_severity rule_reason; do
    [ -z "$rule_id" ] && continue
    check_rule "$rule_id" "$rule_pattern" "$rule_severity" "$rule_reason"
done <<< "$PARSED_RULES"

# ── No match — allow ─────────────────────────────────────────
exit 0
