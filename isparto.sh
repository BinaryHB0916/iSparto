#!/bin/bash
# iSparto local stub — installed at ~/.isparto/bin/isparto.sh
# Handles upgrade (network), uninstall (offline), and version display.
# Symlinked from ~/.isparto/install.sh for backward compatibility.
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ISPARTO_HOME="$HOME/.isparto"
VERSION_FILE="$ISPARTO_HOME/VERSION"
SNAPSHOT_SCRIPT="$ISPARTO_HOME/lib/snapshot.sh"
BACKUP_DIR="$ISPARTO_HOME/backup"
MANIFEST="$BACKUP_DIR/manifest.txt"
BOOTSTRAP_URL="https://raw.githubusercontent.com/BinaryHB0916/iSparto/main/bootstrap.sh"

# ── Helpers ──────────────────────────────────────────────────

show_version() {
    if [ -f "$VERSION_FILE" ]; then
        echo "iSparto $(cat "$VERSION_FILE")"
    else
        echo "iSparto (version unknown)"
    fi
}

show_usage() {
    show_version
    echo ""
    echo "Usage:"
    echo "  ~/.isparto/install.sh --upgrade       Check for and install updates"
    echo "  ~/.isparto/install.sh --uninstall      Remove iSparto and restore files"
    echo "  ~/.isparto/install.sh --version        Show installed version"
    echo "  ~/.isparto/install.sh --dry-run ...    Preview without making changes"
    echo ""
}

# ── Upgrade: download and run bootstrap.sh ───────────────────

do_upgrade() {
    show_version
    echo "Checking for updates..."
    echo ""
    UPGRADE_TMPFILE=$(mktemp)
    trap 'rm -f "$UPGRADE_TMPFILE"' EXIT
    curl -fsSL "$BOOTSTRAP_URL" -o "$UPGRADE_TMPFILE" || {
        printf "  ${RED}Error:${NC} Failed to download bootstrap.sh. Check your network connection.\n" >&2
        rm -f "$UPGRADE_TMPFILE"
        exit 1
    }
    bash "$UPGRADE_TMPFILE" --upgrade
    exit $?
}

# ── Uninstall: 100% offline ──────────────────────────────────

handle_mcp_uninstall() {
    local dry_run="$1"
    if $dry_run; then
        printf "  [dry-run] Would remove Codex MCP Server registration\n"
    elif claude mcp remove codex-reviewer -s user 2>/dev/null; then
        printf "  ${GREEN}✓${NC} Removed Codex MCP Server registration\n"
    else
        printf "  ${YELLOW}→${NC} MCP removal skipped (may not exist)\n"
    fi
}

handle_npm_uninstall() {
    local dry_run="$1"
    local path="$2"
    printf "  ${YELLOW}→${NC} Skipping %s (global npm package — remove manually with: npm uninstall -g %s)\n" "$path" "$path"
}

