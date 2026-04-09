---
name: create-pickup
description: >-
  Create a PIC (pickup) document for any open item. Use when the user says
  "create a pickup", "make a PIC", "save this for later", or wants to capture
  a specific next step as a pickup without running full closeout.
---

# Create Pickup — Write a PIC Document

Create a verified, self-contained pickup document for an open item.

**Arguments:** $ARGUMENTS — The topic to create a pickup for (e.g., "create a pickup for the Metro hub build").

## Step 1 — Gather the Context

Before writing, make sure you have:

1. **Topic** — What is this pickup for? (from $ARGUMENTS or ask)
2. **Project** — Which project does it belong to?
3. **What was done** — What progress has been made so far?
4. **What's next** — The specific next actions (not vague, not a list of options)
5. **Key files** — Any specs, plans, or meeting notes to link
6. **Blockers** — Anything that needs to happen first

If any of these are unclear, ask — but only one question at a time.

## Step 2 — Verify Before Writing

Before writing factual claims (e.g., "Zapier webhook confirmed working"), verify them against the current conversation or live state. Don't write things that aren't true as of right now — the next agent will trust this document.

## Step 3 — Write the PIC

Create `Pickups/PIC - [Topic].md`:

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
[1-2 sentences: what this is and why it matters. Self-contained — don't assume the next agent remembers today.]

## What Was Done
- [Concrete accomplishment]
- [Another]

## What Needs to Happen Next
1. [Specific first action — actionable enough to start without asking a question]
2. [Second step if applicable]

## Key Files
- [[relevant spec, plan, or meeting note]]

## Blockers or Dependencies
- [Anything that needs to happen first, or "None"]
```

## Step 4 — Confirm

Tell the user where the PIC was saved and what the next step is. If this is part of a closeout, continue with the closeout flow.
