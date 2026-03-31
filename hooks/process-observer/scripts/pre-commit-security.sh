#!/bin/bash
# iSparto Process Observer — Pre-commit Security Scanner
#
# Scans staged files for:
#   1) hardcoded secrets (BLOCK for critical/high)
#   2) PII patterns (WARNING only)
#   3) sensitive file globs (BLOCK)
#
# Rules are loaded from:
#   $ISPARTO_HOME/hooks/process-observer/rules/security-patterns.json
#
# Exit codes:
#   0 — pass (including warning-only cases)
#   1 — blocked (secrets/sensitive files found)

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

ISPARTO_HOME="${ISPARTO_HOME:-$HOME/.isparto}"
PATTERNS_FILE="$ISPARTO_HOME/hooks/process-observer/rules/security-patterns.json"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SECUREIGNORE_FILE="$REPO_ROOT/.secureignore"

# Fail open if pattern file is missing.
if [ ! -f "$PATTERNS_FILE" ]; then
    exit 0
fi

TMP_RULES_FILE="$(mktemp)"
TMP_SENSITIVE_FILE_GLOBS="$(mktemp)"
trap 'rm -f "$TMP_RULES_FILE" "$TMP_SENSITIVE_FILE_GLOBS"' EXIT

# Parse secrets + pii pattern objects.
# Output: section<TAB>id<TAB>name<TAB>regex<TAB>severity<TAB>exclude_files_csv<TAB>context_check
awk '
    function decode_json_escapes(s,    i, c, esc, out) {
        esc = 0
        out = ""
        for (i = 1; i <= length(s); i++) {
            c = substr(s, i, 1)
            if (esc) {
                if (c == "n") out = out "\n"
                else if (c == "t") out = out "\t"
                else out = out c
                esc = 0
            } else if (c == "\\") {
                esc = 1
            } else {
                out = out c
            }
        }
        return out
    }

    function extract_json_string(line, key,    token, pos, rest, i, c, esc, out) {
        token = "\"" key "\""
        pos = index(line, token)
        if (!pos) return ""

        rest = substr(line, pos + length(token))
        pos = index(rest, ":")
        if (!pos) return ""

        rest = substr(rest, pos + 1)
        sub(/^[[:space:]]*/, "", rest)
        if (substr(rest, 1, 1) != "\"") return ""

        rest = substr(rest, 2)
        esc = 0
        out = ""
        for (i = 1; i <= length(rest); i++) {
            c = substr(rest, i, 1)
            if (esc) {
                out = out c
                esc = 0
            } else if (c == "\\") {
                esc = 1
            } else if (c == "\"") {
                break
            } else {
                out = out c
            }
        }
        return out
    }

    function extract_json_bool(line, key,    token, pos, rest) {
        token = "\"" key "\""
        pos = index(line, token)
        if (!pos) return ""

        rest = substr(line, pos + length(token))
        pos = index(rest, ":")
        if (!pos) return ""

        rest = substr(rest, pos + 1)
        sub(/^[[:space:]]*/, "", rest)
        if (rest ~ /^true/) return "true"
        if (rest ~ /^false/) return "false"
        return ""
    }

    function extract_csv_array(line, key,    token, pos, rest, close_pos, out) {
        token = "\"" key "\""
        pos = index(line, token)
        if (!pos) return ""

        rest = substr(line, pos + length(token))
        pos = index(rest, "[")
        if (!pos) return ""

        rest = substr(rest, pos + 1)
        close_pos = index(rest, "]")
        if (!close_pos) return ""

        out = substr(rest, 1, close_pos - 1)
        gsub(/"/, "", out)
        gsub(/[[:space:]]/, "", out)
        return out
    }

    function emit_rule() {
        if (id != "") {
            print section "\t" id "\t" name "\t" regex "\t" severity "\t" exclude_files "\t" context_check
        }
    }

    BEGIN {
        section = ""
        in_patterns = 0
        in_object = 0
    }

    {
        line = $0

        if (line ~ /"secrets"[[:space:]]*:/) {
            section = "secrets"
            next
        }
        if (line ~ /"pii"[[:space:]]*:/) {
            section = "pii"
            next
        }

        if (section == "secrets" || section == "pii") {
            if (line ~ /"patterns"[[:space:]]*:/) {
                in_patterns = 1
                next
            }

            if (in_patterns && line ~ /^[[:space:]]*{[[:space:]]*$/) {
                in_object = 1
                id = ""
                name = ""
                regex = ""
                severity = ""
                exclude_files = ""
                context_check = ""
                next
            }

            if (in_object) {
                val = extract_json_string(line, "id")
                if (val != "") id = val

                val = extract_json_string(line, "name")
                if (val != "") name = val

                val = extract_json_string(line, "regex")
                if (val != "") regex = val

                val = extract_json_string(line, "severity")
                if (val != "") severity = val

                val = extract_csv_array(line, "exclude_files")
                if (val != "") exclude_files = val

                val = extract_json_bool(line, "context_check")
                if (val != "") context_check = val

                if (line ~ /^[[:space:]]*}[[:space:]]*,?[[:space:]]*$/) {
                    emit_rule()
                    in_object = 0
                    next
                }
            }

            if (in_patterns && line ~ /^[[:space:]]*][[:space:]]*,?[[:space:]]*$/) {
                in_patterns = 0
                next
            }
        }
    }
