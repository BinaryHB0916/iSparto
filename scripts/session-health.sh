#!/usr/bin/env bash
# session-health.sh — iSparto cross-session recovery preview (v1).
#
# Emits a 5-bullet Markdown block summarising the session's starting state
# so /start-working can paste it verbatim into its Step 9 B-layer briefing.
# The block answers the question "what context do I need to resume work?"
# — branch, last commit, uncommitted files, BLOCKING marker state, and
# observation-period progress. Pure read-only: no network, no writes.
#
# Bullets (fixed order):
#   - Branch: <current branch>
#   - Last commit: <short-hash> <subject truncated to ~80 chars>
#   - Uncommitted files: <N> [if N > 0, (file1, file2, ... up to 5)]
#   - BLOCKING marker: <present (<rationale excerpt>) | clear>
#   - Observation period: <Wave X/5, real-IR M/3 from Waves 2-4 | not active>
#
# Invocation:
#   bash scripts/session-health.sh             emit the preview block
#   bash scripts/session-health.sh --self-test run synthetic fixtures only
#   bash scripts/session-health.sh --help      print usage
#
# Exit codes:
#   0 — successful normal output OR successful --self-test
#   1 — runtime error (git unavailable, etc.) OR --self-test failure
#   2 — internal error (python3 missing, unexpected exception bubble-up)
#
# Style mirror: scripts/doctor-check.sh (bash wrapper + python3 heredoc,
# same option parsing, same exit-code discipline). Output is pure
# Markdown text — no ANSI colour (the block is pasted into a briefing,
# not viewed in a terminal).

set -uo pipefail

RED='\033[0;31m'
NC='\033[0m'

# Resolve the repo to inspect. Prefer the current working directory so that
# a user running the script from a subdirectory still scans the right
# tree; fall back to the script's own repo if PWD is not a git checkout.
PWD_SNAPSHOT="$PWD"
REPO_ROOT=""
if REPO_ROOT="$(git -C "$PWD_SNAPSHOT" rev-parse --show-toplevel 2>/dev/null)"; then
    :
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    REPO_ROOT="$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd)"
fi

# python3 is a hard requirement — matches doctor-check.sh convention.
if ! command -v python3 >/dev/null 2>&1; then
    printf "%bERROR:%b python3 not found on PATH (required by session-health.sh)\n" \
        "$RED" "$NC" >&2
    exit 2
fi

# Parse arguments up-front so --help / --self-test skip the git probes.
MODE="run"
for arg in "$@"; do
    case "$arg" in
        --help|-h)
            MODE="help"
            ;;
        --self-test)
            MODE="self-test"
            ;;
        *)
            printf "%bERROR:%b unknown argument: %s\n" "$RED" "$NC" "$arg" >&2
            printf "Run %s --help for usage.\n" "$0" >&2
            exit 2
            ;;
    esac
done

# Collect git-derived inputs in shell so python stays pure-formatting.
# Non-zero probes are tolerated (empty strings flow into python which
# renders a graceful placeholder); a missing git binary is the one hard
# failure — without it the Branch and Last-commit bullets cannot be
# populated at all, so we exit 1 instead of emitting a corrupt block.
GIT_AVAILABLE=0
if command -v git >/dev/null 2>&1; then
    GIT_AVAILABLE=1
fi

BRANCH=""
LAST_COMMIT=""
PORCELAIN=""
if [ "$MODE" = "run" ]; then
    if [ "$GIT_AVAILABLE" -ne 1 ]; then
        printf "%bERROR:%b git not found on PATH (required by session-health.sh)\n" \
            "$RED" "$NC" >&2
        exit 1
    fi
    if ! git -C "$PWD_SNAPSHOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        printf "%bERROR:%b %s is not inside a git work tree\n" \
            "$RED" "$NC" "$PWD_SNAPSHOT" >&2
        exit 1
    fi
    BRANCH="$(git -C "$PWD_SNAPSHOT" branch --show-current 2>/dev/null || true)"
    LAST_COMMIT="$(git -C "$PWD_SNAPSHOT" log -1 --format='%h %s' 2>/dev/null || true)"
    PORCELAIN="$(git -C "$PWD_SNAPSHOT" status --porcelain 2>/dev/null || true)"
