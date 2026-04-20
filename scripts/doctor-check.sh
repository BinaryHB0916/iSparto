#!/usr/bin/env bash
# doctor-check.sh — iSparto environment diagnostic scanner (v1).
#
# Runs 7 fixed checks (D1..D7) against the current system + iSparto repo
# and reports PASS/WARN/FAIL per check plus a summary line. Output is
# deterministic, language-neutral (English), and machine-parseable so
# commands/doctor.md can read stdout and re-render it in the user's
# language. No side effects: read-only checks, no network, no writes.
#
# Checks:
#   D1  tmux availability            (>= 3.0 required)
#   D2  Codex CLI availability       (>= 0.100.0 required)
#   D3  Claude Code version          (on PATH + --version non-empty)
#   D4  Hook file integrity          (~/.claude/settings.json references
#                                     under $HOME/.isparto/ exist + exec)
#   D5  iSparto repo markers         (CLAUDE.md + docs/plan.md present;
#                                     no unacknowledged BLOCKING markers)
#   D6  Codex config sanity          (~/.codex/config.toml service_tier
#                                     in {unset, "fast", "flex"})
#   D7  VERSION <-> git tag          (VERSION matches highest v* tag)
#
# Invocation:
#   bash scripts/doctor-check.sh             run all 7 checks
#   bash scripts/doctor-check.sh --self-test run synthetic fixtures only
#   bash scripts/doctor-check.sh --help      print usage
#
# Exit codes:
#   0 — zero FAIL (all PASS, or PASS + WARN)
#   1 — one or more FAIL
#   2 — internal script error (repo root resolution, python exception, etc.)

set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Resolve repo root: prefer git, fall back to script-relative. D5/D7 use
# $PWD (caller's current dir) for repo-marker checks; REPO_ROOT is only
# used so the script itself can locate its own source tree if needed.
if REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    :
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    REPO_ROOT="$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd)"
fi

if [ -z "${REPO_ROOT:-}" ]; then
    printf "%bERROR:%b cannot resolve repo root\n" "$RED" "$NC" >&2
    exit 2
fi

# Gather raw inputs in shell (trivial command-existence + version probes)
# and pass them to python3 for formatting + aggregation + self-test. This
# mirrors language-check.sh / policy-lint.sh: shell handles environment
# interaction, python handles structured output.

# D1 — tmux
TMUX_PATH="$(command -v tmux 2>/dev/null || true)"
TMUX_VERSION_RAW=""
if [ -n "$TMUX_PATH" ]; then
    TMUX_VERSION_RAW="$(tmux -V 2>&1 || true)"
fi

# D2 — codex. Capture RC directly (no `|| true` mask) so non-zero
# --version exits surface as FAIL/WARN in python parsing below.
CODEX_PATH="$(command -v codex 2>/dev/null || true)"
CODEX_VERSION_RAW=""
CODEX_VERSION_RC=1
if [ -n "$CODEX_PATH" ]; then
    CODEX_VERSION_RAW="$(codex --version 2>&1)"
    CODEX_VERSION_RC=$?
fi

# D3 — claude. Same RC-preservation pattern as D2.
CLAUDE_PATH="$(command -v claude 2>/dev/null || true)"
CLAUDE_VERSION_RAW=""
CLAUDE_VERSION_RC=1
if [ -n "$CLAUDE_PATH" ]; then
    CLAUDE_VERSION_RAW="$(claude --version 2>&1)"
    CLAUDE_VERSION_RC=$?
fi

# D4 — hooks. settings.json may be a symlink; resolve via cat. Python
# does JSON parsing and exec-bit verification.
SETTINGS_JSON_PATH="$HOME/.claude/settings.json"
SETTINGS_JSON_EXISTS=0
if [ -f "$SETTINGS_JSON_PATH" ] || [ -L "$SETTINGS_JSON_PATH" ]; then
    SETTINGS_JSON_EXISTS=1
fi

# D5 — repo markers use $PWD (where user invoked the script).
PWD_SNAPSHOT="$PWD"

# D6 — codex config
CODEX_CONFIG_PATH="$HOME/.codex/config.toml"
CODEX_CONFIG_EXISTS=0
if [ -f "$CODEX_CONFIG_PATH" ]; then
    CODEX_CONFIG_EXISTS=1
fi

