#!/bin/bash
set -e

# ══════════════════════════════════════════════════════════════
# iSparto Snapshot/Restore Engine
#
# Provides full "factory reset" capability — every iSparto
# operation (install, migrate, init-project) creates a snapshot
# before modifying files, so users can roll back at any time.
#
# Usage:
#   snapshot.sh create   <type> <project_dir> <file1> [file2 ...]
#   snapshot.sh restore  <id>   [--dry-run]
#   snapshot.sh list     [--type=<type>] [--project=<dir>]
#   snapshot.sh info     <id>
#   snapshot.sh prune    [--keep=<n>]
# ══════════════════════════════════════════════════════════════

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ISPARTO_HOME="${ISPARTO_HOME:-$HOME/.isparto}"
SNAPSHOT_DIR="$ISPARTO_HOME/snapshots"

# ── Helpers ──────────────────────────────────────────────────

encode_path() {
    echo "$1" | sed 's|[/ ]|__|g'
}

resolve_path() {
    local project_dir="$1"
    local rel_path="$2"
    if [ "$project_dir" = "global" ]; then
        echo "$rel_path"
    else
        echo "$project_dir/$rel_path"
    fi
}

read_meta() {
    local snap_dir="$1"
    local key="$2"
    grep "^${key}=" "$snap_dir/metadata.txt" 2>/dev/null | cut -d= -f2-
}

# ── create ───────────────────────────────────────────────────
# Creates a snapshot of the listed files before an operation.
#
# For project-level (migrate/init-project):
#   files are relative to project_dir
# For global (install):
#   files are absolute paths, project_dir = "global"
#
# Prints the snapshot ID to stdout.

