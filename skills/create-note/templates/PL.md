# PL Template - Implementation Plan

## Frontmatter additions

```yaml
status: Draft
source: "[[SPC - related spec]]"
ceremony_tier: light | standard | heavy
completed: 0
total: 0
```

Tags: `[plan, <project-tag>]`

## Reference files

Read `references/plan-guide.md` for the oracle-informed plan writing guide.

## Entry

1. Read the source spec. If no spec given, ask.
2. Check for review artifacts in `<project>/reviews/`. Use them as primary input if they exist.
3. Read project `CLAUDE.md`, `lessons.md`, and `REF - Agent Lessons.md`.
4. If no review artifacts exist, warn: "Spec hasn't been reviewed. Recommend /review-spec first. Proceed anyway?"

## Oracle check

Query the cross-cutting spec-driven-development oracle (`40fc91f1`) and any project-specific oracle: "What are proven implementation approaches and common pitfalls for building {plan subject}?" Surface as a proposition. Never silently apply oracle recommendations.

## Classify tier

Assess from the spec's scope, FR count, and systems touched:

| Tier | Signals | Plan shape |
|------|---------|------------|
| **Light** | <15 tasks, no DB/deploy, config/docs/skill work | Flat task table. No phases. |
| **Standard** | 15-40 tasks, auth/schema/deploy work, single service | Phased plan with vertical slices. Deploy gates on production work. |
| **Heavy** | 40+ tasks, multi-service, infrastructure, high risk | Full phased plan with risk register, audit gates. |

Present assessment: "This looks **{tier}** (~{N} tasks). Plan shape: {description}. Agree?"

## Design exploration (Standard + Heavy only)

Before task planning, understand how the spec maps to the codebase.

1. **Standard:** Quick codebase scan. Note discrepancies between spec assumptions and code reality. No formal artifact.
2. **Heavy:** Produce a Design Discussion artifact. Present open questions one at a time.
3. **Light:** Skip. Read code during drafting.

## Plan structure

Save to `<project>/plans/{today}/PL - {Name}.md`. Detailed structure guidance in `references/plan-guide.md`.

All tiers include:
- Frontmatter with tracking fields
- Task table(s) with Status, Acceptance Criteria, Dependencies, Notes
- Work Log section

Standard and Heavy add:
- Decision Log (from review clarifications)
- Phases with user-testable outcomes
- Parallel execution markers `[P]` on independent tasks

Heavy adds:
- Risk Register
- Phase risk ratings with audit gate assignments

## Writing rules

These rules encode patterns from the spec-driven-development oracle (55 sources) and our own lessons.

### Task granularity
- Each task produces **one clear deliverable** (a function, a test file, an API route, a migration). Not "work on the auth system."
- Tasks should take an agent **2-5 minutes of execution time**. If bigger, split. If smaller, batch with related work.
- Each task gets **exact file paths** (Create/Modify/Test). The agent should know what files it will touch before starting.

### File/domain isolation for parallel dispatch
- **Mark parallelizable tasks with `[P]`.** These must not share source files, test suites, or build outputs.
- **Shared foundations run first.** If multiple tasks depend on a shared component (DB migration, shared util, component library), assign those to a Phase 0 or a dedicated sequential task before parallel dispatch.
- **One agent, one domain.** Frontend worker writes to `apps/`, API worker writes to `services/`, DB worker writes migrations. They never touch the same directory simultaneously.

### Acceptance criteria per task
- Every task MUST have a **verification command** the agent runs after completing: a test command, a curl, a grep, a screenshot comparison. Not "it works."
- Write criteria for a **verifier agent**, not the implementor. A separate agent should be able to check each criterion mechanically.
- Include **expected output** alongside the command: "Run `npm test -- --grep feedback`. Expected: 3 tests pass, 0 fail."

### Dependencies
- Express dependencies as task numbers in a `Deps` column: `3, 4` means "cannot start until tasks 3 and 4 are done."
- A pending task with unresolved dependencies cannot be claimed by a worker.
- If no dependency, mark `--`.

### The plan is the tracker
- No external PM tool required. Agents update Status inline and append to the Work Log.
- **Status values:** `todo`, `in-progress`, `done`, `blocked`, `skipped`
- Workers report: what was done, commit hash, verification result. The orchestrator updates the plan file.
- Any agent can read the plan frontmatter (`completed` / `total`) to know progress without parsing the full document.

### Vertical slicing
- Every phase delivers a **user-testable outcome**. No horizontal phases ("Phase 1: all DB work, Phase 2: all API work").
- Each vertical slice should be independently deployable when possible.
- Phase checkpoints validate the slice works before moving to the next.

### Scope discipline
- **No implementation in the spec, no requirements in the plan.** Clean boundary.
- **No soak periods.** Convert "monitor for N days" to concrete validation tasks.
- Tasks implement what the spec says. If the plan reveals the spec is missing something, surface it as a decision, don't silently add scope.

## Task table format

```markdown
| # | Task | Status | Acceptance Criteria | Deps | Files | Notes |
|---|------|--------|---------------------|------|-------|-------|
| 1 | Create migration for voice_feedback tables | todo | Run `alembic upgrade head`. Tables exist: `\d kb.voice_feedback` | -- | `migrations/040_voice_feedback.py` | |
| 2 | [P] Build microphone button component | todo | Component renders. Click starts Web Speech API. Recording indicator visible. | 1 | `apps/kb/src/components/MicButton.tsx` | |
| 3 | [P] Create feedback API route | todo | `curl -X POST /api/ai/feedback/submit` returns 201 with valid payload | 1 | `apps/kb/src/app/api/ai/feedback/submit/route.ts` | |
```

## Work Log format

```markdown
## Work Log
| Date | Task # | Agent | What was done | Commit |
|------|--------|-------|---------------|--------|
```

Agents append one row per completed task.

## Frontmatter tracking

```yaml
completed: 0
total: 12
ceremony_tier: standard
```

Agents update `completed` as tasks finish. Grepable for progress without reading the full plan.

## Show plan to user

1. Summarize: phases (if any), total tasks, key dependencies, parallel dispatch opportunities
2. Highlight decisions made beyond what the spec/review covered
3. "Plan has X tasks across Y phases. Z tasks are parallelizable."

## Handoff

After the user approves:
1. Update status to "Approved"
2. Offer: "Run `/implement` now, or make changes first?"
