#!/bin/bash
# iSparto Installer — installs commands, templates, and tools to ~/.claude/
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
BACKUP_DIR="$ISPARTO_HOME/backup"
MANIFEST="$BACKUP_DIR/manifest.txt"
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
                echo "Try: rm -rf ~/.isparto && reinstall with:"
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
    echo "  iSparto Upgrader (DRY RUN — no changes will be made)"
elif $UPGRADE; then
    echo "  iSparto Upgrader"
elif $DRY_RUN; then
    echo "  iSparto Installer (DRY RUN — no changes will be made)"
else
    echo "  iSparto Installer"
fi
echo "  ─────────────────"
echo ""

# ── Detect need for migration (defer actual cleanup until after file copy) ──

NEEDS_MIGRATION=false
if [ -d "$ISPARTO_HOME/.git" ]; then
    NEEDS_MIGRATION=true
    if $DRY_RUN; then
        printf "  ${BLUE}[dry-run]${NC} Would migrate from git-clone to release-based install\n"
    fi
fi

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
        echo ""
        echo "  What's new in $NEW_VERSION:"
        sed -n "/^## \[$NEW_VERSION\]/,/^## \[/p" "$SCRIPT_DIR/CHANGELOG.md" | sed '$d' | sed 's/^/  /'
        echo ""
    fi
elif [ -z "$OLD_VERSION" ] && [ -n "$NEW_VERSION" ]; then
    if $DRY_RUN; then
        printf "  ${BLUE}[dry-run]${NC} Version: $NEW_VERSION\n"
    else
        printf "  ${GREEN}*${NC} Version: $NEW_VERSION\n"
    fi
fi

# ── Install lib/snapshot.sh to ~/.isparto/lib/ ────────────

if ! $DRY_RUN; then
    mkdir -p "$ISPARTO_HOME/lib"
    cp "$SCRIPT_DIR/lib/snapshot.sh" "$ISPARTO_HOME/lib/snapshot.sh"
    chmod +x "$ISPARTO_HOME/lib/snapshot.sh"
fi

# ── Install local stub (isparto.sh) ──────────────────────

if ! $DRY_RUN; then
    mkdir -p "$ISPARTO_HOME/bin"
    cp "$SCRIPT_DIR/isparto.sh" "$ISPARTO_HOME/bin/isparto.sh"
    chmod +x "$ISPARTO_HOME/bin/isparto.sh"
    # Backward compat: ~/.isparto/install.sh -> bin/isparto.sh
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
    printf "  ${GREEN}✓${NC} Snapshot created: $SNAPSHOT_ID\n"
fi

# ── Legacy backup (kept for backward compatibility) ────────
# Key invariant: the backup directory preserves the user's ORIGINAL files
# from before iSparto was ever installed. Re-installs (updates) must NOT
# overwrite these originals. We only back up a file if no backup exists yet.

if ! $DRY_RUN; then
    mkdir -p "$BACKUP_DIR"
    # Do NOT clear manifest on re-install — append new entries only
    touch "$MANIFEST"
fi

# Helper: compute backup filename for a given path
backup_name_for() {
    echo "$1" | sed 's|[/ ]|__|g'
}

# Helper: record an action in the manifest and back up if needed
record() {
    local action="$1"  # created | overwritten | mkdir | mcp | npm
    local path="$2"
    if ! $DRY_RUN; then
        # Avoid duplicate manifest entries
        if grep -qF "${action}|${path}" "$MANIFEST" 2>/dev/null; then
            return
        fi
        echo "${action}|${path}" >> "$MANIFEST"
        if [[ "$action" == "overwritten" && -f "$path" ]]; then
            local bname
            bname="$(backup_name_for "$path")"
            # Only back up if we don't already have the original
            if [ ! -f "$BACKUP_DIR/$bname" ]; then
                cp "$path" "$BACKUP_DIR/$bname"
            fi
        fi
    fi
}

# ── 1. Node.js ──────────────────────────────────────────────

echo "Checking Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_VERSION" -ge 18 ]; then
        printf "  ${GREEN}✓${NC} Node.js $(node -v)\n"
    else
        printf "  ${RED}✘${NC} Node.js $(node -v) — requires 18+\n"
        echo "  Install from https://nodejs.org"
        exit 1
    fi
else
    printf "  ${RED}✘${NC} Node.js not found\n"
    echo "  Install 18+ from https://nodejs.org"
    exit 1
fi

# ── 2. Claude Code ──────────────────────────────────────────

echo "Checking Claude Code..."
if command -v claude &> /dev/null; then
    printf "  ${GREEN}✓${NC} Claude Code installed\n"
else
    if $DRY_RUN; then
        printf "  ${BLUE}[dry-run]${NC} Would install Claude Code\n"
    else
        printf "  ${YELLOW}→${NC} Installing Claude Code...\n"
        npm install -g @anthropic-ai/claude-code
        record npm "@anthropic-ai/claude-code"
        printf "  ${GREEN}✓${NC} Claude Code installed\n"
    fi
fi

# ── 3. Codex CLI ────────────────────────────────────────────

echo "Checking Codex CLI..."
if command -v codex &> /dev/null; then
    printf "  ${GREEN}✓${NC} Codex CLI installed\n"
