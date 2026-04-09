---
name: plan-spec
description: >-
  Turn a reviewed spec into a phased implementation plan. Use when the user says
  "/plan-spec", "turn this into a plan", "plan this out", "create a plan from this spec",
  or after /review-spec passes. Produces a structured plan document with phases, tasks,
  dependencies, and acceptance criteria — the blueprint that guides execution. Run after
  /review-spec, not before.
---

# Plan Spec — Turn a Spec Into a Plan

Convert a reviewed spec into an actionable phased plan. Good plans prevent "what do we do next" paralysis and give anyone picking up the work a clear path forward.

**Arguments:** $ARGUMENTS — Path to the spec file (e.g., `Projects/SPC - GROW Refresh.md`).

## Step 0 — Gather Inputs

1. Read the spec at the path provided. If no path given, ask: "Which spec should I plan?"
2. Check for review artifacts: look for `Projects/Reviews/*/ARE - {spec_name} Spec Review.md`
   - If a review exists: read it, especially the Clarification Log and Applied Changes — these represent decisions already made that must shape the plan
   - If no review exists: warn the user — "This spec hasn't been reviewed yet. I recommend running `/review-spec` first to catch gaps before planning. Continue anyway?"
3. Read `agents.md` and `lessons.md` for any planning constraints or gotchas relevant to this initiative

## Step 0.5 — Classify Complexity

Before drafting, assess the work to match the plan's structure to the actual scope.

**Light** — Documentation, new skills, templates, process clarification. No new tools, no budget. < 10 tasks. Examples: updating an onboarding checklist, writing a new calibration guide, adding a skill to the toolkit.

**Standard** — Program design, workflow creation, cross-functional coordination. Some tool changes, moderate stakeholder involvement. 10–30 tasks. Examples: redesigning the GROW review process, building a new onboarding program, creating a comp workflow.

**Heavy** — Major initiatives with significant change management, multiple workstreams, budget, or external dependencies. 30+ tasks. Examples: org redesign, large-scale L&D build, policy overhaul with legal/compliance involvement.

Present your assessment and ask about ceremony:

> "This looks like a **[complexity]** initiative (~[N] tasks). Which of these do you want?"

Options (suggest defaults based on complexity):
- **Phased plan** — group tasks into phases with checkpoints _(on for Standard/Heavy, optional for Light)_
- **Acceptance criteria per task** — each task has a concrete "done" check _(always recommended)_
- **Checkpoint reviews** — explicit pause-and-review moments between phases _(on for Heavy, optional for Standard)_
- **Risk tracking** — maintain a risk register throughout _(on for Standard/Heavy)_

Record selections in the plan frontmatter:
```yaml
complexity: light | standard | heavy
ceremony:
  phases: true | false
  acceptance_criteria: true | false
  checkpoints: true | false
  risk_tracking: true | false
```

## Step 1 — Draft the Plan

**Filename:** `Projects/PL - {spec_name_without_SPC_prefix} Plan.md`

If a project subfolder exists under `Projects/`, place the plan there alongside its spec.

```markdown
---
category: Plan
date created: {today}
date modified: {today}
source: "[[{spec_filename}]]"
status: Draft — Pending Review
---

# {Initiative Name} — Implementation Plan

## Source Spec
[[{spec_filename}]]

## Review
[[{review_filename}]] (if exists)

## Pre-Implementation Review
{If review artifacts exist, include the Summary Verdict and any open Critical issues here.
Anyone reading the plan sees the reviewer's concerns upfront.}
{If no review: "Not reviewed — proceed with caution."}

## Progress Overview

| Phase | Name | Tasks | Completed | Status |
|-------|------|-------|-----------|--------|
| 0 | Prerequisites | N | 0 | Not Started |
| 1 | {name} | N | 0 | Not Started |
{etc.}

## Decision Log

Decisions made during planning that affect scope or structure.

| ID | Date | Decision | Rationale |
|----|------|----------|-----------|
| D-1 | {today} | {from clarification log or spec review} | {why} |

## Phase 0 — Prerequisites

**Outcome:** {What will be true after this phase that wasn't before.}
**Checkpoint:** {Explicit conditions that must be true before Phase 1 starts.}

| ID | Task | Description | Acceptance Criteria | Deps |
|----|------|-------------|---------------------|------|
| T0.1 | {task name} | {what needs to happen} | {concrete, verifiable check} | — |
| T0.2 | {task name} | {what needs to happen} | {concrete, verifiable check} | T0.1 |

## Phase 1 — {Name}

**Outcome:** {What the user or team can DO after this phase that they couldn't before.
Each phase must deliver something observable — not just "complete the database layer."}
**Checkpoint:** {What must be true before Phase 2 starts.}

| ID | Task | Description | Acceptance Criteria | Deps |
|----|------|-------------|---------------------|------|
| T1.1 | | | | T0.2 |

{Add phases as needed. Each phase = a vertical slice of value.}

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| {from spec review risk surface} | H/M/L | H/M/L | {action} |
```

### Planning Principles

- **Phase 0 is always setup and prerequisites** — anything that must be true before the real work starts (stakeholder alignment, access/permissions, existing process documentation, tool setup)
- **Each phase delivers something observable** — "managers can submit calibration ratings" not "build the calibration form." If a phase doesn't let someone do something new, restructure it.
- **Tasks should be completable in one focused session** — if a task would take more than a day, split it
- **Every task needs acceptance criteria** — a concrete check that's either true or false. Good: "Manager can submit calibration in the new form and see confirmation." Bad: "Form works."
- **Dependency chains must be explicit** — if T1.3 can't start until T1.1 is done, say so
- **Decisions from the clarification log become Decision Log entries** — with rationale
- **Risks from the spec review become Risk Register entries** — with mitigations
- **No soak periods or "run for N days" tasks** — convert monitoring gates to concrete validation tasks ("verify no errors in last 50 submissions" not "observe for 2 weeks")

## Step 2 — Show Plan to User

Before finalizing:

1. Summarize: number of phases, total tasks, key dependencies, key risks
2. Call out any decisions you made that the spec or review didn't cover — these need buy-in
3. Ask: "This plan has X phases and Y tasks. Anything you want to adjust before I finalize it?"

Apply any changes, then finalize the document.

## Step 3 — Save and Confirm

Save the plan file. Update today's daily note under `## Worked on` with a link to the plan.

Confirm to the user:
- Where the plan was saved
- What Phase 0 looks like (the immediate first steps)
- Offer: "Ready to start executing? You can use `/pickup` to load any task, or just tell me what to work on first."

## What This Skill Does NOT Do

- It does not review or critique the spec — that's `/review-spec`
- It does not execute any of the tasks — it only produces the plan
- It does not push to external project trackers (Plane, Jira, Linear) unless you configure that separately
- It does not start work — Phase 0 is ready to begin, but nothing runs until you decide to start
