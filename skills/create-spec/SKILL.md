---
name: create-spec
description: >-
  Create or update a spec document (SPC - *.md) through a guided interview.
  Use when the user says "/create-spec", "spec this out", "write a spec", "I have
  an idea for", "let's formalize this", "turn this into a spec", "new spec for",
  "add this to the spec", "update the spec with", or describes an initiative, program,
  or process change they want to define before acting on it. Works for People Ops
  projects: onboarding programs, calibration processes, comp workflows, L&D
  initiatives, policy changes, and anything else that benefits from a clear definition
  before building.
---

# Create Spec — Define Before You Build

Structured way to capture what you want to do before you do it. Good specs prevent scope creep, create alignment, and give the review team something concrete to improve.

**Arguments:** $ARGUMENTS — Optional: description of what to spec, or path to an existing spec to update.

## Step 0 — Orient

1. Run `date` for a fresh timestamp
2. Read `agents.md` in the vault to understand current projects and context
3. If a project was mentioned, check for an existing spec in `Projects/` first

## Step 1 — Create or Update?

### Auto-route

- User said "new spec" or described something new → **Create**
- User said "add to", "update", or named an existing spec → **Update**

### Triage (when ambiguous)

1. Glob `Projects/SPC - *.md` and read each one's Purpose section
2. Ask: "I found these existing specs. Does your idea fit under one, or is this new?"
   - List existing specs with one-line summaries
   - Option: "This is a new spec"
3. User picks existing → **Update flow** (go to Step 7)
4. User picks new → **Create flow** (go to Step 2)

---

## Create Flow

## Step 2 — Interview

One question at a time. Don't ask more than 5 — the review gate catches gaps.

**Q1: What is this spec for?**
If the user already described it, confirm rather than re-asking:
> "So you want to spec out [X]? Let me make sure I have it right before we draft."

**Q2: What does success look like?**
Ask for measurable or observable outcomes. For People Ops this might be: "managers complete calibrations in under 2 hours," "new hires hit 90-day milestone at 85%+ rate," "offer acceptance rate improves by 10 points."

**Q3: What's explicitly OUT of scope?**
Offer educated guesses based on what they described:
> "Based on what you've described, which of these are OUT of scope?"
> - [Educated guess A]
> - [Educated guess B]
> - Everything's in scope
> - Different exclusion

**Q4: Any hard constraints?**
Timing, headcount, tools, existing policies, legal/compliance requirements.

**Q5: Confirm understanding**
Give a 3-5 bullet summary of what you heard:
> 1. Draft it
> 2. I want to adjust something first

## Step 3 — File Placement

Check if a project folder exists under `Projects/` for this initiative. If not, the spec lives directly in `Projects/`.

Naming convention: `SPC - [Descriptive Name].md` — title case, concise but specific.

Confirm the path with the user before writing.

## Step 4 — Draft the Spec

All 11 sections are required. Empty sections surface gaps for the review gate — don't skip them.

