#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "  iSparto Installer"
echo "  ─────────────────"
echo ""

# ── 0. If running via curl pipe, clone repo first ─────────
ISPARTO_HOME="$HOME/.isparto"

if [ -f "$(dirname "$0")/settings.json" ] 2>/dev/null; then
    # Running from within the repo
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
else
    # Running standalone (curl | sh) — clone repo
    echo "Downloading iSparto..."
    if [ -d "$ISPARTO_HOME" ]; then
        echo -e "  ${YELLOW}→${NC} Updating existing installation..."
        git -C "$ISPARTO_HOME" pull --quiet
    else
        git clone --quiet https://github.com/BinaryHB0916/iSparto.git "$ISPARTO_HOME"
    fi
    echo -e "  ${GREEN}✓${NC} iSparto downloaded to $ISPARTO_HOME"
    SCRIPT_DIR="$ISPARTO_HOME"
fi

# ── 1. Node.js ──────────────────────────────────────────────

echo "Checking Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_VERSION" -ge 18 ]; then
        echo -e "  ${GREEN}✓${NC} Node.js $(node -v)"
    else
        echo -e "  ${RED}✘${NC} Node.js $(node -v) — requires 18+"
        echo "  Install from https://nodejs.org"
        exit 1
    fi
else
    echo -e "  ${RED}✘${NC} Node.js not found"
    echo "  Install 18+ from https://nodejs.org"
    exit 1
fi

# ── 2. Claude Code ──────────────────────────────────────────

echo "Checking Claude Code..."
if command -v claude &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Claude Code installed"
else
    echo -e "  ${YELLOW}→${NC} Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
    echo -e "  ${GREEN}✓${NC} Claude Code installed"
fi

# ── 3. Codex CLI ────────────────────────────────────────────

echo "Checking Codex CLI..."
if command -v codex &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Codex CLI installed"
else
    echo -e "  ${YELLOW}→${NC} Installing Codex CLI..."
    npm install -g @openai/codex
    echo -e "  ${GREEN}✓${NC} Codex CLI installed"
fi

# ── 4. Codex Login ──────────────────────────────────────────

echo "Checking Codex login..."
if codex login status &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Codex logged in"
else
    echo -e "  ${YELLOW}→${NC} Codex not logged in. Running codex login..."
    codex login
fi

# ── 5. Copy config to ~/.claude/ ────────────────────────────

echo "Installing config to ~/.claude/..."

mkdir -p ~/.claude/commands
mkdir -p ~/.claude/templates

copy_file() {
    local src="$1"
    local dst="$2"
    local label="$3"
    if [ -f "$dst" ]; then
        echo -en "  ${YELLOW}?${NC} $label already exists. Overwrite? [y/N] "
        read -r answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            cp "$src" "$dst"
            echo -e "  ${GREEN}✓${NC} Overwrote $label"
        else
            echo -e "  ${YELLOW}→${NC} Skipped $label"
        fi
    else
        cp "$src" "$dst"
        echo -e "  ${GREEN}✓${NC} Installed $label"
    fi
}

copy_file "$SCRIPT_DIR/settings.json" ~/.claude/settings.json "~/.claude/settings.json"
copy_file "$SCRIPT_DIR/CLAUDE-TEMPLATE.md" ~/.claude/CLAUDE-TEMPLATE.md "~/.claude/CLAUDE-TEMPLATE.md"

for f in "$SCRIPT_DIR"/commands/*.md; do
    name=$(basename "$f")
    copy_file "$f" ~/.claude/commands/"$name" "~/.claude/commands/$name"
done

for f in "$SCRIPT_DIR"/templates/*.md; do
    name=$(basename "$f")
    copy_file "$f" ~/.claude/templates/"$name" "~/.claude/templates/$name"
done

# ── 6. Register Codex MCP Server (global) ───────────────────

echo "Registering Codex MCP Server (global)..."
if claude mcp add codex-reviewer -s user -- npx -y codex-mcp-server 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Codex MCP Server registered globally"
else
    echo -e "  ${YELLOW}→${NC} MCP registration skipped (may already exist)"
fi

# ── Done ────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}Done!${NC} iSparto is ready."
echo ""
echo "To start a new project:"
echo ""
echo "  mkdir my-app && cd my-app"
echo "  claude --effort max"
echo "  /env-nogo                        # check environment readiness"
echo "  /init-project <your product description>"
echo ""
echo "To migrate an existing project:"
echo ""
echo "  cd existing-project/"
echo "  claude --effort max"
echo "  /migrate"
echo ""
