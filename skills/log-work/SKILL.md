---
name: log-work
description: >-
  Log work to the daily note. Use when the user says "log this", "log work",
  "add to worked on", "update the daily note", or wants to capture what they
  just completed. Works in two modes: simple (daily note only) or detailed
  (work log file + daily note summary). Also trigger on "what did I work on"
  to retroactively log from the conversation.
---

# Log Work

Log work to the daily note's `## Worked On` section, and optionally to a dedicated work log file for complex projects.

**Arguments:** $ARGUMENTS — Description of work, path to a plan, or nothing (will scan the conversation).

## Step 1 — Determine What to Log

If $ARGUMENTS provided, use those. Otherwise, scan the current conversation for:
- Files created or modified (specs, plans, meeting notes, drafts)
- Decisions made
- Research completed
- Projects moved forward

If it's ambiguous, ask for confirmation before writing.

## Step 2 — Choose the Mode

**Simple mode** (daily note entry only):
- Work fits in 2-4 bullets
- Single task or one-off research
- No associated plan file

**Detailed mode** (WL file + daily note summary):
- Work has 5+ distinct sub-tasks
- Work is against a plan (`PL -` file)
- Complex project with multiple moving parts
- User explicitly asks for a work log

Default to detailed when there's an associated plan. Otherwise default to simple.

## Step 3 — Identify the Topic

Match the work to a topic:
- If plan-backed: use the plan name (e.g., "Wolf Workflow Kit Implementation Plan")
- If project-scoped: use the project name (e.g., "GROW Program", "Project Metro", "Org Health Dashboard")
- If standalone: use a descriptive label (e.g., "Calibration Prep", "Comp Memos", "Vault Maintenance")

## Step 3b — Merge Check (Before Writing)

Before creating a new `###` heading, scan ALL existing headings under `## Worked On` for the same underlying project:

- **Match by project name first:** All GROW work = one `### GROW Program` heading. All Metro work = one `### Project Metro` heading. The heading is the project, not the specific activity.
- **Match by plan wikilink:** If the new entry references the same plan as an existing heading, append to it.

**When merging into an existing heading:**
- Use **bold sub-labels** to distinguish workstreams within one heading
- Consolidate older bullets if the entry exceeds 6 lines — summarize, don't enumerate

**One heading per project, not one per activity or session.**

## Step 4a — Simple Mode: Update Daily Note

1. Read today's daily note: `Daily/DN - YYYY-MM-DD.md`
2. Run the merge check — find any existing heading for this project
3. If match exists: append bullets (consolidate if over 6 lines)
4. If no match: create `### Topic Name` under `## Worked On` — new topics go at the **top**
5. Add concise, action-oriented bullets:
   - Lead with what was done: "Drafted", "Captured", "Resolved", "Built"
   - Bold key stats inline: "**4 decisions** captured", "**6% merit** approved"
   - Wikilink any artifacts created

## Step 4b — Detailed Mode: Work Log + Daily Note

### Work Log File

Create or update `Projects/WL - Topic.md`:

```markdown
---
date created: YYYY-MM-DD
tags: [work-log]
category: Work Log
plan: "[[PL - Plan Name]]"
project: "Project Name"
---

## YYYY-MM-DD

### HH:MM — Short description
- What changed and why
- Key decisions or outcomes
- Links to artifacts
```

### Daily Note Summary

Add **3-5 bullets max** under the topic heading — this is a summary, not a task log. Add a final bullet linking to the WL file: `- [[WL - Topic|Full log]]`

**Hard rule: ≤ 6 lines per topic** (heading + 5 bullets). Detail goes in the WL file. The daily note is scannable, not exhaustive.

## Formatting Rules

- Short, action-oriented bullets — outcomes, not play-by-play
- Bold key stats inline
- Wikilinks to output files
- No prose paragraphs — bullets only
- Newer entries at top of `## Worked On`
- **≤ 6 lines per topic**

## Examples

**Simple mode:**
```markdown
### Calibration — Taylor Chen
- Ran /meet on calibration transcript — [[MN - 2026-04-09 (Calibration - Taylor Chen)]] created
- **4 decisions** captured: Exceeds rating, 6% merit, coaching 1:1, Q3 promotion flag
- Jordan Kim owns comp analysis by Friday April 11
```

**Detailed mode (daily note summary):**
```markdown
### Wolf Workflow Kit — [[PL - Wolf Workflow Kit Implementation Plan|Plan]]
- Phase 0 complete — Slack MCP ✓, Granola ✓, Zapier webhook ✓
- Phase 1 complete — repo live at github.com/ellenwolf0-hub/wolf-workflow-kit
- Phase 2 in progress — /orient and /meet written, /closeout next
- [[WL - Wolf Workflow Kit|Full log]]
```
