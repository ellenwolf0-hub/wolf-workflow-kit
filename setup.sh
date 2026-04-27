#!/bin/bash
set -e

# ────────────────────────────────────────────────
# Wolf Workflow Kit — Install Script
# Version: 1.1.0
# Run time: under 5 minutes on a standard Mac
# Run from the wolf-workflow-kit directory:
#   bash setup.sh
# ────────────────────────────────────────────────

VAULT_DIR="$(pwd)/vault"
SKILLS_SRC="$(pwd)/skills"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║      Wolf Workflow Kit — Setup           ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── Step 1: Check prerequisites ──────────────────
echo "→ Checking prerequisites..."

if ! command -v brew &>/dev/null; then
  echo ""
  echo "  ✗ Homebrew not found."
  echo "    Homebrew is a package manager for Mac — you need it to install the other tools."
  echo "    Install it by running this in your terminal:"
  echo ""
  echo '    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  echo ""
  echo "    Then run this setup script again."
  exit 1
fi
echo "  ✓ Homebrew found"

if ! command -v node &>/dev/null; then
  echo "  Installing Node.js via Homebrew (this takes about 1 minute)..."
  brew install node
fi
echo "  ✓ Node.js found ($(node --version))"

# ── Step 2: Install Claude Code CLI ──────────────
echo ""
echo "→ Installing Claude Code CLI..."
echo "  (This is different from Claude.ai — it's the version that runs in your terminal)"
echo ""

if command -v claude &>/dev/null; then
  CLAUDE_VER=$(claude --version 2>/dev/null || echo "version unknown")
  echo "  ✓ Claude Code already installed ($CLAUDE_VER)"
else
  echo "  Installing via npm..."
  npm install -g @anthropic-ai/claude-code
  echo "  ✓ Claude Code installed"
fi

# ── Step 3: Install all skills ───────────────────
echo ""
echo "→ Installing skills..."

SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$SKILLS_DIR"

SKILL_COUNT=0
for skill_dir in "$SKILLS_SRC"/*/; do
  skill_name=$(basename "$skill_dir")
  if [ -f "$skill_dir/SKILL.md" ]; then
    mkdir -p "$SKILLS_DIR/$skill_name"
    cp "$skill_dir/SKILL.md" "$SKILLS_DIR/$skill_name/SKILL.md"
    # Copy references/ subdirectory if present (needed by some skills)
    if [ -d "$skill_dir/references" ]; then
      mkdir -p "$SKILLS_DIR/$skill_name/references"
      cp "$skill_dir/references/"*.md "$SKILLS_DIR/$skill_name/references/" 2>/dev/null || true
    fi
    echo "  ✓ /$skill_name"
    SKILL_COUNT=$((SKILL_COUNT + 1))
  fi
done

echo ""
echo "  $SKILL_COUNT skills installed"

# ── Step 4: Open vault in Obsidian ───────────────
echo ""
echo "→ Opening vault in Obsidian..."
echo "  Obsidian is where your notes, meeting captures, and pickup docs live."
echo ""

if ! [ -d "$VAULT_DIR" ]; then
  echo "  ⚠  Vault directory not found at $VAULT_DIR"
  echo "     Are you running this script from the wolf-workflow-kit directory?"
else
  if open -a Obsidian "$VAULT_DIR" 2>/dev/null; then
    echo "  ✓ Obsidian opened — you may see a dialog asking to trust the vault. Click 'Trust'."
  else
    echo "  ⚠  Couldn't open Obsidian automatically."
    echo "     Open Obsidian manually and add this folder as a vault:"
    echo "     $VAULT_DIR"
  fi
fi

# ── Step 5: MCP integrations (optional) ──────────
echo ""
echo "→ Optional: MCP integrations"
echo ""
echo "  MCPs connect Claude Code to your apps (Granola, Slack, Coda)."
echo "  The kit works without them — skills degrade gracefully."
echo "  You can skip this now and add them later."
echo ""

# Granola
if [ -f "$HOME/Library/Application Support/Granola/supabase.json" ]; then
  echo "  [Granola] ✓ Config found automatically — /meet will pull transcripts"
else
  echo "  [Granola] ⚠  Not detected. If you use Granola, make sure you're signed in."
  echo "             /meet will fall back to manual paste if Granola isn't connected."
fi

# Slack
echo ""
echo "  [Slack]    To connect Slack, run this in Claude Code after setup:"
echo "             claude mcp add --transport sse slack https://mcp.slack.com/sse"
echo "             (You'll be prompted to authenticate in your browser)"

# Coda
echo ""
echo "  [Coda]     To connect Coda, you need your API token from coda.io/account"
echo "             Then add it to your shell config (~/.zshrc or ~/.bashrc):"
echo '             export CODA_API_TOKEN="your-token-here"'
echo "             Do not share this token — treat it like a password."

# NotebookLM (Oracle)
echo ""
echo "  [Oracle]   To use /oracle-create, /oracle-ask, /oracle-research:"
echo "             uv tool install notebooklm-mcp-cli"
echo "             claude mcp add notebooklm"
echo "             (Requires uv: https://docs.astral.sh/uv/getting-started/installation/)"

# ── Done ──────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║   Setup complete!                                ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║                                                  ║"
echo "║   Next: open GETTING_STARTED.md                 ║"
echo "║   It walks you through your first session        ║"
echo "║   step by step (about 15 minutes).              ║"
echo "║                                                  ║"
echo "║   Quick start if you want to jump in now:       ║"
echo "║                                                  ║"
echo "║   1. Open a NEW terminal window                  ║"
echo "║   2. Run:                                        ║"
echo "║      claude --dangerously-skip-permissions       ║"
echo "║   3. Type: /orient                               ║"
echo "║                                                  ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
