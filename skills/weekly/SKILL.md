---
name: weekly
description: >-
  Roll up the week's daily notes and meeting notes into a weekly summary. Use
  when the user says "/weekly", "weekly summary", "week in review", "roll up
  the week", "what did I do this week", or wants a summary for a manager update.
  Best run Friday afternoon.
---

# Weekly — Week in Review

Synthesize the week's notes into a readable summary. Good for manager updates, personal reflection, or week-end closeout.

**Arguments:** $ARGUMENTS — Optional week to summarize (defaults to current week). E.g., `/weekly` or `/weekly Apr 7-11`.

## Step 1 — Find This Week's Notes

Determine the week range (Mon-Fri). Default to the current week based on today's date.

Glob and read:
- `Daily/DN - YYYY-MM-DD.md` for each day in the range — read the `## Worked On` sections
- `Meetings/MN - YYYY-MM-DD (Topic).md` for all meeting notes in the range — read the `## Decisions` and `## Action Items` sections

If a day has no daily note, skip it silently.

## Step 2 — Synthesize

Group everything by project/theme, not by day. The output should read like a narrative of the week, not a day-by-day log.

Identify:
- **What shipped or moved forward** — concrete outcomes, decisions made, things completed
- **What's in progress** — active work with clear next steps
- **What's blocked or pending** — things waiting on someone else or a decision
- **Recurring themes** — if the same topic appeared in 3 meeting notes, that's a signal worth naming
- **Open action items** — tasks from this week's meetings that are still open

## Step 3 — Write the Summary

```markdown
# Week in Review — Week of [Mon Date] – [Fri Date]

## What Moved Forward
- **[Project/Theme]:** [1-2 sentence outcome]
- **[Project/Theme]:** [1-2 sentence outcome]

## In Progress
- **[Project/Theme]:** [Where it is and what's next]

## Waiting On / Blocked
- [Item] — waiting on [person/decision]

## Patterns This Week
[Optional: 1-2 observations about recurring themes or how the week felt. Skip if nothing notable.]

## Open Action Items from Meetings
- [ ] [Task] — [owner] — due [date]
- [ ] [Task] — [owner] — due [date]
```

Keep it under 1 page. This should be pasteable into a manager update Slack message or email without editing.

## Step 4 — Save and Present

Save to `Projects/WS - Week of YYYY-MM-DD.md` and present inline.

Ask: "Does this capture the week? Anything to add or remove?"

Offer: "Want me to draft this as a Slack message to your manager?" (invokes `/draft` with the weekly summary as context).
