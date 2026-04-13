---
name: learn
description: >-
  Capture a reusable lesson or rule from the current session and write it to
  lessons.md or agents.md. Use when the user says "/learn", "remember this",
  "add that as a lesson", "save that rule", "note that for next time",
  or after a correction or non-obvious fix that cost real time.
---

# Learn — Capture a Lesson or Rule

Extract what's worth keeping from the current session and persist it so future
sessions don't repeat the same mistakes or re-discover the same workarounds.

**Arguments:** $ARGUMENTS — Optional: description of what to capture.
If omitted, scan the current conversation.

## Step 1 — Identify What to Capture

If $ARGUMENTS provided, use those as the lesson subject.

Otherwise, scan the current conversation for:
- A correction the user made ("no, not that", "that's wrong", "don't do that")
- A failure that cost real time and has a non-obvious fix
- A workaround that contradicts what you'd normally expect
- A preference the user stated that applies beyond this session
- A decision about how to handle a recurring situation

**Gate check — only capture if:**
- It would trip up a fresh agent who hasn't seen this conversation
- It contradicts a reasonable default assumption
- It cost real time to discover

Skip obvious things ("always save files before closing") and one-off situation-specific facts.

## Step 2 — Classify

**Lesson (advisory):** Context that helps an agent make better decisions.
→ Lives in `vault/lessons.md`
→ Format: C-A-W (Condition → Action → Why)

**Rule (mandatory):** Behavior that must always happen, no exceptions.
→ Lives in `agents.md` under a `## Rules` section
→ Format: short imperative title + 1-2 sentence explanation

When in doubt, classify as a lesson. Rules are for true non-negotiables.

## Step 3 — Scope

Use the narrowest applicable scope:
1. **Project-specific** — only applies to one initiative → put in project's `lessons.md` if it exists
2. **People Ops domain** — applies across People Ops work → put in vault `lessons.md`
3. **General agent behavior** — applies everywhere → put in `agents.md` Rules section

## Step 4 — Dedup Check

Before writing, read the target file and search for similar entries by key terms.
If a similar lesson exists, update it rather than duplicate. Also check one scope
level up — if a project lesson is actually universal, put it at the vault level.

## Step 5 — Draft and Get Approval

Present the draft lesson to the user for approval.

**Lesson format (C-A-W):**
```
**L-N: [Short imperative title]**
*When:* [condition — what situation triggers this]
*Do:* [action — numbered steps if multi-step]
*Why:* [consequence of getting this wrong, or why this is non-obvious]
```

**Rule format:**
```
**[Short imperative title]** — [1-2 sentence explanation of what this means in practice]
```

Ask: "Does this capture it right, or do you want to adjust the wording?"

Apply any corrections before writing.

## Step 6 — Write

Append the approved lesson to the target file, matching existing formatting.

For `lessons.md`: append under `## Your Lessons` section.
For `agents.md`: append under `## Rules` section (create section if it doesn't exist).

Number lessons sequentially from the current highest L-N in the file.

## Step 7 — Confirm

Tell the user what was written and where:
> "Added **L-12: [title]** to lessons.md. Claude will load this at the start of every session."
