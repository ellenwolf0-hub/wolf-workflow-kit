---
name: closeout
description: >-
  End the session by logging work and setting up tomorrow's context. Use when the
  user says "/closeout", "closeout", "wrap up", "I'm done for today", "end of day",
  "wind down", "call it a day", "closing out", or "I'm done". Also trigger on
  casual session-ending phrases like "ok I'm done" or "that's it for today".
---

# Closeout — End of Session

Log what happened today and make sure nothing gets lost between now and tomorrow.

## Step 1 — Scan the Session

Read back through the conversation and identify:

- **What was worked on** — files created or modified, meetings captured, drafts written, decisions made, research completed, problems solved
- **What's in progress** — work started but not finished, or work that has a clear next step
- **Open action items** — tasks that came up in meetings or conversation that haven't been tracked yet

Group by project or topic. For each item, determine:
1. Is it done, or does it need a pickup doc for tomorrow?
2. If it needs a pickup: what would someone need to know to continue without re-explaining everything?

**Before logging:** Present your summary and ask: "Does this look right?" Keep it brief — a few bullets showing what you'd log and which topics need pickups. Wait for confirmation before writing.

## Step 2 — Update the Daily Note

Open today's daily note at `Daily/DN - YYYY-MM-DD.md`.

Under `## Worked On`, add a `### Topic Name` section for each project worked on. Put the newest entries at the top.

**Format:**
```markdown
## Worked On

### People Team Workflow Kit
- Built /orient and /meet skills — Tier 1 skills complete
- Zapier webhook confirmed working end-to-end (Slack DM received)
- Plan updated: Phase 2 complete, Phase 3 in progress

### Calibration — Taylor Chen
- Ran /meet on calibration transcript — [[MN - 2026-04-09 (Calibration - Taylor Chen)]] created
- 4 decisions captured, 2 action items assigned
```

**Rules:**
- Bullets are action-oriented. Start with a verb: "Built", "Captured", "Drafted", "Resolved".
- Bold key numbers or outcomes: "**4 decisions** captured", "**6% merit** approved".
- Link to any artifacts created using `[[wikilink]]` format.
- Max 5 bullets per topic — consolidate if there's more.
- If a topic heading already exists in the daily note, append to it rather than creating a duplicate.

## Step 3 — Create Pickup Docs

For each open item, create `Pickups/PIC - [Topic].md`.

**Check first:** Does a pickup for this topic already exist in `Pickups/` with `status: open` or `status: picked-up`? If yes, update it rather than creating a duplicate.

**Pickup format:**
```markdown
---
date created: YYYY-MM-DD
tags: [pickup]
category: Pickup
status: open
project: "[Project Name]"
---

# PIC - [Topic]

## Context
[1-2 sentences: what this is and why it matters. Enough that someone starting fresh understands the situation.]

## What Was Done
- [Concrete accomplishment]
- [Another accomplishment]

## What Needs to Happen Next
1. [Specific next action — not vague, not a list of options]
2. [Second step if applicable]

## Key Files
- [[MN - relevant meeting note]]
- [[any other relevant artifact]]

## Blockers or Dependencies
- [Anything that needs to happen first, or "None"]
```

**Quality rules for pickup docs:**
- "What Needs to Happen Next" must be specific enough that someone can start without asking a question. "Finish the spec" is bad. "Add the degradation matrix to Section 4 of the spec" is good.
- Context must be self-contained. Don't assume the next session remembers today's conversation.
- Verify any factual claims before writing them. Don't say "Zapier confirmed working" if you didn't test it this session.

## Step 4 — Zapier Webhook (if configured)

After updating the daily note, check if `$ZAPIER_CLOSEOUT_WEBHOOK` is set.

If set, build a payload from the worked-on items and fire:
```bash
curl -s -X POST "$ZAPIER_CLOSEOUT_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d "{\"date\":\"DATE\",\"worked_on\":[\"item1\",\"item2\"],\"open_items\":[\"item1\"]}"
```

If the webhook fails or isn't configured, continue silently.

## Step 5 — Confirm

Tell the user what was created — keep it brief:

```
Logged to today's daily note:
• People Team Workflow Kit — 3 bullets
• Calibration — 2 bullets

Pickups created:
• PIC - Taylor Chen Comp Analysis → Pickups/

Zapier fired → Coda tracker updated ✓
```

Don't recite the full content of each pickup — just names and locations. The user can open them if they want to review.
