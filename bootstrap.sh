#!/bin/bash
# iSparto Bootstrap — thin entry point, rarely changes.
# Downloads a verified install.sh from GitHub Releases and executes it.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/BinaryHB0916/iSparto/main/bootstrap.sh | bash
#   curl -fsSL ... | bash -s -- --version=0.2.0
#   curl -fsSL ... | bash -s -- --dry-run
set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO="BinaryHB0916/iSparto"
VERSION=""
PASSTHROUGH_ARGS=()

for arg in "$@"; do
    case "$arg" in
        --version=*) VERSION="${arg#--version=}" ;;
        *)           PASSTHROUGH_ARGS+=("$arg") ;;
    esac
done

# ── Resolve latest version from GitHub Releases ──────────────
if [ -z "$VERSION" ]; then
    VERSION=$(curl -fsSL --connect-timeout 10 --max-time 30 "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null \
        | grep '"tag_name"' | sed -E 's/.*"v?([0-9][^"]*)".*/\1/')
    if [ -z "$VERSION" ]; then
        # Fallback: no releases yet, run install.sh directly from main branch
        printf "${YELLOW}No releases found. Installing from main branch (unverified).${NC}\n" >&2
        BOOTSTRAP_TMPDIR=$(mktemp -d)
        trap 'rm -rf "$BOOTSTRAP_TMPDIR"' EXIT
        curl -fsSL --connect-timeout 10 --max-time 60 "https://raw.githubusercontent.com/$REPO/main/install.sh" -o "$BOOTSTRAP_TMPDIR/install.sh" || {
            printf "${RED}Error:${NC} Failed to download install.sh from main branch.\n" >&2
            exit 1
        }
        bash "$BOOTSTRAP_TMPDIR/install.sh" "${PASSTHROUGH_ARGS[@]}"
        exit $?
    fi
fi

# Validate version format
if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+'; then
    printf "${RED}Error:${NC} Invalid version format: '$VERSION'\n" >&2
    echo "  Expected semver (e.g. 0.6.18). Check https://github.com/$REPO/releases" >&2
    exit 1
fi

TAG="v${VERSION}"
BASE_URL="https://github.com/$REPO/releases/download/$TAG"

# ── Download install.sh + checksums to temp dir ──────────────
BOOTSTRAP_TMPDIR=$(mktemp -d)
trap 'rm -rf "$BOOTSTRAP_TMPDIR"' EXIT

curl -fsSL --connect-timeout 10 --max-time 60 "$BASE_URL/install.sh" -o "$BOOTSTRAP_TMPDIR/install.sh" || {
    printf "${RED}Error:${NC} Failed to download install.sh for $TAG\n" >&2
    echo "  Check that release $TAG exists: https://github.com/$REPO/releases/tag/$TAG" >&2
    exit 1
}

curl -fsSL --connect-timeout 10 --max-time 30 "$BASE_URL/checksums.sha256" -o "$BOOTSTRAP_TMPDIR/checksums.sha256" || {
    printf "${RED}Error:${NC} Failed to download checksums for $TAG\n" >&2
    exit 1
}

# ── Verify SHA256 checksum ───────────────────────────────────
(cd "$BOOTSTRAP_TMPDIR" && shasum -a 256 -c checksums.sha256 --status 2>/dev/null) || {
    printf "${RED}Error:${NC} Checksum verification failed. Aborting.\n" >&2
    echo "  The downloaded install.sh does not match the expected checksum." >&2
    echo "  This could indicate a corrupted download or a tampered file." >&2
    echo "  Try running the command again." >&2
    exit 1
}

# ── Execute verified installer ───────────────────────────────
export ISPARTO_INSTALL_VERSION="$VERSION"
bash "$BOOTSTRAP_TMPDIR/install.sh" "${PASSTHROUGH_ARGS[@]}"
