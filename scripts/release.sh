#!/bin/bash
# iSparto Release Script
# Usage: ./scripts/release.sh <version>
# Example: ./scripts/release.sh 0.3.0
#
# What it does:
#   1. Validates version format and checks preconditions
#   2. Updates VERSION file
#   3. Inserts release date into CHANGELOG.md ([Unreleased] → [x.y.z] - date)
#   4. Commits on release branch, creates PR, merges to main
#   5. Tags the merge commit, creates GitHub Release with install.sh + checksums.sha256 as assets
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
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
RELEASE_BRANCH="release/v$NEW_VERSION"

printf "${GREEN}Releasing:${NC} $OLD_VERSION → $NEW_VERSION\n"
echo ""

# ── 1. Create release branch ─────────────────────────────────

git checkout -b "$RELEASE_BRANCH"
printf "  ${GREEN}✓${NC} Created branch $RELEASE_BRANCH\n"

# ── 2. Update VERSION ───────────────────────────────────────

echo "$NEW_VERSION" > VERSION
printf "  ${GREEN}✓${NC} VERSION → $NEW_VERSION\n"

# ── 3. Update CHANGELOG ─────────────────────────────────────

# Replace [Unreleased] with [Unreleased]\n\n## [x.y.z] - date
# Note: sed -i '' is macOS/BSD syntax. This script is designed for local macOS use only.
sed -i '' "s/## \[Unreleased\]/## [Unreleased]\n\n## [$NEW_VERSION] - $TODAY/" CHANGELOG.md
printf "  ${GREEN}✓${NC} CHANGELOG.md → [$NEW_VERSION] - $TODAY\n"

# ── 4. Commit, push, and create PR ──────────────────────────

git add VERSION CHANGELOG.md
git commit -m "release: v$NEW_VERSION"
git push -u origin "$RELEASE_BRANCH"
printf "  ${GREEN}✓${NC} Pushed $RELEASE_BRANCH\n"

RELEASE_NOTES=$(sed -n "/^## \[$NEW_VERSION\]/,/^## \[/p" CHANGELOG.md | sed '$d' | sed '1d')

PR_URL=$(gh pr create \
    --title "release: v$NEW_VERSION" \
    --body "$RELEASE_NOTES" \
    --base main) || {
    printf "  ${RED}Error:${NC} PR creation failed. Branch '%s' has been pushed but no PR was created.\n" "$RELEASE_BRANCH" >&2
    printf "  Clean up manually: git push origin --delete %s\n" "$RELEASE_BRANCH" >&2
    exit 1
}
printf "  ${GREEN}✓${NC} PR created: $PR_URL\n"

# ── 5. Merge PR ─────────────────────────────────────────────

gh pr merge "$PR_URL" --merge --admin || {
    printf "  ${RED}Error:${NC} PR merge failed. PR exists but was not merged.\n" >&2
    printf "  Merge manually: gh pr merge %s --squash --delete-branch\n" "$RELEASE_BRANCH" >&2
    exit 1
}
printf "  ${GREEN}✓${NC} PR merged to main\n"

# ── 6. Tag merge commit ─────────────────────────────────────

git checkout main
git pull origin main
git tag "v$NEW_VERSION"
git push origin "v$NEW_VERSION"
printf "  ${GREEN}✓${NC} Tagged v$NEW_VERSION on main\n"

# ── 7. Clean up release branch ──────────────────────────────

git branch -d "$RELEASE_BRANCH"
git push origin --delete "$RELEASE_BRANCH" 2>/dev/null || true
printf "  ${GREEN}✓${NC} Cleaned up $RELEASE_BRANCH\n"

# ── 8. Build release assets ─────────────────────────────────

RELEASE_TMPDIR=$(mktemp -d)
trap 'rm -rf "$RELEASE_TMPDIR"' EXIT

cp install.sh "$RELEASE_TMPDIR/install.sh"
(cd "$RELEASE_TMPDIR" && shasum -a 256 install.sh > checksums.sha256)
printf "  ${GREEN}✓${NC} Generated checksums.sha256\n"

# ── 9. Create GitHub Release ────────────────────────────────

gh release create "v$NEW_VERSION" \
    "$RELEASE_TMPDIR/install.sh" \
    "$RELEASE_TMPDIR/checksums.sha256" \
    --title "v$NEW_VERSION" \
    --notes "$RELEASE_NOTES"

printf "  ${GREEN}✓${NC} GitHub Release created\n"

# ── Done ─────────────────────────────────────────────────────

echo ""
printf "${GREEN}Done!${NC} v$NEW_VERSION released.\n"
echo "  https://github.com/BinaryHB0916/iSparto/releases/tag/v$NEW_VERSION"
echo ""
