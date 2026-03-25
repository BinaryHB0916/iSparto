#!/bin/bash
# iSparto Release Script
# Usage: ./scripts/release.sh <version>
# Example: ./scripts/release.sh 0.3.0
#
# What it does:
#   1. Validates version format and checks preconditions
#   2. Updates VERSION file
#   3. Inserts release date into CHANGELOG.md ([Unreleased] → [x.y.z] - date)
#   4. Commits, tags, pushes
#   5. Creates GitHub Release with install.sh + checksums.sha256 as assets
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ── Validate arguments ──────────────────────────────────────

if [ -z "$1" ]; then
    echo "Usage: ./scripts/release.sh <version>"
    echo "Example: ./scripts/release.sh 0.3.0"
    exit 1
fi

NEW_VERSION="$1"

if ! echo "$NEW_VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    printf "${RED}Error:${NC} Version must be semver (e.g., 0.3.0)\n" >&2
    exit 1
fi

# ── Preconditions ────────────────────────────────────────────

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# Must be on main
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    printf "${RED}Error:${NC} Must be on main branch (currently on $CURRENT_BRANCH)\n" >&2
    exit 1
fi

# Working tree must be clean
if [ -n "$(git status --porcelain)" ]; then
    printf "${RED}Error:${NC} Working tree is not clean. Commit or stash changes first.\n" >&2
    exit 1
fi

# Tag must not already exist
if git tag -l "v$NEW_VERSION" | grep -q .; then
    printf "${RED}Error:${NC} Tag v$NEW_VERSION already exists.\n" >&2
    exit 1
fi

# CHANGELOG must have [Unreleased] section
if ! grep -q '## \[Unreleased\]' CHANGELOG.md; then
    printf "${RED}Error:${NC} CHANGELOG.md has no [Unreleased] section.\n" >&2
    exit 1
fi

OLD_VERSION=$(cat VERSION)
TODAY=$(date +%Y-%m-%d)

printf "${GREEN}Releasing:${NC} $OLD_VERSION → $NEW_VERSION\n"
echo ""

# ── 1. Update VERSION ───────────────────────────────────────

echo "$NEW_VERSION" > VERSION
printf "  ${GREEN}✓${NC} VERSION → $NEW_VERSION\n"

# ── 2. Update CHANGELOG ─────────────────────────────────────

# Replace [Unreleased] with [Unreleased]\n\n## [x.y.z] - date
sed -i '' "s/## \[Unreleased\]/## [Unreleased]\n\n## [$NEW_VERSION] - $TODAY/" CHANGELOG.md
printf "  ${GREEN}✓${NC} CHANGELOG.md → [$NEW_VERSION] - $TODAY\n"

# ── 3. Commit and tag ───────────────────────────────────────

git add VERSION CHANGELOG.md
git commit -m "release: v$NEW_VERSION"
git tag "v$NEW_VERSION"
printf "  ${GREEN}✓${NC} Committed and tagged v$NEW_VERSION\n"

# ── 4. Push ──────────────────────────────────────────────────

git push origin main
git push origin "v$NEW_VERSION"
printf "  ${GREEN}✓${NC} Pushed to origin\n"

# ── 5. Build release assets ─────────────────────────────────

TMPDIR=$(mktemp -d)
trap "rm -rf '$TMPDIR'" EXIT

cp install.sh "$TMPDIR/install.sh"
(cd "$TMPDIR" && shasum -a 256 install.sh > checksums.sha256)
printf "  ${GREEN}✓${NC} Generated checksums.sha256\n"

# ── 6. Create GitHub Release ────────────────────────────────

# Extract changelog section for this version
RELEASE_NOTES=$(sed -n "/^## \[$NEW_VERSION\]/,/^## \[/p" CHANGELOG.md | sed '$d' | sed '1d')

gh release create "v$NEW_VERSION" \
    "$TMPDIR/install.sh" \
    "$TMPDIR/checksums.sha256" \
    --title "v$NEW_VERSION" \
    --notes "$RELEASE_NOTES"

printf "  ${GREEN}✓${NC} GitHub Release created\n"

# ── Done ─────────────────────────────────────────────────────

echo ""
printf "${GREEN}Done!${NC} v$NEW_VERSION released.\n"
echo "  https://github.com/BinaryHB0916/iSparto/releases/tag/v$NEW_VERSION"
echo ""
