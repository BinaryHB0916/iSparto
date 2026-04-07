#!/usr/bin/env bash
# language-check.sh — iSparto Documentation Language Convention guardian
#
# Scans Tier 1 (System Prompt Layer) and Tier 2 (Reference Documentation)
# files for CJK characters that would violate the four-tier language
# architecture documented in CLAUDE.md > "Documentation Language Convention".
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
#   docs/framework-feedback-*.md
#   docs/plan.md           (mixed historical Chinese + new English; reviewed manually)
#   docs/zh/               (dedicated Chinese-entry tree, not Tier 2)
#
# Status:
#   Wave 1 — warning mode, manual invocation only.
#   Wave 4 — promoted to a blocking gate inside /end-working Doc Engineer audit.
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
python3 - <<'PYEOF'
import re
import sys
from pathlib import Path

REPO = Path.cwd()

# CJK regex: punctuation + basic CJK + fullwidth + Extension A
CJK = re.compile(r'[\u3000-\u303f\u4e00-\u9fff\uff00-\uffef\u3400-\u4dbf]')

# Tier 2 exclusions — exact relative paths
TIER2_EXCLUDED_FILES = {
    'docs/session-log.md',
    'docs/plan.md',
}

# Tier 2 exclusions — relative-path prefix matches (under docs/)
TIER2_EXCLUDED_PREFIXES = (
    'docs/framework-feedback-',
)

# Tier 2 exclusions — directory prefixes (anything below is excluded)
TIER2_EXCLUDED_DIRS = (
    'docs/zh/',
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
                snippet = line.strip()
                if len(snippet) > 100:
                    snippet = snippet[:97] + '...'
                rel = f.relative_to(REPO).as_posix()
                violations.append(f'[{tier_tag}] {rel}:{lineno}: {snippet}')
    return violations


def main():
    tier1_files = collect_tier1()
    tier2_files = collect_tier2()

    tier1_violations = scan(tier1_files, 'Tier 1')
    tier2_violations = scan(tier2_files, 'Tier 2')

    total = len(tier1_violations) + len(tier2_violations)
    if total == 0:
        print('\033[0;32mPASSED\033[0m: scripts/language-check.sh — '
              'Tier 1 and Tier 2 are CJK-clean.')
        sys.exit(0)

    for v in tier1_violations:
        print(v)
    for v in tier2_violations:
        print(v)

    print()
    print(f'\033[0;31mFAILED\033[0m: scripts/language-check.sh found {total} '
          f'violation(s) ({len(tier1_violations)} Tier 1, '
          f'{len(tier2_violations)} Tier 2).')
    print('See CLAUDE.md "Documentation Language Convention" for the '
          'four-tier architecture and remediation rules.')
    sys.exit(1)


main()
PYEOF

EXIT=$?
exit $EXIT
