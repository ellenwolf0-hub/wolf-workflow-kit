# Spec Writing Guide

The definitive guide for writing agent-friendly specs. Informed by the Spec-Driven Development oracle (55 sources, 2026-04-30) covering GitHub Spec Kit, OpenAI Symphony, Anthropic Claude Code patterns, Martin Fowler's harness engineering, and the HITL comparative analysis.

A spec is a contract between the person who wants something built and the agent that builds it. The quality of agent-produced code is bounded by the quality of the spec.

## The six elements every spec needs

Industry consensus identifies six required elements. Leave any open and the agent fills them in, in ways you won't like.

1. **Outcomes** (not feature names). "A user can sign up with email/password and log in without error" not "build an auth flow."
2. **In-scope AND out-of-scope boundaries.** The out-of-scope list matters as much as in-scope. Agents expand scope when doors aren't explicitly closed.
3. **Constraints and assumptions.** Tech stack decisions, API limits, performance requirements. If it affects implementation and isn't obvious from the code, it belongs in the spec.
4. **Decisions already made.** If the database schema is chosen, state it. Agents that don't know a decision was made will invent their own.
5. **Task breakdown.** Discrete sub-tasks that agents can work on individually, verify incrementally, and execute in parallel when independent.
6. **Verification criteria.** Not "does it work" but what tests pass, what edge cases are handled. This is what the verifier agent checks against.

## Section structure

```markdown
## 1) Purpose / Objectives
- Why this exists and what success looks like (measurable outcomes).
- "Success looks like:" bullet list with concrete, observable criteria.

## 2) Scope (In) and Exclusions (Out)
- **In scope:** what this spec covers.
- **Out of scope:** explicit exclusions. Mandatory, not optional.
  Every spec MUST have an out-of-scope list, even if brief.
  "OAuth is out of scope" prevents an agent from adding it.
- If phased (v1/v2), define scope per phase here.

## 3) Functional Requirements
- What the system must do. One requirement per bullet.
- Use numbered IDs (FR-1, FR-2, or domain-prefixed like KB-1).
- Group by feature area with subsections (3.1, 3.2) if > 10 FRs.
- For each FR: ID | Description | Priority (v1/v2/deferred)
- Active voice, explicit actors: "The API returns 404" not "a 404 is returned."

## 4) Non-Functional Requirements
- Performance, latency, token budgets, security, accessibility.
- NFR-1, NFR-2, etc.
- Replace adjectives with numbers: "Response under 200ms at p95" not "fast."

## 5) Constraints
- Budget, schedule, infrastructure limits, team capacity.
- Technology constraints (must use X, cannot use Y).
- DECISIONS ALREADY MADE. If the DB schema, library, routing pattern,
  or deployment method is chosen, state it here. This prevents agents
  from relitigating resolved decisions.

## 6) Assumptions
- Conditions you are relying on to stay true.
- A-1, A-2, etc. Makes them easy to reference and invalidate later.

## 7) Deliverables
- Tangible outputs grouped by domain for parallel dispatch:
  - **Frontend:** pages, components (with specific file names)
  - **API Routes:** endpoints (with method and path)
  - **Database:** tables, migrations
  - **Infrastructure:** containers, DNS, cron jobs
- Name specific files the implementing agent will touch.
  "Microphone button in KBChat.tsx" not "voice input UI."
- Structure for file/domain isolation: agents working on Frontend
  deliverables should not need to touch API deliverables simultaneously.

## 8) Acceptance Criteria (SAT)
- Pass/fail checks. SAT-1, SAT-2, etc.
- EVERY SAT must include a verification method:
  - A test command to run (npm test, pytest, curl)
  - A SQL query to check
  - A UI action to perform and observe
  - A screenshot to compare against
- Golden examples for quality-dependent features:
  Specific input -> expected output -> pass/fail threshold.
  NOT "the feature works correctly."
- Write SATs for a VERIFIER agent, not the implementor.
  A separate agent reads the SAT and checks the code.
  It does not trust the implementor's self-assessment.

## 9) High-Level Architecture
- Block diagram of major subsystems and interfaces.
- Data flow between components.
- Keep it architectural. No implementation details.

## 10) Risks (Spec-Level)
- Table: Risk | Likelihood | Impact | Mitigation
- Include both technical and domain risks.

## 11) Open Decisions
- Table: Decision | Options | Recommendation | Status
- Every decision MUST have a recommendation. Never leave it blank.
- Decisions that ARE resolved belong in Constraints, not here.
```