```markdown
---
category: Spec
date created: {today}
date modified: {today}
status: Draft v1
project: "[Project Name]"
source: "{what prompted this — user request, meeting, etc.}"
---

# SPC - [Spec Name]

## 1) Purpose / Objectives
[Why does this exist? What problem does it solve? What outcome does it enable?
2-4 sentences. No solution language — just the problem and goal.]

## 2) Scope
### In Scope
- [FR-1] [Specific thing this covers]
- [FR-2] [Another specific thing]

### Out of Scope
- [Thing explicitly NOT included, and why]

## 3) Stakeholders
| Role | Person / Team | Responsibility |
|------|--------------|----------------|
| Owner | [name] | Final decisions on this initiative |
| Contributors | [team/role] | Input, execution |
| Informed | [team/role] | Updates only |

## 4) Functional Requirements
[What the thing must DO. Each requirement gets an ID.]
- [FR-1] [Concrete requirement — must be verifiable]
- [FR-2] [Another requirement]

## 5) Non-Functional Requirements
[Quality, compliance, and operational requirements — not what it does, but how it performs.]
- [NFR-1] [e.g., "Must comply with Grammarly's comp philosophy v2026"]
- [NFR-2] [e.g., "Must be completable by a single HRBP without additional headcount"]

## 6) Assumptions
[What you're assuming to be true that you haven't verified.]
- [A-1] [Assumption — flag if this turns out to be wrong]

## 7) Risks and Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| [Risk] | H/M/L | H/M/L | [Action] |

## 8) Success / Acceptance Criteria
[How will you know this worked? Concrete, measurable, verifiable.]
- [SAT-1] [Specific outcome that's either true or false — no "feels like"]

## 9) Timeline / Milestones
[When things need to happen — not a build plan, just key dates and gates.]
| Milestone | Target Date | Owner |
|-----------|-------------|-------|
| [Phase or gate] | [date] | [name] |

## 10) Open Decisions
[Things not yet decided that would change the spec's direction.]
| ID | Decision | Options | Recommendation | Owner |
|----|----------|---------|----------------|-------|
| OD-1 | [What needs deciding] | [A or B] | [Your recommendation — never leave blank] | [owner] |

## 11) References
[Existing docs, past specs, relevant Coda pages, meeting notes, or Slack threads that informed this.]
- [[Relevant doc or meeting note]]
```

After writing the file, add a wiki-link to today's daily note under `## Worked on`.

## Step 5 — Review Gate

Immediately invoke `/review-spec` with the spec path — no confirmation needed. The review catches gaps before they become plan problems. Let it run to completion.

## Step 6 — Handoff

After review, present a TLDR and offer next steps:

> **Spec:** SPC - [Name]
> **Purpose:** [one line]
> **Key requirements:** [top 2-3 FRs]
> **Open decisions:** [count or "all resolved"]
> **Review verdict:** [from review gate]

Ask:
1. Run `/plan-spec` now to turn this into a phased plan
2. More changes first
3. Done for now

---

## Update Flow

## Step 7 — Load Existing Spec

Read the spec the user pointed to. Understand its current state:
- What FRs already exist (note the highest ID — new ones continue from there)
- What open decisions are unresolved
- Whether a plan already exists downstream

## Step 8 — Understand the Change

Ask:
- What specifically needs to change or be added?
- Does this change any existing requirements, or is it additive?
- Is there a downstream plan or Plane project that needs to reflect this?

## Step 9 — Apply Changes

Follow these rules:
- **New IDs continue from the highest existing** — no gaps, no reuse
- **Bump frontmatter**: increment version, update `date modified`
- **Add a Change Log section** at the bottom of the spec (or append to existing):
  ```markdown
  ## Change Log
  | Date | Version | Change | Source |
  |------|---------|--------|--------|
  | {today} | v{N} | [what changed and why] | [user request / meeting / etc.] |
  ```
- **Superseded requirements**: strike through (~~FR-1~~) with a note pointing to the replacement — don't delete
- **Flag contradictions**: if the change conflicts with an existing requirement, surface it before writing

## Step 10 — Delta Review

After updating, run a lightweight review: "Does this change introduce any new risks or gaps?" Present findings and apply approved fixes.

If a plan already exists, flag: "This spec has a downstream plan. These changes may require new tasks or cancelling existing ones — want me to review the plan next?"

---

## Quality Checklist

### Create Mode
- [ ] All 11 sections present
- [ ] Frontmatter complete
- [ ] IDs on all requirements, assumptions, acceptance criteria
- [ ] No implementation details in the spec (no build phases, no deployment steps)
- [ ] Open decisions have recommendations
- [ ] File placed correctly and daily note updated
- [ ] Review gate passed

### Update Mode
- [ ] New IDs continue from highest existing
- [ ] Frontmatter version bumped and date modified updated
- [ ] Change Log entry added
- [ ] Contradictions flagged
- [ ] Superseded FRs struck through, not deleted
- [ ] Downstream plan flagged if it exists