cmd_create() {
    local type="$1"
    local project_dir="$2"
    shift 2
    local files=("$@")

    if [ -z "$type" ] || [ -z "$project_dir" ] || [ ${#files[@]} -eq 0 ]; then
        echo "Usage: snapshot.sh create <type> <project_dir> <file1> [file2 ...]" >&2
        exit 1
    fi

    local timestamp
    timestamp="$(date +%Y%m%d-%H%M%S)"
    local hash
    hash="$(echo "$project_dir" | shasum | cut -c1-4)"
    local id="${type}-${timestamp}-${hash}"

    local snap_dir="$SNAPSHOT_DIR/$id"
    mkdir -p "$snap_dir/files"

    # Write metadata
    cat > "$snap_dir/metadata.txt" <<EOF
id=$id
type=$type
timestamp=$(date -u +%Y-%m-%dT%H:%M:%S)
project_dir=$project_dir
file_count=${#files[@]}
EOF

    # Process each file
    local files_manifest="$snap_dir/files.txt"
    > "$files_manifest"

    for rel_path in "${files[@]}"; do
        local full_path
        full_path="$(resolve_path "$project_dir" "$rel_path")"

        local encoded
        encoded="$(encode_path "$rel_path")"

        if [ -f "$full_path" ]; then
            echo "exists|$rel_path" >> "$files_manifest"
            cp -L "$full_path" "$snap_dir/files/$encoded"
        else
            echo "absent|$rel_path" >> "$files_manifest"
        fi
    done

    echo "$id"
}

# ── restore ──────────────────────────────────────────────────
# Restores files from a snapshot.
#   exists → restore the backed-up file
#   absent → delete the file (it was created by the operation)

cmd_restore() {
    local id="$1"
    local dry_run=false
    [ "${2:-}" = "--dry-run" ] && dry_run=true

    if [ -z "$id" ]; then
        echo "Usage: snapshot.sh restore <id> [--dry-run]" >&2
        exit 1
    fi

    local snap_dir="$SNAPSHOT_DIR/$id"
    if [ ! -d "$snap_dir" ]; then
        printf "${RED}Error:${NC} Snapshot '$id' not found.\n" >&2
        exit 1
    fi

    local project_dir
    project_dir="$(read_meta "$snap_dir" "project_dir")"
    local snap_type
    snap_type="$(read_meta "$snap_dir" "type")"

    if $dry_run; then
        printf "${BLUE}[dry-run]${NC} Restore preview for snapshot: $id\n"
    else
        printf "Restoring snapshot: $id\n"
    fi

    local restored=0
    local removed=0

    while IFS='|' read -r status rel_path; do
        local full_path
        full_path="$(resolve_path "$project_dir" "$rel_path")"

        local encoded
        encoded="$(encode_path "$rel_path")"

        case "$status" in
            exists)
                if $dry_run; then
                    printf "  ${BLUE}[dry-run]${NC} Would restore: $full_path\n"
                else
                    local parent_dir
                    parent_dir="$(dirname "$full_path")"
                    [ ! -d "$parent_dir" ] && mkdir -p "$parent_dir"
                    cp "$snap_dir/files/$encoded" "$full_path"
                    printf "  ${GREEN}Restored:${NC} $full_path\n"
                fi
                restored=$((restored + 1))
                ;;
            absent)
                if [ -f "$full_path" ]; then
                    if $dry_run; then
                        printf "  ${BLUE}[dry-run]${NC} Would remove: $full_path\n"
                    else
                        rm "$full_path"
                        printf "  ${YELLOW}Removed:${NC}  $full_path\n"
                        # Clean up empty parent directories (up to project root)
                        local parent_dir
                        parent_dir="$(dirname "$full_path")"
                        while [ "$parent_dir" != "$project_dir" ] && [ -d "$parent_dir" ] && [ -z "$(ls -A "$parent_dir")" ]; do
                            rmdir "$parent_dir"
                            parent_dir="$(dirname "$parent_dir")"
                        done
                    fi
                    removed=$((removed + 1))
                else
                    if $dry_run; then
                        printf "  ${BLUE}[dry-run]${NC} Skip (already absent): $full_path\n"
                    fi
                fi
                ;;
        esac
    done < "$snap_dir/files.txt"

    echo ""
    if $dry_run; then
        printf "${BLUE}[dry-run]${NC} Would restore $restored file(s), remove $removed file(s). No changes made.\n"
    else
        printf "${GREEN}Done.${NC} Restored $restored file(s), removed $removed file(s).\n"
    fi
}

# ── list ─────────────────────────────────────────────────────
# Lists all snapshots, optionally filtered.

cmd_list() {
    local filter_type=""
    local filter_project=""
    local latest_only=false

    for arg in "$@"; do
        case "$arg" in
            --type=*) filter_type="${arg#--type=}" ;;
            --project=*) filter_project="${arg#--project=}" ;;
            --latest) latest_only=true ;;
        esac
    done

    if [ ! -d "$SNAPSHOT_DIR" ]; then
        $latest_only || echo "No snapshots found."
        return
    fi

    local found=false
    local last_id=""
    local last_timestamp=""

    $latest_only || printf "%-40s %-14s %-20s %s\n" "ID" "TYPE" "TIMESTAMP" "PROJECT"
    $latest_only || printf "%-40s %-14s %-20s %s\n" "──────────────────────────────────────" "────────────" "───────────────────" "───────"

    for snap_dir in "$SNAPSHOT_DIR"/*/; do
        [ ! -f "$snap_dir/metadata.txt" ] && continue

        local id type timestamp project_dir file_count
        id="$(read_meta "$snap_dir" "id")"
        type="$(read_meta "$snap_dir" "type")"
        timestamp="$(read_meta "$snap_dir" "timestamp")"
        project_dir="$(read_meta "$snap_dir" "project_dir")"
        file_count="$(read_meta "$snap_dir" "file_count")"

        # Apply filters
        [ -n "$filter_type" ] && [ "$type" != "$filter_type" ] && continue
        [ -n "$filter_project" ] && [ "$project_dir" != "$filter_project" ] && continue

        if $latest_only; then
            # Compare timestamps lexicographically (ISO format sorts correctly)
            if [ -z "$last_timestamp" ] || [[ "$timestamp" > "$last_timestamp" ]]; then
                last_id="$id"
                last_timestamp="$timestamp"
            fi
        else
            printf "%-40s %-14s %-20s %s (%s files)\n" "$id" "$type" "$timestamp" "$project_dir" "$file_count"
        fi
        found=true
    done

    if $latest_only; then
        [ -n "$last_id" ] && echo "$last_id"
    elif ! $found; then
        echo "No snapshots found."
    fi
}

# ── info ─────────────────────────────────────────────────────
# Shows details of a specific snapshot.

cmd_info() {
    local id="$1"

    if [ -z "$id" ]; then
        echo "Usage: snapshot.sh info <id>" >&2
        exit 1
    fi

    local snap_dir="$SNAPSHOT_DIR/$id"
    if [ ! -d "$snap_dir" ]; then
        printf "${RED}Error:${NC} Snapshot '$id' not found.\n" >&2
        exit 1
    fi

    echo ""
    echo "Snapshot Details"
    echo "────────────────"
    echo "  ID:        $(read_meta "$snap_dir" "id")"
    echo "  Type:      $(read_meta "$snap_dir" "type")"
    echo "  Timestamp: $(read_meta "$snap_dir" "timestamp")"
    echo "  Project:   $(read_meta "$snap_dir" "project_dir")"
    echo "  Files:     $(read_meta "$snap_dir" "file_count")"
    echo ""
    echo "File Manifest"
    echo "────────────────"

    while IFS='|' read -r status rel_path; do
        case "$status" in
            exists)  printf "  ${GREEN}[backed up]${NC}  $rel_path\n" ;;
            absent)  printf "  ${YELLOW}[new file]${NC}   $rel_path\n" ;;
        esac
    done < "$snap_dir/files.txt"

    echo ""
}

# ── prune ────────────────────────────────────────────────────
# Removes old snapshots. Default: keep 10 most recent per type.

cmd_prune() {
    local keep=10

    for arg in "$@"; do
        case "$arg" in
            --keep=*) keep="${arg#--keep=}" ;;
        esac
    done

    if [ ! -d "$SNAPSHOT_DIR" ]; then
        echo "No snapshots to prune."
        return
    fi

    local pruned=0

    for type in install migrate init-project; do
        local count=0
        # List snapshot dirs for this type, sorted newest first (lexicographic works for our ID format)
        for snap_dir in $(ls -d "$SNAPSHOT_DIR"/${type}-*/ 2>/dev/null | sort -r); do
            [ ! -f "$snap_dir/metadata.txt" ] && continue
            count=$((count + 1))
            if [ "$count" -gt "$keep" ]; then
                local id
                id="$(read_meta "$snap_dir" "id")"
                rm -rf "$snap_dir"
                printf "  ${YELLOW}Pruned:${NC} $id\n"
                pruned=$((pruned + 1))
            fi
        done
    done

    if [ "$pruned" -eq 0 ]; then
        echo "Nothing to prune (all types have <= $keep snapshots)."
    else
        printf "${GREEN}Pruned $pruned snapshot(s).${NC}\n"
    fi
}

# ── Main dispatch ────────────────────────────────────────────

case "${1:-}" in
    create)  shift; cmd_create "$@" ;;
    restore) shift; cmd_restore "$@" ;;
    list)    shift; cmd_list "$@" ;;
    info)    shift; cmd_info "$@" ;;
    prune)   shift; cmd_prune "$@" ;;
    *)
        echo "iSparto Snapshot Engine"
        echo ""
        echo "Usage:"
        echo "  snapshot.sh create  <type> <project_dir> <file1> [file2 ...]"
        echo "  snapshot.sh restore <id>   [--dry-run]"
        echo "  snapshot.sh list    [--type=<type>] [--project=<dir>]"
        echo "  snapshot.sh info    <id>"
        echo "  snapshot.sh prune   [--keep=<n>]"
        echo ""
        echo "Types: install, migrate, init-project"
        exit 1
        ;;
esac
