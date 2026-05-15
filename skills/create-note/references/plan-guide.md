# Plan Writing Guide

The definitive guide for writing agent-dispatchable implementation plans. Informed by the Spec-Driven Development oracle (55 sources, 2026-04-30) and our own implement skill's production experience.

A plan translates a spec's WHAT into HOW and IN WHAT ORDER. The plan file IS the tracker: agents read it, update task status inline, and append to the work log. No external PM tool required.

## The plan's role in the pipeline

```
Spec (what to build) → Plan (how to build it) → Implement (dispatch workers)
```

The spec defines behavior, interfaces, and constraints. The plan defines task decomposition, sequencing, dependencies, and verification commands. The implement skill reads the plan and dispatches workers. Clean boundaries: no requirements in the plan, no build order in the spec.

## Task decomposition principles

### Right-sized tasks

The optimal granularity is a self-contained unit that produces a clear deliverable. Too fine wastes context on setup and coordination. Too coarse causes agents to lose track and drift.

| Too small | Right-sized | Too large |
|-----------|-------------|-----------|
| "Add import statement" | "Create the MicButton component with recording indicator" | "Build the entire feedback UI" |
| "Write one test case" | "Write tests for the feedback API submit endpoint" | "Write all tests" |
| "Add a column" | "Create migration for voice_feedback tables" | "Set up the whole database layer" |

Each task should take an agent **2-5 minutes of execution time**. If you can describe it in one sentence and verify it with one command, it's the right size.

### Exact file paths

Every task MUST include the specific files the agent will create or modify. This serves two purposes:

1. The agent knows exactly where to work without exploring the codebase
2. The orchestrator can detect file conflicts between tasks before dispatch

```
| Files | apps/kb/src/components/MicButton.tsx (Create), apps/kb/src/components/KBChat.tsx (Modify) |
```

### Verification commands per task

Every task MUST include a command the agent runs after completing to verify success. This is the single highest-leverage improvement from the oracle research.

**Good acceptance criteria:**
```
Run `npm test -- --grep MicButton`. Expected: 3 tests pass, 0 fail.
Run `curl -sf http://localhost:3000/api/ai/feedback/submit -X POST -d '{"items":[]}' -H 'Content-Type: application/json'`. Expected: 400 (empty items).
Run `psql -c "\d kb.voice_feedback"`. Expected: table exists with columns session_id, user_id, submitted_at.
```

**Bad acceptance criteria:**
```
Component works correctly.
API endpoint responds properly.
Tables are created.
```

## Parallel dispatch patterns

### Mark parallelizable tasks

Tasks that can run simultaneously get a `[P]` marker. These tasks MUST NOT share:
- Source files (same `.tsx`, `.py`, `.ts`)
- Test suites (same test file or test DB)
- Build outputs (same Docker image)
- Git branch (unless using worktrees)

### Shared foundations first

If multiple tasks depend on the same foundation (DB migration, shared component, utility function), that foundation runs as a sequential prerequisite before any parallel dispatch.

```
Phase 0 (sequential):
  T1: Create DB migration for voice_feedback tables

Phase 1 (parallel):
  T2: [P] Build MicButton component          → apps/kb/src/components/
  T3: [P] Create feedback API route           → apps/kb/src/app/api/
  T4: [P] Register feedback prompt in gateway → AI gateway config
```

T2, T3, and T4 all depend on T1 but don't touch each other's files. Safe to parallelize.

### Domain isolation

The safest parallel pattern assigns each worker a distinct domain:

| Worker | Domain | Files |
|--------|--------|-------|
| Frontend worker | UI components | `apps/kb/src/components/`, `apps/kb/src/app/` pages |
| API worker | Backend routes | `apps/kb/src/app/api/` routes |
| DB worker | Schema | `migrations/`, seed scripts |
| Config worker | Infrastructure | Docker, env vars, prompt templates |

Workers in different domains can run simultaneously. Workers in the SAME domain run sequentially.

## Plan tiers

### Light (<15 tasks)

Flat task table, no phases. For config changes, documentation, skill work, single-endpoint additions.

```markdown
## Tasks
| # | Task | Status | Acceptance Criteria | Deps | Files | Notes |
|---|------|--------|---------------------|------|-------|-------|
| 1 | ... | todo | ... | -- | ... | |
```

### Standard (15-40 tasks)

Phased plan with vertical slices. Each phase delivers a user-testable outcome.

```markdown
## Decision Log
| # | Decision | Rationale | Source |
|---|----------|-----------|--------|

