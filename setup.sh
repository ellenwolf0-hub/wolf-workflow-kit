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
AGENTS_SRC="$(pwd)/agents"

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
      if [ -d "$skill_dir/overlays" ]; then
        mkdir -p "$SKILLS_DIR/$skill_name/overlays"
        cp -R "$skill_dir/overlays/"* "$SKILLS_DIR/$skill_name/overlays/" 2>/dev/null || true
      fi
      echo "  ✓ /$skill_name"
      SKILL_COUNT=$((SKILL_COUNT + 1))
    fi
  done

  echo ""
  echo "  $SKILL_COUNT skills installed"
}

install_agents() {
  # Agent profiles (e.g. the pipeline-coordination orchestrator/worker) live in
  # agents/ and load at session start. Skipped silently if the repo has none.
  [ -d "$AGENTS_SRC" ] || return 0
  AGENTS_DIR="$HOME/.claude/agents"
  mkdir -p "$AGENTS_DIR"

  AGENT_COUNT=0
  for agent_file in "$AGENTS_SRC"/*.md; do
    [ -f "$agent_file" ] || continue
    cp "$agent_file" "$AGENTS_DIR/$(basename "$agent_file")"
    echo "  ✓ agent: $(basename "$agent_file" .md)"
    AGENT_COUNT=$((AGENT_COUNT + 1))
  done

  echo ""
  echo "  $AGENT_COUNT agents installed"
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

configure_wfk_paths() {
  # Many skills read ~/.claude/wfk-paths.json at startup to resolve vault
  # directories. Write a sensible default if it's missing — never clobber a
  # customized one. vault_root prefers workflow-kit.config.json (set by /setup),
  # else the bundled vault dir.
  PATHS_FILE="$HOME/.claude/wfk-paths.json"
  if [ -f "$PATHS_FILE" ]; then
    echo "  ✓ wfk-paths.json already present — left as-is"
    return 0
  fi
  VAULT_ROOT="$VAULT_DIR"
  if [ -f "$VAULT_DIR/workflow-kit.config.json" ]; then
    VAULT_ROOT=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1])).get('vault_root') or sys.argv[2])" "$VAULT_DIR/workflow-kit.config.json" "$VAULT_DIR" 2>/dev/null || echo "$VAULT_DIR")
  fi
  python3 - "$PATHS_FILE" "$VAULT_ROOT" <<'PY'
import json, sys
path, vault_root = sys.argv[1], sys.argv[2]
n = "01_Notes"
data = {
    "vault_root": vault_root,
    "paths": {
        "daily_notes": f"{n}/Daily",
        "meetings": f"{n}/Meetings",
        "reports": f"{n}/Reports",
        "pickups": f"{n}/Pickups",
        "work_logs": f"{n}/Work Logs",
        "weekly": f"{n}/Weekly",
        "projects": "02_Projects",
        "operations": "03_Operations",
        "reference": "04_Reference",
        "system": "05_System",
        "media": "06_Media",
    },
}
with open(path, "w") as f:
    json.dump(data, f, indent=2)
print(f"  ✓ wrote wfk-paths.json (vault_root={vault_root})")
PY
}

if [ "$SKILLS_ONLY" = true ]; then
  echo ""
  echo "→ Installing skills (skills-only mode)..."
  install_skills
  install_agents
  configure_wfk_paths
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

# ── Step 3.1: Install agent profiles ─────────────
echo ""
echo "→ Installing agents..."

install_agents

# ── Step 3.5: Configure Claude Code MCP defaults ──
echo ""
echo "→ Configuring Claude Code MCP defaults..."
echo "  (Caps hung calls + pre-approves common Coda tools so prompts don't block your flow.)"
configure_wfk_paths
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
echo "  [Coda]     In Claude Code, run:"
echo "             claude mcp add --transport http Coda https://coda.io/apis/mcp"
echo "             Then run /mcp and complete the browser sign-in. No API token needed."
echo "             Note: Coda's login expires periodically and can't auto-renew, so"
echo "             you'll occasionally re-authenticate via /mcp. That's a Coda-side"
echo "             limitation, not a setup error."

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
