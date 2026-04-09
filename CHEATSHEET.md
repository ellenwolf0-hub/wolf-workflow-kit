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
/create-spec        — start a new project formally
/review-spec        — review a spec before planning
/plan-spec          — turn a spec into a plan
/create-agent       — delegate a task to an agent
/create-pickup      — create a PIC for any open item
/end-day            — full day wrap with Granola + Slack sweep
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
| Slack MCP error | Re-run `/orient` — will prompt browser re-auth |
| Lost track of session | Run `/recap` then `/closeout` to reset |
| Any question | Ask Claude: "What does /[skill] do?" |
