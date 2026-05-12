#!/usr/bin/env bash
# check-command-rename.sh — iSparto v0.9.0 command-rename guardian (v1).
#
# Scans the repo for stale references to the 10 pre-v0.9.0 iSparto slash
# command names (start-working, end-working, plan, doctor, init-project,
# migrate, restore, release, security-audit, env-nogo), applying a narrow
# allowlist for legitimate retentions. This is a single-purpose guardian
# scoped to the v0.9.0 rename; it intentionally does NOT generalize into a
# rename-framework. Once the v0.9.0 dust settles and the allowlist regions
# stabilize (or the rename is sufficiently old that residuals would be
# pre-existing bugs not regressions), this script can be retired.
#
# Detection patterns:
#   (a) slash invocation:   /<old> followed by EOL or non-word/non-hyphen
#                           /non-slash/non-letter-after-period
#   (b) commands/<old>.md   literal path reference
#   (c) brace-expansion:    {old1,old2,...}.md form, e.g. as used in shell
#                           uninstall help text
#
# Allowlist (file + region anchored):
#   - docs/session-log.md             (entire file, Tier 4 frozen)
#   - docs/independent-review.md      (entire file, Tier 4 frozen)
#   - CHANGELOG.md                    (Unreleased block; entries <= 0.8.4
#                                      historical; 0.9.0 block once it lands)
#   - docs/plan.md                    (Tier-4-frozen "Completed Wave" historical
#                                      region heading text in maintainer's
#                                      working language; "Completed Wave Index"
#                                      sub-heading text in maintainer's working
#                                      language; "### v0.8.0 ..." Wave entries +
#                                      observation tracker region;
#                                      Backlog table "Surfaced by" column —
#                                      column 5 of "| FR-/DV-/ED-" rows)
#   - docs/troubleshooting.md         ("## Old commands not found after
#                                      v0.9.0 rename" section)
#   - install.sh                      (print_v090_rename_notice() body —
#                                      the rename-mapping printf block;
#                                      run_v090_rename_cleanup() body —
#                                      the bare stale_names array)
#
# Usage:
#   bash scripts/check-command-rename.sh             scan repo
#   bash scripts/check-command-rename.sh --self-test fixtures only
#   bash scripts/check-command-rename.sh --help      print usage
#
# Exit codes:
#   0  clean (no stale references outside allowlist)
#   1  one or more stale references found
#   2  environment error / self-test failure

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

if ! command -v python3 >/dev/null 2>&1; then
    printf "%bERROR:%b python3 not found on PATH\n" "$RED" "$NC" >&2
    exit 2
fi

export REPO_ROOT_ENV="$REPO_ROOT"

python3 - "$@" <<'PYEOF'
import os
import re
import sys
import tempfile
import shutil
from pathlib import Path

# === Configuration ============================================================

OLD_NAMES = [
    "start-working", "end-working", "plan", "doctor",
    "init-project", "migrate", "restore", "release",
    "security-audit", "env-nogo",
]
NAMES_RE = "|".join(re.escape(n) for n in OLD_NAMES)

# (a) slash invocation: /<old> NOT preceded by word/hyphen,
#     NOT followed by word/hyphen/slash/period-then-letter
SLASH_RE = re.compile(rf"(?<![\w-])/({NAMES_RE})(?=$|[^\w/.\-]|\.(?![a-zA-Z]))")

# (b) commands/<old>.md
COMMANDS_PATH_RE = re.compile(rf"commands/({NAMES_RE})\.md\b")

# (c) brace-expansion {a,b,c}.md
BRACE_RE = re.compile(r"\{([\w,\-]+)\}\.md\b")
OLD_NAMES_SET = set(OLD_NAMES)


def brace_contains_old(brace_content):
    return any(n.strip() in OLD_NAMES_SET for n in brace_content.split(","))


SCAN_EXTS = {".md", ".sh", ".json"}
SKIP_DIRS = {".git", "node_modules", ".idea", ".vscode"}


# === Allowlist =================================================================