# D7 — VERSION + highest git tag (both scoped to $PWD). Resolving the
# highest tag requires git; tolerate missing git gracefully.
VERSION_FILE_PATH="$PWD_SNAPSHOT/VERSION"
VERSION_FILE_CONTENT=""
if [ -f "$VERSION_FILE_PATH" ]; then
    VERSION_FILE_CONTENT="$(head -n 1 "$VERSION_FILE_PATH" 2>/dev/null | tr -d '[:space:]' || true)"
fi
HIGHEST_TAG=""
if git -C "$PWD_SNAPSHOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    HIGHEST_TAG="$(git -C "$PWD_SNAPSHOT" tag --list 'v*' --sort=-v:refname 2>/dev/null | head -n 1 || true)"
fi

# TTY detection for color gating. python3 also inspects isatty but we
# pass an explicit flag so behavior is identical across shells.
if [ -t 1 ]; then
    IS_TTY=1
else
    IS_TTY=0
fi

export TMUX_PATH TMUX_VERSION_RAW
export CODEX_PATH CODEX_VERSION_RAW CODEX_VERSION_RC
export CLAUDE_PATH CLAUDE_VERSION_RAW CLAUDE_VERSION_RC
export SETTINGS_JSON_PATH SETTINGS_JSON_EXISTS
export PWD_SNAPSHOT
export CODEX_CONFIG_PATH CODEX_CONFIG_EXISTS
export VERSION_FILE_PATH VERSION_FILE_CONTENT HIGHEST_TAG
export IS_TTY

python3 - "$@" <<'PYEOF'
import json
import os
import re
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Output primitives
# ---------------------------------------------------------------------------

IS_TTY = os.environ.get('IS_TTY', '0') == '1'

RED = '\033[0;31m' if IS_TTY else ''
GREEN = '\033[0;32m' if IS_TTY else ''
YELLOW = '\033[0;33m' if IS_TTY else ''
NC = '\033[0m' if IS_TTY else ''

STATUS_COLORS = {
    'PASS': GREEN,
    'WARN': YELLOW,
    'FAIL': RED,
}

CHECK_ORDER = ['D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7']
CHECK_NAMES = {
    'D1': 'tmux availability',
    'D2': 'Codex CLI availability',
    'D3': 'Claude Code version',
    'D4': 'Hook file integrity',
    'D5': 'iSparto repo markers',
    'D6': 'Codex config sanity',
    'D7': 'VERSION <-> git tag consistency',
}


def make_result(status, check_id, detail, fix=None):
    """Return a result dict with a stable schema."""
    if status not in STATUS_COLORS:
        raise ValueError(f'invalid status: {status}')
    return {
        'id': check_id,
        'name': CHECK_NAMES[check_id],
        'status': status,
        'detail': detail,
        'fix': fix,
    }


def format_line(result):
    status = result['status']
    color = STATUS_COLORS[status]
    head = f'[{status}]'
    if color:
        head = f'{color}{head}{NC}'
    base = f"{head} {result['id']}: {result['name']} \u2014 {result['detail']}"
    if status != 'PASS' and result.get('fix'):
        base = f"{base} (fix: {result['fix']})"
    return base


def emit_results(results):
    # Preserve the D1..D7 order regardless of the order the checks ran in.
    by_id = {r['id']: r for r in results}
    for cid in CHECK_ORDER:
        if cid in by_id:
            print(format_line(by_id[cid]))
    summary(results)


def summary(results):
    n_pass = sum(1 for r in results if r['status'] == 'PASS')
    n_warn = sum(1 for r in results if r['status'] == 'WARN')
    n_fail = sum(1 for r in results if r['status'] == 'FAIL')
    total = len(results)
    line = (
        f'=== Summary: {n_pass} PASS, {n_warn} WARN, {n_fail} FAIL '
        f'/ {total} total ==='
    )
    print(line)
    return n_pass, n_warn, n_fail


# ---------------------------------------------------------------------------
# Version helpers
# ---------------------------------------------------------------------------

VERSION_TOKEN = re.compile(r'(\d+)\.(\d+)\.(\d+)')
# tmux versions are X.Y[letter], e.g. "3.6a" — no patch component. A
# relaxed parser treats the letter suffix as patch=0 so tmux can be
# compared against (3, 0, 0).
VERSION_TOKEN_LAX = re.compile(r'(\d+)\.(\d+)(?:\.(\d+))?')


