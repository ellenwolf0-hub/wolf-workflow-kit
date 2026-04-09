---
name: review-spec
description: >-
  Run a structured 3-perspective review of a spec document before planning.
  Use when the user says "/review-spec", "review this spec", "critique my spec",
  "is this spec ready to plan?", or as the gate that /create-spec triggers automatically.
  Catches gaps, surfaces conflicts with existing work, and gets user answers to open
  questions — before those gaps become plan blockers.
---

# Review Spec — Catch Problems Before They Become Blockers

A structured review that evaluates your spec from three angles: what it actually touches (scope), what context exists from past work (lessons), and whether it holds up under scrutiny (critical review).

**Arguments:** $ARGUMENTS — Path to the spec file to review (e.g., `Projects/SPC - GROW Refresh.md`).

## Step 0 — Orient

Read the spec at the path provided. If no path given, ask: "Which spec should I review?"

Then read:
- `agents.md` — for project context and any relevant constraints
- `lessons.md` — for past lessons that apply to this spec's domain

## Step 1 — Three-Perspective Analysis

Work through these three perspectives sequentially. Each builds on the last.

---

### Perspective 1: Scope Analyst — What Does This Actually Touch?

**Goal:** Map everything this spec would affect if implemented.

For a People Ops spec, examine:

**Programs and processes affected:**
- Which existing programs, processes, or workflows would this change?
- What currently happens that would change or be replaced?
- Are there related programs that could conflict or overlap?

**People and stakeholders:**
- Who needs to do something different if this is implemented?
- Who needs to be consulted or informed that isn't listed in the spec?
- What manager, IC, or cross-functional dependencies are implicit but not named?

**Tools and systems:**
- Which tools (Coda, Workday, Greenhouse, Slack, etc.) would this touch?
- Are there existing integrations, trackers, or automations that would break or need updating?
- Is there data that needs to move or be restructured?

**Downstream effects:**
- What does this make easier or harder for the people who execute it?
- What follow-on work would this create that the spec doesn't mention?

Write the Scope Analysis as:
```markdown
## Scope Analysis

### Affected Areas
[Table: Component | Type | Impact | Notes]

### Dependency Map
[What connects to this initiative, upstream and downstream]

### Resource Reality Check
[Honest estimate: headcount, time, tool access, budget needed — even rough]

### Risk Surface
[What could go wrong during implementation that isn't named in the spec]
```

---

### Perspective 2: Context Researcher — What Do We Already Know?

**Goal:** Surface lessons, past decisions, and related work that should inform this spec.

Search the vault for:

1. **Lessons** — read `lessons.md` for anything relevant to this spec's domain (onboarding, calibration, comp, L&D, etc.)

2. **Related specs** — glob `Projects/SPC - *.md` and scan for overlapping scope. Has this problem been specced before? Was a prior effort abandoned? Why?

3. **Related meeting notes** — glob `Meetings/MN - *.md` and search for the spec's key topics. What decisions have already been made in meetings that this spec should reflect?

4. **Related plans** — glob `Projects/PL - *.md` for plans covering similar ground. Is there in-progress work this would conflict with?

5. **Patterns from past work** — what has succeeded or failed in similar initiatives? What assumptions proved wrong?

Write the Context Brief as:
```markdown
## Context Brief

### Applicable Lessons
[Lesson | Source | Relevance to this spec]

### Related Specs & Plans
[File | Status | Overlap or conflict with this spec]

### Decisions Already Made
[Decisions from meeting notes or past specs that this spec should reflect but doesn't]

### Historical Patterns
[What's worked / not worked in similar initiatives]
```

---

### Perspective 3: Critical Reviewer — Does This Spec Hold Up?

**Goal:** Evaluate the spec honestly against these criteria, using the Scope Analysis and Context Brief.

**Completeness** — Are there gaps? Missing acceptance criteria? Undefined behavior at boundaries? Sections that say "TBD" or are effectively empty?

