# Retro Report Template

This is the detailed template structure for the RET document produced in Phase 2 (Review).

## Report Structure

Save to the project's vault Reports directory as `RET - {Project Name} - {Scope}.md`. The project name and scope go in the title — no "Retrospective" suffix (the `RET` prefix is self-evident).

```markdown
---
category: Retrospective
date created: {today}
date modified: {today}
tags: [retrospective, {scope-tag}, {project-tag}]
---
```

## Required Sections

### 1. Summary Statistics
| Metric | Value |
|--------|-------|
| Total commits | N |
| Feature commits | N |
| Fix/polish commits | N |
| Build:fix ratio | X% : Y% |
| Distinct incidents | N |
| Incidents caught by user | N |
| Incidents caught by QA | N |
| Incidents self-caught | N |

### 2. What Worked Well (5-8 items)
For each: what happened, WHY it worked, which process/template enabled it.
Look for: audit-first gate catches, smart architecture decisions, carry-forward effectiveness, compound returns from shared packages.

### 3. What Didn't Work Well (every incident)
For each incident:
- What happened (user-visible symptom)
- Root cause (technical)
- How caught (user / QA / worker / self)
- Fix timeline (commits + elapsed time)
- Template rule that SHOULD have prevented it
- Category (framework gotcha / compliance failure / gap / scope miss / visual)

### 4. Carry-Forward Effectiveness
Table: each carry-forward from previous retro → was it effective? If not, why?

### 5. Process Gaps
For each gap: which template file needs the change, what the change should say.

### 6. Proposed Changes
**This is the most important section.** For each proposed change:
- Change ID (C1, C2, ...)
- Target file (worker-template.md, auditor-prompts.md, tracker-prompts.md, SKILL.md, lessons.md)
- Exact text to add/replace — not descriptions, ACTUAL TEXT
- Which incidents it prevents

### 7. Success Patterns to Preserve
Non-obvious approaches that worked and should be documented so future sprints repeat them.

### 8. Handoff — Operational State

This section replaces what was previously a separate HAN document. It captures everything the next session needs to resume efficiently.

#### Outcome
- Status: {COMPLETE / IN PROGRESS / BLOCKED}
- Plan progress: {N}/{total} tasks done

#### Task Status

**Completed:**
| Task | Description | Status |
|------|-------------|--------|
| {task_id} | {description + key commit hashes} | Done |

**In Progress** (if work unit is incomplete):
| Task | Description | Status |
|------|-------------|--------|
| {task_id} | {description} | {status + what's needed} |

**Pending:**
| Task | Description | Blocked On |
|------|-------------|-----------|
| {task_id} | {description} | {blocker} |

#### Infrastructure Changes
| # | Change | Impact |
|---|--------|--------|
| {n} | {what changed} | {effect} |

#### Carry-Forwards

**Immediate (next session start):**
| # | Item | Action |
|---|------|--------|
| {n} | {item} | {what to do} |

**Technical Debt (tracked, not blocking):**
| # | Item | Priority |
|---|------|----------|
| {n} | {item} | {priority} |

**Shared Service Issues (flagged, not fixed):**
| # | Service | Issue | Severity |
|---|---------|-------|----------|
| {n} | {service} | {description} | {H/M/L} |

#### Plane State Reference
Include project IDs, state UUIDs, and issue IDs the next session will need.
> **CRITICAL:** Plane API requires **full UUIDs** in PATCH requests. Partial 8-char prefixes silently fail (L32).

#### Plans & Key Files
- Plan: {path}
- Spec: {path}
- Daily note: {path}

#### Lessons Added
List any new lessons with their IDs and one-line summaries.

## Present to User

After the report is generated, present a summary to the user:
- Key numbers (build:fix ratio, incident count)
- Top 3 incidents by impact
- Proposed changes table (ID, file, what it prevents)
- Carry-forwards summary
- Ask: "Want me to apply all N changes?"
