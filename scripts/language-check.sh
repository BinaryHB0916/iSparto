#!/usr/bin/env bash
# language-check.sh — iSparto Documentation Language Convention guardian
#
# Scans:
#   1) Tier 1 (System Prompt Layer) files for CJK characters
#   2) Tier 2 (Reference Documentation) files for CJK characters
#   3) Principle 1 hard-coded user-facing literal violations in commands/*.md
#      and agents/*.md (missing "(in user's language)" intent qualifier)
# to enforce CLAUDE.md > "Documentation Language Convention".
#
# Tier 1 (AI agent system prompts, English only):
#   CLAUDE.md, CLAUDE-TEMPLATE.md
#   commands/*.md, agents/*.md, templates/*.md
#   hooks/**/*.sh, hooks/**/*.json
#   bootstrap.sh, install.sh, isparto.sh
#   scripts/*.sh, lib/*.sh
#
# Tier 2 (reference docs, English only):
#   docs/*.md, EXCEPT historical artifacts and the docs/zh/ tree
#
# Tier 2 explicit exclusions (Tier 4 historical, frozen by design):
#   docs/session-log.md
#   docs/plan.md              (mixed historical Chinese + new English; reviewed manually)
#   docs/independent-review.md (IR audit trail — entries quote plan.md section titles
#                               and other Tier 4 source material verbatim in their original
#                               language per the IR audit-trail-immutability principle)
#   docs/zh/                  (dedicated Chinese-entry tree, not Tier 2)
#
# Retired (2026-04-17): docs/framework-feedback-*.md — the pattern was removed
# from the repo per the Single TODO source rule (CLAUDE.md Development Rules);
# any lingering references appear only in frozen historical entries (session-log,
# plan.md Wave entries, CHANGELOG) which are already Tier 4.
#
# Status:
#   Wave 1 — warning mode, manual invocation only.
#   Wave 4 — promoted to a blocking gate inside /end-working Doc Engineer audit.
#   Principle 1 detector — mechanical first-line guard for command/agent layer.
#
# Self-test:
#   --self-test  Run synthetic Principle 1 fixture checks only.
#
# Exit codes:
#   0 — clean
#   1 — violations found
#   2 — environment error (cannot resolve repo root, etc.)

set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

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

# Use python3 over stdin (single-quoted heredoc) to avoid shell expansion of
# the CJK escape ranges and to sidestep set -e / heredoc interaction issues.
python3 - "$@" <<'PYEOF'
import re
import sys
from pathlib import Path

REPO = Path.cwd()

# CJK regex: punctuation + basic CJK + fullwidth + Extension A
CJK = re.compile(r'[\u3000-\u303f\u4e00-\u9fff\uff00-\uffef\u3400-\u4dbf]')

# Principle 1 patterns
PRINCIPLE1_QUALIFIER = re.compile(r"\(in (?:the )?user's language\)", re.IGNORECASE)
PRINCIPLE1_OUTPUT_VERB = re.compile(
    r'\b(?:inform|tell|ask|instruct|warn|report|notify|announce|output|display|'
    r'print|echo|note|show)\b',
    re.IGNORECASE,
)
PRINCIPLE1_QUOTED_LITERAL = re.compile(r'["\u201c]([A-Z][^"\u201d]{11,})["\u201d]')
PRINCIPLE1_EXAMPLE_MARKERS = (
    'e.g.',
    'eg.',
    'for example',
    'for instance',
    'such as',
)

PRINCIPLE1_FIXTURES = [
    '1. Inform user "Environment is ready, you may proceed."',
    '2. Tell the user: "No-go items found and must be fixed first."',
    '3. Report to user "Migration complete. Run install.sh --upgrade to apply."',
    '4. Display the message "Welcome to the iSparto framework."',
    '5. Notify the user "Hooks have been installed and verified successfully."',
]

PRINCIPLE1_SANITY_NEGATIVE = (
    '- RIGHT: describing the intent, e.g., "Report to user (in user\'s language) '
    'that the gh account has been auto-switched to $REPO_OWNER"'
)