class Allowlist:
    """Per-file region predicates. Each predicate returns True if the line is
    inside an allowed region (stale refs there are NOT violations)."""

    def __init__(self, repo_root):
        self.repo_root = Path(repo_root)
        self._cache = {}

    def is_allowed(self, rel_path, lines, line_idx, match_start):
        key = rel_path
        if key == "docs/session-log.md":
            return True
        if key == "docs/independent-review.md":
            return True
        if key == "CHANGELOG.md":
            return self._changelog_predicate(lines, line_idx)
        if key == "docs/plan.md":
            return self._plan_predicate(lines, line_idx, match_start)
        if key == "docs/troubleshooting.md":
            return self._troubleshooting_predicate(lines, line_idx)
        if key == "install.sh":
            return self._install_predicate(lines, line_idx)
        return False

    @staticmethod
    def _bounded_region(lines, start_re, end_re):
        """Find first line matching start_re; region ends at first subsequent
        line matching end_re. Returns (start_idx, end_idx) or (None, None)."""
        start = None
        for i, line in enumerate(lines):
            if start is None and start_re.match(line):
                start = i
            elif start is not None and end_re.match(line):
                return (start, i - 1)
        if start is not None:
            return (start, len(lines) - 1)
        return (None, None)

    def _changelog_predicate(self, lines, line_idx):
        # 1. [Unreleased] block: from "## [Unreleased]" to next "## [..."
        un_start, un_end = self._bounded_region(
            lines,
            re.compile(r"^## \[Unreleased\]\s*$"),
            re.compile(r"^## \[(?!Unreleased\])"),
        )
        if un_start is not None and un_start <= line_idx <= un_end:
            return True
        # 2. [0.9.0] block once it appears
        v9_start, v9_end = self._bounded_region(
            lines,
            re.compile(r"^## \[0\.9\.0\]"),
            re.compile(r"^## \[(?!0\.9\.0)"),
        )
        if v9_start is not None and v9_start <= line_idx <= v9_end:
            return True
        # 3. Historical entries <= [0.8.4] — from "## [0.8.4]" to EOF
        for i, line in enumerate(lines):
            if line.startswith("## [0.8.4]"):
                if line_idx >= i:
                    return True
                break
        return False

    def _plan_predicate(self, lines, line_idx, match_start):
        # 1. Top-level "Completed" historical section. Heading text is in
        # the maintainer's working language; accept both the English
        # "## Completed" and the CJK equivalent (codepoints U+5DF2 U+5B8C
        # U+6210 — "Completed" as a two-character CJK word). Codepoint
        # escapes keep this Tier 1 file CJK-free per the language
        # convention.
        wc_start, wc_end = self._bounded_region(
            lines,
            re.compile(r"^## (?:\u5df2\u5b8c\u6210|Completed)\s*$"),
            re.compile(r"^## (?!(?:\u5df2\u5b8c\u6210|Completed))"),
        )
        if wc_start is not None and wc_start <= line_idx <= wc_end:
            return True
        # 2. "Completed Wave Index" sub-heading region. Same English-or-CJK
        # disjunction. CJK form: U+5DF2 U+5B8C U+6210 + " Wave " +
        # U+7D22 U+5F15 ("Index").
        idx_heading_re = re.compile(
            r"^### (?:\u5df2\u5b8c\u6210\s*Wave\s*\u7d22\u5f15|Completed\s+Wave\s+Index)"
        )
        idx_not_heading_re = re.compile(
            r"^### (?!(?:\u5df2\u5b8c\u6210\s*Wave\s*\u7d22\u5f15|Completed\s+Wave\s+Index))"
        )
        idx_start, idx_end = self._bounded_region(
            lines,
            idx_heading_re,
            idx_not_heading_re,
        )
        if idx_start is not None and idx_start <= line_idx <= idx_end:
            return True
        # 3. "### v0.8.0 ..." Wave entries + observation tracker
        v080_start = None
        for i, line in enumerate(lines):
            if re.match(r"^### v0\.8\.0", line):
                if v080_start is None:
                    v080_start = i
        v080_end = None
        if v080_start is not None:
            for i in range(v080_start + 1, len(lines)):
                if re.match(r"^## ", lines[i]):
                    v080_end = i - 1
                    break
            if v080_end is None:
                v080_end = len(lines) - 1
        if v080_start is not None and v080_start <= line_idx <= v080_end:
            return True
        # 4. Backlog table "Surfaced by" column (cell 5) of FR/DV/ED rows
        line = lines[line_idx]
        if re.match(r"^\| (FR|DV|ED)-", line):
            pipes = [i for i, ch in enumerate(line) if ch == '|']
            if len(pipes) >= 6:
                if pipes[4] < match_start < pipes[5]:
                    return True
        return False

    def _troubleshooting_predicate(self, lines, line_idx):
        ts_start, ts_end = self._bounded_region(
            lines,
            re.compile(r"^## Old commands not found after v0\.9\.0 rename\s*$"),
            re.compile(r"^## (?!Old commands not found)"),
        )
        return ts_start is not None and ts_start <= line_idx <= ts_end

    def _install_predicate(self, lines, line_idx):
        # Allow lines within the v0.9.0 migration helper functions
        # (print_v090_rename_notice, run_v090_rename_cleanup,
        # run_migration_self_test) — they legitimately reference the
        # pre-rename names in print statements, in the stale_names
        # array, and in self-test fixtures.
        for fn in ("print_v090_rename_notice", "run_v090_rename_cleanup", "run_migration_self_test"):
            start = None
            for i, line in enumerate(lines):
                if start is None and re.match(rf"^{fn}\(\)", line):
                    start = i
                elif start is not None and re.match(r"^\}\s*$", line):
                    if start <= line_idx <= i:
                        return True
                    start = None  # closed; not in this function
                    break
        return False


