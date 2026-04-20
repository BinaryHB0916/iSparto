#!/usr/bin/env bash
# plan-md-contract-check.sh — iSparto plan.md authoring + transition contract guardian
#
# Mechanically enforces the separation-of-concerns contract codified in
# commands/end-working.md Step 4 "plan.md, session-log.md and CHANGELOG
# authoring + transition contract". plan.md is "where we are now"
# (current actionable + in-progress + navigation); completed Wave
# retrospectives, completed FR narratives, and [DONE] annotations belong
# in docs/session-log.md, not in docs/plan.md.
#
# Rules enforced:
#   R1  [DONE] annotation           — any match of \[DONE( in Wave N)?\]
#                                     in plan.md is a violation. The
#                                     completed-Wave index table should be
#                                     a table of links, not a table of
#                                     [DONE] markers.
#   R2  Full Wave retrospective     — a level-3 heading that combines
#                                     `### Wave N ...` with a completion
#                                     token (Complete / Completed /
#                                     retrospective, or the equivalent CJK
#                                     token) is a violation UNLESS it sits
#                                     inside the completed-Wave index
#                                     section (scan-excluded region: from
#                                     the level-2 completed-index heading
#                                     to the next level-2 heading).
#   R3  Cross-file paragraph dup    — for every paragraph in plan.md that is
#                                     non-trivial (>100 chars after
#                                     whitespace normalisation) and not a
#                                     pure markdown link line, compute a
#                                     SHA1 and compare against
#                                     session-log.md paragraph hashes.
#                                     Any hash collision is a violation.
#   R4  Transition incompleteness   — optional, requires --diff-base. If
#                                     plan.md has net line deletions in the
#                                     diff but session-log.md has zero net
#                                     additions in the same diff, flag
#                                     `transition-incomplete`. Soft check:
#                                     bulk line-count heuristic, not
#                                     semantic.
#
# Usage:
#   scripts/plan-md-contract-check.sh
#   scripts/plan-md-contract-check.sh --plan-path /tmp/foo.md --session-log-path /tmp/bar.md
#   scripts/plan-md-contract-check.sh --diff-base origin/main
#   scripts/plan-md-contract-check.sh --help
#
# Exit codes:
#   0 — clean (or docs/plan.md absent — the latter is not a violation,
#       just a "nothing to scan" signal; a warning is printed to stderr)
#   1 — one or more violations detected
#   2 — environment error (bad arguments, repo-root unresolved, etc.)
#
# Integrated into commands/end-working.md Step 4 enforcement block + the
# Doc Engineer audit item 11 semantic check (see docs/roles.md).

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

usage() {
    cat <<'USAGE'
plan-md-contract-check.sh — plan.md / session-log.md / CHANGELOG separation guardian

Usage:
  scripts/plan-md-contract-check.sh [options]

Options:
  --plan-path <path>         Override docs/plan.md path (default: docs/plan.md). Test-mode hook.
  --session-log-path <path>  Override docs/session-log.md path (default: docs/session-log.md).
  --diff-base <ref>          Enable transition-incompleteness check against <ref>..HEAD (default: disabled).
  -h, --help                 Show this help text.

Exit codes:
  0  clean
  1  violations detected
  2  environment error
USAGE
}

# Resolve repo root: prefer git, fall back to script-relative.
if REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    :
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

if ! cd "$REPO_ROOT"; then
    printf "%bERROR:%b cannot cd to repo root: %s\n" "$RED" "$NC" "$REPO_ROOT" >&2
    exit 2
fi

