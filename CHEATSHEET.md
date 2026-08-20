# Wolf Workflow Kit — Cheat Sheet

**Built by Ellen Wolf** · [github.com/ellenwolf0-hub/wolf-workflow-kit](https://github.com/ellenwolf0-hub/wolf-workflow-kit)

---

## The Ramp-Up Path

### Week 1 — Learn the Loop (3 commands)

Do these every single day until they're muscle memory.

| When | Command | What it does |
|------|---------|-------------|
| Morning | `/orient` | Loads your context, surfaces open pickups |
| After every meeting | `/meet` | Captures decisions and action items from Granola |
| Evening | `/closeout` | Logs your work, creates tomorrow's pickups |

*The loop works because each skill reads what the last one wrote. Don't skip closeout — that's what makes tomorrow's orient useful.*

---

### Week 2 — Add Context Management

| Command | What it does | When to use |
|---------|-------------|-------------|
| `/pickup` | Load a specific PIC and get right back to work | When you know exactly what you're continuing |
| `/log-work` | Log something to the daily note mid-session | After a focused sprint, before switching topics |
| `/park` | Save in-progress context without losing the thread | When you need to switch gears |
| `/recap` | Summarize the current session | Before closeout, or when you lose track |

---

### Week 3 — Add Project Structure

| Command | What it does |
|---------|-------------|
| `/create-spec` | Formally define a project, program, or initiative |
| `/review-spec` | Run a 3-agent review team on your spec |
| `/plan-spec` | Turn a reviewed spec into a phased plan |
| `/create-pickup` | Create a PIC for any open item |

*Pipeline: create-spec → review-spec → plan-spec. Review catches gaps before they become blockers.*

---

### Week 4+ — Full Power

| Command | What it does | Best for |
|---------|-------------|----------|
| `/prep [meeting]` | Pre-meeting brief — past context, open decisions, suggested agenda | Calibrations, 1:1s, stakeholder meetings |
| `/draft` | Write Slack, email, or talking points in your voice | Anytime you're staring at a blank message |
| `/weekly` | Roll up the week into a summary | Friday afternoon manager update |
| `/create-agent` | Dispatch an agent to do research or a first draft autonomously | Work done while you're in another meeting |
| `/end-day` | Full day wrap — Granola sweep, Slack sweep, EOD + SOD | When you want the full picture at day's end |
| `/ingest-day` 🆕 | Pull today's Granola meetings into a by-project context block (also powers `/end-day`) | Catching up on what was said; grounding a session. New — feedback welcome |
| `/assess` | People team diagnostic — sweep all sources, surface what's actually going on | New role, new quarter, or any time you need to cut through noise |

---

## Quick Reference

```
/orient             — start every session with this
/pickup             — load a specific PIC
/meet               — after any meeting
/prep [meeting]     — before important meetings
/closeout           — end every session with this
/log-work           — log what you just did
/park               — save context to return to later
/recap              — where are we right now?
/draft              — write something
/weekly             — roll up the week
/assess             — People team diagnostic: what's actually going on?
/create-spec        — start a new project formally
/review-spec        — review a spec before planning
/plan-spec          — turn a spec into a plan
/create-agent       — delegate a task to an agent
/create-pickup      — create a PIC for any open item
/end-day            — full day wrap with Granola + Slack sweep
/ingest-day         — pull today's meeting context (Granola), by project  🆕
```

---

## Role Playbooks

**HRBP:** `/orient` → `/prep` before calibrations → `/meet` after → `/draft` for follow-up memos → `/closeout`

**Recruiter:** `/orient` → `/meet` after debrief calls → `/draft` for offer letters and candidate comms → `/closeout`

**People Ops Lead:** Full stack — all skills. Start with Week 1 loop, build up over 4 weeks.

**People Ops Coordinator:** `/orient` → `/meet` after program meetings → `/closeout` with open items

---

## Zapier Automations

Set in `~/.zshrc` to enable:
```bash
export ZAPIER_MEET_WEBHOOK=""      # /meet → Slack channel
export ZAPIER_CLOSEOUT_WEBHOOK=""  # /closeout → Coda tracker
export ZAPIER_PREP_WEBHOOK=""      # /prep → Slack DM (10 min before meeting)
```
See `zapier/README.md` for setup.

---

## If Something Breaks

| Problem | Fix |
|---------|-----|
| Granola not pulling | Paste transcript manually when `/meet` prompts |
| Zapier not firing | Check your Zap is **Published** (not Draft) at zapier.com |
| Gmail/Calendar/Slack missing entirely | Connector trap — see below. Don't re-login, it won't help |
| Slack MCP error | Re-run `/orient` — will prompt browser re-auth |
| Lost track of session | Run `/recap` then `/closeout` to reset |
| Any question | Ask Claude: "What does /[skill] do?" |

### "Claude can't see my Gmail / Calendar / Slack" (the connector trap)

This is the single most common setup dead end, and it costs people an hour if they don't know about it. There are **two different ways** to wire an app into Claude, and only one of them reaches Claude Code.

**Path 1 — claude.ai connectors.** Managed by Anthropic, configured in the browser at `claude.ai/customize/connectors`. These show up in Claude Code's `/mcp` list **only if your login carries a Claude subscription seat**. If your account is usage-based (API billing, no subscription), Claude Code will not load them — no error, they're just silently absent.

**Path 2 — local MCP servers.** What this kit runs on. Configured with `claude mcp add` and stored in `~/.claude.json`. These work regardless of seat type.

**How to tell which situation you're in:**

```bash
claude mcp list        # shows ONLY Path 2 servers — never claude.ai connectors
```

Then run `/mcp` inside Claude Code. If you see a `claude.ai` section, Path 1 is working for you. If that section is **entirely absent** — not "needs authentication," just missing — your seat doesn't carry connectors and no amount of `/login`, re-auth, or restarting will change it.

**Don't chase this.** Signing out and back in won't fix it. Re-authenticating the connectors in the browser won't fix it. The connectors page will keep showing them as happily connected, because they *are* connected — to the web surface, not to Claude Code.

**What to do instead:** set the app up as a Path 2 local server. Check your company's internal IT documentation first — many orgs run a single MCP gateway that covers Gmail, Calendar, Drive, and Docs in one server, which is far less fiddly than wiring each app separately. If yours does, add that one gateway and you're done.

> If your org's official Claude setup doc walks you through the `claude.ai Gmail` / `claude.ai Google Calendar` connectors, note that those instructions assume a subscription seat. On a usage-based seat they will not work, and the doc may not say so.

### When Coda hangs or asks you to re-authenticate

Coda connects natively over HTTP with OAuth (`claude mcp add --transport http Coda https://coda.io/apis/mcp`). No API token, no `mcp-remote` shim — the old community proxy that used to wedge for hours has been removed.

**Re-authentication is expected, not a bug.** Coda issues a short-lived login and provides no auto-renew, so every few hours you'll be asked to sign in again. Run `/mcp`, complete the browser sign-in, continue. Known Coda-side limitation, not something your setup did wrong.

**If calls hang or the server drops:** run `/mcp` to reconnect. If that doesn't clear it, `/exit` and relaunch Claude Code. Last resort:

```bash
claude mcp remove Coda
claude mcp add --transport http Coda https://coda.io/apis/mcp
```

**Safety nets applied by `setup.sh`** (run `/update-wfk pull` if you set up before 2026-05-19):

1. **Timeout caps.** `~/.claude/settings.json` has `MCP_TOOL_TIMEOUT=90000` (90s) and `MCP_TIMEOUT=30000` (30s), so worst-case latency is bounded.
2. **Pre-approved Coda permissions.** `~/.claude/settings.local.json` pre-approves common Coda read/write tools so prompts don't fire on every call. Destructive ops (delete, `document_create`) still require manual approval.
