#!/usr/bin/env bash
# gh-account-guard.sh — iSparto mid-session gh account alignment guard (FR-13).
#
# Purpose: close the gap between /start-working Step 6 and /end-working Step 8.
# Both existing steps perform gh account alignment at session boundaries, but a
# user can run `gh auth switch --user <other>` mid-session and flip the active
# account silently. The subsequent `gh pr create` would then post under the
# wrong identity (fork-attribution errors, or PR creation failing entirely).
# This guard is designed to be invoked immediately before `gh pr create` in
# /end-working Step 9 so any mid-session drift is caught and either
# auto-realigned or reported as an unrecoverable mismatch before the PR call.
#
# Behaviour:
#   1. Extract REPO_OWNER from `git remote get-url origin` (GitHub owner slug).
#   2. Extract GH_USER from `gh api /user --jq .login` (currently active gh
#      account).
#   3. If either probe yields an empty string (gh not installed, not
#      authenticated, no origin remote, non-GitHub host, etc.) exit 0 silently
#      — the guard is advisory only when it has the data it needs, never
#      blocks when the environment simply lacks a gh account to check.
#   4. If both are non-empty and they match: exit 0 silently (aligned, no
#      action).
#   5. If they mismatch: emit one WARN line to stderr naming the drift, then
#      run `gh auth switch --user "$REPO_OWNER"` to realign, then re-probe
#      `gh api /user --jq .login`:
#        - Re-verify succeeds (post-switch GH_USER == REPO_OWNER): exit 0.
#        - Re-verify still mismatches: emit a second ERROR line to stderr and
#          exit 2 so the caller (/end-working) can halt before `gh pr create`.
#
# Invocation:
#   bash scripts/gh-account-guard.sh             run the guard (normal mode)
#   bash scripts/gh-account-guard.sh --self-test run synthetic fixtures only
#   bash scripts/gh-account-guard.sh --help      print usage
#
# Self-test strategy: fixtures mock the `git` / `gh` binaries via a per-fixture
# PATH shim directory so no real network call or gh state mutation is made.
# Each fixture writes stub `git` and `gh` wrappers that honour
# GH_GUARD_TEST_* env vars to return canned output. The fixtures cover:
#   (a) aligned  — REPO_OWNER == GH_USER, guard exits 0 with empty stderr.
#   (b) mismatch-auto-recovers — initial GH_USER differs, `gh auth switch`
#       stub flips the canned GH_USER, re-probe matches, guard exits 0 with
#       one WARN stderr line.
#   (c) mismatch-unrecoverable — initial GH_USER differs, `gh auth switch`
#       stub fails (simulating an unavailable secondary account), re-probe
#       still mismatches, guard exits 2 with WARN + ERROR stderr lines.
#
# Exit codes:
#   0 — aligned, or environment lacks the data needed to check, or --help
#       / --self-test success
#   2 — mismatch persists after an auto-switch attempt (caller should halt),
#       or --self-test failure, or internal error (python3 missing, bad arg)
#
# Style mirror: scripts/session-health.sh (bash wrapper + python3 heredoc,
# same option parsing, same shell-collected inputs, same exit-code
# discipline). No colour in the guard itself — it is invoked from inside
# /end-working and its stderr is read by Lead, not the terminal.

set -uo pipefail

RED='\033[0;31m'
NC='\033[0m'

# python3 is a hard requirement (matches session-health.sh / doctor-check.sh
# convention). The guard's control flow is simple enough to be inline bash,
# but keeping the python3-heredoc structure preserves stylistic parity and
# leaves room for future assertions without rewriting the shell surface.
if ! command -v python3 >/dev/null 2>&1; then
    printf "%bERROR:%b python3 not found on PATH (required by gh-account-guard.sh)\n" \
        "$RED" "$NC" >&2
    exit 2
fi

# Parse arguments up-front so --help / --self-test skip the real git/gh
# probes entirely.
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

# In run mode, collect the two probes in shell so the python layer stays
# pure-formatting. The probes tolerate any failure (non-zero exit, missing
# binary, unauthenticated gh, non-GitHub remote) by letting the strings
# default to empty — the "both non-empty" predicate in python then drops
# the guard into the silent-skip branch that step (3) above describes.
REPO_OWNER=""
GH_USER=""
SWITCH_TARGET=""
SWITCH_RC=""
POST_SWITCH_GH_USER=""