# === Scanner ==================================================================

def scan_repo(repo_root, allowlist):
    violations = []
    repo_root = Path(repo_root)
    for root, dirs, files in os.walk(repo_root):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        for fname in files:
            ext = os.path.splitext(fname)[1]
            if ext not in SCAN_EXTS:
                continue
            # Skip this guardian's own source — it contains old names by design.
            fpath = Path(root) / fname
            rel = str(fpath.relative_to(repo_root))
            if rel == "scripts/check-command-rename.sh":
                continue
            try:
                content = fpath.read_text(encoding="utf-8", errors="replace")
            except Exception:
                continue
            lines = content.splitlines()
            for i, line in enumerate(lines):
                for m in SLASH_RE.finditer(line):
                    if allowlist.is_allowed(rel, lines, i, m.start()):
                        continue
                    violations.append((rel, i + 1, f"slash /{m.group(1)}", line.strip()[:140]))
                for m in COMMANDS_PATH_RE.finditer(line):
                    if allowlist.is_allowed(rel, lines, i, m.start()):
                        continue
                    violations.append((rel, i + 1, f"path commands/{m.group(1)}.md", line.strip()[:140]))
                for m in BRACE_RE.finditer(line):
                    if not brace_contains_old(m.group(1)):
                        continue
                    if allowlist.is_allowed(rel, lines, i, m.start()):
                        continue
                    violations.append((rel, i + 1, f"brace {{{m.group(1)}}}.md", line.strip()[:140]))
    return violations


# === Self-test ===============================================================

def _make_fixture(tmp, name, files):
    fdir = tmp / name
    fdir.mkdir(parents=True, exist_ok=True)
    for rel, content in files.items():
        p = fdir / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(content)
    return fdir


