---
name: create-spec
description: >-
  Create or update a spec document (SPC - *.md) through a guided workflow.
  Use when the user says "/create-spec", "spec this out", "write a spec", "I have
  an idea for", "let's formalize this", "turn this into a spec", "new spec for",
  "add this to the spec", "update the spec with", or describes an initiative, program,
  or process change they want to define before acting on it. Works for People Ops
  projects: onboarding programs, calibration processes, comp workflows, L&D
  initiatives, policy changes, and anything else that benefits from a clear definition
  before building. Does NOT trigger for reviewing existing specs (use /review-spec)
  or planning from specs (use /plan-spec).
---

# Create Spec — Define Before You Build

Create specs with depth proportional to complexity. A process tweak doesn't need 11 sections. A new onboarding program does.

**Design principle:** The spec defines *what* to do and *why*. The plan defines *how* and *in what order*. If you're writing phases or task lists, stop — that's plan content.

**Arguments:** $ARGUMENTS — Optional: description of what to spec, or path to an existing spec to update.

## Step 0 — Orient

1. Run `date` for a fresh timestamp
2. Read `agents.md` in the vault to understand current projects and context
3. If a project was mentioned, check for an existing spec in `Projects/` first

## Step 1 — Create or Update?

### Auto-route
- User said "new spec" or described something new → **Create**
- User said "add to", "update", or named an existing spec → **Update** (go to Step 8)

### Triage (when ambiguous)
1. Glob `Projects/SPC - *.md` and read each one's Purpose section
2. Ask: "I found these existing specs. Does your idea fit under one, or is this new?"
3. User picks existing → **Update**; picks "new" → **Create**

---

## Create Flow

## Step 2 — Classify Depth

Before asking questions, assess what the user described:

| Tier | When to use | Sections |
|------|------------|----------|
| **Brief** | Single process tweak, policy clarification, one-off program change. < 5 requirements. | Purpose, Scope, Requirements, Acceptance Criteria |
| **Standard** | New program feature, workflow redesign, cross-functional initiative. 5–15 requirements. | Purpose, Scope, FRs, NFRs, Constraints, Deliverables, SATs, Open Decisions |
| **Full** | New program from scratch, major policy overhaul, org-wide initiative. 15+ requirements. | All 11 sections |

Present your assessment:
> "This looks like a **[tier]** spec — I'll ask [N] questions then draft. Sound right?"

If the user wants more or less depth, adjust.

## Step 3 — Interview

One question at a time. Interview until you can confidently draft all sections for the tier.

**Brief (2–3 questions):**
- What is this and why?
- What does "done" look like?
- Anything explicitly out of scope?

**Standard (4–6 questions):**
- What and why?
- Measurable success criteria?
- What's explicitly out of scope?
- Hard constraints (timing, headcount, tools, compliance)?
- Any open decisions that would change the scope?
- Confirm understanding: 3–5 bullet summary, then ask to proceed

**Full (6+ questions):**
- All of Standard, plus:
- Deep dive into stakeholder boundaries, data flows, dependencies
- Open decisions with recommendations

## Step 4 — File Placement

Check if a project folder exists under `Projects/` for this initiative.

Naming: `SPC - [Descriptive Name].md` — title case, concise but specific.

Confirm with the user before writing.

## Step 5 — Draft the Spec

**Brief tier:**
```markdown
---
category: Spec
date created: {today}
date modified: {today}
status: Draft v1
project: "[Project Name]"
source: "{what prompted this}"
---

# SPC - [Name]

## Purpose
[Why does this exist? What problem does it solve? 2-3 sentences.]

## Scope
### In Scope
- [FR-1] [Requirement]

### Out of Scope
- [Thing explicitly not included]

## Requirements
- [FR-1] [Concrete, verifiable requirement]

## Acceptance Criteria
- [SAT-1] [Specific outcome — true or false, not "feels right"]
```

**Standard and Full tiers** — use all applicable sections:

```markdown
---
category: Spec
date created: {today}
date modified: {today}
status: Draft v1
project: "[Project Name]"
source: "{what prompted this}"
---

# SPC - [Name]

## 1) Purpose / Objectives
## 2) Scope (In / Out)
## 3) Stakeholders
## 4) Functional Requirements (FR-N)
## 5) Non-Functional Requirements (NFR-N)
## 6) Assumptions (A-N)
## 7) Risks and Mitigations
## 8) Success / Acceptance Criteria (SAT-N)
## 9) Timeline / Milestones
## 10) Open Decisions (OD-N — always include recommendation)
## 11) References
```

**Rules for all tiers:**
- IDs on everything trackable (FR-1, NFR-1, SAT-1, A-1, OD-1)
- No implementation phases or build order in the spec
- Open decisions must have recommendations — never leave blank
- Verify any external references before writing them in

After writing the file, add a wikilink to today's daily note under `## Worked On`.

## Step 6 — Review Gate

Tiered review matching spec depth:

| Tier | Review |
|------|--------|
| **Brief** | Self-review inline: are SATs testable? Is scope clear? No implementation leakage? Takes 30 seconds. |
| **Standard** | Single-pass review: read spec + project context, flag gaps and assumptions. Present findings, apply approved fixes. |
| **Full** | Invoke `/review-spec` — full 3-perspective analysis. Let it run to completion. |

## Step 7 — Handoff

After review, present a TLDR:
> - **What:** [one-line purpose]
> - **Key requirements:** [top 2-3 FRs]
> - **Open decisions:** [count or "all resolved"]
> - **Review verdict:** [pass / conditional / needs work]

Ask:
1. Run `/plan-spec` now
2. More changes first
3. Done for now

---

## Update Flow

## Step 8 — Load Existing Spec

Read the spec the user pointed to. Understand current state: highest existing IDs, open decisions, whether a downstream plan exists.

## Step 9 — Understand the Change

Ask:
- What specifically needs to change or be added?
- Is this additive or does it replace existing requirements?
- Is there a downstream plan that needs to reflect this?

## Step 10 — Apply Changes

- New IDs continue from the highest existing — no gaps, no reuse
- Bump `date modified` in frontmatter
- Add a Change Log section (or append to existing):
  ```markdown
  ## Change Log
  | Date | Version | Change | Source |
  |------|---------|--------|--------|
  | {today} | v{N} | [what changed and why] | [source] |
  ```
- Superseded requirements: strike through (~~FR-1~~) with a note pointing to replacement — don't delete
- Flag contradictions before writing

If a plan exists, flag: "This spec has a downstream plan. These changes may affect existing tasks — want me to review the plan next?"

---

## Quality Checklist

### Create Mode
- [ ] Tier is appropriate for the work complexity
- [ ] All sections for the tier are present
- [ ] Frontmatter complete
- [ ] IDs on all requirements and acceptance criteria
- [ ] No implementation phases in the spec
- [ ] Open decisions have recommendations
- [ ] File placed correctly and daily note updated
- [ ] Review gate passed

### Update Mode
- [ ] New IDs continue from highest existing
- [ ] `date modified` updated
- [ ] Change Log entry added
- [ ] Contradictions flagged and resolved
- [ ] Superseded FRs struck through, not deleted
- [ ] Downstream plan flagged if it exists