PLAN_PATH="docs/plan.md"
SESSION_LOG_PATH="docs/session-log.md"
DIFF_BASE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --plan-path)
            [[ $# -lt 2 ]] && { printf "%bERROR:%b --plan-path requires a value\n" "$RED" "$NC" >&2; exit 2; }
            PLAN_PATH="$2"
            shift 2
            ;;
        --session-log-path)
            [[ $# -lt 2 ]] && { printf "%bERROR:%b --session-log-path requires a value\n" "$RED" "$NC" >&2; exit 2; }
            SESSION_LOG_PATH="$2"
            shift 2
            ;;
        --diff-base)
            [[ $# -lt 2 ]] && { printf "%bERROR:%b --diff-base requires a value\n" "$RED" "$NC" >&2; exit 2; }
            DIFF_BASE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf "%bERROR:%b unknown argument: %s\n" "$RED" "$NC" "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

if [[ ! -f "$PLAN_PATH" ]]; then
    printf "%bWARNING:%b plan.md not found at %s — nothing to scan\n" "$YELLOW" "$NC" "$PLAN_PATH" >&2
    exit 0
fi

export PLAN_PATH SESSION_LOG_PATH DIFF_BASE

python3 - <<'PYEOF'
import hashlib
import os
import re
import subprocess
import sys
from pathlib import Path

PLAN_PATH = Path(os.environ['PLAN_PATH'])
SESSION_LOG_PATH = Path(os.environ['SESSION_LOG_PATH'])
DIFF_BASE = os.environ.get('DIFF_BASE', '').strip()

violations = []  # list of (rule_id, file, line_or_zero, message)

plan_text = PLAN_PATH.read_text(encoding='utf-8')
plan_lines = plan_text.splitlines()

# ---- R1: [DONE] annotations --------------------------------------------------
DONE_RE = re.compile(r'\[DONE(?: in Wave \d+)?\]')
for idx, line in enumerate(plan_lines, start=1):
    if DONE_RE.search(line):
        violations.append((
            'R1', str(PLAN_PATH), idx,
            f'forbidden [DONE] annotation: {line.strip()[:120]}'
        ))

# ---- R2: full Wave retrospective headings -----------------------------------
# Compute the scan-excluded region covering the level-2 completed-Wave
# index heading through the next `## ` heading. Inside the excluded
# region, level-3 Wave headings are allowed because the index is a table
# of links to session-log.md entries.
#
# The heading text is maintainer-language-dependent. Two forms are
# accepted: English ("## Completed Wave Index") or the CJK equivalent
# ("\u5df2\u5b8c\u6210 Wave \u7d22\u5f15" — the four-character "completed"
# word + "Wave" + two-character "index" word). Encoded as Unicode escapes
# so this source file stays CJK-free per the Tier 1 language convention.
INDEX_HEADING_RE = re.compile(
    r'^##\s+(?:'
    r'\u5df2\u5b8c\u6210\s*Wave\s*\u7d22\u5f15'
    r'|Completed\s+Wave\s+Index'
    r')\b'
)
NEXT_SECTION_RE = re.compile(r'^##\s+')

excluded_start = None
excluded_end = None
for idx, line in enumerate(plan_lines, start=1):
    if excluded_start is None and INDEX_HEADING_RE.match(line):
        excluded_start = idx
        continue
    if excluded_start is not None and excluded_end is None and NEXT_SECTION_RE.match(line) \
            and not INDEX_HEADING_RE.match(line) and idx != excluded_start:
        excluded_end = idx - 1
        break

if excluded_start is not None and excluded_end is None:
    excluded_end = len(plan_lines)

def in_excluded_region(line_no):
    if excluded_start is None:
        return False
    return excluded_start <= line_no <= excluded_end

# Match a level-3 Wave heading that self-declares completion. The forms
# observed in real plan.md / session-log drift are:
#   `### Wave N: Title -- Complete`
#   `### Wave N -- Title (YYYY-MM-DD) -- Completed`
#   `### Wave N <completion token> / Wave N retrospective`
# The Complete / Completed / retrospective tokens (plus the CJK
# two-character "completed" equivalent, Unicode escape \u5b8c\u6210) are
# the retrospective-flavour markers; the plain `### Wave N: Title` form
# is allowed (that's the in-progress heading). The CJK token is encoded
# as a Unicode escape to keep this source file CJK-free per the Tier 1
# language convention.
WAVE_RETRO_RE = re.compile(
    r'^###\s+Wave\s+\S+.*?(?:\u5b8c\u6210|Completed?|retrospective)\b',
    re.IGNORECASE,
)

for idx, line in enumerate(plan_lines, start=1):
    if WAVE_RETRO_RE.match(line):
        if in_excluded_region(idx):
            continue
        violations.append((
            'R2', str(PLAN_PATH), idx,
            f'Wave retrospective heading outside index region: {line.strip()[:120]}'
        ))

# ---- R3: cross-file paragraph duplication -----------------------------------
def split_paragraphs(text):
    """Split on blank-line boundaries. Return list of (start_line, text)."""
    paragraphs = []
    cur = []
    cur_start = 0
    for idx, raw in enumerate(text.splitlines(), start=1):
        if raw.strip() == '':
            if cur:
                paragraphs.append((cur_start, '\n'.join(cur)))
                cur = []
                cur_start = 0
            continue
        if not cur:
            cur_start = idx
        cur.append(raw)
    if cur:
        paragraphs.append((cur_start, '\n'.join(cur)))
    return paragraphs

def normalise(text):
    # Collapse runs of whitespace; strip.
    return re.sub(r'\s+', ' ', text).strip()

PURE_LINK_RE = re.compile(r'^\s*[-*]?\s*\[[^\]]+\]\([^)]+\)\s*$')

def is_trivial(para_text):
    stripped = para_text.strip()
    if not stripped:
        return True
    # Pure single-line markdown link (list item or standalone) is trivial.
    if '\n' not in stripped and PURE_LINK_RE.match(stripped):
        return True
    return False

session_hashes = {}
if SESSION_LOG_PATH.is_file():
    sl_text = SESSION_LOG_PATH.read_text(encoding='utf-8')
    for (sl_line, sl_para) in split_paragraphs(sl_text):
        normed = normalise(sl_para)
        if len(normed) < 100:
            continue
        h = hashlib.sha1(normed.encode('utf-8')).hexdigest()
        session_hashes.setdefault(h, (sl_line, sl_para))

for (line_no, para) in split_paragraphs(plan_text):
    normed = normalise(para)
    if len(normed) < 100:
        continue
    if is_trivial(para):
        continue
    h = hashlib.sha1(normed.encode('utf-8')).hexdigest()
    if h in session_hashes:
        snippet = normed[:80].replace('\n', ' ')
        violations.append((
            'R3', str(PLAN_PATH), line_no,
            f'paragraph duplicated in {SESSION_LOG_PATH} (hash {h[:12]}): "{snippet}..."'
        ))

# ---- R4: transition-incompleteness (requires --diff-base) -------------------
def git_numstat(diff_base, path):
    """Return (adds, dels) tuple for `path` against diff_base..HEAD; (0,0) on any error."""
    try:
        out = subprocess.check_output(
            ['git', 'diff', '--numstat', f'{diff_base}..HEAD', '--', path],
            text=True,
            stderr=subprocess.DEVNULL,
        )
    except subprocess.CalledProcessError:
        return (0, 0)
    except FileNotFoundError:
        return (0, 0)
    total_add = 0
    total_del = 0
    for line in out.splitlines():
        parts = line.split('\t')
        if len(parts) < 2:
            continue
        a, d = parts[0], parts[1]
        try:
            total_add += int(a)
            total_del += int(d)
        except ValueError:
            # Binary file rows carry '-' markers; skip.
            continue
    return (total_add, total_del)

if DIFF_BASE:
    plan_add, plan_del = git_numstat(DIFF_BASE, str(PLAN_PATH))
    sl_add, _sl_del = git_numstat(DIFF_BASE, str(SESSION_LOG_PATH))
    # Heuristic: plan.md lost substantive content (>10 lines deleted net)
    # but session-log.md gained none. Likely a transition failure.
    if (plan_del - plan_add) > 10 and sl_add == 0:
        violations.append((
            'R4', str(PLAN_PATH), 0,
            f'transition-incomplete: plan.md net-deleted {plan_del - plan_add} '
            f'lines against {DIFF_BASE} but {SESSION_LOG_PATH} gained 0 additions'
        ))

# ---- Emit --------------------------------------------------------------------
if not violations:
    sys.exit(0)

for rule, f, ln, msg in violations:
    if ln > 0:
        sys.stderr.write(f'[{rule}] {f}:{ln}: {msg}\n')
    else:
        sys.stderr.write(f'[{rule}] {f}: {msg}\n')
sys.stderr.write(f'\n{len(violations)} plan.md contract violation(s) detected.\n')
sys.exit(1)
PYEOF