def self_test():
    tmp = Path(tempfile.mkdtemp(prefix="check-command-rename-"))
    failed = 0
    try:
        # Fixture A: README.md with /start-working → expect 1 violation
        a = _make_fixture(tmp, "a", {"README.md": "Use /start-working to begin.\n"})
        vs = scan_repo(str(a), Allowlist(str(a)))
        if len(vs) != 1:
            print(f"  [FAIL] fixture-a (live README /start-working): expected 1 violation, got {len(vs)}: {vs}")
            failed += 1
        else:
            print("  [PASS] fixture-a (live README /start-working flagged)")
        # Fixture B: CHANGELOG.md [Unreleased] block with /start-working → 0 violations
        b = _make_fixture(tmp, "b", {
            "CHANGELOG.md": "## [Unreleased]\n\nLegacy /start-working renamed.\n\n## [0.8.0]\n\nOld.\n",
        })
        vs = scan_repo(str(b), Allowlist(str(b)))
        if vs:
            print(f"  [FAIL] fixture-b (CHANGELOG [Unreleased] /start-working): expected 0, got {len(vs)}: {vs}")
            failed += 1
        else:
            print("  [PASS] fixture-b (CHANGELOG [Unreleased] allowed)")
        # Fixture C: plan.md Backlog row, Surfaced by column has /doctor → 0 violations
        c = _make_fixture(tmp, "c", {
            "docs/plan.md": "| FR-1 | desc | suggested fix | low | Wave 2 /doctor session |\n",
        })
        vs = scan_repo(str(c), Allowlist(str(c)))
        if vs:
            print(f"  [FAIL] fixture-c (plan.md Surfaced-by /doctor): expected 0, got {len(vs)}: {vs}")
            failed += 1
        else:
            print("  [PASS] fixture-c (plan.md Surfaced-by allowed)")
        # Fixture D: plan.md Backlog row, Description column has /doctor → 1 violation
        d = _make_fixture(tmp, "d", {
            "docs/plan.md": "| FR-1 | use /doctor here | suggested fix | low | 2026-04-27 |\n",
        })
        vs = scan_repo(str(d), Allowlist(str(d)))
        if len(vs) != 1:
            print(f"  [FAIL] fixture-d (plan.md Description /doctor): expected 1, got {len(vs)}: {vs}")
            failed += 1
        else:
            print("  [PASS] fixture-d (plan.md Description flagged)")
        # Fixture E: troubleshooting.md migration section with /doctor → 0 violations
        e = _make_fixture(tmp, "e", {
            "docs/troubleshooting.md": "# T\n\n## Old commands not found after v0.9.0 rename\n\nUse /doctor-isparto. The old /doctor is gone.\n",
        })
        vs = scan_repo(str(e), Allowlist(str(e)))
        if vs:
            print(f"  [FAIL] fixture-e (troubleshooting migration section): expected 0, got {len(vs)}: {vs}")
            failed += 1
        else:
            print("  [PASS] fixture-e (troubleshooting migration section allowed)")
        # Fixture F: brace-expansion in shell with old names → 1 violation
        f = _make_fixture(tmp, "f", {
            "isparto.sh": "rm -f ~/.claude/commands/{start-working,end-working}.md\n",
        })
        vs = scan_repo(str(f), Allowlist(str(f)))
        if len(vs) != 1:
            print(f"  [FAIL] fixture-f (shell brace expansion old names): expected 1, got {len(vs)}: {vs}")
            failed += 1
        else:
            print("  [PASS] fixture-f (shell brace expansion flagged)")
        # Fixture G: brace-expansion with all-new names → 0 violations
        g = _make_fixture(tmp, "g", {
            "isparto.sh": "rm -f ~/.claude/commands/{start-isparto,end-isparto}.md\n",
        })
        vs = scan_repo(str(g), Allowlist(str(g)))
        if vs:
            print(f"  [FAIL] fixture-g (shell brace expansion new names): expected 0, got {len(vs)}: {vs}")
            failed += 1
        else:
            print("  [PASS] fixture-g (shell brace expansion new names allowed)")
        # Fixture H: scripts/release.sh path (NOT a slash command) → 0 violations
        h = _make_fixture(tmp, "h", {
            "README.md": "Run scripts/release.sh and grab the release.tar.gz file.\n",
        })
        vs = scan_repo(str(h), Allowlist(str(h)))
        if vs:
            print(f"  [FAIL] fixture-h (non-slash-command path): expected 0, got {len(vs)}: {vs}")
            failed += 1
        else:
            print("  [PASS] fixture-h (non-slash-command path safe)")
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

    if failed == 0:
        print(f"\n  ✓ check-command-rename.sh --self-test: all 8 fixtures PASS")
        return 0
    print(f"\n  ✗ check-command-rename.sh --self-test: {failed} fixture(s) FAILED")
    return 2


def usage():
    return (
        "check-command-rename.sh — iSparto v0.9.0 command-rename guardian\n"
        "\n"
        "Usage:\n"
        "  bash scripts/check-command-rename.sh             scan repo for stale refs\n"
        "  bash scripts/check-command-rename.sh --self-test run synthetic fixtures\n"
        "  bash scripts/check-command-rename.sh --help      print this message\n"
        "\n"
        "Exit codes:\n"
        "  0  clean (no stale refs outside allowlist)\n"
        "  1  stale references found\n"
        "  2  environment error / self-test failure\n"
    )


def main(argv):
    args = argv[1:]
    if args:
        if args[0] == "--self-test":
            sys.exit(self_test())
        if args[0] in ("--help", "-h"):
            print(usage())
            sys.exit(0)
        print(f"Unknown argument: {args[0]}", file=sys.stderr)
        print(usage(), file=sys.stderr)
        sys.exit(2)

    repo_root = os.environ.get("REPO_ROOT_ENV", os.getcwd())
    violations = scan_repo(repo_root, Allowlist(repo_root))
    if not violations:
        print("✓ check-command-rename: 0 stale references found")
        sys.exit(0)
    print(f"FAILED: check-command-rename found {len(violations)} stale reference(s):\n")
    for rel, line, kind, snippet in violations:
        print(f"  {rel}:{line}: {kind}")
        print(f"    > {snippet}")
    sys.exit(1)


main(sys.argv)
PYEOF