def parse_version_tuple(s):
    """Return the first (major, minor, patch) triple found in s, or None."""
    if not s:
        return None
    m = VERSION_TOKEN.search(s)
    if not m:
        return None
    return tuple(int(x) for x in m.groups())


def parse_version_tuple_lax(s):
    """Like parse_version_tuple but accepts X.Y (patch defaults to 0) so
    that tmux-style "3.6a" parses to (3, 6, 0). Intended for D1 only.
    """
    if not s:
        return None
    m = VERSION_TOKEN_LAX.search(s)
    if not m:
        return None
    major, minor, patch = m.group(1), m.group(2), m.group(3)
    return (int(major), int(minor), int(patch) if patch is not None else 0)


def cmp_version(a, b):
    """Compare version tuples a vs b: -1 if a<b, 0 if equal, 1 if a>b."""
    if a == b:
        return 0
    return -1 if a < b else 1


# ---------------------------------------------------------------------------
# Individual checks — each returns a result dict built via make_result.
# Checks read environment variables populated by the bash wrapper so they
# stay pure (no subprocesses / filesystem probes beyond what the wrapper
# already gathered, except where the check intrinsically needs filesystem
# introspection — D4/D5/D6/D7).
# ---------------------------------------------------------------------------

def check_d1():
    tmux_path = os.environ.get('TMUX_PATH', '').strip()
    raw = os.environ.get('TMUX_VERSION_RAW', '').strip()

    if not tmux_path:
        return make_result(
            'FAIL', 'D1',
            'tmux not found on PATH',
            fix='brew install tmux',
        )

    # tmux uses X.Y[letter] (e.g. "3.6a"), so the lax parser is required.
    version = parse_version_tuple_lax(raw)
    if version is None:
        return make_result(
            'WARN', 'D1',
            f'tmux found at {tmux_path} but version string unparseable ({raw!r})',
            fix='verify tmux -V output manually',
        )

    if cmp_version(version, (3, 0, 0)) < 0:
        version_str = '.'.join(str(x) for x in version)
        return make_result(
            'WARN', 'D1',
            f'tmux {version_str} found at {tmux_path} (< 3.0 required)',
            fix='brew upgrade tmux',
        )

    # Preserve the raw form (e.g. "tmux 3.6a") for fidelity; the gate is
    # driven by the parsed tuple.
    return make_result(
        'PASS', 'D1',
        f'{raw} found at {tmux_path}',
    )


def check_d2():
    codex_path = os.environ.get('CODEX_PATH', '').strip()
    raw = os.environ.get('CODEX_VERSION_RAW', '').strip()
    rc = os.environ.get('CODEX_VERSION_RC', '1').strip()

    if not codex_path:
        return make_result(
            'FAIL', 'D2',
            'codex not found on PATH',
            fix='install from https://github.com/openai/codex',
        )

    if rc != '0':
        return make_result(
            'WARN', 'D2',
            f'codex at {codex_path} but --version returned non-zero ({raw!r})',
            fix='reinstall or check PATH for a stale binary',
        )

    version = parse_version_tuple(raw)
    if version is None:
        return make_result(
            'WARN', 'D2',
            f'codex at {codex_path} but --version output unparseable ({raw!r})',
            fix='verify codex --version output manually',
        )

    version_str = '.'.join(str(x) for x in version)
    if cmp_version(version, (0, 100, 0)) < 0:
        return make_result(
            'WARN', 'D2',
            f'codex {version_str} at {codex_path} (< 0.100.0 required)',
            fix='upgrade codex CLI',
        )

    return make_result(
        'PASS', 'D2',
        f'codex-cli {version_str} at {codex_path}',
    )


def check_d3():
    claude_path = os.environ.get('CLAUDE_PATH', '').strip()
    raw = os.environ.get('CLAUDE_VERSION_RAW', '').strip()
    rc = os.environ.get('CLAUDE_VERSION_RC', '1').strip()

    if not claude_path:
        return make_result(
            'FAIL', 'D3',
            'claude not found on PATH',
            fix='install from claude.ai/code',
        )

    if rc != '0' or not raw:
        return make_result(
            'WARN', 'D3',
            f'claude at {claude_path} but --version errored ({raw!r})',
            fix='reinstall Claude Code',
        )

    raw_last_line = raw.splitlines()[-1].strip() if raw.splitlines() else raw
    return make_result(
        'PASS', 'D3',
        f'{raw_last_line} at {claude_path}',
    )