else
    if $DRY_RUN; then
        printf "  ${BLUE}[dry-run]${NC} Would install Codex CLI\n"
    else
        printf "  ${YELLOW}→${NC} Installing Codex CLI...\n"
        npm install -g @openai/codex
        record npm "@openai/codex"
        printf "  ${GREEN}✓${NC} Codex CLI installed\n"
    fi
fi

# ── 4. Codex Login ──────────────────────────────────────────

echo "Checking Codex login..."
if command -v codex &> /dev/null && codex login status &> /dev/null; then
    printf "  ${GREEN}✓${NC} Codex logged in\n"
else
    if $DRY_RUN; then
        printf "  ${BLUE}[dry-run]${NC} Would run codex login\n"
    else
        printf "  ${YELLOW}→${NC} Codex not logged in. Running codex login...\n"
        codex login
    fi
fi

# ── 5. Copy config to ~/.claude/ ────────────────────────────

echo "Installing global commands & templates to ~/.claude/ ..."
echo "  (project-level config will be created when you run /init-project or /migrate)"

if ! $DRY_RUN; then
    [ ! -d ~/.claude/commands ] && mkdir -p ~/.claude/commands && record mkdir "$HOME/.claude/commands"
    [ ! -d ~/.claude/templates ] && mkdir -p ~/.claude/templates && record mkdir "$HOME/.claude/templates"
fi

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
        if [ -f "$dst" ]; then
            record overwritten "$dst"
            cp "$src" "$dst"
            printf "  ${GREEN}✓${NC} Updated $label\n"
        else
            cp "$src" "$dst"
            record created "$dst"
            printf "  ${GREEN}✓${NC} Installed $label\n"
        fi
    fi
}

install_file "$SCRIPT_DIR/CLAUDE-TEMPLATE.md" ~/.claude/CLAUDE-TEMPLATE.md "~/.claude/CLAUDE-TEMPLATE.md"

for f in "$SCRIPT_DIR"/commands/*.md; do
    name=$(basename "$f")
    install_file "$f" ~/.claude/commands/"$name" "~/.claude/commands/$name"
done

for f in "$SCRIPT_DIR"/templates/*.md; do
    name=$(basename "$f")
    install_file "$f" ~/.claude/templates/"$name" "~/.claude/templates/$name"
done

# ── 6. Register Codex MCP Server (global) ───────────────────

echo "Registering Codex MCP Server (global)..."
if $DRY_RUN; then
    if claude mcp list -s user 2>/dev/null | grep -q codex-reviewer; then
        printf "  ${GREEN}✓${NC} Codex MCP Server already registered\n"
    else
        printf "  ${BLUE}[dry-run]${NC} Would register Codex MCP Server globally\n"
    fi
else
    if claude mcp add codex-reviewer -s user -- npx -y codex-mcp-server 2>/dev/null; then
        record mcp "codex-reviewer"
        printf "  ${GREEN}✓${NC} Codex MCP Server registered globally\n"
    else
        printf "  ${YELLOW}→${NC} MCP registration skipped (may already exist)\n"
    fi
fi

# ── Track installed version ──────────────────────────────────

if ! $DRY_RUN; then
    echo "$INSTALL_VERSION" > "$ISPARTO_HOME/VERSION"
fi

# ── Migrate: clean up old git-clone files (deferred until after copy) ──

if $NEEDS_MIGRATION && ! $DRY_RUN; then
    printf "  ${YELLOW}→${NC} Cleaning up old git-clone files...\n"
    rm -rf "$ISPARTO_HOME/.git"
    rm -rf "$ISPARTO_HOME/commands" "$ISPARTO_HOME/templates" "$ISPARTO_HOME/docs"
    rm -rf "$ISPARTO_HOME/assets" "$ISPARTO_HOME/.github"
    rm -f "$ISPARTO_HOME/README.md" "$ISPARTO_HOME/README.zh-CN.md"
    rm -f "$ISPARTO_HOME/CLAUDE.md" "$ISPARTO_HOME/CLAUDE-TEMPLATE.md"
    rm -f "$ISPARTO_HOME/CONTRIBUTING.md" "$ISPARTO_HOME/LICENSE"
    rm -f "$ISPARTO_HOME/CHANGELOG.md" "$ISPARTO_HOME/.gitignore"
    rm -f "$ISPARTO_HOME/.DS_Store" "$ISPARTO_HOME/settings.json"
    printf "  ${GREEN}✓${NC} Migrated to release-based install\n"
fi

# ── Done ────────────────────────────────────────────────────

echo ""
if $DRY_RUN; then
    printf "${GREEN}Dry run complete!${NC} No changes were made.\n"
    echo ""
    echo "Run without --dry-run to install:"
    echo ""
    echo "  curl -fsSL https://raw.githubusercontent.com/$REPO/main/bootstrap.sh | bash"
else
    if [ -n "$NEW_VERSION" ]; then
        printf "${GREEN}Done!${NC} iSparto $NEW_VERSION is ready.\n"
    else
        printf "${GREEN}Done!${NC} iSparto is ready.\n"
    fi
    printf "  Snapshot saved (use ~/.isparto/install.sh --uninstall to revert)\n"
    echo ""
    echo "Next step — launch Claude Code in your project directory:"
    echo ""
    echo "  claude --effort max"
    echo "  /init-project <description>      # new project"
    echo "  /migrate                         # existing project"
fi
echo ""