# Tier 2 exclusions — exact relative paths
TIER2_EXCLUDED_FILES = {
    'docs/session-log.md',
    'docs/plan.md',
    # IR audit trail: entries quote plan.md section titles and other Tier 4
    # source material verbatim in their original language. Treating this file
    # as a Tier-4-like exclusion preserves both the language guardian and the
    # audit trail. See docs/plan.md Wave 3 Lead-Resolution Option A.
    'docs/independent-review.md',
    # Dogfood log: Tier 4 historical artifact recording subjective session
    # experience. Each cycle entry is written in the user's working language
    # (Chinese for the current maintainer) and is never modified retroactively.
    # See docs/plan.md v0.7.5 T7 and CLAUDE.md Documentation Language Convention.
    'docs/dogfood-log.md',
}

# Tier 2 exclusions — relative-path prefix matches (under docs/)
# Currently empty — the former `docs/framework-feedback-` prefix exclusion was
# removed 2026-04-17 when the file pattern itself was retired.
TIER2_EXCLUDED_PREFIXES = ()

# Tier 2 exclusions — directory prefixes (anything below is excluded)
TIER2_EXCLUDED_DIRS = (
    'docs/zh/',
    # Observation period audit artifacts (v0.8.0 5-Wave horizon).
    # Each wave's DE audit output is preserved verbatim in the maintainer's
    # working language as Tier 4 historical evidence — never modified
    # retroactively. See docs/plan.md observation-period tracker section.
    'docs/observation-period/',
)


def collect_tier1():
    """Tier 1 — System Prompt Layer files."""
    files = []

    # Top-level individual files
    for name in ('CLAUDE.md', 'CLAUDE-TEMPLATE.md',
                 'bootstrap.sh', 'install.sh', 'isparto.sh'):
        p = REPO / name
        if p.is_file():
            files.append(p)

    # commands/*.md
    cmd_dir = REPO / 'commands'
    if cmd_dir.is_dir():
        files.extend(sorted(cmd_dir.glob('*.md')))

    # agents/*.md
    agt_dir = REPO / 'agents'
    if agt_dir.is_dir():
        files.extend(sorted(agt_dir.glob('*.md')))

    # templates/*.md
    tpl_dir = REPO / 'templates'
    if tpl_dir.is_dir():
        files.extend(sorted(tpl_dir.glob('*.md')))

    # hooks/**/*.sh and hooks/**/*.json
    hooks_dir = REPO / 'hooks'
    if hooks_dir.is_dir():
        files.extend(sorted(hooks_dir.rglob('*.sh')))
        files.extend(sorted(hooks_dir.rglob('*.json')))

    # scripts/*.sh
    scripts_dir = REPO / 'scripts'
    if scripts_dir.is_dir():
        files.extend(sorted(scripts_dir.glob('*.sh')))

    # lib/*.sh
    lib_dir = REPO / 'lib'
    if lib_dir.is_dir():
        files.extend(sorted(lib_dir.glob('*.sh')))

    return files


def collect_tier2():
    """Tier 2 — docs/*.md, excluding historical artifacts and docs/zh/."""
    files = []
    docs_dir = REPO / 'docs'
    if not docs_dir.is_dir():
        return files
    for p in sorted(docs_dir.glob('*.md')):
        rel = p.relative_to(REPO).as_posix()
        if rel in TIER2_EXCLUDED_FILES:
            continue
        if any(rel.startswith(pref) for pref in TIER2_EXCLUDED_PREFIXES):
            continue
        if any(rel.startswith(d) for d in TIER2_EXCLUDED_DIRS):
            continue
        files.append(p)
    return files


def collect_principle1_files():
    """Principle 1 scope — commands/*.md and agents/*.md only."""
    files = []

    cmd_dir = REPO / 'commands'
    if cmd_dir.is_dir():
        files.extend(sorted(cmd_dir.glob('*.md')))

    agt_dir = REPO / 'agents'
    if agt_dir.is_dir():
        files.extend(sorted(agt_dir.glob('*.md')))

    return files


def format_snippet(line):
    snippet = line.strip()
    if len(snippet) > 100:
        snippet = snippet[:97] + '...'
    return snippet


