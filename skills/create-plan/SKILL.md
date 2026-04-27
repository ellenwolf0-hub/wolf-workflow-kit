---
name: create-plan
description: >-
  Take a reviewed spec (SPC - *.md) and produce an implementation plan with depth proportional
  to complexity — flat task lists for simple work, phased plans for complex systems. The plan file
  IS the tracker — agents read it, update task status inline, and append to the work log. No
  external project management sync required. Use this skill when the user wants to plan from a
  spec, create a plan, turn a spec into tasks, or says "plan this", "create a plan", "make this
  actionable", "set up tasks". Also trigger after /create-spec or /review-spec completes.
  Second step in the spec>plan>implement pipeline.
---

# Plan Creator

Produce a plan document from a reviewed spec. Plan depth matches work complexity. A 10-task config
change gets a flat task list. A 68-task platform build gets phased vertical slices.

**Design principles:**
- The plan defines *how* and *in what order*.
- Every task has acceptance criteria a different agent can verify independently.
- Vertical slices only — every phase delivers a user-testable outcome.
- **The plan file is the tracker.** No external PM tool required. Agents update task status
  inline and append to the work log. Any agent can read the plan to know current state.

## Entry

```
/create-plan <path-to-spec>
```

1. Read the spec. If no path given, ask.
2. Check for review artifacts in `Projects/Reviews/` — if they exist, use them as primary input.
3. Read `agents.md` and `lessons.md`.
4. If no review artifacts exist, warn: "Spec hasn't been reviewed. Recommend /review-spec first. Proceed anyway?"

## Classify Tier

Assess from the spec's scope, FR count, and what systems are touched:

| Tier | Signals | Plan shape |
|------|---------|------------|
| **Light** | <15 tasks, no DB/deploy, config/docs/skill work | Flat task table. No phases. `ceremony_tier: light` |
| **Standard** | 15-40 tasks, auth/schema/deploy work, single service | Phased plan with vertical slices. Deploy gates on production work. `ceremony_tier: standard` |
| **Heavy** | 40+ tasks, multi-service, infrastructure, high risk | Full phased plan with risk register, audit gates, all ceremony. `ceremony_tier: heavy` |

Present assessment to user: "This looks **{tier}** (~{N} tasks). Plan shape: {description}. Agree?"

## Design Exploration (Standard + Heavy Only)

Before task planning, understand how the spec maps to the codebase.

0. **Oracle check:** Read the project's PJL frontmatter for `oracles:`. If an oracle exists, query it for implementation patterns: "What are proven implementation approaches and common pitfalls for building {plan subject}?" Surface as a proposition: "Oracle suggests {approach} based on {source}. Want to follow this pattern or take a different approach?" See [[SD - Oracle System]].
1. If the project has a repo, explore it: current state of modules the spec touches, existing patterns, gaps between spec assumptions and reality.
2. For heavy tier (>500 LOC or multi-module): produce a Design Discussion artifact at `Projects/Designs/DD - {Name}.md`. Present open questions to user one at a time.
3. For standard tier: quick codebase scan, note discrepancies, no formal DD artifact.
4. For light tier: skip. Read the code when needed during drafting.

## Draft the Plan

Save to `Projects/PL - {Name} Implementation Plan.md`.

### Task Table Format (All Tiers)

Every task table includes Status and Notes columns for agent tracking:

```markdown
| # | Task | Status | Acceptance Criteria | Deps | Prior | Notes |
|---|------|--------|---------------------|------|-------|-------|
| 1 | ... | todo | ... | -- | | |
| 2 | ... | todo | ... | 1 | | |
```

**Prior column (standard+ tiers):** Lists earlier fixes targeting the same failure family.
If count >= 2 with the same family (e.g., "prompt edits for title shape"), route the next
attempt to a DIFFERENT family (post-processor, schema enforcement, decomposition).
Source: MQ-12 (fighting the prompt). Leave blank for tasks with no prior intervention history.

**Status values:** `todo`, `in-progress`, `done`, `blocked`, `skipped`

Agents update Status inline as they work. Notes capture blockers, decisions, or commit hashes.

### Frontmatter Tracking

Every plan includes machine-readable progress in frontmatter:

```yaml
completed: 0
total: 12
live_monitor_required: false    # true when any task runs >10 min
synthetic_repro_required: false  # true when fixing transient/intermittent failures
blind_dimension_scan: pending    # complete | skipped | pending
```

Agents update `completed` as tasks finish. Any agent can grep frontmatter to know progress
without reading the full plan. The three new fields are grep-able triggers:
`/implement` auto-dispatches a live monitor when `live_monitor_required: true`,
requires synthetic verification when `synthetic_repro_required: true`, and blocks
scale launch until `blind_dimension_scan: complete`.
Source: RC-1, MQ-7, MQ-20 (marathon postmortem).

### Work Log

Every plan ends with a Work Log section. Agents append one row per completed task:

```markdown
## Work Log
| Date | Task # | Agent | What was done | Commit |
|------|--------|-------|---------------|--------|
```

This replaces both external PM tools and separate WL files for most plans.

### Light Tier Plan

Flat task table (no phases), frontmatter with `ceremony_tier: light`, source link, task table
with Status/Notes, work log. No decision log unless decisions were made during planning.

### Standard Tier Plan

Phased plan with vertical slices. Include:
- Frontmatter with `ceremony_tier: standard` and `completed`/`total`
- Decision Log (from review clarifications)
- Phases with user-testable outcomes
- Task tables with Status, Acceptance Criteria, Deps, Notes
- Work Log
- No risk register unless review flagged high risks

### Heavy Tier Plan

Everything in standard, plus:
- Risk Register
- Phase Risk Ratings with audit gate assignments
- Pre-Implementation Review summary
- Structure Outline artifact

## Planning Principles (All Tiers)

- **Vertical slicing:** Every phase delivers a user-testable outcome. No horizontal phases.
- **Acceptance criteria are mandatory:** Concrete, verifiable checks. "curl /api/auth returns 200" not "auth works".
- **No soak periods:** Convert "monitor for N days" to concrete validation tasks.
- **Tasks < 2 hours of agent time.** If bigger, split.
- **Dependency chains explicit.** If T3 needs T1 done, say so.
- **Decisions from review become Decision Log entries.**
- **No implementation in the spec, no requirements in the plan.** Clean boundary.

## Show Plan to User

1. Summarize: phases (if any), total tasks, key dependencies
2. Highlight decisions you made beyond what the spec/review covered
3. "Plan has X tasks."

## Handoff

After presenting the plan:
1. Update plan status to "Approved -- Ready for Implementation"
2. Proceed to `/implement`

## Reference Files

| File | Purpose |
|------|---------|
| `references/dd-template.md` | Design Discussion template (standard/heavy) |
| `references/so-template.md` | Structure Outline template (heavy only) |
