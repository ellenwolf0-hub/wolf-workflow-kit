# Spec Template

Use this structure for all specs. Adapt sections to the domain — software specs will lean into DB schemas and API routes, field/hardware projects into environmental constraints and parts. But every spec needs all 11 sections, even if some are brief.

```markdown
---
category: Spec
date created: {YYYY-MM-DD}
date modified: {YYYY-MM-DD}
status: Draft v1
project: "[[{Project Name}]]"
source: "{wiki-link to prompt note, meeting note, or conversation that spawned this}"
---

# SPC - {Spec Name}

## 1) Purpose / Objectives
- Why this project exists.
- What success looks like (measurable outcomes).
- "Success looks like:" bullet list.

## 2) Scope (In) and Exclusions (Out)
- **In scope:** what this spec covers.
- **Out of scope:** explicit exclusions so there's no ambiguity.
- If phased (v1/v2), define scope per phase here.

## 3) Functional Requirements
- What the system must do.
- Use numbered IDs (FR-1, FR-2, or domain-prefixed like KB-1, CM-1).
- Group by feature area with subsections (3.1, 3.2) if there are many.
- For each FR: ID | Description | Priority (v1/v2/deferred)

## 4) Non-Functional Requirements
- Performance, latency, token budgets, security, accessibility.
- NFR-1, NFR-2, etc.

## 5) Constraints
- Budget, schedule, infrastructure limits, team capacity.
- Technology constraints (must use X, cannot use Y).

## 6) Assumptions
- Conditions you are relying on to stay true.
- A-1, A-2, etc. — makes them easy to reference and invalidate later.

## 7) Deliverables
- Tangible outputs grouped by type:
  - **Frontend:** pages, components
  - **API Routes:** endpoints
  - **Database:** tables, migrations
  - **Infrastructure:** containers, DNS, cron jobs

## 8) Acceptance Criteria (SAT)
- Pass/fail checks and performance thresholds.
- SAT-1, SAT-2, etc.
- For quality-dependent features, include a golden-example test (specific input → expected output → pass/fail threshold).

## 9) High-Level Architecture
- Block diagram (ASCII or description) of major subsystems and interfaces.
- Data flow between components.
- Keep it architectural — no implementation details.

## 10) Risks (Spec-Level)
- Table: Risk | Likelihood | Impact | Mitigation
- Include both technical and domain risks.

## 11) Open Decisions
- Table: Decision | Options | Recommendation | Status
- Decisions that must be resolved before planning.
- Include the recommendation column — never leave it blank.
```

## Section-Specific Guidance

**Entity boundaries (L3):** If the spec processes people, contacts, or entities, section 2 or 3 MUST define who gets included, excluded, and what classification threshold triggers the feature.

**Data model fields (L2):** If the spec references fields from external systems, verify they exist before listing them. Don't assume field names from memory.

**Golden examples (L4):** Quality-dependent acceptance criteria need concrete examples, not just "user can do X successfully."

**No implementation phases:** Specs define behavior, interfaces, and constraints. Build order, effort estimates, and deployment sequencing belong in the plan document. If you find yourself writing "Phase 1: Build X, Phase 2: Build Y" — stop, that's plan content.

## Extending the Template

Real specs often need sections beyond these 11. Common additions:
- **Phase 0 Prerequisites** — what must exist before implementation starts
- **Database Schema** — full CREATE TABLE statements with seed data
- **v1 vs v2+ Scope Split** — detailed breakdown when phased
- **Related Specs** — wiki-links to specs this one depends on or extends
- **Appendix** — supporting links, external references
