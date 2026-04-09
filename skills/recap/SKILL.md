---
name: recap
description: >-
  Summarize what's happened in the current session. Use when the user says
  "recap", "what have we done", "where are we", "summarize the session",
  or before a closeout to check what should be logged.
---

# Recap — Session Summary

Summarize the current session so nothing gets lost and the user can confirm what should be logged.

**Arguments:** $ARGUMENTS — Optional scope (e.g., "recap just the GROW work" or "recap everything since 2pm").

## Step 1 — Scan the Session

Read back through the conversation and identify:

**Main thread:** What was the primary work? What moved forward?

**Branches:** Were there side topics, questions answered, decisions made along the way?

**Outputs produced:** Files written, specs drafted, notes created, messages sent.

**Open items:** Work that was started but not finished, questions unanswered, things explicitly deferred.

## Step 2 — Present the Recap

Structure:

```
## Session Recap — [Date, approximate time range]

**Main thread:** [1-2 sentences: the primary work and outcome]

**Also handled:**
- [Side topic or branch 1]
- [Side topic or branch 2]

**Produced:**
- [[artifact 1]]
- [[artifact 2]]

**Still open:**
- [Item that needs a pickup]
- [Question that wasn't answered]
```

Keep it scannable. This feeds directly into `/closeout` — the user should be able to confirm or correct it quickly.

## Step 3 — Ask What to Do With It

> "Does this look right? I can use this to run /closeout, or you can adjust anything first."
