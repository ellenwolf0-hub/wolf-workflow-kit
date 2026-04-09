# People Team Workflow Kit — Cheat Sheet

## The Daily Loop

```
Morning          →    During Day         →    Evening
/orient               /meet (after mtgs)       /closeout
                       /draft (when writing)
                       /prep (before big mtgs)
```

---

## Skills

### Tier 1 — Core (Always Ship)

| Skill | What it does | Example |
|-------|-------------|---------|
| `/orient` | Loads your vault context, surfaces open pickups, asks what to work on | `Run /orient` at the start of every session |
| `/meet` | Pulls your Granola transcript, generates a structured note with decisions, action items, and open questions. Saves to vault. | `Run /meet after the calibration session` |
| `/closeout` | Logs what you worked on, creates pickup docs for open items, updates daily note | `Run /closeout` at the end of every session |

### Tier 2 — Power (Ship If Time Allows)

| Skill | What it does | Example |
|-------|-------------|---------|
| `/prep` | Pre-meeting brief: who's in the room, last meeting context, open decisions, suggested agenda | `Run /prep "Calibration — Taylor Chen"` |
| `/draft` | Writes a Slack message, email, or talking points in your voice from meeting context | `Draft a follow-up to Taylor Chen about the comp decision` |
| `/weekly` | Rolls up 5 days of notes into a weekly summary for your manager update | `Run /weekly` on Friday afternoons |

---

## Zapier Automations (Optional)

Once configured (see `zapier/README.md`), these fire automatically:

| Trigger | What happens |
|---------|-------------|
| `/prep` runs | Slack DM to you 10 min before the meeting |
| `/meet` completes | Decisions + action items posted to your team Slack channel |
| `/closeout` completes | Work log entry added to shared Coda tracker |

---

## Common Prompts

```
Run /orient
Run /meet after the standup
Run /prep "Design Review with Brady"
Draft a message to my manager about the Metro delay
Run /draft — turn the calibration note into a talking points doc
Run /closeout
Run /weekly
```

---

## Personas

**HRBP:** `/orient` → `/prep` before calibrations → `/meet` after → `/draft` for follow-ups

**Recruiter:** `/orient` → `/meet` after debrief calls → `/draft` for offer letters and candidate comms

**People Ops Coordinator:** `/orient` → `/meet` after any program meeting → `/closeout` with open items

---

## If Something Breaks

- **Granola not pulling?** Paste the transcript manually when prompted by `/meet`
- **Zapier not firing?** Check that your Zap is Published (not Draft) at zapier.com
- **Slack MCP error?** Re-run `/orient` — Claude will prompt for browser re-auth
- **Everything else:** Ask Claude: "What's wrong with [skill name]?"
