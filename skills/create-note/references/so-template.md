---
date created: {today}
category: Structure Outline
source: "[[{spec_filename}]]"
design: "[[{dd_filename}]]"
tags: [{relevant tags}]
---

# SO - {Spec Name} Structure Outline

## Module Boundaries
{Which modules/services/files are touched. High-level component map.}
| Module | Scope of Changes | New/Modified |
|--------|-----------------|--------------|

## Key Signatures & Types
{New or changed function signatures, API endpoints, database columns, types. NOT the implementation — just the interface.}

### API Changes
| Endpoint | Method | Input | Output | Notes |
|----------|--------|-------|--------|-------|

### Schema Changes
| Table | Column | Type | Notes |
|-------|--------|------|-------|

### New Types/Interfaces
{TypeScript interfaces, Pydantic models, etc. — just the shape, not the logic.}

## Data Flow
{How data moves through the system for the key user-facing scenarios. Can be ASCII diagram or numbered steps.}

## Phase Order
{Implementation phases in vertical slices. Each phase MUST deliver a user-testable outcome.}

### Phase 1: {name}
- **User-testable outcome:** {what the user can do after this phase}
- **Changes:** {which modules, what signatures}
- **Checkpoint:** {how to verify this phase works}

### Phase 2: {name}
- **User-testable outcome:** {what new capability}
- **Changes:** {which modules}
- **Checkpoint:** {verification}

## Vertical Slice Verification
{For each phase, answer: "Can the user do something new after this phase?" If no → the phase is horizontal and must be restructured.}
| Phase | User-Testable Outcome | Vertical? |
|-------|----------------------|-----------|