fi

# plan.md always lives under repo root; anchor to REPO_ROOT so users
# running from a subdirectory still locate the correct file. The
# fallback resolution above ensures REPO_ROOT is set even when PWD is
# not itself a git work tree (in that case --run mode already exited).
PLAN_MD_PATH="$REPO_ROOT/docs/plan.md"

export PWD_SNAPSHOT BRANCH LAST_COMMIT PORCELAIN PLAN_MD_PATH MODE

python3 - <<'PYEOF'
import os
import re
import sys
import tempfile
from pathlib import Path

# ---------------------------------------------------------------------------
# Output primitives — no colour (output is pasted into a briefing, not a
# terminal). Subject-line truncation is intentional (~80 chars so the bullet
# fits on a single line in typical Markdown renderers).
# ---------------------------------------------------------------------------

SUBJECT_MAX = 80
FILE_LIST_MAX = 5
# Per-line budget guarding the "Uncommitted files" bullet — when the list
# of names would exceed this many characters it collapses to an ellipsis.
# Chosen to keep the bullet on one typical editor-width line (~120 cols
# including the leading "- Uncommitted files: N (" prefix).
FILE_LIST_LINE_MAX = 100
RATIONALE_MAX = 60

BLOCKING_MARKER = '\U0001f6a8 BLOCKING: Next Wave requires NEW SESSION'
BLOCKING_ACK_PREFIX = '> '
OBSERVATION_HEADING = '### v0.8.0 \u5347\u7ea7\u89c2\u5bdf\u671f Tracker'


def _truncate(text, limit):
    """Truncate text to `limit` characters, appending an ellipsis when cut.
    Preserves short inputs untouched. The ellipsis is a single character
    (U+2026) so it does not inflate the character budget.
    """
    if text is None:
        return ''
    if len(text) <= limit:
        return text
    if limit <= 1:
        return text[:limit]
    return text[: limit - 1] + '\u2026'


# ---------------------------------------------------------------------------
# Branch / last-commit / uncommitted-files rendering
# ---------------------------------------------------------------------------

def _render_branch(branch):
    # `git branch --show-current` prints empty string in detached-HEAD mode.
    branch = (branch or '').strip()
    return branch if branch else '(detached HEAD)'


def _render_last_commit(last_commit):
    raw = (last_commit or '').strip()
    if not raw:
        return '(no commits)'
    # `git log -1 --format='%h %s'` → "<hash> <subject>". The hash cannot
    # contain spaces so a single split is safe; subject may be empty.
    parts = raw.split(' ', 1)
    if len(parts) == 1:
        return parts[0]
    hash_, subject = parts
    return f'{hash_} {_truncate(subject, SUBJECT_MAX)}'


def _parse_porcelain_files(porcelain):
    """Extract file paths from `git status --porcelain` stdout.
    Porcelain format: first 2 columns are status codes, then a space, then
    the path. Rename lines use `R  old -> new` — we record the destination
    path (post-arrow) so the list reflects what the user currently sees.
    """
    files = []
    for line in porcelain.splitlines():
        if not line.strip():
            continue
        # Status codes occupy cols 0-1, col 2 is a space, path starts at 3.
        if len(line) < 4:
            continue
        path = line[3:]
        # Rename/copy: "old -> new"; take the right-hand side.
        if ' -> ' in path:
            path = path.split(' -> ', 1)[1]
        # Strip surrounding quotes git adds for paths with unusual chars.
        if len(path) >= 2 and path.startswith('"') and path.endswith('"'):
            path = path[1:-1]
        files.append(path)
    return files


