---
name: retro
description: Run a retrospective — audit what happened, analyze what worked and what didn't, and apply process improvements. Works for sprints, phases, milestones, or any bounded unit of work. Also generates the handoff section (carry-forwards, infra changes, Plane refs) so the next session can resume efficiently. Use after completing a sprint or phase, when the user says "retro", "retrospective", "sprint review", "what went well", "what went wrong", "what can we improve", "review the sprint", or wants to analyze the build:fix ratio and prevent recurring issues. Also trigger automatically at the end of any /implement sprint that had incidents (fix cycles, user-caught bugs, compliance failures). Even casual requests like "let's look at what happened this sprint" or "how did that go" should trigger this skill when an implementation sprint just completed.
---

# Retro — Audit, Review, Handoff, Apply

A three-phase retrospective process that turns incidents into durable process improvements AND captures the operational state needed for the next session to resume. The RET document is the single artifact produced at the end of any bounded work unit (sprint, phase, milestone).

## Why This Exists

Sprint 6 P13 had a 39% build / 61% fix ratio — 15 of 25 commits were post-deploy fixes. Most were preventable with better pre-deploy checklists. This skill ensures every sprint's lessons get captured and applied, not just discussed and forgotten. The handoff section was merged in (Sprint 7) to eliminate producing two separate documents (RET + HAN) at each completion.

## Scope

This skill works for any bounded unit of work:
- **Sprint** — a full sprint with multiple phases (e.g., Sprint 7)
- **Phase** — a single phase within a sprint (e.g., P15)
- **Milestone** — a project milestone or goal
- **Any bounded work** — whatever the user wants to retrospect on

The naming convention reflects this: `RET - {Project} - {Scope}.md` where scope can be "Sprint 7 P15", "Phase 2", "Q1 Milestone", etc.

## Three Phases

```
Phase 1: AUDIT ─── Gather evidence from all sources
                   (git log, plan files, Plane, daily notes, team messages)
                   Identify every incident, fix cycle, and deviation
                        │
Phase 2: REVIEW ── Analyze patterns across incidents
                   What worked, what didn't, carry-forward effectiveness
                   Propose concrete changes with exact template text
                   Generate handoff section for next session
                        │
Phase 3: APPLY ─── Execute the proposed changes
                   Update skill templates, add lessons, verify no regressions
                   Commit and confirm
```

## Artifact Naming — Mandatory

ALL files produced by this skill MUST use the correct vault prefix:

- **Audit artifact:** `ARE - {Project Name} - {Scope} Retro Audit.md` (goes in `reviews/{date}/`)
- **Retro report:** `RET - {Project Name} - {Scope}.md` (goes in project reports directory)
- **Any other artifact** produced during the retro (cleanup plans, action items, etc.) MUST use `ARE -` prefix if it's an agent report or `RET -` prefix if it's a retrospective document.

**NEVER** use slugified names like `post_sprint_cleanup.md`, `retro-audit.md`, or `action-items.md`. Every file in the vault uses a prefix convention — no exceptions.

## Phase 1 — Audit

Dispatch a read-only Opus agent to gather evidence. The agent writes its findings to the project's `reviews/{date}/` directory as `ARE - {Project Name} - {Scope} Retro Audit.md` with frontmatter `category: Agent Report`. All vault files use prefixed names — never use slugified names like `retro-audit.md`.

The agent reads (but never modifies):

### Data Sources

| Source | What to Extract |
|--------|----------------|
| **Git log** | All commits in the work unit. Categorize: feature, fix, polish, infra. Count the build:fix ratio. |
| **Plan files** | Scope changes (D-N decisions), task definitions, phase structure. Status comes from Plane issue history, not plan file. Compare Progress Overview at-start vs at-end for phase-level changes. |
| **Plane states** | Issue state history. Any items that went Done→reopened? |
| **Daily notes** | Hotfix entries, user-reported bugs, soak clock resets. |
| **Implement skill templates** | What rules existed that should have prevented each incident? |
| **Lessons file** | What lessons existed from prior work? Were they followed? |
| **Previous retros** | What carried forward from the previous retro? Was it effective? |
| **Team messages** (if available) | Worker self-reports vs QA findings vs user reports. Who caught each bug? |

