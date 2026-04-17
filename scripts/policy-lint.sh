#!/usr/bin/env bash
# policy-lint.sh — iSparto Information Layering Policy guardian (v1).
#
# Scans the most recent entry in docs/session-log.md for ceremonial wrapper
# phrases that Step 9 / closing-briefing C-layer rules forbid. The
# forbidden-phrase list is mirrored verbatim from commands/end-working.md
# ("C-layer items — NEVER emit in the closing briefing").
#
# v1 scope: ceremonial wrapper detector only. Bullet-stack and A-layer
# wording detectors are explicitly out of v1 to preserve signal purity;
# a future Wave may add them under --strict once precision is validated.
#
# Self-test:
#   --self-test  Run 8 fixtures (5 positive + 3 negative) and exit.
#
# Exit codes:
#   0 — clean (or nothing to scan)
#   1 — violations found
#   2 — environment error (cannot resolve repo root, unknown argument)

set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

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

python3 - "$@" <<'PYEOF'
import re
import sys
from pathlib import Path

REPO = Path.cwd()
SESSION_LOG = REPO / 'docs' / 'session-log.md'

CEREMONIAL = re.compile(
    r'\b(session complete|ready for next session|'
    r'doc engineer audit passed|process observer audit passed|'
    r'security scan passed)\b',
    re.IGNORECASE,
)
SESSION_HEADING = re.compile(r'^## .* Session')

POSITIVE_FIXTURES = [
    'Session complete — all tasks done',
    'Ready for next session',
    'Doc Engineer audit passed with 9/9 green',
    'Process Observer audit passed',
    'Security scan passed — no findings',
]

NEGATIVE_FIXTURES = [
    'The session was productive',
    'Doc Engineer caught 2 issues',
    'Security patterns updated',
]


def find_most_recent_heading(lines):
    for idx in range(len(lines) - 1, -1, -1):
        if SESSION_HEADING.match(lines[idx]):
            return idx
    return None


def run_self_test():
    failures = []
    for fx in POSITIVE_FIXTURES:
        if not CEREMONIAL.search(fx):
            failures.append(f'FAIL: positive fixture not flagged: {fx!r}')
    for fx in NEGATIVE_FIXTURES:
        if CEREMONIAL.search(fx):
            failures.append(f'FAIL: negative fixture incorrectly flagged: {fx!r}')
    for msg in failures:
        print(msg, file=sys.stderr)
    if failures:
        return 1
    total = len(POSITIVE_FIXTURES) + len(NEGATIVE_FIXTURES)
    print(f'PASS: policy-lint.sh --self-test ({total}/{total} fixtures OK)')
    return 0


def main():
    args = sys.argv[1:]
    for a in args:
        if a != '--self-test':
            print(f'ERROR: unknown argument: {a}', file=sys.stderr)
            sys.exit(2)

    if '--self-test' in args:
        sys.exit(run_self_test())

    if not SESSION_LOG.is_file():
        print('\033[0;32mPASSED\033[0m: policy-lint.sh — session-log.md not present, nothing to scan.')
        sys.exit(0)

    lines = SESSION_LOG.read_text(encoding='utf-8', errors='replace').splitlines()
    start = find_most_recent_heading(lines)
    if start is None:
        print('\033[0;32mPASSED\033[0m: policy-lint.sh — no session entries yet, nothing to scan.')
        sys.exit(0)

    violations = []
    for offset, line in enumerate(lines[start:]):
        if CEREMONIAL.search(line):
            lineno = start + offset + 1
            snippet = line.strip()
            if len(snippet) > 100:
                snippet = snippet[:97] + '...'
            violations.append(f'[Policy C-layer] docs/session-log.md:{lineno}: {snippet}')

    if not violations:
        print('\033[0;32mPASSED\033[0m: policy-lint.sh — most recent session entry has no ceremonial wrappers.')
        sys.exit(0)

    for v in violations:
        print(v)
    print()
    print(f'\033[0;31mFAILED\033[0m: policy-lint.sh found {len(violations)} ceremonial-wrapper violation(s).')
    print('See commands/end-working.md "C-layer items — NEVER emit in the closing briefing".')
    sys.exit(1)


main()
PYEOF

EXIT=$?
exit $EXIT