**Feasibility** — Given the scope analysis, is this realistic given current headcount, timelines, and tools? Are resource requirements acknowledged?

**Conflicts** — Does this contradict existing specs, plans, past decisions from meetings, or lessons learned?

**Gotchas** — Based on the context brief, what is likely to go wrong? What has gone wrong before in similar work?

**Scope creep risk** — Is the spec tightly scoped or does it invite unbounded additions?

**Clarity** — Could two different people read this and make the same choices when implementing it? Where would they diverge?

**Clarification needs** — What open questions must the user answer before this spec can be planned confidently?

Write the Spec Review as:
```markdown
---
category: Review
date created: {today}
source: "review-spec"
spec: "[[{spec_filename}]]"
---

# Spec Review: {spec_name}

## Spec Quality Score

| Criteria | Rating (0–3) | Notes |
|----------|-------------|-------|
| Completeness | | |
| Feasibility | | |
| Clarity | | |
| Scope Control | | |
| **Total** | **/12** | |

**Gate:** PASS (0 Critical issues, score ≥ 8) | CONDITIONAL (0 Critical, score 5–7) | FAIL (any Critical issues OR score < 5)

## Summary Verdict
{1-2 sentences: ready to plan? needs revision? needs clarification?}

## Clarifications Needed
{Questions whose answers would change the shape of the plan — not just polish questions.
Each one is a decision only the user can make.}
- **CL-1:** [Question] — [Why this matters for planning, in one sentence]
- **CL-2:** [Question] — [Why this matters]
{If none: "None — spec is clear enough to plan."}

## Issues
{Problems with the spec itself, by severity.}

**Critical (blocks planning):**
- [C-1] [Title]: [Problem] — [Concrete suggestion for fix]

**Warnings (should address, doesn't block):**
- [W-1] [Title]: [Problem] — [Suggestion]

**Info (optional improvements):**
- [I-1] [Title]: [Suggestion]

## Suggested Spec Improvements
{Numbered list — user can say "apply 1, 3, and 5"}
1. [Specific change — concrete enough to apply directly]
2. [Another]

## Lessons to Watch
{Lessons from context brief that directly apply to this spec}
| Lesson | Spec Section | Risk |
|--------|-------------|------|
```

Save the review to `Projects/Reviews/{date}/ARE - {spec_name} Spec Review.md`.

---

## Step 2 — Present Findings & Get Clarification

1. Summarize key findings: verdict, issue count by severity, top 2-3 gotchas
2. If Clarifications Needed is non-empty, ask them **one at a time**:
   > "Before we can plan this, I need your answer on one thing: [CL-1 question] — [why it matters]. What's your call?"
3. Record each answer by appending a Clarification Log to the review file:
   ```markdown
   ## Clarification Log

   **CL-1:** [question]
   **Answer:** [user's answer] ({date})
   ```

## Step 3 — Apply Improvements

After clarifications are resolved:

1. **Auto-apply** any improvement that directly implements a clarification answer — no second ask
2. **Present remaining improvements** in one pass (use multi-select if available):
   > "I found [N] additional improvements. Which should I apply?"
3. Apply approved changes to the spec file
4. Record all changes in an Applied Changes section of the review file:
   ```markdown
   ## Applied Changes
   - [x] #1: [description] (auto-applied — implements CL-1)
   - [x] #2: [description] (user-approved)
   - [ ] #3: [description] (skipped by user)
   ```

## Step 4 — Verdict

After all changes are applied:

- **PASS** → "Spec is ready for `/plan-spec`."
- **CONDITIONAL** → "Spec can proceed to `/plan-spec` but has warnings worth reviewing. Proceed anyway?"
- **FAIL** → "Spec is not ready for planning. [N] Critical issues must be resolved first." Do NOT suggest proceeding.

## What This Skill Does NOT Do

- It does not produce a plan — that's `/plan-spec`
- It does not make architectural decisions — it surfaces decisions that need to be made
- It does not implement anything
- It does not modify the spec without your approval
