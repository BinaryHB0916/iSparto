#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ISPARTO_HOME="$HOME/.isparto"
BACKUP_DIR="$ISPARTO_HOME/backup"
MANIFEST="$BACKUP_DIR/manifest.txt"

DRY_RUN=false
UNINSTALL=false
UPGRADE=false

for arg in "$@"; do
    case "$arg" in
        --dry-run)   DRY_RUN=true ;;
        --uninstall) UNINSTALL=true ;;
        --upgrade)   UPGRADE=true ;;
    esac
done

# ══════════════════════════════════════════════════════════════
# Uninstall mode
# ══════════════════════════════════════════════════════════════

if $UNINSTALL; then
    echo ""
    echo "  iSparto Uninstaller"
    echo "  ────────────────────"
    echo ""

    # Try new snapshot system first, fall back to legacy manifest
    SNAPSHOT_SCRIPT="$ISPARTO_HOME/lib/snapshot.sh"
    LATEST_SNAP=""
    if [ -x "$SNAPSHOT_SCRIPT" ]; then
        LATEST_SNAP=$("$SNAPSHOT_SCRIPT" list --type=install 2>/dev/null | tail -1 | awk '{print $1}')
    fi

    if [ -n "$LATEST_SNAP" ] && [ "$LATEST_SNAP" != "No" ] && [ "$LATEST_SNAP" != "ID" ]; then
        echo "  Restoring from snapshot: $LATEST_SNAP"
        "$SNAPSHOT_SCRIPT" restore "$LATEST_SNAP"

        # Snapshot doesn't handle MCP or npm — do those via legacy manifest
        if [ -f "$MANIFEST" ]; then
            while IFS='|' read -r action path; do
                case "$action" in
                    mcp)
                        if claude mcp remove codex-reviewer -s user 2>/dev/null; then
                            printf "  ${GREEN}✓${NC} Removed Codex MCP Server registration\n"
                        else
                            printf "  ${YELLOW}→${NC} MCP removal skipped (may not exist)\n"
                        fi
                        ;;
                    npm)
                        printf "  ${YELLOW}→${NC} Skipping $path (global npm package — remove manually with: npm uninstall -g $path)\n"
                        ;;
                esac
            done < "$MANIFEST"
        fi
    elif [ -f "$MANIFEST" ]; then
        echo "  Restoring from legacy backup..."

        while IFS='|' read -r action path; do
            case "$action" in
                created)
                    if [ -f "$path" ]; then
                        rm "$path"
                        printf "  ${GREEN}✓${NC} Removed $path\n"
                    fi
                    ;;
                overwritten)
                    backup_file="$BACKUP_DIR/$(echo "$path" | sed 's|[/ ]|__|g')"
                    if [ -f "$backup_file" ]; then
                        cp "$backup_file" "$path"
                        printf "  ${GREEN}✓${NC} Restored $path\n"
                    else
                        printf "  ${YELLOW}→${NC} Backup missing for $path, skipping\n"
                    fi
                    ;;
                mkdir)
                    if [ -d "$path" ] && [ -z "$(ls -A "$path")" ]; then
                        rmdir "$path"
                        printf "  ${GREEN}✓${NC} Removed empty directory $path\n"
                    fi
                    ;;
                mcp)
                    if claude mcp remove codex-reviewer -s user 2>/dev/null; then
                        printf "  ${GREEN}✓${NC} Removed Codex MCP Server registration\n"
                    else
                        printf "  ${YELLOW}→${NC} MCP removal skipped (may not exist)\n"
                    fi
                    ;;
                npm)
                    printf "  ${YELLOW}→${NC} Skipping $path (global npm package — remove manually with: npm uninstall -g $path)\n"
                    ;;
            esac
        done < "$MANIFEST"
    else
        printf "  ${RED}✘${NC} No snapshot or legacy manifest found.\n"
        echo "  Nothing to uninstall, or iSparto was installed before the backup feature existed."
        echo ""
        echo "  To manually clean up:"
        echo "    rm -rf ~/.isparto"
        echo "    rm -f ~/.claude/CLAUDE-TEMPLATE.md"
        echo "    rm -f ~/.claude/commands/{start-working,end-working,plan,init-project,env-nogo,migrate,restore}.md"
        echo "    rm -f ~/.claude/templates/{product-spec,tech-spec,design-spec,plan}-template.md"
        echo "    claude mcp remove codex-reviewer -s user"
        echo ""
        exit 1
    fi

    # Remove backup, snapshots, and isparto home
    rm -rf "$BACKUP_DIR"
    if [ -d "$ISPARTO_HOME" ] && [ -z "$(ls -A "$ISPARTO_HOME")" ]; then
        rmdir "$ISPARTO_HOME"
        printf "  ${GREEN}✓${NC} Removed $ISPARTO_HOME\n"
    else
        printf "  ${YELLOW}→${NC} $ISPARTO_HOME still has files (e.g. git repo), not removed\n"
        echo "    Remove manually if you want: rm -rf $ISPARTO_HOME"
    fi

    echo ""
    printf "${GREEN}Uninstall complete.${NC}\n"
    echo ""
    exit 0
