#!/bin/bash
set -e

# ────────────────────────────────────────────────
# People Team Workflow Kit — Install Script
# Version: 1.0.0 (pinned to Claude Code CLI ≥ 1.0)
# Run time: under 5 minutes on a standard Mac
# ────────────────────────────────────────────────

VAULT_DIR="$(pwd)/vault"
CLAUDE_CONFIG="$HOME/.claude.json"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   People Team Workflow Kit — Setup       ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── Step 1: Check prerequisites ──────────────────
echo "→ Checking prerequisites..."

if ! command -v brew &>/dev/null; then
  echo "  ✗ Homebrew not found. Install it first: https://brew.sh"
  exit 1
fi
echo "  ✓ Homebrew found"

if ! command -v node &>/dev/null; then
  echo "  Installing Node.js via Homebrew..."
  brew install node
fi
echo "  ✓ Node.js found ($(node --version))"

# ── Step 2: Install Claude Code CLI ──────────────
echo ""
echo "→ Installing Claude Code CLI..."

if command -v claude &>/dev/null; then
  echo "  ✓ Claude Code already installed ($(claude --version 2>/dev/null || echo 'version unknown'))"
else
  npm install -g @anthropic-ai/claude-code
  echo "  ✓ Claude Code installed"
fi

# ── Step 3: Install skills ────────────────────────
echo ""
echo "→ Installing skills..."

SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$SKILLS_DIR"

for skill in orient meet closeout prep draft weekly; do
  if [ -d "skills/$skill" ]; then
    cp -r "skills/$skill" "$SKILLS_DIR/$skill"
    echo "  ✓ /$skill installed"
  fi
done

# ── Step 4: MCP Configuration ─────────────────────
echo ""
echo "→ Setting up MCP integrations..."
echo ""
echo "  You'll need to authenticate 4 integrations."
echo "  Skip any you don't use — skills degrade gracefully."
echo ""

# Granola MCP
echo "  [1/4] Granola (meeting transcripts)"
if [ -f "$HOME/Library/Application Support/Granola/supabase.json" ]; then
  echo "       ✓ Granola config found automatically"
else
  echo "       ⚠ Granola config not found at default path."
  echo "         Make sure Granola is installed and you've signed in."
fi

# Slack MCP
echo ""
echo "  [2/4] Slack"
echo "       After setup, run this in Claude Code to authenticate:"
echo "       Type /orient — Claude will prompt for browser auth if needed."

# Coda MCP
echo ""
echo "  [3/4] Coda"
read -p "       Enter your Coda API token (or press Enter to skip): " CODA_TOKEN
if [ -n "$CODA_TOKEN" ]; then
  echo "       ✓ Coda token saved"
  # Token written to env — not hardcoded in config
  echo "export CODA_API_TOKEN='$CODA_TOKEN'" >> "$HOME/.zshrc"
fi

# Zoom MCP (optional)
echo ""
echo "  [4/4] Zoom (optional — only needed for /prep calendar integration)"
echo "       Skip for now. You can add this later if needed."

# ── Step 5: Open vault in Obsidian ───────────────
echo ""
echo "→ Opening vault in Obsidian..."

if [ -d "$VAULT_DIR" ]; then
  open -a Obsidian "$VAULT_DIR" 2>/dev/null || echo "  ⚠ Couldn't open Obsidian automatically. Open it manually and add $VAULT_DIR as a vault."
else
  echo "  ⚠ Vault directory not found at $VAULT_DIR"
fi

# ── Done ──────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   Setup complete! Next steps:            ║"
echo "║                                          ║"
echo "║   1. Open a terminal in vault/           ║"
echo "║   2. Type: /orient                       ║"
echo "║   3. Fill in your name + role in         ║"
echo "║      agents.md when prompted             ║"
echo "║   4. See CHEATSHEET.md for all commands  ║"
echo "╚══════════════════════════════════════════╝"
echo ""