' "$PATTERNS_FILE" > "$TMP_RULES_FILE"

# Parse sensitive file glob patterns.
awk '
    function decode_simple_json_string(s) {
        gsub(/\\"/, "\"", s)
        gsub(/\\\\/, "\\", s)
        return s
    }

    function emit_quoted_strings(chunk,    q) {
        while (match(chunk, /"([^"\\]|\\.)*"/)) {
            q = substr(chunk, RSTART + 1, RLENGTH - 2)
            print decode_simple_json_string(q)
            chunk = substr(chunk, RSTART + RLENGTH)
        }
    }

    BEGIN {
        in_sensitive = 0
        in_patterns = 0
    }

    {
        line = $0

        if (line ~ /"sensitive_files"[[:space:]]*:/) {
            in_sensitive = 1
            next
        }

        if (in_sensitive && line ~ /"patterns"[[:space:]]*:/) {
            in_patterns = 1
            pos = index(line, "[")
            if (pos > 0) {
                emit_quoted_strings(substr(line, pos + 1))
            }
            if (line ~ /\]/) {
                in_patterns = 0
                in_sensitive = 0
            }
            next
        }

        if (in_patterns) {
            emit_quoted_strings(line)
            if (line ~ /\]/) {
                in_patterns = 0
                in_sensitive = 0
            }
            next
        }

        if (in_sensitive && line ~ /^[[:space:]]*}[[:space:]]*,?[[:space:]]*$/) {
            in_sensitive = 0
        }
    }
' "$PATTERNS_FILE" > "$TMP_SENSITIVE_FILE_GLOBS"

SECURE_PATHS=()
SECURE_PATTERN_IDS=()
SECURE_REASONS=()
SECURE_COUNT=0

trim_spaces() {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s' "$value"
}

load_secureignore() {
    local line file_rule rest pattern_rule reason
    if [ ! -f "$SECUREIGNORE_FILE" ]; then
        return
    fi

    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ ^[[:space:]]*$ ]] || [[ "$line" =~ ^[[:space:]]*# ]]; then
            continue
        fi

        file_rule="${line%%:*}"
        rest="${line#*:}"
        if [ "$file_rule" = "$line" ] || [ -z "$rest" ]; then
            continue
        fi

        if [[ "$rest" == *:* ]]; then
            pattern_rule="${rest%%:*}"
            reason="${rest#*:}"
        else
            pattern_rule="*"
            reason="$rest"
        fi

        file_rule="$(trim_spaces "$file_rule")"
        pattern_rule="$(trim_spaces "$pattern_rule")"
        reason="$(trim_spaces "$reason")"

        [ -z "$file_rule" ] && continue
        [ -z "$pattern_rule" ] && pattern_rule="*"

        SECURE_PATHS+=("$file_rule")
        SECURE_PATTERN_IDS+=("$pattern_rule")
        SECURE_REASONS+=("$reason")
        SECURE_COUNT=$((SECURE_COUNT + 1))
    done < "$SECUREIGNORE_FILE"
}

is_whitelisted() {
    local file_path="$1"
    local pattern_id="$2"
    local i file_glob id_glob

    for ((i = 0; i < SECURE_COUNT; i++)); do
        file_glob="${SECURE_PATHS[$i]}"
        id_glob="${SECURE_PATTERN_IDS[$i]}"
        case "$file_path" in
            $file_glob)
                if [ "$id_glob" = "*" ] || [ "$id_glob" = "$pattern_id" ]; then
                    return 0
                fi
                ;;
        esac
    done

    return 1
}