def scan(files, tier_tag):
    violations = []
    for f in files:
        try:
            text = f.read_text(encoding='utf-8', errors='replace')
        except OSError as e:
            print(f'WARN: cannot read {f}: {e}', file=sys.stderr)
            continue
        for lineno, line in enumerate(text.splitlines(), 1):
            if CJK.search(line):
                snippet = format_snippet(line)
                rel = f.relative_to(REPO).as_posix()
                violations.append(f'[{tier_tag}] {rel}:{lineno}: {snippet}')
    return violations


def line_has_principle1_violation(line):
    if PRINCIPLE1_QUALIFIER.search(line):
        return False
    if not PRINCIPLE1_OUTPUT_VERB.search(line):
        return False

    for match in PRINCIPLE1_QUOTED_LITERAL.finditer(line):
        open_quote_index = match.start()
        before = line[:open_quote_index]
        before_tail = before[-40:].lower()

        if any(marker in before_tail for marker in PRINCIPLE1_EXAMPLE_MARKERS):
            continue
        if before.count('[') > before.count(']'):
            continue
        return True
    return False


def scan_principle1(files):
    violations = []
    for f in files:
        try:
            text = f.read_text(encoding='utf-8', errors='replace')
        except OSError as e:
            print(f'WARN: cannot read {f}: {e}', file=sys.stderr)
            continue
        for lineno, line in enumerate(text.splitlines(), 1):
            if line_has_principle1_violation(line):
                rel = f.relative_to(REPO).as_posix()
                violations.append(
                    f'[Principle 1] {rel}:{lineno}: {format_snippet(line)}'
                )
    return violations


def run_self_test():
    failures = []

    if line_has_principle1_violation(PRINCIPLE1_SANITY_NEGATIVE):
        failures.append(
            'FAIL: Test 1 — CLAUDE.md illustrative example was incorrectly flagged'
        )
    else:
        print(
            "PASS: Test 1 — CLAUDE.md illustrative example (correctly not flagged)"
        )

    missed = [line for line in PRINCIPLE1_FIXTURES
              if not line_has_principle1_violation(line)]
    if missed:
        failures.append(
            f'FAIL: Test 4 — Principle 1 fixture misses ({len(missed)}/'
            f'{len(PRINCIPLE1_FIXTURES)} not flagged)'
        )
        for line in missed:
            failures.append(f'  MISSED: {line}')
    else:
        print('PASS: Test 4 — Principle 1 fixture (5/5 flagged)')

    if failures:
        for msg in failures:
            print(msg, file=sys.stderr)
        return 1
    return 0


def main():
    for arg in sys.argv[1:]:
        if arg != '--self-test':
            print(f'ERROR: unknown argument: {arg}', file=sys.stderr)
            sys.exit(2)

    if '--self-test' in sys.argv[1:]:
        sys.exit(run_self_test())

    tier1_files = collect_tier1()
    tier2_files = collect_tier2()
    principle1_files = collect_principle1_files()

    tier1_violations = scan(tier1_files, 'Tier 1')
    tier2_violations = scan(tier2_files, 'Tier 2')
    principle1_violations = scan_principle1(principle1_files)

    total = (
        len(tier1_violations) +
        len(tier2_violations) +
        len(principle1_violations)
    )
    if total == 0:
        print('\033[0;32mPASSED\033[0m: scripts/language-check.sh — '
              'Tier 1/Tier 2 are CJK-clean and Principle 1 is clean.')
        sys.exit(0)

    for v in tier1_violations:
        print(v)
    for v in tier2_violations:
        print(v)
    for v in principle1_violations:
        print(v)

    print()
    print(f'\033[0;31mFAILED\033[0m: scripts/language-check.sh found {total} '
          f'violation(s) ({len(tier1_violations)} Tier 1 CJK, '
          f'{len(tier2_violations)} Tier 2 CJK, '
          f'{len(principle1_violations)} Principle 1).')
    print('See CLAUDE.md "Documentation Language Convention" for the '
          'four-tier architecture and remediation rules.')
    sys.exit(1)


main()
PYEOF

EXIT=$?
exit $EXIT