if [ "$MODE" = "run" ]; then
    if command -v git >/dev/null 2>&1; then
        ORIGIN_URL="$(git remote get-url origin 2>/dev/null || true)"
        # Accept either `git@github.com:owner/repo.git` or
        # `https://github.com/owner/repo(.git)?` shapes. The regex mirrors
        # the one embedded in /start-working Step 6 and /end-working Step 8
        # (single source of truth — see FR-13 gap statement). Non-GitHub
        # remotes (GitLab, Bitbucket) fall through to empty REPO_OWNER.
        REPO_OWNER="$(printf '%s' "$ORIGIN_URL" \
            | sed -E 's#.+[:/]([^/]+)/[^/]+(\.git)?$#\1#' \
            2>/dev/null || true)"
        # Guard against the sed regex falling through unchanged on a URL
        # shape we do not recognise — in that case REPO_OWNER would equal
        # ORIGIN_URL, which is never a plausible GitHub owner. Treat this
        # as "no data" and let python skip silently.
        if [ "$REPO_OWNER" = "$ORIGIN_URL" ]; then
            REPO_OWNER=""
        fi
    fi
    if command -v gh >/dev/null 2>&1; then
        GH_USER="$(gh api /user --jq .login 2>/dev/null || true)"
    fi

    # If both probes are populated and they mismatch, attempt the auto-switch
    # here (shell side) and re-probe, then let python render the decision.
    # Doing the side-effectful call in shell keeps the python layer pure and
    # mirrors the session-health.sh split (shell collects, python formats).
    if [ -n "$REPO_OWNER" ] && [ -n "$GH_USER" ] && [ "$REPO_OWNER" != "$GH_USER" ]; then
        SWITCH_TARGET="$REPO_OWNER"
        # `gh auth switch --user` exits non-zero when the target account is
        # not logged in locally; capture the exit code so python can decide
        # whether to attempt the re-probe or go straight to unrecoverable.
        if gh auth switch --user "$SWITCH_TARGET" >/dev/null 2>&1; then
            SWITCH_RC="0"
        else
            SWITCH_RC="1"
        fi
        POST_SWITCH_GH_USER="$(gh api /user --jq .login 2>/dev/null || true)"
    fi
fi

export MODE REPO_OWNER GH_USER SWITCH_TARGET SWITCH_RC POST_SWITCH_GH_USER

python3 - <<'PYEOF'
import os
import shutil
import subprocess
import sys
import tempfile
import textwrap
from pathlib import Path


USAGE = """\
gh-account-guard.sh \u2014 iSparto mid-session gh account alignment guard (FR-13)

Usage:
  bash scripts/gh-account-guard.sh             run the guard
  bash scripts/gh-account-guard.sh --self-test run synthetic fixtures
  bash scripts/gh-account-guard.sh --help      print this message

Behaviour:
  - Extracts REPO_OWNER from `git remote get-url origin`.
  - Extracts GH_USER from `gh api /user --jq .login`.
  - If either is empty: exit 0 silently (no data to check).
  - If aligned: exit 0 silently.
  - If mismatched: WARN to stderr, run `gh auth switch --user <REPO_OWNER>`,
    re-verify. Exit 0 if recovered, exit 2 if still mismatched.

Exit codes:
  0 \u2014 aligned, environment lacks probe data, or --help / --self-test success
  2 \u2014 mismatch persists after auto-switch, --self-test failure, or
       internal error (python3 missing, bad argument)

Integration: called from commands/end-working.md Step 9 immediately before
`gh pr create`. When exit == 2, the caller halts via an A-layer interrupt.
"""


# ---------------------------------------------------------------------------
# Normal-run rendering
# ---------------------------------------------------------------------------


def run_guard():
    """Render the guard decision from env-collected probes.

    The shell layer has already performed the probes and (if needed) the
    `gh auth switch` side-effect. Python's job is to decide the exit code
    and emit the correct stderr lines.
    """
    repo_owner = os.environ.get('REPO_OWNER', '').strip()
    gh_user = os.environ.get('GH_USER', '').strip()
    switch_target = os.environ.get('SWITCH_TARGET', '').strip()
    switch_rc = os.environ.get('SWITCH_RC', '').strip()
    post_switch_gh_user = os.environ.get('POST_SWITCH_GH_USER', '').strip()

    # Skip silently when either probe yielded no data. This matches the
    # existing /start-working Step 6 and /end-working Step 8 behaviour
    # ("If gh is not installed, not authenticated, or only one account
    # exists: skip silently").
    if not repo_owner or not gh_user:
        return 0

    # Aligned — silent success, the expected steady state.
    if repo_owner == gh_user:
        return 0

    # Mismatch path. The shell layer already attempted the switch; our job
    # is to interpret the outcome.
    print(
        f'WARN: gh account drift detected — active GH_USER={gh_user!r} '
        f'does not match REPO_OWNER={repo_owner!r}; '
        f'attempted `gh auth switch --user {switch_target}`.',
        file=sys.stderr,
    )

    if switch_rc == '0' and post_switch_gh_user == repo_owner:
        # Auto-recovery succeeded. Exit 0; the WARN stands as audit trail.
        return 0

    # Unrecoverable mismatch — either the switch itself failed, or the
    # post-switch re-probe still disagrees with REPO_OWNER.
    print(
        f'ERROR: gh account mismatch persists after auto-switch '
        f'(post-switch GH_USER={post_switch_gh_user!r}, '
        f'expected {repo_owner!r}). Caller should halt before `gh pr create`.',
        file=sys.stderr,
    )
    return 2


