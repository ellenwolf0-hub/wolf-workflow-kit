---
name: meet
description: >-
  Capture meeting decisions and action items after a meeting ends. Use when the user
  says "/meet", "meeting notes", "capture the meeting", "write up the meeting",
  "process [meeting name]", "log the [meeting name]", or finishes describing what
  happened in a meeting. Pulls from Granola automatically if available. Accepts
  manual transcript paste or conversational dictation as fallback.
---

# Meet — Post-Meeting Capture

Turn any meeting into a structured note with decisions, action items, and open questions. Save it to the vault. Optionally fire a Zapier webhook to post to Slack.

**Arguments:** $ARGUMENTS — Optional meeting name or description to help identify the right Granola transcript (e.g., `/meet calibration Taylor Chen`).

## Step 1 — Get the Meeting Content

Try these sources in order:

**1a. Granola MCP (preferred)**

Search for recent meetings using `search_granola_events` or `list_granola_documents`. Look for a meeting from the past 4 hours.

If $ARGUMENTS was provided, use it to narrow the search (match by title or attendee name).

If a match is found, confirm before proceeding: "I found **[meeting title]** from [time] — is that the one?"

**1b. Manual fallback**

If Granola is unavailable, didn't capture the meeting, or the user says to skip it:

> "Granola didn't find a recent transcript. Paste the transcript, describe what happened, or tell me the key points and I'll structure it."

Accept input in any form: raw transcript, bulleted notes, or conversational dictation. Do not interview the user topic-by-topic — take whatever they give in one pass.

**If no content is provided at all:** Ask once: "What meeting should I capture?" Then wait.

## Step 2 — Extract Structure

Parse the meeting content and extract:

1. **Date** — from Granola metadata, transcript header, or today's date as fallback
2. **Attendees** — only explicitly mentioned participants. Never infer attendees from context. If speaker labels use aliases ("You", "Speaker 1"), map them only when the real name is unambiguous.
3. **Topic** — short descriptor for the filename. Derive from dominant theme or the meeting title.
4. **Decisions** — things explicitly decided. Each decision must have: what was decided + who owns it. If nothing was decided, omit this section entirely.
5. **Action items** — tasks with a clear owner and deliverable. Format: `- [ ] Owner: description — due date`. Omit if none.
6. **Open questions** — things that came up but weren't resolved. These are the loose ends the team needs to return to. Omit if none.
7. **Discussion notes** — key context, reasoning behind decisions, important facts stated. Group by topic. Keep it signal-only — skip greetings, small talk, and filler.

## Step 3 — Quality Rules

These rules are non-negotiable:

### Content fidelity
- Never invent, infer, or embellish. If it wasn't said, it doesn't go in the note.
- Capture the reasoning behind decisions, not just the decision itself.
- Preserve specifics: names, numbers, dates, dollar amounts, percentages. Never round or generalize.
- Bold key details throughout discussion bullets.

### Structure
- **Decisions are a first-class element.** They go in their own `## Decisions` table — never nested inside discussion bullets or action items. This is what `/prep` surfaces before the next meeting with these people.
- Omit Decisions, Action Items, and Open Questions sections entirely when empty — don't leave blank section headers.
- Discussion notes use `**Bold topic header**` with bullets underneath. No numbered lists.

### Signal vs. noise
- Skip greetings, wrap-ups, small talk, ambient noise, and filler.
- Collapse repetitive back-and-forth into the conclusion.
- Every bullet should carry information someone would want when reviewing this note later.

### Style
- No em dashes. Use commas, periods, or ` - ` if a dash is needed.
- Tight spacing. No double blank lines.
- Concise — these notes may be shared with stakeholders who skim.

## Step 4 — Save to Vault

Create `Meetings/MN - YYYY-MM-DD (Topic).md` with this exact structure:

```markdown
---
date created: YYYY-MM-DD
tags: [meeting]
category: Meeting
attendees: [Name, Name]
---

# MN - YYYY-MM-DD (Topic)

**Date:** Month D, YYYY
**Attendees:** Name, Name, Name

## Decisions

| Decision | Owner | Date |
|----------|-------|------|
| [what was decided] | [owner] | YYYY-MM-DD |

## Action Items

- [ ] Owner: Task description - due date

## Open Questions

- Question that wasn't resolved

## Discussion Notes

**Topic 1**
- Key point with **bold detail**

**Topic 2**
- Key point
```

If today's daily note exists at `Daily/DN - YYYY-MM-DD.md`, add a link under `## Meetings`:
```markdown
- [Time if known] [[MN - YYYY-MM-DD (Topic)]] - one-line summary
```

## Step 5 — Zapier Webhook (if configured)

After saving, check if `$ZAPIER_MEET_WEBHOOK` is set as an environment variable.

If set, fire:
```bash
curl -s -X POST "$ZAPIER_MEET_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d "{\"meeting\":\"TOPIC\",\"date\":\"DATE\",\"decisions\":[],\"action_items\":[],\"open_questions\":[]}"
```

Populate the arrays from what was extracted. If the webhook fails or isn't set, continue silently — mention it in the output only if the user has Zapier configured and it didn't fire.

## Step 6 — Confirm Output

Tell the user:
- Filename and location of the saved note
- Number of decisions captured (with a one-line preview of the most important one)
- Number of action items captured
- Whether Zapier fired (and to which destination)

Do not ask for confirmation before writing — just write it. The user can request changes.
