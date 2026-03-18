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

if [ -f "$(dirname "$0")/commands/start-working.md" ] 2>/dev/null; then
    # Running from within the repo
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
else
    # Running standalone (curl | bash) — clone repo
    echo "Downloading iSparto..."
    if [ -d "$ISPARTO_HOME" ]; then
        printf "  ${YELLOW}→${NC} Updating existing installation...\n"
        git -C "$ISPARTO_HOME" pull --quiet
    else
        git clone --quiet https://github.com/BinaryHB0916/iSparto.git "$ISPARTO_HOME"
    fi
    printf "  ${GREEN}✓${NC} iSparto downloaded to $ISPARTO_HOME\n"
    SCRIPT_DIR="$ISPARTO_HOME"
fi

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
    printf "  ${YELLOW}→${NC} Installing Claude Code...\n"
    npm install -g @anthropic-ai/claude-code
    printf "  ${GREEN}✓${NC} Claude Code installed\n"
fi

# ── 3. Codex CLI ────────────────────────────────────────────

echo "Checking Codex CLI..."
if command -v codex &> /dev/null; then
    printf "  ${GREEN}✓${NC} Codex CLI installed\n"
else
    printf "  ${YELLOW}→${NC} Installing Codex CLI...\n"
    npm install -g @openai/codex
    printf "  ${GREEN}✓${NC} Codex CLI installed\n"
fi

# ── 4. Codex Login ──────────────────────────────────────────

echo "Checking Codex login..."
if codex login status &> /dev/null; then
    printf "  ${GREEN}✓${NC} Codex logged in\n"
else
    printf "  ${YELLOW}→${NC} Codex not logged in. Running codex login...\n"
    codex login
fi

# ── 5. Copy config to ~/.claude/ ────────────────────────────

echo "Installing global commands & templates to ~/.claude/ ..."
echo "  (project-level config will be created when you run /init-project or /migrate)"

mkdir -p ~/.claude/commands
mkdir -p ~/.claude/templates

install_file() {
    local src="$1"
    local dst="$2"
    local label="$3"
    local action="Installed"
    [ -f "$dst" ] && action="Updated"
    cp "$src" "$dst"
    printf "  ${GREEN}✓${NC} $action $label\n"
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
if claude mcp add codex-reviewer -s user -- npx -y codex-mcp-server 2>/dev/null; then
    printf "  ${GREEN}✓${NC} Codex MCP Server registered globally\n"
else
    printf "  ${YELLOW}→${NC} MCP registration skipped (may already exist)\n"
fi

# ── Done ────────────────────────────────────────────────────

echo ""
printf "${GREEN}Done!${NC} iSparto is ready.\n"
echo ""
echo "Next step — launch Claude Code in your project directory:"
echo ""
echo "  claude --effort max"
echo "  /init-project <description>      # new project"
echo "  /migrate                         # existing project"
echo ""
