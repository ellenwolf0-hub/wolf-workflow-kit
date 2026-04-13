---
name: log-work
description: >-
  Log work to the daily note. Use when the user says "log this", "log work",
  "add to worked on", "update the daily note", or wants to capture what they
  just completed. Also trigger on "what did I work on" to retroactively log
  from the conversation.
---

# Log Work

Log what you did to the daily note so nothing gets lost between sessions.

**Arguments:** $ARGUMENTS — Description of work, path to a plan, or nothing (will scan the conversation).

## Step 1 — Determine What to Log

If $ARGUMENTS provided, use those. Otherwise, scan the current conversation for:
- Files created or modified (specs, plans, meeting notes, drafts)
- Decisions made
- Research completed
- Projects moved forward

If it's ambiguous, ask for confirmation before writing.

## Step 2 — Identify the Topic

Match the work to a **project name** — the broadest stable label, not the specific activity:
- "GROW Program", not "GROW Q2 calibration prep"
- "Wolf Workflow Kit", not "SKILL.md update session"
- "Project Metro", not "Metro kickoff alignment call"

Plans, activities, and phases are detail that goes in the entry. The heading is the project.

## Step 3 — Merge Check (Before Writing)

Before creating a new heading, scan ALL existing headings under `## Worked On`:

- **One heading per project** — all GROW work goes under one `### GROW Program` heading
- If a matching heading exists, append new bullets (consolidate if over 4 lines)
- If no match, create a new `### Project Name` heading — new topics go at the **top**

## Step 4 — Update the Daily Note

Read today's daily note: `Daily/DN - YYYY-MM-DD.md`

Add concise, action-oriented bullets under the project heading:

**Format:**
```markdown
## Worked On

### GROW Program
- **Finalized Q2 calibration ratings** for Jordan Kim's org — 12 employees reviewed, 3 flagged for stretch goals
- Drafted comp memo for Taylor Chen — [[MN - 2026-04-13 (Calibration Taylor Chen)]]

### Wolf Workflow Kit
- Fixed setup.sh to install all 17 skills (was only installing 6)
- Created GETTING_STARTED.md — cold-start guide for new users
```

**Rules:**
- Lead with what moved forward: "Built", "Drafted", "Resolved", "Captured", "Finalized"
- Bold the key outcome or artifact
- Link to artifacts created using `[[wikilink]]` format
- **≤ 4 lines per project** (heading + 3 bullets max) — if there's more, consolidate
- No play-by-play — write like a 30-second standup update to yourself

**Good:**
```
- **Ran calibration with Jordan** — 4 decisions captured, comp analysis due Friday
```

**Bad:**
```
- Calibration session step 1 complete, discussed ratings, reviewed comp bands,
  Jordan agreed on 6% merit for Taylor, need to send to Finance
```

## Step 5 — For Complex Projects: Work Log File

If the work has 5+ distinct sub-tasks, is against a plan file, or is too detailed for 3 bullets:

Create or update `Projects/WL - Topic.md`:

```markdown
---
date created: YYYY-MM-DD
tags: [work-log]
category: Work Log
project: "Project Name"
---

## YYYY-MM-DD

### Session description
- What changed and why
- Decisions made and the reasoning
- Links to artifacts
- What was tried and didn't work (prevents repeating it)
```

Then summarize to the daily note in 2-3 bullets with a link:
```
- [[WL - GROW Program|Full session log]]
```

The daily note is the human layer — brief and scannable. The work log is the agent layer — complete and detailed.

## Formatting Rules

- Action-oriented bullets — outcomes, not process
- Bold the key result
- Wikilinks to output files
- No prose paragraphs — bullets only
- Newer entries at top of `## Worked On`
- **≤ 4 lines per project**