## Section-specific guidance

**Entity boundaries.** If the spec processes people, contacts, or entities, section 2 or 3 MUST define who gets included, excluded, and what classification threshold triggers the feature.

**Data model fields.** If the spec references fields from external systems, verify they exist before listing them. Don't assume field names from memory.

**Golden examples.** Quality-dependent acceptance criteria need concrete examples, not just "user can do X successfully." Example:

> **SAT-1:** User says "the phone number is wrong, it should be 624-555-1234."
> **Verify:** Agent responds with a structured summary identifying this as a fine-grained correction to the contact section. The raw transcript does NOT appear in the chat.
> **Pass:** Summary references the correct section, proposed change matches the user's input, scope is classified as "correction."

**No implementation phases.** Specs define behavior, interfaces, and constraints. Build order, effort estimates, and deployment sequencing belong in the plan document. If you find yourself writing "Phase 1: Build X, Phase 2: Build Y," stop. That's plan content.

**Context precision over volume.** Reference specific files and patterns, not "the existing codebase." Each requirement should point implementing agents to exactly the files they need. A million tokens of codebase context is not an advantage. Precise, task-relevant context produces better output.

**Progressive disclosure.** Don't inline everything into the spec. Cross-reference SDs, ADRs, and other specs. The implementing agent reads supplemental docs on-demand, conserving context. Link, don't duplicate.

## Anti-patterns to avoid

1. **The description trap.** YAML descriptions or top-level summaries that contain workflow details. Agents follow the short summary and ignore the detailed constraints below. Keep descriptions as short triggers only.

2. **Trust-then-verify gap.** Specs without verification commands in SATs. The human becomes the only feedback loop. Every SAT MUST include a verification command.

3. **Vague "vibe coding" requirements.** "Make the dashboard look better" or "make it secure." Replace with deterministic rules: "implement this design screenshot" or "use bcrypt with salt rounds of 12."

4. **Relitigating prior decisions.** Not documenting decisions already made. The agent invents new schemas, patterns, and approaches for problems already solved.

5. **Oversized specs.** If a spec is too large for a human to comfortably review, it's too large for an agent to reliably implement. The "lost in the middle" problem applies to spec documents themselves. Target: human-reviewable in one sitting.

6. **Mixed What and How.** Including build order, deployment steps, or implementation phases in the spec. These belong in the plan. The spec should be implementation-order-independent.

## Extending the template

Real specs often need sections beyond these 11:
- **Phase 0 Prerequisites** -- what must exist before implementation starts
- **Database Schema** -- full CREATE TABLE statements with seed data
- **v1 vs v2+ Scope Split** -- detailed breakdown when phased
- **Related Specs** -- wiki-links to specs this one depends on or extends
- **Appendix** -- supporting links, external references

## Oracle reference

This guide is informed by the Spec-Driven Development oracle (`40fc91f1`, 55 sources). Key sources:

- Augment Code: "What Is Spec-Driven Development?" (6 elements, adversarial verifier)
- Martin Fowler: "Harness Engineering" (feedforward/feedback, lint-as-prompt)
- GitHub Spec Kit (Specify-Plan-Tasks-Implement)
- Anthropic: Claude Code Best Practices (explore-plan-implement, CLAUDE.md)
- Addy Osmani: "Agent Harness Engineering" (sprint contracts, self-verification bias)
- HITL Comparative Analysis (tool scoping, YAGNI enforcement, verification gates)

Full grounding report: [[ARE - Spec-Driven Development Grounding Report]]