fi

# ══════════════════════════════════════════════════════════════
# Install mode (normal or dry-run)
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

# ── 0. If running via curl pipe, clone repo first ─────────

if [ -f "$(dirname "$0")/commands/start-working.md" ] 2>/dev/null; then
    # Running from within the repo
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
else
    # Running standalone (curl | bash) — clone repo
    echo "Downloading iSparto..."
    if $DRY_RUN; then
        if [ -d "$ISPARTO_HOME" ]; then
            printf "  ${BLUE}[dry-run]${NC} Would update existing installation\n"
        else
            printf "  ${BLUE}[dry-run]${NC} Would clone to $ISPARTO_HOME\n"
        fi
        # Still need SCRIPT_DIR for file checks — use existing if available
        if [ -d "$ISPARTO_HOME" ]; then
            SCRIPT_DIR="$ISPARTO_HOME"
        else
            printf "  ${YELLOW}→${NC} No local copy found. Dry-run cannot preview file changes.\n"
            printf "  ${YELLOW}→${NC} Run without --dry-run first, or clone manually.\n"
            exit 0
        fi
    else
        if [ -d "$ISPARTO_HOME" ]; then
            printf "  ${YELLOW}→${NC} Updating existing installation...\n"
            git -C "$ISPARTO_HOME" pull --quiet
        else
            git clone --quiet https://github.com/BinaryHB0916/iSparto.git "$ISPARTO_HOME"
        fi
        printf "  ${GREEN}✓${NC} iSparto downloaded to $ISPARTO_HOME\n"
    fi
    SCRIPT_DIR="$ISPARTO_HOME"
fi

# ── Detect upgrade and show what's new ─────────────────────

OLD_VERSION=""
if [ -f "$ISPARTO_HOME/VERSION" ]; then
    OLD_VERSION=$(cat "$ISPARTO_HOME/VERSION")
fi
NEW_VERSION=""
if [ -f "$SCRIPT_DIR/VERSION" ]; then
    NEW_VERSION=$(cat "$SCRIPT_DIR/VERSION")
fi

if [ -n "$OLD_VERSION" ] && [ -n "$NEW_VERSION" ] && [ "$OLD_VERSION" != "$NEW_VERSION" ]; then
    if $DRY_RUN; then
        printf "  ${BLUE}[dry-run]${NC} Would upgrade: $OLD_VERSION -> $NEW_VERSION\n"
        if [ -f "$SCRIPT_DIR/CHANGELOG.md" ]; then
            echo ""
            echo "  What's new in $NEW_VERSION:"
            sed -n "/^## \[$NEW_VERSION\]/,/^## \[/p" "$SCRIPT_DIR/CHANGELOG.md" | sed '$d' | sed 's/^/  /'
            echo ""
        fi
    else
        printf "  ${GREEN}*${NC} Upgrading: $OLD_VERSION -> $NEW_VERSION\n"
        if [ -f "$SCRIPT_DIR/CHANGELOG.md" ]; then
            echo ""
            echo "  What's new in $NEW_VERSION:"
            sed -n "/^## \[$NEW_VERSION\]/,/^## \[/p" "$SCRIPT_DIR/CHANGELOG.md" | sed '$d' | sed 's/^/  /'
            echo ""
        fi
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
    if [ -f "$SCRIPT_DIR/VERSION" ]; then
        cp "$SCRIPT_DIR/VERSION" "$ISPARTO_HOME/VERSION"
    fi
fi

# ── Done ────────────────────────────────────────────────────

echo ""
if $DRY_RUN; then
    printf "${GREEN}Dry run complete!${NC} No changes were made.\n"
    echo ""
    echo "Run without --dry-run to install:"
    echo ""
    echo "  ./install.sh"
else
    if [ -n "$NEW_VERSION" ]; then
        printf "${GREEN}Done!${NC} iSparto $NEW_VERSION is ready.\n"
    else
        printf "${GREEN}Done!${NC} iSparto is ready.\n"
    fi
    printf "  Snapshot saved (use ./install.sh --uninstall to revert)\n"
    echo ""
    echo "Next step — launch Claude Code in your project directory:"
    echo ""
    echo "  claude --effort max"
    echo "  /init-project <description>      # new project"
    echo "  /migrate                         # existing project"
fi
echo ""
