#!/bin/bash
# iSparto Installer — installs commands, templates, and tools to $HOME/.claude/
# Invoked by bootstrap.sh (verified) or directly from a local repo clone.
#
# When run via bootstrap.sh, ISPARTO_INSTALL_VERSION is set.
# When run from a local repo, it reads VERSION from the repo directory.
set -e
shopt -s nullglob

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ── Helper: read_version_file ──────────────────────────────
# Read a VERSION file, strip all whitespace, validate semver-ish format.
# Usage: read_version_file <path_to_VERSION_file>
# On success: echoes the trimmed version to stdout, returns 0.
# On error  : writes a clear message to stderr, returns 1.
# Accepted format: MAJOR.MINOR.PATCH with optional -prerelease or +build tail.
read_version_file() {
    _rvf_path="$1"
    if [ ! -f "$_rvf_path" ]; then
        echo "install.sh: VERSION file not found at $_rvf_path" >&2
        return 1
    fi
    _rvf_raw=$(cat "$_rvf_path")
    _rvf_trimmed=$(printf '%s' "$_rvf_raw" | tr -d '[:space:]')
    # Portable semver-ish check via grep -E (POSIX ERE; works on macOS and Linux).
    if ! printf '%s' "$_rvf_trimmed" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+([-+][A-Za-z0-9.-]+)?$'; then
        echo "install.sh: VERSION file at $_rvf_path is malformed (got: '$_rvf_raw')" >&2
        return 1
    fi
    printf '%s\n' "$_rvf_trimmed"
    return 0
}

# ── Platform check ─────────────────────────────────────────
if [ "$(uname)" != "Darwin" ]; then
    printf "${YELLOW}Warning:${NC} iSparto is designed for macOS. Agent Team mode requires iTerm2.\n"
    printf "  Solo + Codex mode may work but is untested on this platform.\n"
fi

# ── tmux required since v0.8.0 ─────────────────────────────
# IR (Independent Reviewer) runtime moved from Claude Code sub-agent to
# `codex exec` invoked inside a tmux pane. tmux is now a hard dependency.
if ! command -v tmux >/dev/null 2>&1; then
    printf "${RED}Error:${NC} tmux is required since iSparto v0.8.0.\n" >&2
    printf "  The Independent Reviewer is invoked via 'codex exec' in a tmux pane.\n" >&2
    printf "  Install on macOS:  ${BLUE}brew install tmux${NC}\n" >&2
    exit 1
fi

ISPARTO_HOME="$HOME/.isparto"
REPO="BinaryHB0916/iSparto"

DRY_RUN=false
UPGRADE=false

for arg in "$@"; do
    case "$arg" in
        --dry-run)   DRY_RUN=true ;;
        --upgrade)   UPGRADE=true ;;
        --uninstall)
            # Delegate to the local stub if it exists
            if [ -x "$ISPARTO_HOME/bin/isparto.sh" ]; then
                exec "$ISPARTO_HOME/bin/isparto.sh" "$@"
            else
                echo "iSparto is not installed or uses an older version."
                echo "Try: rm -rf $HOME/.isparto && reinstall with:"
                echo "  curl -fsSL https://raw.githubusercontent.com/$REPO/main/bootstrap.sh | bash"
                exit 1
            fi
            ;;
    esac
done

# ══════════════════════════════════════════════════════════════
# Determine SCRIPT_DIR — where to find source files
# ══════════════════════════════════════════════════════════════

INSTALL_VERSION="${ISPARTO_INSTALL_VERSION:-}"

_use_local_source=false
if [ -f "$(dirname "$0")/commands/start-working.md" ] 2>/dev/null; then
    _candidate_dir="$(cd "$(dirname "$0")" && pwd)"
    _isparto_resolved="$(cd "$ISPARTO_HOME" 2>/dev/null && pwd || echo "")"
    if [ "$_candidate_dir" != "$_isparto_resolved" ]; then
        # Running from a local repo clone (development or manual install)
        _use_local_source=true
        SCRIPT_DIR="$_candidate_dir"
        if [ -z "$INSTALL_VERSION" ] && [ -f "$SCRIPT_DIR/VERSION" ]; then
            INSTALL_VERSION=$(read_version_file "$SCRIPT_DIR/VERSION") || exit 1
        fi
    fi