def _collect_hook_commands(obj):
    """Walk a settings.json structure and yield every 'command' string
    under hooks.*. Schema (as of Claude Code 2.x):
      hooks = { <Event>: [ { matcher, hooks: [ { type, command } ] } ] }
    """
    if not isinstance(obj, dict):
        return
    hooks = obj.get('hooks')
    if not isinstance(hooks, dict):
        return
    for _event, entries in hooks.items():
        if not isinstance(entries, list):
            continue
        for entry in entries:
            if not isinstance(entry, dict):
                continue
            sub = entry.get('hooks')
            if not isinstance(sub, list):
                continue
            for h in sub:
                if isinstance(h, dict) and isinstance(h.get('command'), str):
                    yield h['command']


def _extract_isparto_paths(command_str):
    """Return absolute paths inside $HOME/.isparto/ referenced by a hook
    command string. Matches both $HOME/.isparto/... and ~/.isparto/...
    shell forms that install.sh emits; tolerates surrounding quoting.
    """
    home = os.environ.get('HOME', '')
    if not home:
        return []
    results = []
    # Match the two forms install.sh emits, up to the next whitespace
    # or closing quote. The trailing character class excludes typical
    # shell word-boundary characters without being over-aggressive.
    pattern = re.compile(r'(?:\$HOME|~)/\.isparto/[^\s"\';]+')
    for m in pattern.finditer(command_str):
        raw_path = m.group(0)
        resolved = raw_path.replace('$HOME', home, 1)
        if resolved.startswith('~/'):
            resolved = home + resolved[1:]
        results.append(resolved)
    return results


def check_d4():
    settings_path_str = os.environ.get('SETTINGS_JSON_PATH', '').strip()
    exists_flag = os.environ.get('SETTINGS_JSON_EXISTS', '0').strip()

    if exists_flag != '1' or not settings_path_str:
        return make_result(
            'WARN', 'D4',
            '~/.claude/settings.json not present',
            fix='run ~/.isparto/install.sh to register hooks',
        )

    settings_path = Path(settings_path_str)
    try:
        raw_text = settings_path.read_text(encoding='utf-8', errors='replace')
    except OSError as e:
        return make_result(
            'FAIL', 'D4',
            f'cannot read {settings_path_str}: {e}',
            fix='check file permissions',
        )

    try:
        data = json.loads(raw_text)
    except json.JSONDecodeError as e:
        return make_result(
            'FAIL', 'D4',
            f'{settings_path_str} is not valid JSON ({e.msg} line {e.lineno})',
            fix='restore from backup or rerun ~/.isparto/install.sh --upgrade',
        )

    hook_cmds = list(_collect_hook_commands(data))
    if not hook_cmds:
        return make_result(
            'WARN', 'D4',
            f'{settings_path_str} has no hooks registered',
            fix='run ~/.isparto/install.sh to register Process Observer hooks',
        )

    isparto_paths = []
    for cmd in hook_cmds:
        isparto_paths.extend(_extract_isparto_paths(cmd))

    if not isparto_paths:
        return make_result(
            'WARN', 'D4',
            'hooks registered but none reference ~/.isparto/',
            fix='verify install.sh ran successfully',
        )

    broken = []
    for p in isparto_paths:
        if not os.path.isfile(p):
            broken.append(f'{p} (missing)')
        elif not os.access(p, os.X_OK):
            broken.append(f'{p} (not executable)')

    if broken:
        preview = broken[0]
        more = f' (+{len(broken) - 1} more)' if len(broken) > 1 else ''
        return make_result(
            'FAIL', 'D4',
            f'{len(broken)} of {len(isparto_paths)} hook path(s) broken: {preview}{more}',
            fix='~/.isparto/install.sh --upgrade',
        )

    return make_result(
        'PASS', 'D4',
        f'{len(isparto_paths)} hook path(s) verified under ~/.isparto/',
    )


BLOCKING_MARKER = '\U0001f6a8 BLOCKING: Next Wave requires NEW SESSION'
BLOCKING_ACK_PREFIX = '> '


def _is_standalone_blocking_line(line):
    """True when the line IS the marker (optional surrounding whitespace)
    — not a prose mention where the marker literal appears inside
    backticks / quotes / paragraph text. Prevents D5 false positives on
    Wave-internal prose that references the marker by its literal form.
    """
    stripped = line.strip()
    return stripped == BLOCKING_MARKER