def _render_uncommitted(porcelain):
    files = _parse_porcelain_files(porcelain or '')
    n = len(files)
    if n == 0:
        return '0'
    preview = files[:FILE_LIST_MAX]
    joined = ', '.join(preview)
    more = n - len(preview)
    suffix = f', +{more} more' if more > 0 else ''
    full = f'{joined}{suffix}'
    # Guard the per-line budget. If the full listing would blow past the
    # line budget, collapse to a trimmed prefix + ellipsis so the bullet
    # stays single-line. _truncate already appends its own ellipsis on
    # truncation, so do NOT add a second one here.
    if len(full) > FILE_LIST_LINE_MAX:
        full = _truncate(full, FILE_LIST_LINE_MAX)
    return f'{n} ({full})'


# ---------------------------------------------------------------------------
# BLOCKING marker — mirrors scripts/doctor-check.sh D5 "last-marker
# semantic": only the most recent marker's acknowledgement status matters.
# ---------------------------------------------------------------------------

def _is_standalone_blocking_line(line):
    return line.strip() == BLOCKING_MARKER


def _extract_blocking_state(plan_text):
    """Return ('clear', None) if the LAST marker is acknowledged, otherwise
    ('present', <rationale excerpt>). Returns ('absent', None) when no
    marker exists at all — /start-working treats this the same as clear
    but we preserve the distinction for self-test clarity.
    """
    lines = plan_text.splitlines()
    last_idx = None
    for idx, line in enumerate(lines):
        if _is_standalone_blocking_line(line):
            last_idx = idx
    if last_idx is None:
        return ('absent', None)

    # Walk forward from the marker to find the first non-empty line.
    j = last_idx + 1
    while j < len(lines) and lines[j].strip() == '':
        j += 1
    if j >= len(lines):
        return ('present', _pick_rationale(lines, last_idx + 1))

    first_non_empty = lines[j]
    if first_non_empty.startswith('> \u2705 Session boundary acknowledged'):
        return ('clear', None)

    return ('present', _pick_rationale(lines, last_idx + 1))


def _pick_rationale(lines, start_idx):
    """Pick a ~60-char excerpt representing why the marker is present.

    Preference order:
    1. The `> Rationale` blockquote line if one appears within the next 10
       lines (typical authoring pattern).
    2. The first non-empty, non-blockquote-ack prose line otherwise.
    """
    window_end = min(len(lines), start_idx + 10)
    rationale_line = None
    fallback_line = None

    for j in range(start_idx, window_end):
        raw = lines[j].rstrip()
        if not raw.strip():
            continue
        if raw.startswith('> \u2705 Session boundary acknowledged'):
            # Never use the acknowledgement line — it's not a rationale.
            continue
        stripped = raw.lstrip('> ').strip()
        if rationale_line is None and stripped.lower().startswith('rationale'):
            rationale_line = stripped
            break
        if fallback_line is None:
            fallback_line = stripped

    chosen = rationale_line or fallback_line or ''
    return _truncate(chosen, RATIONALE_MAX)


def _render_blocking(plan_path):
    plan = Path(plan_path)
    if not plan.is_file():
        # Absent plan.md → treat as clear (no marker can be active).
        return 'clear'
    try:
        text = plan.read_text(encoding='utf-8', errors='replace')
    except OSError:
        return 'clear'
    state, rationale = _extract_blocking_state(text)
    if state == 'present':
        if rationale:
            return f'present ({rationale})'
        return 'present'
    # 'clear' and 'absent' both render as 'clear' for the user-facing
    # bullet — both mean "no action required".
    return 'clear'


# ---------------------------------------------------------------------------
# Observation period — parse the tracker table under the v0.8.0 heading.
# ---------------------------------------------------------------------------

def _locate_tracker_section(plan_text):
    """Return the slice of plan.md starting at the tracker heading and
    ending before the next `### ` heading (or EOF). Returns None when the
    heading is absent.
    """
    lines = plan_text.splitlines()
    start = None
    for idx, line in enumerate(lines):
        if line.strip() == OBSERVATION_HEADING:
            start = idx
            break
    if start is None:
        return None
    end = len(lines)
    for idx in range(start + 1, len(lines)):
        if lines[idx].startswith('### '):
            end = idx
            break
    return '\n'.join(lines[start:end])


