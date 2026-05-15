# SPC Template - Spec

## Frontmatter additions

```yaml
status: Draft
source: "[[related doc or request]]"
```

Tags: `[spec, <project-tag>]`

## Reference files

Read `references/spec-guide.md` for the agent-friendly spec writing guide (oracle-informed, 55 sources).
Read `references/update-spec.md` if updating an existing spec.

## Classify tier

Before interviewing, assess the scope:

| Tier | Signals | Sections |
|------|---------|----------|
| **Brief** | Config change, single endpoint, <5 FRs | Purpose, Scope, Requirements, Acceptance Criteria |
| **Standard** | Feature addition, 5-20 FRs | 8 sections: Purpose, Scope, FRs, NFRs, Constraints, Deliverables, SATs, Open Decisions |
| **Full** | New system, 20+ FRs | All 11 sections from spec-guide.md |

Present assessment: "This looks like a **{tier}** spec. I'll ask {N} questions then draft."

## Oracle check

Check for a cross-cutting oracle at `04_Reference/oracle-ledger.md` (spec-driven-development oracle, `40fc91f1`). Also check the project's own oracle ledger if one exists. Query the oracle with the spec's domain to ground design decisions before writing.

## Interview

Constraint-based, not fixed-question. One question at a time via AskUserQuestion.

**All tiers:**
- What outcome defines "done"? (measurable, not a feature name)
- What is explicitly OUT of scope? (the out-of-scope list is as important as in-scope)

**Standard adds:**
- What decisions are already locked? (DB schema chosen, library selected, pattern established)
- What existing code/patterns should the agent follow? (specific files, not "look at the codebase")
- Success criteria: what test, command, or observable behavior proves it works?
- What constraints would an agent not know from reading the code? (API limits, org rules, deployment quirks)

**Full adds:**
- Entity boundaries: who/what gets included, excluded, and at what threshold?
- Data flows between systems
- Security and access model
- Research isolation: dispatch a research agent with ONLY factual questions (not spec content or user answers) to verify DB schemas, APIs, existing patterns. Prevents research bias.

## Spec structure (all tiers)

Write the spec using this section structure. Adapt per tier (Brief uses 4 sections, Standard uses 8, Full uses all 11). Detailed guidance for each section is in `references/spec-guide.md`.

```
## 1) Purpose / Objectives
## 2) Scope (In) and Exclusions (Out)
## 3) Functional Requirements
## 4) Non-Functional Requirements
## 5) Constraints
## 6) Assumptions
## 7) Deliverables
## 8) Acceptance Criteria (SAT)
## 9) High-Level Architecture
## 10) Risks
## 11) Open Decisions
```

## Writing rules

These rules apply to all spec writing. They encode patterns from the spec-driven development oracle (55 sources, 2025-2026 industry best practices).

### Requirements
- RFC-style keywords (MUST/SHOULD/MAY)
- One requirement per bullet, IDs on everything (FR-1, NFR-1, SAT-1)
- No implementation phases or build order (that's plan content)
- Active voice, explicit actors: "The API returns 404" not "a 404 is returned"

### Scope boundaries
- **Out-of-scope is mandatory, not optional.** Agents expand scope if doors aren't explicitly closed. "OAuth is out of scope" prevents an auth-building agent from adding it. Every spec MUST have an explicit out-of-scope list, even if brief.
- **YAGNI enforcement.** Specs MUST NOT include features the user didn't ask for. If a reviewer suggests an expansion, verify actual codebase usage before adopting it.

### Prior decisions
- **Document decisions already made.** If the database schema is chosen, the encryption library is selected, or the routing pattern is established, state it explicitly. Agents that don't know a decision was made will invent their own.
- **Reference specific files.** "Follow the pattern in `KBChat.tsx`" not "follow existing patterns." Context precision beats context volume.

### Acceptance criteria
- **Every SAT must include a verification command or observable check.** Not "the feature works" but the specific test, curl command, SQL query, or UI check that proves it.
- **Golden examples for quality-dependent features.** Concrete input/output pairs, not "user can do X successfully." Example: "User says 'the phone number is wrong, it should be 624-555-1234'. Agent responds with a structured summary identifying this as a correction to the contact section. NOT the raw transcript."
- **Write SATs for a verifier, not the implementor.** A separate agent should be able to check each SAT mechanically without needing to understand the implementation. The verifier is prompted to be skeptical and to read actual code against requirements line by line.

### Deliverables
- **Group by file/domain isolation.** Structure deliverables so parallel agents can work on independent domains without touching the same files. Frontend deliverables, API deliverables, and DB deliverables in separate groups with clear boundaries.
- **Name specific files.** "Microphone button component in KBChat.tsx" not "voice input UI." This is what the implementing agent will actually touch.

### Open decisions
- Every open decision MUST have a recommendation column. Never leave it blank.
- Decisions that are already resolved belong in Constraints or Assumptions, not here.

## Review gate (MANDATORY, do not ask)

After writing the spec, run the review immediately. Do NOT ask the user for permission. The review is a built-in step, not an optional gate.

| Tier | Review |
|------|--------|
| Brief | Inline self-review: check the spec-guide.md checklist (SATs have verification commands, out-of-scope exists, prior decisions documented). Fix issues before presenting. |
| Standard | Invoke `/review-spec` with the spec path. Wait for the review to complete. Apply any Critical or Important findings before presenting the spec to the user. |
| Full | Invoke `/review-spec` with the spec path (full 3-agent team). Wait for completion. Apply Critical findings, present Important findings for user decision. |

The review agent (or team) queries the spec-driven-development oracle to evaluate the spec against industry best practices. The oracle checks: are SATs verifiable? Are scope boundaries explicit? Are prior decisions documented? Is the deliverable structure parallel-dispatch-friendly?

## Handoff

TLDR (3-5 bullets) including review findings addressed, then offer: run `/create-note PL` now, or more changes first.