# ---------------------------------------------------------------------------
# Self-test — run fixtures against the real scripts/gh-account-guard.sh via
# a per-fixture PATH shim that replaces `git` and `gh` with stub wrappers.
# ---------------------------------------------------------------------------


GIT_STUB = textwrap.dedent(
    """\
    #!/usr/bin/env bash
    # Test stub: only answers `git remote get-url origin`. Other invocations
    # are treated as no-op successes so that any inline `command -v git`
    # check in the parent script still succeeds.
    if [ "${1:-}" = "remote" ] && [ "${2:-}" = "get-url" ] && [ "${3:-}" = "origin" ]; then
        printf '%s\\n' "${GH_GUARD_TEST_ORIGIN_URL:-}"
        exit 0
    fi
    if [ "${1:-}" = "rev-parse" ]; then
        # language-check.sh / session-health.sh both probe rev-parse; return
        # a stub root so nothing downstream fails.
        printf '%s\\n' "${GH_GUARD_TEST_REPO_ROOT:-/}"
        exit 0
    fi
    exit 0
    """
)

# The `gh` stub keeps a tiny state file tracking "current user". The
# `auth switch` subcommand updates that file (or fails, when directed by
# GH_GUARD_TEST_SWITCH_FAIL). The `api /user --jq .login` subcommand reads
# it back. This faithfully models the three fixtures without touching real
# gh configuration.
GH_STUB = textwrap.dedent(
    """\
    #!/usr/bin/env bash
    STATE_FILE="${GH_GUARD_TEST_STATE_FILE:-/tmp/gh-account-guard-state}"
    sub="${1:-}"
    case "$sub" in
        api)
            # Usage: gh api /user --jq .login
            if [ -f "$STATE_FILE" ]; then
                cat "$STATE_FILE"
            fi
            exit 0
            ;;
        auth)
            # Usage: gh auth switch --user <name>
            shift
            if [ "${1:-}" = "switch" ]; then
                shift
                user=""
                while [ "$#" -gt 0 ]; do
                    case "$1" in
                        --user)
                            shift
                            user="${1:-}"
                            ;;
                    esac
                    shift || true
                done
                if [ "${GH_GUARD_TEST_SWITCH_FAIL:-0}" = "1" ]; then
                    exit 1
                fi
                # Successful switch: update the state file so the next
                # `gh api /user --jq .login` returns the new user.
                if [ -n "$user" ]; then
                    printf '%s' "$user" > "$STATE_FILE"
                fi
                exit 0
            fi
            exit 0
            ;;
        *)
            exit 0
            ;;
    esac
    """
)


FIXTURES = (
    # Each tuple: (name, initial_gh_user, origin_url, switch_fail,
    #              expected_exit, stderr_must_contain, stderr_must_not_contain)
    (
        'aligned',
        'octocat',
        'https://github.com/octocat/iSparto.git',
        False,
        0,
        (),                          # no stderr expected
        ('WARN', 'ERROR'),           # and neither WARN nor ERROR
    ),
    (
        'mismatch-auto-recovers',
        'other-user',
        'git@github.com:octocat/iSparto.git',
        False,
        0,
        ('WARN', 'drift detected'),  # warn line present
        ('ERROR',),                  # no ERROR line
    ),
    (
        'mismatch-unrecoverable',
        'other-user',
        'https://github.com/octocat/iSparto',
        True,
        2,
        ('WARN', 'ERROR', 'persists'),  # both present
        (),
    ),
)


def _write_stub(path, content):
    path.write_text(content, encoding='utf-8')
    path.chmod(0o755)