def _parse_tracker_rows(section):
    """Return a list of data rows (each a list of cell strings) under the
    tracker heading. Only rows starting with `| Wave ` are treated as
    data; header + separator rows are skipped. Each cell is stripped.
    """
    rows = []
    for line in section.splitlines():
        # Data rows all start with `| Wave ` — the schema header in the
        # tracker ("Wave <CJK-name-token>") shares the same prefix, so
        # we additionally filter it out below via a CJK-codepoint escape.
        if not line.startswith('| Wave '):
            continue
        # Trim leading/trailing `|` then split.
        inner = line.strip()
        if inner.startswith('|'):
            inner = inner[1:]
        if inner.endswith('|'):
            inner = inner[:-1]
        cells = [c.strip() for c in inner.split('|')]
        # Header row heuristic: the schema-header first cell is
        # "Wave <U+540D>" (the CJK character meaning "name"). Data rows
        # use numeric wave identifiers. The \u540d escape keeps the
        # source free of literal CJK codepoints (Tier 1 English-only).
        if cells and cells[0].startswith('Wave \u540d'):
            continue
        rows.append(cells)
    return rows


def _row_is_filled(cells):
    """A filled row has all 4 observation columns non-empty and NOT
    literally `(\u5f85\u586b)` (i.e. the CJK placeholder for "to fill")
    and NOT `-`. Schema: [wave_name, deceng, lead_esc, teammate, remark].
    If the row has >5 cells (inline escaped pipes in narrative content
    can inflate the split), we still check indices 1..4 as a
    lower-bound proxy — a row where cells[1..4] are all genuine prose
    (not placeholder tokens) is considered filled regardless of any
    additional cells beyond index 4.
    """
    if len(cells) < 5:
        return False
    placeholder = '(\u5f85\u586b)'
    for col in cells[1:5]:
        token = col.strip()
        if token in ('', '-', placeholder):
            return False
    return True


# Real-IR counting strategy (documented for auditability):
#
# Each Wave row ends with a "\u5907\u6ce8" (remark) column containing
# narrative prose about whether the Wave Boundary IR ran as a real
# Codex CLI invocation or was skipped under the FR-19 carve-out. The
# tracker has no dedicated "IR kind" column, so we grep the remark
# content for the canonical 3-word substring "real Wave Boundary IR"
# that Wave 2 established and /end-working Step 3 produces. Because
# narrative cells may embed escaped pipes (e.g. `\|\|`) that inflate
# the cell count past 5, we scan the JOINED post-name content — i.e.
# everything from cells[1] onward — rather than assuming cells[4]
# alone is the remark. This is safe: the substring is specific enough
# that false-positive matches in the DocEng / Lead / Teammate columns
# would themselves constitute a real-IR mention worth counting.
#
# Alternative proxies considered and rejected:
#   - "real run" — too generic; appears in acceptance-row cells too.
#   - "Wave Boundary IR" — also matches rows that carve-out skipped IR
#     ("skip Wave Boundary IR").
# Chosen substring: "real Wave Boundary IR" (case-sensitive, 3-word
# phrase unique to genuine-IR narratives).
REAL_IR_SUBSTR = 'real Wave Boundary IR'
TARGET_WAVES = ('Wave 2', 'Wave 3', 'Wave 4')


def _count_real_ir(rows):
    """Count how many of the Waves 2/3/4 tracker rows record a real IR.
    Scan all post-name cells (cells[1:]) joined together to tolerate
    inline escaped-pipe cell inflation. Rows that are still
    `(\u5f85\u586b)` or otherwise unfilled are skipped — they contribute
    no signal yet.
    """
    count = 0
    for cells in rows:
        if not cells:
            continue
        name = cells[0]
        if not any(name.startswith(w) for w in TARGET_WAVES):
            continue
        if not _row_is_filled(cells):
            continue
        narrative = ' '.join(cells[1:])
        if REAL_IR_SUBSTR in narrative:
            count += 1
    return count


