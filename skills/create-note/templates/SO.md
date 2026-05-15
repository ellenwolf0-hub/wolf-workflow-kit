# SO Template - Structure Outline

## Frontmatter additions

```yaml
status: Draft
source: "[[SPC - Source Spec]]"
```

Tags: `[plan, structure-outline, <project-tag>]`

## Input

Requires a spec path. If not provided, ask which spec to structure.

## Pre-steps

1. Read the spec. Extract project name and scope.
2. Check for a DD in `designs/` directory. If one exists, read it for design decisions.
3. If no DD exists and LOC >500, recommend running `/create-note DD` first.
4. Read project CLAUDE.md. Explore codebase if repo path is specified.

## Reference files

Read `references/so-template.md` for the full template structure.

## Section structure (~2 pages)

1. **Module Boundaries** - which modules/services/files are touched
2. **Key Signatures & Types** - new or changed interfaces, endpoints, schemas (shape only, not logic)
3. **Data Flow** - how data moves for key user-facing scenarios
4. **Phase Order** - implementation phases as vertical slices

## Vertical slice enforcement

Every phase MUST deliver a user-testable outcome. If any phase is purely horizontal (e.g., "set up all database tables"), restructure into vertical slices.

Fill the Vertical Slice Verification table: "Can the user do something new after this phase?" If no, restructure.

## Review

Present phase order to user for approval before saving. They may reorder, split, or merge phases.

## Handoff

"Structure outline complete. Ready for `/create-plan` to create the detailed implementation plan."