def _run_fixture(name, initial_user, origin_url, switch_fail, script_path):
    """Run scripts/gh-account-guard.sh inside a PATH-isolated sandbox.

    Returns (returncode, stderr_text). Any unexpected internal crash
    bubbles up as an exception — the caller treats that as a fixture
    failure.
    """
    tmp = Path(tempfile.mkdtemp(prefix=f'gh-guard-{name}-'))
    try:
        shim_dir = tmp / 'bin'
        shim_dir.mkdir(parents=True, exist_ok=True)

        state_file = tmp / 'state'
        state_file.write_text(initial_user, encoding='utf-8')

        _write_stub(shim_dir / 'git', GIT_STUB)
        _write_stub(shim_dir / 'gh', GH_STUB)

        # Preserve essential tools (bash, python3, sed, cat, printf).
        # shutil.which resolves the real absolute path; we symlink those
        # into shim_dir so the sandboxed PATH still finds them without
        # pulling in the rest of the user's $PATH (which might contain a
        # real `gh` binary that shadows our stub).
        for tool in ('bash', 'python3', 'sed', 'cat', 'printf', 'env',
                     'head', 'dirname', 'pwd', 'command'):
            real = shutil.which(tool)
            if real:
                link = shim_dir / tool
                if not link.exists():
                    try:
                        link.symlink_to(real)
                    except OSError:
                        # Fall back to copy if symlink is refused (e.g.
                        # exotic filesystem). The stub still works.
                        shutil.copy2(real, link)

        env = {
            'PATH': str(shim_dir),
            'HOME': str(tmp),
            'GH_GUARD_TEST_ORIGIN_URL': origin_url,
            'GH_GUARD_TEST_STATE_FILE': str(state_file),
            'GH_GUARD_TEST_SWITCH_FAIL': '1' if switch_fail else '0',
            'GH_GUARD_TEST_REPO_ROOT': str(tmp),
        }

        result = subprocess.run(
            ['bash', str(script_path)],
            env=env,
            capture_output=True,
            text=True,
            timeout=15,
        )
        return result.returncode, result.stderr
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def run_self_test():
    # Resolve the script file we are embedded in. When launched as
    # `bash scripts/gh-account-guard.sh --self-test`, $0 inside the outer
    # bash wrapper is the absolute path we need. Python's sys.argv[0] is
    # `-` (heredoc), so we read it from the env PWD + hard-coded relpath
    # as a last resort.
    script_path = _locate_script_path()
    if script_path is None or not script_path.is_file():
        print('FAIL: cannot locate gh-account-guard.sh for self-test',
              file=sys.stderr)
        return 1

    failures = []
    for (name, initial_user, origin_url, switch_fail, expected_exit,
         must_contain, must_not_contain) in FIXTURES:
        try:
            rc, stderr = _run_fixture(
                name, initial_user, origin_url, switch_fail, script_path,
            )
        except Exception as e:  # noqa: BLE001
            failures.append(f'fixture {name!r}: crashed with {e!r}')
            print(f'FAIL: {name}')
            continue

        errs = []
        if rc != expected_exit:
            errs.append(
                f'exit code {rc} (expected {expected_exit})'
            )
        for token in must_contain:
            if token not in stderr:
                errs.append(f'stderr missing {token!r}')
        for token in must_not_contain:
            if token in stderr:
                errs.append(f'stderr unexpectedly contains {token!r}')

        if errs:
            joined = '; '.join(errs)
            failures.append(
                f'fixture {name!r}: {joined}\n'
                f'--- stderr ---\n{stderr}\n--- end ---'
            )
            print(f'FAIL: {name}')
        else:
            print(f'PASS: {name}')

    if failures:
        for msg in failures:
            print(msg, file=sys.stderr)
        print(
            f'FAILED: gh-account-guard.sh --self-test '
            f'({len(failures)} issue(s))',
            file=sys.stderr,
        )
        return 1

    print(
        'PASSED: gh-account-guard.sh --self-test '
        f'({len(FIXTURES)}/{len(FIXTURES)} fixtures OK)'
    )
    return 0


def _locate_script_path():
    """Find scripts/gh-account-guard.sh on disk.

    The python heredoc does not receive the outer bash script's $0, so we
    reconstruct it by walking up from the current working directory (the
    bash wrapper runs from the user's invocation point) until we find a
    `scripts/gh-account-guard.sh`. This is good enough for the self-test
    because the test is always invoked inside the iSparto checkout.
    """
    start = Path(os.environ.get('PWD', '.')).resolve()
    for candidate in (start, *start.parents):
        p = candidate / 'scripts' / 'gh-account-guard.sh'
        if p.is_file():
            return p
    # Fallback: git rev-parse --show-toplevel from the real filesystem.
    try:
        out = subprocess.run(
            ['git', 'rev-parse', '--show-toplevel'],
            capture_output=True, text=True, timeout=5,
        )
        if out.returncode == 0:
            root = Path(out.stdout.strip())
            p = root / 'scripts' / 'gh-account-guard.sh'
            if p.is_file():
                return p
    except Exception:  # noqa: BLE001
        pass
    return None


def main():
    mode = os.environ.get('MODE', 'run').strip()

    if mode == 'help':
        print(USAGE)
        return 0

    if mode == 'self-test':
        return run_self_test()

    try:
        return run_guard()
    except Exception as e:  # noqa: BLE001 — any bubble-up is exit 2
        print(
            f'ERROR: internal failure in gh-account-guard.sh: '
            f'{type(e).__name__}: {e}',
            file=sys.stderr,
        )
        return 2


sys.exit(main())
PYEOF

EXIT=$?
exit $EXIT
