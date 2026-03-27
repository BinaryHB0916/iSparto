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

# ── Platform check ─────────────────────────────────────────
if [ "$(uname)" != "Darwin" ]; then
    printf "${YELLOW}Warning:${NC} iSparto is designed for macOS. Agent Team mode requires iTerm2.\n"
    printf "  Solo + Codex mode may work but is untested on this platform.\n"
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
            INSTALL_VERSION=$(cat "$SCRIPT_DIR/VERSION")
        fi
    fi
fi

if ! $_use_local_source; then
    # Running via bootstrap.sh, or from ISPARTO_HOME (legacy git-clone) — download release
    if [ -z "$INSTALL_VERSION" ]; then
        # Auto-resolve latest version from GitHub Releases
        INSTALL_VERSION=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null \
            | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
    fi
    if [ -z "$INSTALL_VERSION" ]; then
        echo "Error: Could not determine version. Use bootstrap.sh to install:" >&2
        echo "  curl -fsSL https://raw.githubusercontent.com/$REPO/main/bootstrap.sh | bash" >&2
        exit 1
    fi
    if $UPGRADE && [ -f "$ISPARTO_HOME/VERSION" ] && [ "$(cat "$ISPARTO_HOME/VERSION")" = "$INSTALL_VERSION" ]; then
        echo ""
        printf "  ${GREEN}✓${NC} Already up to date (v$INSTALL_VERSION)\n"
        echo ""
        exit 0
    fi

    TAG="v${INSTALL_VERSION}"
    TARBALL_URL="https://github.com/$REPO/archive/refs/tags/$TAG.tar.gz"

    echo "Downloading iSparto $INSTALL_VERSION..."
    if $DRY_RUN; then
        printf "  ${BLUE}[dry-run]${NC} Would download release $TAG\n"
        # For dry-run, we need an existing SCRIPT_DIR to preview files
        if [ -d "$ISPARTO_HOME" ] && { [ -f "$ISPARTO_HOME/VERSION" ] || [ -d "$ISPARTO_HOME/.git" ]; }; then
            # Use a temp extraction anyway so we can show accurate diffs
            TMPDIR_RELEASE=$(mktemp -d)
            trap 'rm -rf "$TMPDIR_RELEASE"' EXIT
            if curl -fsSL "$TARBALL_URL" -o "$TMPDIR_RELEASE/release.tar.gz" 2>/dev/null; then
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
        TMPDIR_RELEASE=$(mktemp -d)
        trap 'rm -rf "$TMPDIR_RELEASE"' EXIT
        curl -fsSL "$TARBALL_URL" -o "$TMPDIR_RELEASE/release.tar.gz" || {
            printf "  ${RED}Error:${NC} Failed to download release $TAG\n" >&2
            exit 1
        }
        tar -xzf "$TMPDIR_RELEASE/release.tar.gz" -C "$TMPDIR_RELEASE"
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
    OLD_VERSION=$(cat "$ISPARTO_HOME/VERSION")
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

# 2. Claude Code
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

# 3. Codex CLI
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

# 4. Codex Login
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
    printf "  ${GREEN}✓${NC} Dependencies OK (${_node_label}, Claude Code, Codex)\n"
fi

# ── 5. Copy config to $HOME/.claude/ ────────────────────────────

if ! $DRY_RUN; then
    [ ! -d "$HOME/.claude/commands" ] && mkdir -p "$HOME/.claude/commands"
    [ ! -d "$HOME/.claude/templates" ] && mkdir -p "$HOME/.claude/templates"
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

if $DRY_RUN; then
    if claude mcp list -s user 2>/dev/null | grep -q codex-reviewer; then
        printf "  ${GREEN}✓${NC} Codex MCP Server OK\n"
    else
        printf "  ${BLUE}[dry-run]${NC} Would register Codex MCP Server globally\n"
    fi
else
    if claude mcp add codex-reviewer -s user -- npx -y codex-mcp-server 2>/dev/null; then
        printf "  ${GREEN}✓${NC} Codex MCP Server registered\n"
    else
        # Already registered — only mention on fresh install
        if [ -z "$OLD_VERSION" ]; then
            printf "  ${GREEN}✓${NC} Codex MCP Server OK\n"
        fi
    fi