def _scan_unacknowledged_blocking(plan_md_path):
    """Return the 1-based line number of the MOST RECENT standalone
    BLOCKING marker in plan.md IF its next non-empty line is not a
    blockquote acknowledgement (starts with '> '); otherwise None.

    Only the last (highest-line-number) marker is relevant — /start-working
    acknowledges one marker per session, so older markers that predate the
    Step 0 acknowledgement protocol are historical artifacts, not active
    state. D5's semantic question is "do I need a new session right now?"
    which depends solely on the latest marker.
    """
    try:
        text = plan_md_path.read_text(encoding='utf-8', errors='replace')
    except OSError:
        return None
    lines = text.splitlines()
    last_marker_idx = None
    for idx, line in enumerate(lines):
        if _is_standalone_blocking_line(line):
            last_marker_idx = idx
    if last_marker_idx is None:
        return []
    j = last_marker_idx + 1
    while j < len(lines) and lines[j].strip() == '':
        j += 1
    if j >= len(lines):
        return [last_marker_idx + 1]
    if not lines[j].startswith(BLOCKING_ACK_PREFIX):
        return [last_marker_idx + 1]
    return []


def check_d5():
    pwd = os.environ.get('PWD_SNAPSHOT', '').strip()
    if not pwd:
        return make_result(
            'WARN', 'D5',
            'cannot determine current directory',
            fix='cd into an iSparto repo',
        )

    claude_md = Path(pwd) / 'CLAUDE.md'
    plan_md = Path(pwd) / 'docs' / 'plan.md'

    if not (claude_md.is_file() and plan_md.is_file()):
        return make_result(
            'WARN', 'D5',
            'not inside an iSparto repo (CLAUDE.md or docs/plan.md missing)',
            fix='cd into an iSparto repo',
        )

    unacked = _scan_unacknowledged_blocking(plan_md)
    if unacked is None:
        return make_result(
            'WARN', 'D5',
            'cannot read docs/plan.md',
            fix='check file permissions',
        )

    if unacked:
        return make_result(
            'WARN', 'D5',
            f'latest BLOCKING marker in docs/plan.md line {unacked[0]} is unacknowledged',
            fix='run /start-working to acknowledge or start a new session',
        )

    return make_result(
        'PASS', 'D5',
        'iSparto repo markers present; no unacknowledged BLOCKING markers',
    )


SERVICE_TIER_ALLOWED = {'fast', 'flex'}
# Matches: service_tier = "fast"   |   service_tier='flex'   |   service_tier = fast
# Captures the unquoted token. TOML strings use double or single quotes.
SERVICE_TIER_LINE = re.compile(
    r'^\s*service_tier\s*=\s*(?:"([^"]*)"|\'([^\']*)\'|([^\s#]+))\s*(?:#.*)?$'
)


def _parse_service_tier(text):
    """Return (found, value). value is None if the line is absent."""
    # We intentionally do a lightweight line-scan rather than requiring a
    # TOML parser dependency. The key is top-level in install defaults.
    for line in text.splitlines():
        stripped = line.lstrip()
        if not stripped.startswith('service_tier'):
            continue
        m = SERVICE_TIER_LINE.match(line)
        if not m:
            continue
        val = m.group(1) or m.group(2) or m.group(3) or ''
        return True, val
    return False, None


def check_d6():
    config_path = os.environ.get('CODEX_CONFIG_PATH', '').strip()
    exists_flag = os.environ.get('CODEX_CONFIG_EXISTS', '0').strip()

    if exists_flag != '1':
        return make_result(
            'WARN', 'D6',
            f'{config_path} not present',
            fix='codex will use default settings',
        )

    try:
        text = Path(config_path).read_text(encoding='utf-8', errors='replace')
    except OSError as e:
        return make_result(
            'FAIL', 'D6',
            f'cannot read {config_path}: {e}',
            fix='check file permissions',
        )

    found, value = _parse_service_tier(text)
    if not found:
        return make_result(
            'PASS', 'D6',
            f'{config_path} OK (service_tier unset, default applies)',
        )

    if value in SERVICE_TIER_ALLOWED:
        return make_result(
            'PASS', 'D6',
            f'{config_path} OK (service_tier="{value}")',
        )

    return make_result(
        'FAIL', 'D6',
        f'{config_path} has invalid service_tier="{value}"',
        fix='set to "fast" or "flex" or remove the line',
    )