def _render_observation(plan_path):
    plan = Path(plan_path)
    if not plan.is_file():
        return 'not active'
    try:
        text = plan.read_text(encoding='utf-8', errors='replace')
    except OSError:
        return 'not active'
    section = _locate_tracker_section(text)
    if section is None:
        return 'not active'
    rows = _parse_tracker_rows(section)
    if not rows:
        return 'not active'
    filled = sum(1 for r in rows if _row_is_filled(r))
    total = 5  # Observation period = 5 Waves; table may list fewer if
               # future Waves are still pre-population.
    real_ir = _count_real_ir(rows)
    return (
        f'Wave {filled}/{total}, real-IR {real_ir}/3 from Waves 2-4'
    )


# ---------------------------------------------------------------------------
# Assembly
# ---------------------------------------------------------------------------

def build_block(branch, last_commit, porcelain, plan_md_path):
    lines = ['## Session Health Preview']
    lines.append(f'- Branch: {_render_branch(branch)}')
    lines.append(f'- Last commit: {_render_last_commit(last_commit)}')
    lines.append(f'- Uncommitted files: {_render_uncommitted(porcelain)}')
    lines.append(f'- BLOCKING marker: {_render_blocking(plan_md_path)}')
    lines.append(f'- Observation period: {_render_observation(plan_md_path)}')
    return '\n'.join(lines)


# ---------------------------------------------------------------------------
# Self-test fixtures — 3 scenarios, each asserting specific substrings in
# the rendered output. Fixtures write plan.md content to a temp file so
# _render_blocking / _render_observation exercise the real file-I/O path.
# ---------------------------------------------------------------------------

def _fixture_clean_no_observation():
    name = 'clean-no-observation'
    branch = 'main'
    last_commit = 'abc1234 initial commit'
    porcelain = ''
    plan_text = '# Empty plan\n\nNothing here.\n'
    expected_substrings = [
        '## Session Health Preview',
        '- Branch: main',
        '- Last commit: abc1234 initial commit',
        '- Uncommitted files: 0',
        '- BLOCKING marker: clear',
        '- Observation period: not active',
    ]
    return name, branch, last_commit, porcelain, plan_text, expected_substrings


def _fixture_uncommitted_and_blocking():
    name = 'uncommitted-and-blocking'
    branch = 'feat/wave-X'
    # Subject deliberately longer than SUBJECT_MAX to exercise truncation.
    long_subject = 'introduce a very long and rambling commit subject ' * 3
    last_commit = f'def5678 {long_subject}'.strip()
    porcelain_lines = [
        ' M scripts/foo.sh',
        'A  commands/new.md',
        '?? docs/drafts/bar.md',
    ]
    porcelain = '\n'.join(porcelain_lines)
    plan_text = (
        '# plan\n\n'
        '## Some section\n\n'
        '\U0001f6a8 BLOCKING: Next Wave requires NEW SESSION\n\n'
        '> Rationale: CLAUDE.md Module Boundaries edited and cache reset.\n'
    )
    expected_substrings = [
        '- Branch: feat/wave-X',
        '- Last commit: def5678 ',
        '\u2026',  # ellipsis indicating truncation
        '- Uncommitted files: 3 (scripts/foo.sh, commands/new.md, docs/drafts/bar.md)',
        '- BLOCKING marker: present (',
        'Rationale',
    ]
    return name, branch, last_commit, porcelain, plan_text, expected_substrings