fi

if ! $_use_local_source; then
    # Running via bootstrap.sh, or from ISPARTO_HOME (legacy git-clone) — download release
    if [ -z "$INSTALL_VERSION" ]; then
        # Auto-resolve latest version from GitHub Releases
        INSTALL_VERSION=$(curl -fsSL --connect-timeout 10 --max-time 30 "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null \
            | grep '"tag_name"' | sed -E 's/.*"v?([0-9][^"]*)".*/\1/')
    fi
    if [ -z "$INSTALL_VERSION" ]; then
        echo "Error: Could not determine version. Use bootstrap.sh to install:" >&2
        echo "  curl -fsSL https://raw.githubusercontent.com/$REPO/main/bootstrap.sh | bash" >&2
        exit 1
    fi
    if $UPGRADE && [ -f "$ISPARTO_HOME/VERSION" ]; then
        # Only short-circuit when the installed VERSION is valid AND matches.
        # A malformed installed VERSION falls through to reinstall, which is safer
        # than silently exiting.
        if _installed_ver=$(read_version_file "$ISPARTO_HOME/VERSION" 2>/dev/null) \
           && [ "$_installed_ver" = "$INSTALL_VERSION" ]; then
            echo ""
            printf "  ${GREEN}✓${NC} Already up to date (v$INSTALL_VERSION)\n"
            echo ""
            exit 0
        fi
    fi

    TAG="v${INSTALL_VERSION}"
    TARBALL_URL="https://github.com/$REPO/archive/refs/tags/$TAG.tar.gz"

    echo "Downloading iSparto $INSTALL_VERSION..."
    if $DRY_RUN; then
        printf "  ${BLUE}[dry-run]${NC} Would download release $TAG\n"
        # For dry-run, we need an existing SCRIPT_DIR to preview files
        if [ -d "$ISPARTO_HOME" ] && { [ -f "$ISPARTO_HOME/VERSION" ] || [ -d "$ISPARTO_HOME/.git" ]; }; then
            # Use a temp extraction anyway so we can show accurate diffs
            TMPDIR_RELEASE=$(mktemp -d) || { printf "  ${RED}Error:${NC} Failed to create temp directory\n" >&2; exit 1; }
            trap 'rm -rf "$TMPDIR_RELEASE"' EXIT
            if curl -fsSL --connect-timeout 10 --max-time 60 "$TARBALL_URL" -o "$TMPDIR_RELEASE/release.tar.gz" 2>/dev/null; then
                tar -xzf "$TMPDIR_RELEASE/release.tar.gz" -C "$TMPDIR_RELEASE" 2>/dev/null
                SCRIPT_DIR="$TMPDIR_RELEASE/iSparto-${INSTALL_VERSION}"
            else
                printf "  ${YELLOW}→${NC} Could not download tarball for dry-run preview.\n"
                exit 0
            fi
        else
            printf "  ${YELLOW}→${NC} No existing installation. Run without --dry-run to install.\n"
            exit 0
        fi
    else
        TMPDIR_RELEASE=$(mktemp -d) || { printf "  ${RED}Error:${NC} Failed to create temp directory\n" >&2; exit 1; }
        trap 'rm -rf "$TMPDIR_RELEASE"' EXIT
        curl -fsSL --connect-timeout 10 --max-time 60 "$TARBALL_URL" -o "$TMPDIR_RELEASE/release.tar.gz" || {
            printf "  ${RED}Error:${NC} Failed to download release $TAG\n" >&2
            exit 1
        }
        tar -xzf "$TMPDIR_RELEASE/release.tar.gz" -C "$TMPDIR_RELEASE" || {
            printf "  ${RED}Error:${NC} Failed to extract release archive\n" >&2
            exit 1
        }
        SCRIPT_DIR="$TMPDIR_RELEASE/iSparto-${INSTALL_VERSION}"
        printf "  ${GREEN}✓${NC} Downloaded iSparto $INSTALL_VERSION\n"
    fi
fi

# ══════════════════════════════════════════════════════════════
# Install mode
# ══════════════════════════════════════════════════════════════

echo ""
if $UPGRADE && $DRY_RUN; then
    echo "  iSparto Upgrader (DRY RUN)"
elif ! $UPGRADE && $DRY_RUN; then
    echo "  iSparto Installer (DRY RUN — no changes will be made)"
    echo "  ─────────────────"
elif ! $UPGRADE; then
    echo "  iSparto Installer"
    echo "  ─────────────────"
fi
echo ""

# ── Detect upgrade and show what's new ─────────────────────

OLD_VERSION=""
if [ -f "$ISPARTO_HOME/VERSION" ]; then
    # Tolerate a malformed installed VERSION here (stay empty and proceed as fresh install).
    OLD_VERSION=$(read_version_file "$ISPARTO_HOME/VERSION" 2>/dev/null || true)
fi
NEW_VERSION="$INSTALL_VERSION"

if [ -n "$OLD_VERSION" ] && [ -n "$NEW_VERSION" ] && [ "$OLD_VERSION" != "$NEW_VERSION" ]; then
    if $DRY_RUN; then
        printf "  ${BLUE}[dry-run]${NC} Would upgrade: $OLD_VERSION -> $NEW_VERSION\n"
    else
        printf "  ${GREEN}*${NC} Upgrading: $OLD_VERSION -> $NEW_VERSION\n"
    fi
    if [ -f "$SCRIPT_DIR/CHANGELOG.md" ]; then
        # Show only Added items; summarize Changed/Fixed/Removed with counts
        _cl_block=$(sed -n "/^## \[$NEW_VERSION\]/,/^## \[/p" "$SCRIPT_DIR/CHANGELOG.md" | sed '$d')
        _added=$(echo "$_cl_block" | sed -n '/^### Added/,/^### /p' | sed '$d' | grep '^- ' || true)
        if [ -n "$_added" ]; then
            echo ""
            echo "  What's new:"
            echo "$_added" | sed 's/^/    /'
        fi
        _n_changed=$(echo "$_cl_block" | sed -n '/^### Changed/,/^### /{ /^### Changed/d; /^### /d; p; }' | grep -c '^- ' || true)
        _n_fixed=$(echo "$_cl_block" | sed -n '/^### Fixed/,/^### /{ /^### Fixed/d; /^### /d; p; }' | grep -c '^- ' || true)
        _n_removed=$(echo "$_cl_block" | sed -n '/^### Removed/,/^### /{ /^### Removed/d; /^### /d; p; }' | grep -c '^- ' || true)
        _summary_parts=()
        [ "$_n_changed" -gt 0 ] 2>/dev/null && _summary_parts+=("${_n_changed} changed")
        [ "$_n_fixed" -gt 0 ] 2>/dev/null && _summary_parts+=("${_n_fixed} fixed")
        [ "$_n_removed" -gt 0 ] 2>/dev/null && _summary_parts+=("${_n_removed} removed")
        if [ ${#_summary_parts[@]} -gt 0 ]; then
            _IFS_BAK="$IFS"; IFS=", "; _summary="${_summary_parts[*]}"; IFS="$_IFS_BAK"
            printf "  … plus ${_summary} — full changelog:\n"
            printf "    https://github.com/$REPO/releases/tag/v$NEW_VERSION\n"
        fi
        echo ""
    fi
elif [ -z "$OLD_VERSION" ] && [ -n "$NEW_VERSION" ]; then
    if $DRY_RUN; then
        printf "  ${BLUE}[dry-run]${NC} Version: $NEW_VERSION\n"
    else
        printf "  ${GREEN}*${NC} Version: $NEW_VERSION\n"
    fi
fi

# ── Install lib/snapshot.sh to $HOME/.isparto/lib/ ────────────

if ! $DRY_RUN; then
    mkdir -p "$ISPARTO_HOME/lib"
    cp "$SCRIPT_DIR/lib/snapshot.sh" "$ISPARTO_HOME/lib/snapshot.sh"
    chmod +x "$ISPARTO_HOME/lib/snapshot.sh"
    cp "$SCRIPT_DIR/lib/patch-settings.py" "$ISPARTO_HOME/lib/patch-settings.py"
fi

# ── Install hooks/process-observer ───────────────────────

if ! $DRY_RUN; then
    mkdir -p "$ISPARTO_HOME/hooks/process-observer/scripts"
    mkdir -p "$ISPARTO_HOME/hooks/process-observer/rules"
    cp "$SCRIPT_DIR/hooks/process-observer/scripts/pre-tool-check.sh" \
       "$ISPARTO_HOME/hooks/process-observer/scripts/pre-tool-check.sh"
    chmod +x "$ISPARTO_HOME/hooks/process-observer/scripts/pre-tool-check.sh"
    cp "$SCRIPT_DIR/hooks/process-observer/rules/dangerous-operations.json" \
       "$ISPARTO_HOME/hooks/process-observer/rules/dangerous-operations.json"
    cp "$SCRIPT_DIR/hooks/process-observer/rules/workflow-rules.json" \
       "$ISPARTO_HOME/hooks/process-observer/rules/workflow-rules.json"
    cp "$SCRIPT_DIR/hooks/process-observer/scripts/pre-commit-security.sh" \
       "$ISPARTO_HOME/hooks/process-observer/scripts/pre-commit-security.sh"
    chmod +x "$ISPARTO_HOME/hooks/process-observer/scripts/pre-commit-security.sh"
    cp "$SCRIPT_DIR/hooks/process-observer/rules/security-patterns.json" \
       "$ISPARTO_HOME/hooks/process-observer/rules/security-patterns.json"
fi

# ── Install local stub (isparto.sh) ──────────────────────

if ! $DRY_RUN; then
    mkdir -p "$ISPARTO_HOME/bin"
    cp "$SCRIPT_DIR/isparto.sh" "$ISPARTO_HOME/bin/isparto.sh"
    chmod +x "$ISPARTO_HOME/bin/isparto.sh"
    # Backward compat: $HOME/.isparto/install.sh -> bin/isparto.sh
    ln -sf "$ISPARTO_HOME/bin/isparto.sh" "$ISPARTO_HOME/install.sh"
fi

# ── Snapshot: create pre-install snapshot ──────────────────

if ! $DRY_RUN; then
    SNAPSHOT_FILES=()
    SNAPSHOT_FILES+=("$HOME/.claude/CLAUDE-TEMPLATE.md")
    SNAPSHOT_FILES+=("$HOME/.claude/agents/process-observer-audit.md")
    SNAPSHOT_FILES+=("$HOME/.isparto/hooks/process-observer/scripts/pre-commit-security.sh")
    SNAPSHOT_FILES+=("$HOME/.isparto/hooks/process-observer/rules/security-patterns.json")
    for f in "$SCRIPT_DIR"/commands/*.md; do
        SNAPSHOT_FILES+=("$HOME/.claude/commands/$(basename "$f")")
    done
    for f in "$SCRIPT_DIR"/templates/*.md; do
        SNAPSHOT_FILES+=("$HOME/.claude/templates/$(basename "$f")")
    done
    SNAPSHOT_ID=$("$ISPARTO_HOME/lib/snapshot.sh" create install global "${SNAPSHOT_FILES[@]}")
    # Fresh install: show snapshot ID; upgrade: silent (mentioned in Done)
    if [ -z "$OLD_VERSION" ]; then
        printf "  ${GREEN}✓${NC} Snapshot created: $SNAPSHOT_ID\n"
    fi
fi

# ── Dependencies ─────────────────────────────────────────────
# On upgrade: collapse to one line when all pass.
# On fresh install: show each step for clarity.

_dep_ok=true   # track whether all deps pass silently

# 1. Node.js
_node_label=""
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_VERSION" -ge 18 ]; then
        _node_label="Node $(node -v | sed 's/v//')"
    else
        _dep_ok=false
        printf "  ${RED}✘${NC} Node.js $(node -v) — requires 18+\n"
        echo "  Install from https://nodejs.org"
        exit 1
    fi
else
    _dep_ok=false
    printf "  ${RED}✘${NC} Node.js not found\n"
    echo "  Install 18+ from https://nodejs.org"
    exit 1
fi

# 2. Python3 (required for Process Observer hooks registration)
if command -v python3 &> /dev/null; then
    _python_label="Python $(python3 --version 2>&1 | sed 's/Python //')"
else
    _dep_ok=false
    printf "  ${RED}✘${NC} python3 not found — required for Process Observer hooks\n"
    echo "  Install Python 3: https://www.python.org/downloads/"
    exit 1
fi

# 3. Claude Code (auto-install if missing)
if command -v claude &> /dev/null; then
    : # already installed
else
    _dep_ok=false
    if $DRY_RUN; then
        printf "  ${BLUE}[dry-run]${NC} Would install Claude Code\n"
    else
        printf "  ${YELLOW}→${NC} Installing Claude Code...\n"
        npm install -g @anthropic-ai/claude-code
        printf "  ${GREEN}✓${NC} Claude Code installed\n"
    fi
fi

# 4. Codex CLI (auto-install if missing)
if command -v codex &> /dev/null; then
    : # already installed
else
    _dep_ok=false
    if $DRY_RUN; then
        printf "  ${BLUE}[dry-run]${NC} Would install Codex CLI\n"
    else
        printf "  ${YELLOW}→${NC} Installing Codex CLI...\n"
        npm install -g @openai/codex
        printf "  ${GREEN}✓${NC} Codex CLI installed\n"
    fi
fi

# 5. Codex Login
if command -v codex &> /dev/null && codex login status &> /dev/null; then
    : # already logged in
else
    _dep_ok=false
    if $DRY_RUN; then
        printf "  ${BLUE}[dry-run]${NC} Would run codex login\n"
    else
        printf "  ${YELLOW}→${NC} Codex not logged in. Running codex login...\n"
        codex login
    fi
fi

# Summary line when all deps already satisfied
if $_dep_ok; then
    printf "  ${GREEN}✓${NC} Dependencies OK (${_node_label}, ${_python_label}, Claude Code, Codex)\n"
fi

# ── 5. Copy config to $HOME/.claude/ ────────────────────────────

if ! $DRY_RUN; then
    [ ! -d "$HOME/.claude/commands" ] && mkdir -p "$HOME/.claude/commands"
    [ ! -d "$HOME/.claude/templates" ] && mkdir -p "$HOME/.claude/templates"
    [ ! -d "$HOME/.claude/agents" ] && mkdir -p "$HOME/.claude/agents"
fi

_file_count=0

install_file() {
    local src="$1"
    local dst="$2"
    local label="$3"
    if $DRY_RUN; then
        if [ -f "$dst" ]; then
            if diff -q "$src" "$dst" &>/dev/null; then
                printf "  ${GREEN}✓${NC} $label (already up to date)\n"
            else
                printf "  ${BLUE}[dry-run]${NC} Would overwrite $label\n"
            fi
        else
            printf "  ${BLUE}[dry-run]${NC} Would install $label\n"
        fi
    else
        cp "$src" "$dst"
        _file_count=$((_file_count + 1))
        # Fresh install: show each file; upgrade: silent (summary below)
        if [ -z "$OLD_VERSION" ]; then
            printf "  ${GREEN}✓${NC} Installed $label\n"
        fi
    fi
}

if [ -z "$OLD_VERSION" ]; then
    echo "Installing global commands & templates to $HOME/.claude/ ..."
    echo "  (project-level config will be created when you run /init-project or /migrate)"
fi

install_file "$SCRIPT_DIR/CLAUDE-TEMPLATE.md" "$HOME/.claude/CLAUDE-TEMPLATE.md" "$HOME/.claude/CLAUDE-TEMPLATE.md"
install_file "$SCRIPT_DIR/agents/process-observer-audit.md" "$HOME/.claude/agents/process-observer-audit.md" "$HOME/.claude/agents/process-observer-audit.md"

for f in "$SCRIPT_DIR"/commands/*.md; do
    name=$(basename "$f")
    install_file "$f" "$HOME/.claude/commands/$name" "$HOME/.claude/commands/$name"
done

for f in "$SCRIPT_DIR"/templates/*.md; do
    name=$(basename "$f")
    install_file "$f" "$HOME/.claude/templates/$name" "$HOME/.claude/templates/$name"
done

# Upgrade: single summary line
if [ -n "$OLD_VERSION" ] && ! $DRY_RUN; then
    printf "  ${GREEN}✓${NC} ${_file_count} files updated (commands, templates, config)\n"
fi

# ── 6. Register Codex MCP Server (global) ───────────────────
#
# Note: existence checks below use `claude mcp get <name>` (exit 0 if present,
# 1 if missing) instead of the legacy `mcp list` + scope-filter + grep pattern.
# Claude Code silently removed the scope flag from `mcp list` around v1.0.58
# when the command was reworked to do live health probing; the legacy pattern
# would error with an unknown-option message and, with stderr muted, fall
# through to "not found" forever. `mcp get` is scope-agnostic, which matches
# our actual need (we only care whether the matcher will resolve, not which
# scope holds the server). `mcp add` and `mcp remove` still accept the scope
# flag and are unchanged. If `mcp get` itself ever breaks in a future Claude
# Code release, grep this repo for "claude mcp get" to find all sites.

if $DRY_RUN; then
    if claude mcp get codex-dev >/dev/null 2>&1; then
        printf "  ${GREEN}✓${NC} Codex MCP Server OK\n"
    elif claude mcp get codex-reviewer >/dev/null 2>&1; then
        printf "  ${BLUE}[dry-run]${NC} Would migrate MCP: codex-reviewer → codex-dev\n"
    else
        printf "  ${BLUE}[dry-run]${NC} Would register Codex MCP Server globally\n"
    fi
else
    # Migrate old name if present
    if claude mcp get codex-reviewer >/dev/null 2>&1; then
        claude mcp remove codex-reviewer -s user 2>/dev/null
    fi
    if claude mcp add codex-dev -s user -- npx -y codex-mcp-server 2>/dev/null; then
        if [ -n "$OLD_VERSION" ]; then
            printf "  ${GREEN}✓${NC} Migrated MCP: codex-reviewer → codex-dev\n"
        else
            printf "  ${GREEN}✓${NC} Codex MCP Server registered\n"
        fi
    else
        # Already registered — only mention on fresh install
        if [ -z "$OLD_VERSION" ]; then
            printf "  ${GREEN}✓${NC} Codex MCP Server OK\n"
        fi
    fi
fi

# ── Patch user-level settings (hooks registration) ──────────
# Register Process Observer Bash safety hook in user-level ~/.claude/settings.json.
# Bash rules (git dangerous ops, sensitive files, destructive deletes) are universal
# and benefit all projects. Workflow hooks (Edit/Write/Codex) are registered at
# project level by /init-project and /migrate.

_user_settings="$HOME/.claude/settings.json"
if ! $DRY_RUN; then
    mkdir -p "$HOME/.claude"
    # python3 already verified in Dependencies section
    _hook_cmd="bash $ISPARTO_HOME/hooks/process-observer/scripts/pre-tool-check.sh"
    _patch_result=$(python3 "$SCRIPT_DIR/lib/patch-settings.py" patch-user "$_user_settings" "$_hook_cmd" "Bash" 2>&1 || true)
    if [ "$_patch_result" = "PATCHED" ]; then
        printf "  ${GREEN}✓${NC} Process Observer Bash hook registered in user settings (~/.claude/settings.json)\n"
    elif echo "$_patch_result" | grep -q "^ERROR:"; then
        printf "  ${YELLOW}→${NC} Could not patch ~/.claude/settings.json: ${_patch_result#ERROR: }\n"
        printf "    Add Process Observer hooks to ~/.claude/settings.json manually\n"
    fi

    # Clean up project-level Bash hook residue (Bash is now at user level;
    # Edit/Write/Codex remain at project level — do not remove them)
    if [ -f ".claude/settings.json" ] && command -v python3 &>/dev/null; then
        _cleanup_result=$(python3 "$SCRIPT_DIR/lib/patch-settings.py" clean-project ".claude/settings.json" 2>&1 || true)
        if [ "$_cleanup_result" = "CLEANED" ]; then
            printf "  ${GREEN}✓${NC} Removed old project-level Bash hook (now in user settings)\n"
        fi
    fi
else
    # Dry-run mode
    _needs_user_hook_patch=false
    if [ ! -f "$_user_settings" ]; then
        _needs_user_hook_patch=true
    elif ! grep -q "pre-tool-check.sh" "$_user_settings" 2>/dev/null; then
        _needs_user_hook_patch=true
    else
        for _matcher in "Bash"; do
            if ! grep -q "\"matcher\"[[:space:]]*:[[:space:]]*\"$_matcher\"" "$_user_settings" 2>/dev/null; then
                _needs_user_hook_patch=true
                break
            fi
        done
    fi
    if $_needs_user_hook_patch; then
        printf "  ${BLUE}[dry-run]${NC} Would register Process Observer hooks in user settings (~/.claude/settings.json)\n"
    fi
    # Check for workflow matchers that would be cleaned from user level
    _needs_user_hook_cleanup=false
    if [ -f "$_user_settings" ]; then
        for _wf_matcher in "Edit" "Write" "mcp__codex-dev__codex" "mcp__codex-reviewer__codex"; do
            if grep -q "\"matcher\"[[:space:]]*:[[:space:]]*\"$_wf_matcher\"" "$_user_settings" 2>/dev/null; then
                _needs_user_hook_cleanup=true
                break
            fi
        done
    fi
    if $_needs_user_hook_cleanup; then
        printf "  ${BLUE}[dry-run]${NC} Would remove workflow hooks (Edit/Write/Codex) from user settings (moved to project level)\n"
    fi
fi

# ── Track installed version ──────────────────────────────────

if ! $DRY_RUN; then
    echo "$INSTALL_VERSION" > "$ISPARTO_HOME/VERSION"
fi

# ── Done ────────────────────────────────────────────────────

echo ""
if $DRY_RUN; then
    printf "${GREEN}Dry run complete!${NC} No changes were made.\n"
    echo ""
    echo "Run without --dry-run to install:"
    echo "  curl -fsSL https://raw.githubusercontent.com/$REPO/main/bootstrap.sh | bash"
else
    if [ -n "$NEW_VERSION" ]; then
        printf "${GREEN}Done!${NC} iSparto $NEW_VERSION is ready.\n"
    else
        printf "${GREEN}Done!${NC} iSparto is ready.\n"
    fi
    printf "  Rollback: $HOME/.isparto/install.sh --uninstall\n"
    # Fresh install: show next steps
    if [ -z "$OLD_VERSION" ]; then
        echo ""
        echo "Next step — launch Claude Code in your project directory:"
        echo ""
        echo "  claude --effort max"
        echo "  /init-project <description>      # new project"
        echo "  /migrate                         # existing project"
    fi
fi
echo ""