### What to Identify

For each work unit, produce:
- **Incident log** — every bug, crash, regression, or user-reported issue
- **Fix timeline** — for each incident: what happened, root cause, who caught it, how many commits to fix
- **Commit categorization** — feature / fix / polish / infra with counts and ratio
- **Compliance check** — which template rules were followed, which were skipped

### Incident Classification

Each incident gets categorized:

| Category | Description | Example |
|----------|-------------|---------|
| **Framework gotcha** | Language/framework-specific pattern the worker didn't know | Date serialization in Next.js RSC |
| **Compliance failure** | Template rule existed but wasn't followed | Deploy protocol skipped |
| **Gap** | No template rule existed for this class of issue | No AG Grid checklist |
| **Scope miss** | Plan description didn't match reality | Meetings/Timeline content swap |
| **Visual/UX** | Functional but visually wrong | Badge sizing, viewport overflow |

## Phase 2 — Review

Analyze the audit findings and produce a structured retrospective report.

Read `references/retro-template.md` for the full report template structure, including file naming, frontmatter, all 8 required sections (Summary Statistics, What Worked Well, What Didn't Work Well, Carry-Forward Effectiveness, Process Gaps, Proposed Changes, Success Patterns, Handoff — Operational State), and the Present to User checklist.

## Phase 3 — Apply

Once the user approves (all or a subset of proposed changes):

### Apply Each Change

1. **Read the target file** before editing
2. **Apply the exact text** from the proposed change
3. **Check for duplicates** — some changes may partially overlap with content added during the sprint. Merge, don't duplicate.
4. **Verify coherence** — the new text should flow with the existing content

### Target Files

| File | Location | What Goes Here |
|------|----------|----------------|
| `worker-template.md` | `~/.claude/skills/implement/references/` | Worker instructions, checklists, verification steps |
| `auditor-prompts.md` | `~/.claude/skills/implement/references/` | QA auditor checks and report format |
| `tracker-prompts.md` | `~/.claude/skills/implement/references/` | PM behavior, cascade protocol, cross-checks |
| `SKILL.md` | `~/.claude/skills/implement/` | Orchestrator behavior, gates, deploy protocol |
| `lessons.md` | Monorepo root or project-specific | Reusable technical lessons (L-numbered) |

### After Applying

1. **Commit lessons.md** if it was modified (it's in a git repo)
2. **Link the retro report** in today's daily note
3. **Announce the target metric** for next work unit: "Goal: < X% fix time (down from Y%)"
4. **Offer /learn** for any lessons that should also go into the general lessons file

## Trigger Signals

### Automatic (at end of /implement)
The implement skill's Step 6 (Completion) checks for trigger signals. If any are present, it should suggest running `/retro`. Signals:
- Worker-reported "done" that failed user or QA verification
- Fix cycles (same issue needed 2+ attempts)
- Scope mismatches caught during audit
- User-reported bugs after deploy
- QA auditor FAIL results
- Build:fix ratio > 50%

### Manual
User says: "retro", "retrospective", "sprint review", "phase review", "what went well", "what went wrong", "review the sprint", "what can we improve", "how did that go"

## Arguments

Accepts an optional path to:
- A previous retro (`RET - *.md`) — extracts carry-forwards and context
- A plan file (`PL - *.md`) — identifies the phases/tasks
- Nothing — scans the current daily note and recent git log to identify the most recent work unit

## Model Selection

- **Phase 1 (Audit agent):** Opus — needs to read many files and synthesize patterns
- **Phase 2 (Review):** Orchestrator (Opus) — analysis and report writing
- **Phase 3 (Apply):** Opus agent or orchestrator — careful file edits

## What This Skill Does NOT Do

- Modify code (only modifies skill templates and lessons)
- Make architectural decisions (proposes, doesn't decide)
- Skip user approval before applying changes
- Run without evidence (every proposed change must cite specific incidents)

## Local Customizations

If `LOCAL.md` exists in this skill directory, load and follow it after these instructions. Local instructions override upstream where they conflict.
