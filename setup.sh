#!/bin/bash
set -e

# ────────────────────────────────────────────────
# Wolf Workflow Kit — Install Script
# Version: 1.2.0
# Run time: under 5 minutes on a standard Mac
# Run from the wolf-workflow-kit directory:
#   bash setup.sh              (full install)
#   bash setup.sh --skills-only (skills only, used by /update-wfk pull)
# ────────────────────────────────────────────────

VAULT_DIR="$(pwd)/vault"
SKILLS_SRC="$(pwd)/skills"

SKILLS_ONLY=false
for arg in "$@"; do
  case "$arg" in
    --skills-only) SKILLS_ONLY=true ;;
  esac
done

install_skills() {
  SKILLS_DIR="$HOME/.claude/skills"
  mkdir -p "$SKILLS_DIR"

  SKILL_COUNT=0
  for skill_dir in "$SKILLS_SRC"/*/; do
    skill_name=$(basename "$skill_dir")
    if [ -f "$skill_dir/SKILL.md" ]; then
      mkdir -p "$SKILLS_DIR/$skill_name"
      cp "$skill_dir/SKILL.md" "$SKILLS_DIR/$skill_name/SKILL.md"
      if [ -d "$skill_dir/references" ]; then
        mkdir -p "$SKILLS_DIR/$skill_name/references"
        cp -R "$skill_dir/references/"* "$SKILLS_DIR/$skill_name/references/" 2>/dev/null || true
      fi
      if [ -d "$skill_dir/templates" ]; then
        mkdir -p "$SKILLS_DIR/$skill_name/templates"
        cp -R "$skill_dir/templates/"* "$SKILLS_DIR/$skill_name/templates/" 2>/dev/null || true
      fi
      echo "  ✓ /$skill_name"
      SKILL_COUNT=$((SKILL_COUNT + 1))
    fi
  done

  echo ""
  echo "  $SKILL_COUNT skills installed"
}

configure_mcp_timeouts() {
  SETTINGS_FILE="$HOME/.claude/settings.json"
  mkdir -p "$(dirname "$SETTINGS_FILE")"
  python3 - "$SETTINGS_FILE" <<'PY'
import json, sys
path = sys.argv[1]
try:
    with open(path) as f:
        data = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    data = {}
env = data.get("env")
if not isinstance(env, dict):
    env = {}
    data["env"] = env
env.setdefault("MCP_TOOL_TIMEOUT", "90000")
env.setdefault("MCP_TIMEOUT", "30000")
with open(path, "w") as f:
    json.dump(data, f, indent=2)
PY
}

configure_coda_permissions() {
  LOCAL_SETTINGS="$HOME/.claude/settings.local.json"
  mkdir -p "$(dirname "$LOCAL_SETTINGS")"
  python3 - "$LOCAL_SETTINGS" <<'PY'
import json, sys
path = sys.argv[1]
CODA_SAFE_TOOLS = [
    "mcp__Coda__search",
    "mcp__Coda__url_convert",
    "mcp__Coda__whoami",
    "mcp__Coda__tool_guide",
    "mcp__Coda__document_read",
    "mcp__Coda__page_read",
    "mcp__Coda__page_create",
    "mcp__Coda__page_update",
    "mcp__Coda__content_modify",
    "mcp__Coda__content_duplicate",
    "mcp__Coda__table_columns_read",
    "mcp__Coda__table_columns_manage",
    "mcp__Coda__table_rows_read",
    "mcp__Coda__table_rows_manage",
    "mcp__Coda__table_create",
    "mcp__Coda__formula_execute",
]
try:
    with open(path) as f:
        data = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    data = {}
perms = data.get("permissions")
if not isinstance(perms, dict):
    perms = {}
    data["permissions"] = perms
allow = perms.get("allow")
if not isinstance(allow, list):
    allow = []
    perms["allow"] = allow
existing = set(allow)
added = 0
for tool in CODA_SAFE_TOOLS:
    if tool not in existing:
        allow.append(tool)
        added += 1
with open(path, "w") as f:
    json.dump(data, f, indent=2)
print(f"  ✓ {added} Coda tools pre-approved ({len(CODA_SAFE_TOOLS)} total in safe set)")
print(f"  ✓ Destructive ops (delete, document_create) still require manual approval")
PY
}

if [ "$SKILLS_ONLY" = true ]; then
  echo ""
  echo "→ Installing skills (skills-only mode)..."
  install_skills
  configure_mcp_timeouts
  echo "  ✓ MCP timeouts checked (MCP_TOOL_TIMEOUT=90s, MCP_TIMEOUT=30s)"
  configure_coda_permissions
  echo ""
  echo "  Done. Restart Claude Code to pick up new slash commands."
  exit 0
fi

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

install_skills

# ── Step 3.5: Configure Claude Code MCP defaults ──
echo ""
echo "→ Configuring Claude Code MCP defaults..."
echo "  (Caps hung calls + pre-approves common Coda tools so prompts don't block your flow.)"
configure_mcp_timeouts
echo "  ✓ MCP_TOOL_TIMEOUT=90s, MCP_TIMEOUT=30s set in ~/.claude/settings.json"
configure_coda_permissions

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
echo "             1. uv tool install notebooklm-mcp-cli"
echo "             2. claude mcp add notebooklm"
echo "             3. nlm login        (opens a Chrome window — sign in with Google)"
echo "             4. nlm login --check  (verify auth succeeded)"
echo "             5. Restart Claude Code so the MCP picks up the fresh auth"
echo "             (Requires uv: https://docs.astral.sh/uv/getting-started/installation/)"
echo "             Note: do NOT try to authenticate via Claude Code's setup_auth tool."
echo "             The MCP server runs headless and cannot render the OAuth flow."

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