def check_d7():
    pwd = os.environ.get('PWD_SNAPSHOT', '').strip()
    version_raw = os.environ.get('VERSION_FILE_CONTENT', '').strip()
    highest_tag = os.environ.get('HIGHEST_TAG', '').strip()

    if not pwd:
        return make_result(
            'WARN', 'D7',
            'cannot determine current directory',
            fix='run from iSparto repo root',
        )

    version_file = Path(pwd) / 'VERSION'
    if not version_file.is_file() or not version_raw:
        return make_result(
            'WARN', 'D7',
            'VERSION file not present',
            fix='run from iSparto repo root',
        )

    version_tuple = parse_version_tuple(version_raw)
    if version_tuple is None:
        return make_result(
            'FAIL', 'D7',
            f'VERSION file content unparseable ({version_raw!r})',
            fix='restore VERSION file',
        )

    if not highest_tag:
        return make_result(
            'WARN', 'D7',
            f'VERSION={version_raw} but no git v* tags found',
            fix='run from iSparto repo root or fetch tags: git fetch --tags',
        )

    tag_tuple = parse_version_tuple(highest_tag)
    if tag_tuple is None:
        return make_result(
            'WARN', 'D7',
            f'VERSION={version_raw} but highest tag {highest_tag!r} unparseable',
            fix='verify git tag naming convention',
        )

    order = cmp_version(version_tuple, tag_tuple)
    if order == 0:
        return make_result(
            'PASS', 'D7',
            f'VERSION={version_raw} matches highest tag {highest_tag}',
        )
    if order > 0:
        return make_result(
            'WARN', 'D7',
            f'VERSION={version_raw} ahead of highest tag {highest_tag} (merged-not-released)',
            fix='release pending — run /release patch when observation period is complete',
        )
    return make_result(
        'FAIL', 'D7',
        f'VERSION={version_raw} behind highest tag {highest_tag}',
        fix='git fetch && git pull',
    )


# ---------------------------------------------------------------------------
# Real run
# ---------------------------------------------------------------------------

def run_all():
    results = []
    for cid in CHECK_ORDER:
        fn = globals()[f'check_{cid.lower()}']
        try:
            results.append(fn())
        except Exception as e:  # noqa: BLE001 — any check bug must exit 2
            print(
                f'ERROR: internal failure in check {cid}: {type(e).__name__}: {e}',
                file=sys.stderr,
            )
            return None
    return results


# ---------------------------------------------------------------------------
# Self-test fixtures — validate the output-format + summary + exit-code
# pipeline using hardcoded result arrays. Does NOT touch real system state.
# ---------------------------------------------------------------------------

def _fixture_all_pass():
    return [
        make_result('PASS', 'D1', 'tmux 3.6a found at /opt/homebrew/bin/tmux'),
        make_result('PASS', 'D2', 'codex-cli 0.121.0 at /opt/homebrew/bin/codex'),
        make_result('PASS', 'D3', '2.1.114 (Claude Code) at /usr/local/bin/claude'),
        make_result('PASS', 'D4', '1 hook path(s) verified under ~/.isparto/'),
        make_result('PASS', 'D5', 'iSparto repo markers present; no unacknowledged BLOCKING markers'),
        make_result('PASS', 'D6', '~/.codex/config.toml OK (service_tier="fast")'),
        make_result('PASS', 'D7', 'VERSION=0.7.8 matches highest tag v0.7.8'),
    ]


def _fixture_two_warn():
    return [
        make_result('PASS', 'D1', 'tmux 3.6a found at /opt/homebrew/bin/tmux'),
        make_result('PASS', 'D2', 'codex-cli 0.121.0 at /opt/homebrew/bin/codex'),
        make_result('PASS', 'D3', '2.1.114 (Claude Code) at /usr/local/bin/claude'),
        make_result('PASS', 'D4', '1 hook path(s) verified under ~/.isparto/'),
        make_result(
            'WARN', 'D5',
            '1 unacknowledged BLOCKING marker(s) in docs/plan.md: line 748',
            fix='run /start-working to acknowledge or start a new session',
        ),
        make_result('PASS', 'D6', '~/.codex/config.toml OK (service_tier="fast")'),
        make_result(
            'WARN', 'D7',
            'VERSION=0.8.0 ahead of highest tag v0.7.8 (merged-not-released)',
            fix='release pending — run /release patch when observation period is complete',
        ),
    ]