matches_glob_csv() {
    local file_path="$1"
    local glob_csv="$2"
    local old_ifs="$IFS"
    local glob_item

    [ -z "$glob_csv" ] && return 1

    IFS=','
    for glob_item in $glob_csv; do
        case "$file_path" in
            $glob_item)
                IFS="$old_ifs"
                return 0
                ;;
        esac
    done
    IFS="$old_ifs"
    return 1
}

is_binary_skip_file() {
    local file_path="$1"
    local base_name lower_base
    base_name="$(basename "$file_path")"
    lower_base="$(printf '%s' "$base_name" | tr '[:upper:]' '[:lower:]')"

    case "$lower_base" in
        *.png|*.jpg|*.jpeg|*.gif|*.ico|*.svg|*.woff|*.woff2|*.ttf|*.eot|*.mp3|*.mp4|*.zip|*.tar|*.gz|*.pdf|.ds_store|*.pbxproj|*.xcworkspacedata)
            return 0
            ;;
    esac

    return 1
}

should_skip_all_pii_for_file() {
    local file_path="$1"
    local base_name
    base_name="$(basename "$file_path")"

    case "$file_path" in
        *.md|*.txt|*.json|*.lock|*.yaml|*.yml)
            return 0
            ;;
    esac
    case "$base_name" in
        CLAUDE*)
            return 0
            ;;
    esac

    return 1
}

should_skip_email_hardcoded() {
    local file_path="$1"
    local base_name
    base_name="$(basename "$file_path")"

    case "$file_path" in
        *.md|*.txt|package.json|*.lock)
            return 0
            ;;
    esac
    case "$base_name" in
        CLAUDE*)
            return 0
            ;;
    esac

    return 1
}