fi

# ── Patch project-level settings (hooks registration) ────────
# If we're inside a project directory (has CLAUDE.md), ensure Process Observer
# hooks are registered in .claude/settings.json. This covers projects that were
# init'd before Process Observer existed.

_project_settings=".claude/settings.json"
if [ -f "CLAUDE.md" ] && ! $DRY_RUN; then
    mkdir -p .claude
    # Use Python (available on macOS) for reliable JSON merge
    # Prints "PATCHED" if modified, empty if already registered, "ERROR:..." on failure
    if ! command -v python3 &>/dev/null; then
        printf "  ${YELLOW}→${NC} python3 not found — skipped project hooks registration\n"
        printf "    Add Process Observer hooks to .claude/settings.json manually or run /migrate\n"
    else
        _patch_result=$(python3 -c "
import json, sys, os

path = '$_project_settings'
hook_cmd = 'bash $HOME/.isparto/hooks/process-observer/scripts/pre-tool-check.sh'
required_matchers = ['Bash', 'Edit', 'Write', 'mcp__codex-reviewer__codex']

try:
    if os.path.exists(path):
        with open(path) as f:
            settings = json.load(f)
    else:
        settings = {}
except Exception as e:
    print('ERROR: ' + str(e))
    sys.exit(0)

changed = False

hooks = settings.get('hooks')
if not isinstance(hooks, dict):
    hooks = {}
    settings['hooks'] = hooks
    changed = True

pre_tool_use = hooks.get('PreToolUse')
if not isinstance(pre_tool_use, list):
    pre_tool_use = []
    hooks['PreToolUse'] = pre_tool_use
    changed = True

for matcher in required_matchers:
    matched_entry = None
    for entry in pre_tool_use:
        if isinstance(entry, dict) and entry.get('matcher') == matcher:
            matched_entry = entry
            break

    if matched_entry is None:
        pre_tool_use.append({
            'matcher': matcher,
            'hooks': [{
                'type': 'command',
                'command': hook_cmd
            }]
        })
        changed = True
        continue

    entry_hooks = matched_entry.get('hooks')
    if not isinstance(entry_hooks, list):
        entry_hooks = []
        matched_entry['hooks'] = entry_hooks
        changed = True

    has_hook_cmd = any(
        isinstance(h, dict) and h.get('command') == hook_cmd
        for h in entry_hooks
    )
    if not has_hook_cmd:
        entry_hooks.append({
            'type': 'command',
            'command': hook_cmd
        })
        changed = True

if not changed:
    sys.exit(0)

with open(path, 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')

print('PATCHED')
" 2>&1 || true)
        if [ "$_patch_result" = "PATCHED" ]; then
            printf "  ${GREEN}✓${NC} Process Observer hooks registered in project settings\n"
        elif echo "$_patch_result" | grep -q "^ERROR:"; then
            printf "  ${YELLOW}→${NC} Could not patch .claude/settings.json: ${_patch_result#ERROR: }\n"
            printf "    Add Process Observer hooks manually or run /migrate\n"
        fi
    fi
elif [ -f "CLAUDE.md" ] && $DRY_RUN; then
    _needs_project_hook_patch=false
    if [ ! -f "$_project_settings" ]; then
        _needs_project_hook_patch=true
    elif ! grep -q "pre-tool-check.sh" "$_project_settings" 2>/dev/null; then
        _needs_project_hook_patch=true
    else
        for _matcher in "Bash" "Edit" "Write" "mcp__codex-reviewer__codex"; do
            if ! grep -q "\"matcher\"[[:space:]]*:[[:space:]]*\"$_matcher\"" "$_project_settings" 2>/dev/null; then
                _needs_project_hook_patch=true
                break
            fi
        done
    fi
    if $_needs_project_hook_patch; then
        printf "  ${BLUE}[dry-run]${NC} Would register Process Observer hooks in project settings\n"
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