def _fixture_one_fail():
    return [
        make_result('PASS', 'D1', 'tmux 3.6a found at /opt/homebrew/bin/tmux'),
        make_result(
            'FAIL', 'D2',
            'codex not found on PATH',
            fix='install from https://github.com/openai/codex',
        ),
        make_result('PASS', 'D3', '2.1.114 (Claude Code) at /usr/local/bin/claude'),
        make_result('PASS', 'D4', '1 hook path(s) verified under ~/.isparto/'),
        make_result('PASS', 'D5', 'iSparto repo markers present; no unacknowledged BLOCKING markers'),
        make_result('PASS', 'D6', '~/.codex/config.toml OK (service_tier="fast")'),
        make_result('PASS', 'D7', 'VERSION=0.7.8 matches highest tag v0.7.8'),
    ]


def run_self_test():
    fixtures = [
        ('all-pass', _fixture_all_pass(), (7, 0, 0), 0),
        ('two-warn', _fixture_two_warn(), (5, 2, 0), 0),
        ('one-fail', _fixture_one_fail(), (6, 0, 1), 1),
    ]

    failures = []
    for name, results, expected_counts, expected_exit in fixtures:
        # Verify structure + rendering without emitting the colored output
        # to keep self-test output compact. We still call emit_results so
        # the real code path is exercised, but it's followed by an
        # assertion line summarising the check.
        print(f'--- fixture: {name} ---')
        emit_results(results)

        n_pass = sum(1 for r in results if r['status'] == 'PASS')
        n_warn = sum(1 for r in results if r['status'] == 'WARN')
        n_fail = sum(1 for r in results if r['status'] == 'FAIL')
        got = (n_pass, n_warn, n_fail)

        if got != expected_counts:
            failures.append(
                f'fixture {name!r}: counts mismatch (got {got}, expected {expected_counts})'
            )

        exit_from_fail = 1 if n_fail > 0 else 0
        if exit_from_fail != expected_exit:
            failures.append(
                f'fixture {name!r}: exit code mismatch '
                f'(got {exit_from_fail}, expected {expected_exit})'
            )

        # Verify every line renders without throwing and contains the
        # expected prefix tokens.
        for r in results:
            line = format_line(r)
            prefix_token = f'[{r["status"]}]'
            if prefix_token not in line:
                failures.append(
                    f'fixture {name!r}: missing {prefix_token} in rendered line for {r["id"]}'
                )
            if r['status'] != 'PASS':
                if not r.get('fix'):
                    failures.append(
                        f'fixture {name!r}: {r["id"]} has status {r["status"]} but no fix hint'
                    )
                elif '(fix:' not in line:
                    failures.append(
                        f'fixture {name!r}: {r["id"]} rendered line missing "(fix:" suffix'
                    )
            else:
                if '(fix:' in line:
                    failures.append(
                        f'fixture {name!r}: {r["id"]} is PASS but rendered line contains "(fix:"'
                    )
        print()

    if failures:
        for msg in failures:
            print(f'FAIL: {msg}', file=sys.stderr)
        print(
            f'\n{RED}FAILED{NC}: doctor-check.sh --self-test '
            f'({len(failures)} issue(s))',
            file=sys.stderr,
        )
        return 1

    print(f'{GREEN}PASSED{NC}: doctor-check.sh --self-test (3/3 fixtures OK)')
    return 0


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

USAGE = """\
doctor-check.sh — iSparto environment diagnostic scanner

Usage:
  bash scripts/doctor-check.sh             run all 7 checks (D1..D7)
  bash scripts/doctor-check.sh --self-test run synthetic fixtures only
  bash scripts/doctor-check.sh --help      print this message

Exit codes:
  0 — zero FAIL
  1 — one or more FAIL
  2 — internal script error
"""


def main():
    args = sys.argv[1:]
    for a in args:
        if a not in ('--self-test', '--help', '-h'):
            print(f'ERROR: unknown argument: {a}', file=sys.stderr)
            print(USAGE, file=sys.stderr)
            sys.exit(2)

    if '--help' in args or '-h' in args:
        print(USAGE)
        sys.exit(0)

    if '--self-test' in args:
        sys.exit(run_self_test())

    results = run_all()
    if results is None:
        sys.exit(2)

    emit_results(results)
    n_fail = sum(1 for r in results if r['status'] == 'FAIL')
    sys.exit(1 if n_fail > 0 else 0)


main()
PYEOF

EXIT=$?
exit $EXIT
