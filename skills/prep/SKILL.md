---
name: prep
description: >-
  Generate a pre-meeting brief before an important meeting. Use when the user
  says "/prep", "prep for", "brief me on", "what do I need to know before",
  or wants context before a meeting. Accepts a meeting name as input. Optionally
  triggers a Zapier webhook to deliver the brief via Slack DM.
---

# Prep — Pre-Meeting Brief

Generate a structured brief before a meeting: who's in the room, what was discussed last time, and what needs to come out of this one.

**Arguments:** $ARGUMENTS — Meeting name or description (e.g., `/prep Calibration — Taylor Chen` or `/prep my 1:1 with Brady`).

## Step 1 — Identify the Meeting

If $ARGUMENTS provided, use that as the meeting name. If not, ask: "What meeting are you prepping for?"

Optionally check Zoom MCP for upcoming meetings if credentials are configured. If unavailable, manual input is the primary path — don't block on Zoom.

## Step 2 — Find Past Context

Search the vault for prior meetings with the same people or topic:

1. Glob `Meetings/MN - *.md` and read frontmatter to find meetings with matching attendees or topic keywords
2. For each matching meeting note, extract:
   - `## Decisions` table — open decisions or deferred items
   - `## Open Questions` — things that weren't resolved
   - `## Action Items` — any tasks that were assigned

3. Check today's daily note and recent pickups for any open items related to this person or project

## Step 3 — Build the Brief

Structure the pre-meeting brief:

```markdown
# Pre-Meeting Brief — [Meeting Name]
**Date:** [today]
**Attendees:** [who's in the room — from vault history or user input]

## Last Time We Met
[Date of most recent meeting with these people]
[2-3 bullet summary of what was covered and decided]

## Open Decisions
[Decisions from past meetings that were deferred or need follow-up]
- [Decision] — deferred from [date], owner [name]

## Open Action Items
[Action items from past meetings that may need status check]
- [ ] [task] — assigned to [owner], due [date]

## Suggested Agenda
Based on open items and context, here's a suggested focus:
1. [Most important thing to resolve]
2. [Second priority]
3. [Third if time allows]

## Things to Watch For
[Anything flagged in lessons.md or past meeting notes about this person or topic]
```

If no prior meeting notes are found, say so: "No past meeting notes found for [topic/person]. Brief is based on vault context only."

## Step 4 — Zapier Webhook (if configured)

After generating the brief, check if `$ZAPIER_PREP_WEBHOOK` is set.

If set, fire:
```bash
curl -s -X POST "$ZAPIER_PREP_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d "{\"meeting\":\"MEETING_NAME\",\"attendees\":[],\"prior_context\":\"SUMMARY\",\"decisions_needed\":[\"item1\"]}"
```

This delivers the brief as a Slack DM — useful for getting a heads-up on your phone 10 minutes before the meeting.

## Step 5 — Present

Show the brief and ask: "Anything to add before the meeting?"
