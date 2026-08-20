#!/bin/bash
echo ""
echo "  WOLF WORKFLOW KIT — HEALTH CHECK"
echo "  ================================================"
P=0; W=0; F=0
ok(){ echo "  [ OK ]  $1"; P=$((P+1)); }
wn(){ echo "  [note]  $1"; W=$((W+1)); }
no(){ echo "  [FIX ]  $1"; F=$((F+1)); }

echo ""; echo "  MCP SERVERS  (what the kit actually needs)"
M=$(claude mcp list 2>&1 | grep -v "^\[mcp-sdk\]")
for s in Coda granola; do
  echo "$M" | grep -q "^$s:.*Connected" && ok "$s connected" \
    || { echo "$M" | grep -q "^$s:" && no "$s registered but not connected — run /mcp and authenticate" \
    || no "$s missing"; }
done
if echo "$M" | grep -q "^notebooklm-mcp:.*Connected"; then ok "notebooklm-mcp connected"
elif echo "$M" | grep -q "^notebooklm-mcp:"; then no "notebooklm-mcp not connected — run: nlm login"
else wn "notebooklm-mcp missing (only needed for /oracle)"; fi
echo "$M" | grep -q "^slack:.*Connected" && ok "slack connected" || wn "slack not connected (optional — /end-day reads it)"

echo ""; echo "  NOTHING BROKEN LEFT BEHIND"
CLEAN=1
echo "$M" | grep -qi "default-profile" && { no "default-profile present — dead service. Run: claude mcp remove default-profile"; CLEAN=0; }
echo "$M" | grep -q "^notebooklm:" && { no "duplicate 'notebooklm'. Run: claude mcp remove notebooklm"; CLEAN=0; }
echo "$M" | grep -qiE "^gmail:|workspace-mcp" && { wn "a gmail/workspace server is registered but unconfigured — harmless. Remove with: claude mcp remove gmail"; CLEAN=0; }
[ $CLEAN -eq 1 ] && ok "no dead or duplicate servers"

echo ""; echo "  SKILLS"
D=~/.claude/skills; N=$(ls "$D" 2>/dev/null | wc -l | tr -d ' ')
MISS=""; for s in orient pickup meet onboard; do [ -d "$D/$s" ] || MISS="$MISS /$s"; done
if [ -n "$MISS" ]; then no "core skills missing:$MISS — run /update-wfk pull"
else ok "$N skills installed, core set present"; fi
SPEC=""; for s in create-note create-spec; do [ -d "$D/$s" ] && SPEC="$SPEC /$s"; done
[ -n "$SPEC" ] && ok "spec/project authoring:$SPEC" || no "no spec skill found — run /update-wfk pull"
CTX=""; for s in ingest-day granola-sync end-day closeout log-work weekly recap; do [ -d "$D/$s" ] && CTX="$CTX /$s"; done
[ -n "$CTX" ] && ok "context + logging:$CTX" || wn "no context/logging skills found"

echo ""; echo "  VAULT + PROFILE"
J=~/.claude/wfk-paths.json
if [ -f "$J" ]; then
  V=$(python3 -c "import json;print(json.load(open('$J'))['vault_root'])" 2>/dev/null)
  if [ -d "$V" ]; then ok "vault: $V"
    A="$V/agents.md"
    if [ -f "$A" ]; then
      R=$(grep -i "kit role" "$A" | head -1 | sed 's/.*[Kk]it [Rr]ole:[* ]*//' | tr -d '*` ' | tr 'A-Z' 'a-z')
      case "$R" in
        user|developer) ok "agents.md Kit Role: $R" ;;
        "")             ok "agents.md present" ;;
        *)              no "agents.md Kit Role is '$R' — change it to 'user'" ;;
      esac
      grep -qE '\[Your |\{\{|<your-|TBD_' "$A" && wn "agents.md still has template placeholders — run /onboard"
    else no "no agents.md in the vault — run /onboard"; fi
  else no "wfk-paths.json points at a folder that doesn't exist: $V"; fi
else no "wfk-paths.json missing — re-run setup.sh"; fi

echo ""; echo "  ================================================"
printf "  %d ok" $P; [ $W -gt 0 ] && printf " · %d notes" $W; [ $F -gt 0 ] && printf " · %d to fix" $F; echo ""
echo ""
if [ $F -eq 0 ]; then
  echo "  You're good. Working right now, no Google needed:"
  echo "    /orient /pickup      load context, see what's open"
  echo "    /create-note /create-spec   spec out a new project"
  echo "    /meet /ingest-day    pull Granola transcripts into the vault"
  echo "    /draft /log-work     write in your voice, log what you did"
  echo "    /oracle              NotebookLM research"
else
  echo "  Fix the [FIX] lines above, then run this again."
fi
echo ""
