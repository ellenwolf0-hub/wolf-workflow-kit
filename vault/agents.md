---
date created: 2026-04-09
tags: [agents, vault-root]
category: Reference
---

# People Team Workflow Kit — Agent Context

## Who Am I

> Fill this in on first run. Claude reads this at the start of every session.

**Name:** [Your name]
**Role:** [Your title — e.g., "HRBP", "Recruiter", "People Ops Coordinator", "Director of People"]
**Team:** [Your team name — e.g., "People Team", "Talent Acquisition", "Total Rewards"]
**Manager:** [Your manager's name]
**Key stakeholders:** [2-3 people you work with most]

**My top priorities right now:**
- [Priority 1]
- [Priority 2]
- [Priority 3]

---

## Tools I Use

Slack, Zoom, Coda, Granola, Google Calendar, Workday

## How I Like to Work

- Ask me one question at a time with numbered options — never bundle multiple questions
- Keep responses concise — I don't need long explanations, just the output
- When I ask for a draft, write it ready-to-send, not a template with [placeholders]
- Flag sensitive information (comp data, PIPs, legal matters) before including in any output

## Skills Available

**Daily loop (start here):**
- `/orient` — start of every session
- `/meet` — after any meeting
- `/closeout` — end of every session

**Context management:**
- `/pickup` — resume a specific open item
- `/log-work` — log what you just did mid-session
- `/park` — set aside in-progress work to return to later
- `/recap` — summarize what's happened in the current session
- `/create-pickup` — create a pickup doc for any open item

**Meeting workflow:**
- `/prep [meeting name]` — pre-meeting brief before important meetings
- `/draft` — write Slack, email, or talking points in your voice
- `/weekly` — Friday afternoon week rollup

**Diagnostics:**
- `/assess` — People team diagnostic: sweep all sources, surface what's actually going on

**Project structure:**
- `/create-spec` — formally define a project or initiative
- `/review-spec` — catch gaps before planning
- `/plan-spec` — turn a reviewed spec into a phased plan
- `/create-agent` — dispatch an agent to do research autonomously

**Full day wrap:**
- `/end-day` — Granola sweep + Slack sweep + EOD report + tomorrow's SOD

## Vault Structure

```
vault/
├── agents.md          ← this file — your profile and preferences
├── lessons.md         ← context that accumulates over time
├── Daily/             ← DN - YYYY-MM-DD.md
├── Meetings/          ← MN - YYYY-MM-DD (Topic).md
├── Pickups/           ← PIC - Topic.md
└── templates/         ← note templates
```

## Routing Rules

- Daily notes → `Daily/DN - YYYY-MM-DD.md`
- Meeting notes → `Meetings/MN - YYYY-MM-DD (Topic).md`
- Pickup docs → `Pickups/PIC - Topic.md`

## Zapier Webhooks (optional)

Set these as environment variables to enable automations:

```bash
export ZAPIER_MEET_WEBHOOK=""      # /meet → Slack channel
export ZAPIER_CLOSEOUT_WEBHOOK=""  # /closeout → Coda tracker
export ZAPIER_PREP_WEBHOOK=""      # /prep → Slack DM (10 min before meeting)
```

Leave blank to disable. Skills degrade gracefully — no webhook, no problem.