do_uninstall() {
    local dry_run=false
    for arg in "$@"; do
        [ "$arg" = "--dry-run" ] && dry_run=true
    done

    echo ""
    echo "  iSparto Uninstaller"
    echo "  --------------------"
    echo ""

    # Try snapshot system first, fall back to legacy manifest
    LATEST_SNAP=""
    if [ -x "$SNAPSHOT_SCRIPT" ]; then
        LATEST_SNAP=$("$SNAPSHOT_SCRIPT" list --type=install 2>/dev/null | tail -1 | awk '{print $1}')
    fi

    if [ -n "$LATEST_SNAP" ] && [ "$LATEST_SNAP" != "No" ] && [ "$LATEST_SNAP" != "ID" ]; then
        if $dry_run; then
            printf "  [dry-run] Would restore from snapshot: $LATEST_SNAP\n"
        else
            echo "  Restoring from snapshot: $LATEST_SNAP"
            "$SNAPSHOT_SCRIPT" restore "$LATEST_SNAP" || {
                printf "  ${RED}Error:${NC} Snapshot restore failed. Aborting uninstall to prevent data loss.\n" >&2
                exit 1
            }
        fi

        # Snapshot doesn't handle MCP or npm — do those via legacy manifest
        if [ -f "$MANIFEST" ]; then
            while IFS='|' read -r action path; do
                case "$action" in
                    mcp) handle_mcp_uninstall "$dry_run" ;;
                    npm) handle_npm_uninstall "$dry_run" "$path" ;;
                esac
            done < "$MANIFEST"
        fi
    elif [ -f "$MANIFEST" ]; then
        if $dry_run; then
            printf "  [dry-run] Would restore from legacy backup...\n"
        else
            echo "  Restoring from legacy backup..."
        fi

        while IFS='|' read -r action path; do
            case "$action" in
                created)
                    if $dry_run; then
                        printf "  [dry-run] Would remove $path\n"
                    elif [ -f "$path" ]; then
                        rm "$path"
                        printf "  ${GREEN}✓${NC} Removed $path\n"
                    fi
                    ;;
                overwritten)
                    backup_file="$BACKUP_DIR/$(echo "$path" | sed 's|[/ ]|__|g')"
                    if $dry_run; then
                        printf "  [dry-run] Would restore $path\n"
                    elif [ -f "$backup_file" ]; then
                        cp "$backup_file" "$path"
                        printf "  ${GREEN}✓${NC} Restored $path\n"
                    else
                        printf "  ${YELLOW}→${NC} Backup missing for $path, skipping\n"
                    fi
                    ;;
                mkdir)
                    if $dry_run; then
                        printf "  [dry-run] Would remove empty directory $path\n"
                    elif [ -d "$path" ] && [ -z "$(ls -A "$path")" ]; then
                        rmdir "$path"
                        printf "  ${GREEN}✓${NC} Removed empty directory $path\n"
                    fi
                    ;;
                mcp) handle_mcp_uninstall "$dry_run" ;;
                npm) handle_npm_uninstall "$dry_run" "$path" ;;
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

    if ! $dry_run; then
        # Remove backup, snapshots, and internal directories
        rm -rf "$BACKUP_DIR"
        rm -rf "$ISPARTO_HOME/snapshots"

        # Remove isparto home if empty (or mostly empty)
        rm -f "$ISPARTO_HOME/VERSION"
        rm -f "$ISPARTO_HOME/install.sh"
        rm -rf "$ISPARTO_HOME/bin"
        rm -rf "$ISPARTO_HOME/lib"
        rm -rf "$ISPARTO_HOME/hooks"

        if [ -d "$ISPARTO_HOME" ] && [ -z "$(ls -A "$ISPARTO_HOME")" ]; then
            rmdir "$ISPARTO_HOME"
            printf "  ${GREEN}✓${NC} Removed $ISPARTO_HOME\n"
        elif [ -d "$ISPARTO_HOME" ]; then
            printf "  ${YELLOW}→${NC} $ISPARTO_HOME still has files, not removed\n"
            echo "    Remove manually if you want: rm -rf $ISPARTO_HOME"
        fi
    fi

    echo ""
    if $dry_run; then
        printf "${GREEN}Dry run complete.${NC} No changes were made.\n"
    else
        printf "${GREEN}Uninstall complete.${NC}\n"
    fi
    echo ""
}

# ── Main dispatch ────────────────────────────────────────────

DRY_RUN=false
ACTION=""

for arg in "$@"; do
    case "$arg" in
        --upgrade)   ACTION="upgrade" ;;
        --uninstall) ACTION="uninstall" ;;
        --version)   ACTION="version" ;;
        --dry-run)   DRY_RUN=true ;;
    esac
done

case "$ACTION" in
    upgrade)
        if $DRY_RUN; then
            show_version
            echo "[dry-run] Would download and run bootstrap.sh from:"
            echo "  $BOOTSTRAP_URL"
        else
            do_upgrade
        fi
        ;;
    uninstall)
        if $DRY_RUN; then
            do_uninstall --dry-run
        else
            do_uninstall
        fi
        ;;
    version)
        show_version
        ;;
    *)
        show_usage
        ;;
esac