## Phase 1: {User-testable outcome}
| # | Task | Status | Acceptance Criteria | Deps | Files | Notes |
|---|------|--------|---------------------|------|-------|-------|

## Phase 2: {Next user-testable outcome}
...
```

### Heavy (40+ tasks)

Everything in standard, plus risk register, audit gates, and structure outline.

## Vertical slicing

Every phase delivers something the user can test. No horizontal phases.

**Bad (horizontal):**
- Phase 1: All database work
- Phase 2: All API work
- Phase 3: All frontend work

**Good (vertical):**
- Phase 1: Voice recording works (DB table + API route + MicButton component)
- Phase 2: Feedback conversation works (prompt + chat integration + structured output)
- Phase 3: Submit and review (submit API + review pipeline integration)

Each vertical slice is independently deployable when possible. Phase checkpoints validate the slice works before the orchestrator moves to the next.

## The plan as tracker

### Inline status updates

Workers update task status directly in the plan file:

```markdown
| 3 | Create feedback API route | done | curl returns 201 | 1 | route.ts | commit `a1b2c3d` |
```

The orchestrator updates `completed` in frontmatter after each task.

### Work Log

Every plan ends with a Work Log. Agents append one row per completed task:

```markdown
## Work Log
| Date | Task # | Agent | What was done | Commit |
|------|--------|-------|---------------|--------|
| 2026-04-30 | 1 | db-worker | Created migration 040_voice_feedback.py | `a1b2c3d` |
| 2026-04-30 | 2,3 | frontend-worker, api-worker | MicButton + feedback route (parallel) | `d4e5f6g`, `h7i8j9k` |
```

### Frontmatter progress

```yaml
completed: 7
total: 12
ceremony_tier: standard
```

Any agent can grep frontmatter to know progress without reading the full plan.

## Anti-patterns

1. **Horizontal phases.** "Phase 1: all DB, Phase 2: all API" delivers nothing testable until the end. Use vertical slices.
2. **Missing verification commands.** "It works" is not an acceptance criterion. Include the exact command and expected output.
3. **Unscoped file access.** Tasks without explicit file paths let agents wander the codebase. Name every file.
4. **Implicit dependencies.** If T3 requires T1's migration, say so in the Deps column. Don't rely on ordering.
5. **Over-engineering ceremony.** A 10-task config change doesn't need phases, a decision log, or a risk register. Match ceremony to complexity.
6. **Soak periods.** "Monitor for 3 days" blocks the plan. Convert to concrete validation: "Run 100 test inputs, verify 0 errors."
7. **Scope expansion.** If the plan reveals the spec is missing something, surface it as a decision. Don't silently add tasks that aren't in the spec.

## Oracle reference

This guide is informed by the Spec-Driven Development oracle (`40fc91f1`, 55 sources). Key plan-specific findings:

- **Task granularity:** Self-contained units producing clear deliverables, 2-5 minutes per task (Anthropic agent teams, Superpowers framework)
- **File isolation:** Git worktrees for parallel workers, explicit file ownership per task (HITL comparative analysis)
- **Verification commands:** Exact commands with expected output, not "it works" (Superpowers verification-before-completion)
- **Adversarial verifier:** Implementor and verifier have opposing goals (Augment Code, Spec Kit)
- **Plan-as-tracker:** Filesystem-based progress tracking, no PM relay agents (our implement skill, Anthropic research)
- **Vertical slicing:** INVEST framework, independently-deployable phases (intent-driven.dev)

Full grounding report: [[ARE - Spec-Driven Development Grounding Report]]