find_match_lines() {
    local content="$1"
    local regex="$2"
    local context_mode="${3:-none}"

    if [ "$context_mode" = "string_assignment" ]; then
        printf '%s' "$content" | REGEX="$regex" perl -ne '
            BEGIN {
                $re = eval { qr{$ENV{REGEX}} };
                if ($@) { exit 2; }
            }
            $hit = 0;
            while (/[A-Za-z_][A-Za-z0-9_.-]*\s*[:=]\s*(["\x27])(.*?)\1/g) {
                if ($2 =~ /$re/) {
                    $hit = 1;
                    last;
                }
            }
            print "$.\n" if $hit;
        '
    else
        printf '%s' "$content" | REGEX="$regex" perl -ne '
            BEGIN {
                $re = eval { qr{$ENV{REGEX}} };
                if ($@) { exit 2; }
            }
            print "$.\n" if /$re/;
        '
    fi
}

mask_line_numbers() {
    local line_list="$1"
    local out=""
    local line_no
    local total=0
    local shown=0

    while IFS= read -r line_no; do
        [ -z "$line_no" ] && continue
        total=$((total + 1))
        if [ "$shown" -lt 3 ]; then
            if [ -n "$out" ]; then
                out="$out, "
            fi
            out="${out}L${line_no}"
            shown=$((shown + 1))
        fi
    done <<EOF
$line_list
EOF

    if [ -z "$out" ]; then
        printf 'n/a'
        return
    fi

    if [ "$total" -gt 3 ]; then
        out="$out, ..."
    fi

    printf '%s' "$out"
}

print_block() {
    local pattern_name="$1"
    local file_path="$2"
    local line_desc="$3"
    printf "${RED}BLOCK${NC} %s\n" "$pattern_name"
    printf "  file: %s\n" "$file_path"
    printf "  lines: %s\n" "$line_desc"
}

print_warning() {
    local pattern_name="$1"
    local file_path="$2"
    printf "${YELLOW}WARNING${NC} %s\n" "$pattern_name"
    printf "  file: %s\n" "$file_path"
    printf "  verify this is intentional\n"
}

load_secureignore

BLOCK_COUNT=0
WARNING_COUNT=0

while IFS= read -r -d '' staged_file; do
    [ -z "$staged_file" ] && continue

    if is_binary_skip_file "$staged_file"; then
        continue
    fi

    # Block sensitive file globs.
    while IFS= read -r sensitive_glob || [ -n "$sensitive_glob" ]; do
        [ -z "$sensitive_glob" ] && continue
        case "$staged_file" in
            $sensitive_glob)
                if is_whitelisted "$staged_file" "sensitive-file"; then
                    continue
                fi
                BLOCK_COUNT=$((BLOCK_COUNT + 1))
                print_block "Sensitive File Pattern (${sensitive_glob})" "$staged_file" "n/a"
                ;;
        esac
    done < "$TMP_SENSITIVE_FILE_GLOBS"

    if ! staged_content="$(git show ":$staged_file" 2>/dev/null)"; then
        continue
    fi

    while IFS=$'\t' read -r section pattern_id pattern_name regex severity exclude_csv context_check || [ -n "$section$pattern_id$pattern_name$regex$severity$exclude_csv$context_check" ]; do
        [ -z "$pattern_id" ] && continue

        if is_whitelisted "$staged_file" "$pattern_id"; then
            continue
        fi

        if [ -n "$exclude_csv" ] && matches_glob_csv "$staged_file" "$exclude_csv"; then
            continue
        fi

        if [ "$section" = "pii" ]; then
            if should_skip_all_pii_for_file "$staged_file"; then
                continue
            fi
            if [ "$pattern_id" = "email-hardcoded" ] && should_skip_email_hardcoded "$staged_file"; then
                continue
            fi
        fi

        context_mode="none"
        if [ "$section" = "pii" ] && { [ "$pattern_id" = "china-phone" ] || [ "$pattern_id" = "bank-card" ]; }; then
            context_mode="string_assignment"
        fi

        if ! matched_lines="$(find_match_lines "$staged_content" "$regex" "$context_mode")"; then
            continue
        fi

        [ -z "$matched_lines" ] && continue

        if [ "$section" = "secrets" ]; then
            severity_lc="$(printf '%s' "$severity" | tr '[:upper:]' '[:lower:]')"
            if [ "$severity_lc" = "critical" ] || [ "$severity_lc" = "high" ]; then
                BLOCK_COUNT=$((BLOCK_COUNT + 1))
                print_block "$pattern_name" "$staged_file" "$(mask_line_numbers "$matched_lines")"
            else
                WARNING_COUNT=$((WARNING_COUNT + 1))
                print_warning "$pattern_name" "$staged_file"
            fi
        else
            WARNING_COUNT=$((WARNING_COUNT + 1))
            print_warning "$pattern_name" "$staged_file"
        fi
    done < "$TMP_RULES_FILE"
done < <(git diff --cached --name-only --diff-filter=ACM -z)

if [ "$BLOCK_COUNT" -gt 0 ]; then
    printf "\n${RED}═══ COMMIT BLOCKED ═══${NC}\n"
    printf "Remove or rotate exposed secrets and sensitive files before committing.\n"
    printf "If a match is intentional, add a whitelist entry in .secureignore:\n"
    printf "  file_path:pattern_id:reason\n"
    printf "  file_path:reason\n"
    exit 1
fi

printf "${GREEN}✓ Security scan passed${NC}\n"
exit 0
