# DD Template - Design Discussion

## Frontmatter additions

```yaml
status: Draft
source: "[[SPC - Source Spec]]"
```

Tags: `[plan, design-discussion, <project-tag>]`

## Input

Requires a spec path. If not provided, ask which spec to work from.

## Pre-steps

1. Read the spec. Extract project name and scope.
2. Check for review artifacts in `reviews/` directory. Read scope-analysis, context-brief, spec-review if they exist.
3. If CLAUDE.md specifies a repo path, explore the codebase for Current State and Patterns sections.
4. Estimate LOC. If <500, inform user DD is optional and offer to skip to `/create-note SO`.

## Reference files

Read `references/dd-template.md` for the full template structure.

## Section structure (~200 lines)

1. **Current State** - what exists today, from codebase exploration
2. **Desired End State** - concrete target behavior from the spec
3. **Patterns Found** - table of relevant patterns from the codebase
4. **Approach Options** - at least 2 options with tradeoffs, effort estimates, and a recommendation
5. **Resolved Decisions** - locked in from spec or review
6. **Open Questions** - questions that change the implementation approach

## Question resolution

For each Open Question, present to user one at a time via AskUserQuestion. Include question, impact, and default. Record answers in Resolved Decisions.

## Handoff

"Design discussion complete. Ready for `/create-note SO` to create the structure outline."
