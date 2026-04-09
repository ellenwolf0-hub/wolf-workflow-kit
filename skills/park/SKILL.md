---
name: park
description: >-
  Set aside in-progress work to return to later without losing context. Use when
  the user says "park this", "set this aside", "I need to switch gears", "come
  back to this later", "don't lose this context", or pivots to a different topic
  mid-session.
---

# Park — Preserve Context for Later

Save the current thread of work so it can be resumed without re-explaining anything.

**Arguments:** $ARGUMENTS — Optional label for what's being parked (e.g., "park the GROW narrative draft").

## Step 1 — Capture What's In Flight

Identify what's currently in progress:
- What work was being done?
- What's the last decision or output produced?
- What was the next step before the pivot?
- Any open questions or blockers?

## Step 2 — Create a Pickup Doc

Create `Pickups/PIC - [Topic].md` with:

```markdown
---
date created: YYYY-MM-DD
tags: [pickup, parked]
category: Pickup
status: open
project: "[Project]"
parked_at: YYYY-MM-DD HH:MM
---

# PIC - [Topic]

## Context
[1-2 sentences: what this is and why it matters]

## What Was Done
- [Concrete progress made before parking]

## Where We Left Off
[Exact stopping point — specific enough that resuming doesn't require re-reading the whole conversation]

## What Needs to Happen Next
1. [First action to take when resuming]
2. [Second action if applicable]

## Key Files
- [[any relevant artifacts]]

## Parked Context
[Any ephemeral context that won't be obvious from files alone — e.g., "Ellen was leaning toward the 6% merit option but hadn't decided", "the Coda query was returning stale data"]
```

## Step 3 — Confirm

Tell the user:
- PIC created at `Pickups/PIC - [Topic].md`
- How to resume: "Run `/pickup` and select [topic]"

Then help them pivot to whatever they want to work on next.
