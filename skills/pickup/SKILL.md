---
name: pickup
description: >-
  Load context from a pickup (PIC) document and get oriented to continue work.
  Use when the user says "pickup", "pick up", "what's on my plate", "what do I
  need to do", "get started", "load the pickup", "continue where I left off",
  "resume work", or points at a specific PIC document. Also trigger when the
  user opens a new session and says "ok what am I doing today" or "what was I
  working on". Run /orient first if it hasn't already run this session.
---

# Pickup — Load Context and Continue

Load a pickup document (PIC) and get oriented so work can resume without re-explaining anything.

## Pre-Flight: Orient Check

Before doing anything else, check whether `/orient` has already run in this session. Look for evidence in conversation history — vault context loaded, agents.md read, open pickups listed.

If `/orient` has NOT run: invoke it first. Pickup without orient means missing vault config, lessons, and interaction preferences. Do not skip this.

After orient completes, continue below.

## PIC Lifecycle

PICs have three statuses:

- **`open`** — created by closeout, waiting to be picked up
- **`picked-up`** — actively being worked on in a session
- **`closed`** — work is complete, removed from the open list

Manage these transitions. When you pick up a PIC, mark it `picked-up` immediately. When work is done, ask to close it. Don't let PICs accumulate in `picked-up` status across multiple sessions.

## Step 1 — Find the Pickup

**If the user pointed at a specific PIC:** Read it directly.

**If no PIC was specified:** Glob `Pickups/*.md`. Read each file's frontmatter and filter to `status: open` only.

- **Multiple open:** Present them — name, project, and first item from "What Needs to Happen Next." Ask which one to load.
- **Exactly one:** Confirm: "I found one open pickup: [topic]. Want me to load it?"
- **None:** "No open pickups. Starting fresh — what do you want to work on?"

## Step 2 — Load Context

Once you have the PIC:

1. Read the full PIC document
2. Read every file in the `## Key Files` section
3. Read the project's `agents.md` and `lessons.md` if they exist
4. If the PIC references a spec or plan, read those too

Build your understanding of: what this project is, what was already done, what comes next, and any blockers or decisions made in the previous session.

## Step 3 — Mark as Picked Up

Update the PIC frontmatter immediately:
- `status: open` → `status: picked-up`
- Add `picked_up_date: YYYY-MM-DD`

Do this before presenting the plan.

## Step 4 — Present the Plan

Brief orientation — keep it tight:

1. **One-line context** — project and what we're continuing
2. **Where we left off** — key outcome from the previous session (1-2 sentences)
3. **Today's plan** — the numbered next steps from the PIC as a proposed sequence
4. **Blockers** — anything in the way (or "none")

Ask: "Ready to start, or do you want to adjust?"

Once confirmed, begin work. You have full context — treat this as a continuation.

## Step 5 — Close When Done

When all steps are complete (or the user says they're done), ask:

> "The work from [topic] looks complete — [one-line summary of what was accomplished]. Can I close this pickup?"

If yes, update frontmatter:
- `status: picked-up` → `status: closed`
- Add `closed_date: YYYY-MM-DD`

Before closing, append to the PIC:

```markdown
## Closing Update
**Closed:** YYYY-MM-DD
**Outcome:** [1-2 sentences: what was accomplished vs. the original next steps]
**Artifacts:** [[links to anything produced]]
**Carry-forward:** [anything not completed, or "None — fully resolved"]
```

Also update today's daily note under `## Worked On`:
`- Closed [[PIC - Topic Name]] — [one-line outcome]`

## Lingering PIC Detection

If a PIC is still in `picked-up` status but hasn't been actively worked on during this session, ask before the session ends: "[[PIC - Topic]] is still marked as picked-up. Should I close it, carry it forward, or leave it for next session?"

## Local Customizations

If `LOCAL.md` exists in this skill directory, load and follow it after these instructions. Local instructions override upstream where they conflict.