def _fixture_observation_tracker():
    name = 'observation-tracker'
    branch = 'feat/wave-3'
    last_commit = '0badbee Wave 2 close-out'
    porcelain = ''
    # Two marker occurrences — the LAST one is acknowledged.
    plan_text = (
        '# plan\n\n'
        '## Older section\n\n'
        '\U0001f6a8 BLOCKING: Next Wave requires NEW SESSION\n\n'
        '> Rationale: Old marker, should be ignored.\n\n'
        f'{OBSERVATION_HEADING}\n\n'
        'Narrative paragraph.\n\n'
        '| Wave \u540d | DocEng | Lead | Teammate | \u5907\u6ce8 |\n'
        '|---------|--------|------|----------|------|\n'
        '| Wave 0 | ok | N/A | N/A | baseline row, no IR text here |\n'
        '| Wave 1 | ok | ok | N/A | carve-out skip, not real |\n'
        '| Wave 2 | ok | ok | first-data | first real Wave Boundary IR landed |\n'
        '| (\u5f85\u586b) | - | - | - | - |\n'
        '| (\u5f85\u586b) | - | - | - | - |\n\n'
        '### Next heading\n\n'
        '\U0001f6a8 BLOCKING: Next Wave requires NEW SESSION\n'
        '> \u2705 Session boundary acknowledged 2026-04-20 by /start-working\n'
    )
    expected_substrings = [
        '- Branch: feat/wave-3',
        '- Uncommitted files: 0',
        '- BLOCKING marker: clear',
        '- Observation period: Wave 3/5, real-IR 1/3 from Waves 2-4',
    ]
    return name, branch, last_commit, porcelain, plan_text, expected_substrings


def run_self_test():
    fixtures = [
        _fixture_clean_no_observation(),
        _fixture_uncommitted_and_blocking(),
        _fixture_observation_tracker(),
    ]
    failures = []
    with tempfile.TemporaryDirectory() as tmp:
        for (name, branch, last_commit, porcelain, plan_text,
             expected) in fixtures:
            plan_dir = Path(tmp) / name / 'docs'
            plan_dir.mkdir(parents=True, exist_ok=True)
            plan_path = plan_dir / 'plan.md'
            plan_path.write_text(plan_text, encoding='utf-8')

            output = build_block(
                branch=branch,
                last_commit=last_commit,
                porcelain=porcelain,
                plan_md_path=str(plan_path),
            )
            missing = [s for s in expected if s not in output]
            if missing:
                failures.append(
                    f'fixture {name!r}: missing substrings {missing!r}\n'
                    f'--- rendered output ---\n{output}\n--- end ---'
                )
                print(f'FAIL: {name}')
            else:
                print(f'PASS: {name}')

    if failures:
        for msg in failures:
            print(msg, file=sys.stderr)
        print(
            f'FAILED: session-health.sh --self-test ({len(failures)} issue(s))',
            file=sys.stderr,
        )
        return 1
    print('PASSED: session-health.sh --self-test (3/3 fixtures OK)')
    return 0


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

USAGE = """\
session-health.sh \u2014 iSparto cross-session recovery preview

Usage:
  bash scripts/session-health.sh             emit the preview block
  bash scripts/session-health.sh --self-test run synthetic fixtures
  bash scripts/session-health.sh --help      print this message

Output: a 5-bullet Markdown block under the '## Session Health Preview'
heading, covering branch, last commit, uncommitted files, BLOCKING
marker state, and observation-period progress. /start-working Step 9
pastes this block verbatim into its B-layer briefing.

Exit codes:
  0 \u2014 successful normal output OR successful --self-test
  1 \u2014 runtime error OR --self-test failure
  2 \u2014 internal error (python3 missing, bad argument)
"""


def main():
    mode = os.environ.get('MODE', 'run').strip()

    if mode == 'help':
        print(USAGE)
        return 0

    if mode == 'self-test':
        return run_self_test()

    branch = os.environ.get('BRANCH', '')
    last_commit = os.environ.get('LAST_COMMIT', '')
    porcelain = os.environ.get('PORCELAIN', '')
    plan_md_path = os.environ.get('PLAN_MD_PATH', '')

    try:
        block = build_block(
            branch=branch,
            last_commit=last_commit,
            porcelain=porcelain,
            plan_md_path=plan_md_path,
        )
    except Exception as e:  # noqa: BLE001 — any bubble-up is exit 2
        print(
            f'ERROR: internal failure in session-health.sh: '
            f'{type(e).__name__}: {e}',
            file=sys.stderr,
        )
        return 2

    print(block)
    return 0


sys.exit(main())
PYEOF

EXIT=$?
exit $EXIT
