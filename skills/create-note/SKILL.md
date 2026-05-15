---
name: create-note
description: >-
  Unified vault document creator. Handles SD, SPC, PIC, MN, PD, FD, DD, SO, RE, EB, and CAM
  documents with correct frontmatter, routing, writing profiles, and type-specific
  structure. Replaces individual create-sd, create-spec, create-pickup, create-MN,
  create-concept-brief, design, and structure skills.
  Trigger: "create note", "create SD", "create spec", "create PIC", "create MN",
  "create PD", "create FD", "feature definition", "design discussion", "structure outline",
  "write a report", "executive brief", "create EB", "create campaign", "pulse campaign",
  or any request to create a vault document by prefix.
---

# Create Note

Unified document creation for the Work Vault. One skill, all document types. The type determines frontmatter, routing, writing profile, and section structure.

## Step 1: Determine type

Parse the user's request or argument to identify the document type. Accept any of:

| Type | Triggers | Old skill |
|------|----------|-----------|
| `SD` | "create SD", "system definition" | `/create-sd` |
| `SPC` | "create spec", "spec this", "write a spec" | `/create-spec` |
| `PL` | "create plan", "plan this", "make this actionable" | `/create-plan` |
| `PIC` | "create pickup", "make a PIC", "save for later" | `/create-pickup` |
| `MN` | "create MN", "meeting note", "write up the meeting" | `/create-MN` |
| `PD` | "product definition", "create PD", "I have an idea" | `/create-concept-brief` |
| `FD` | "feature definition", "create FD", "define this feature" | (none) |
| `DD` | "design discussion", "DD for this spec" | `/design` |
| `SO` | "structure outline", "SO for this spec" | `/structure` |
| `RE` | "create report", "write a report" | (none) |
| `EB` | "executive brief", "exec brief", "create EB", "write a brief" | (none) |
| `CAM` | "create campaign", "pulse campaign", "KB campaign" | (none) |

If the type is ambiguous, ask via AskUserQuestion.

## Step 2: Shared setup

Run these for every type. This is the boilerplate that was duplicated across 7 skills.

1. **Path resolution.** Read `~/.claude/wfk-paths.json`. Use `vault_root` and `paths` to resolve all directory references. If missing, use defaults and warn once.

2. **Project context.** Read the target project's `CLAUDE.md` and `lessons.md` if they exist. If the project is ambiguous, ask.

3. **Writing profiles.** Load `WP - General.md` from your vault's Writing Profiles directory. Then load the type-specific profile if one exists (see lookup table below). Follow both.

4. **Oracle check.** Read the project's PJL frontmatter for `oracles:`. If an oracle exists, query it for domain grounding relevant to the document being created. If none exists, offer to create one. This is a prompt, not a gate. Skip for MN and PIC (they don't benefit from oracle grounding).

5. **Frontmatter.** Set from the lookup table below. Never guess the category.

## Lookup table

This is the single source of truth for document metadata. Every field is mandatory.

| Type | Category (frontmatter) | Writing Profile | Routing |
|------|----------------------|-----------------|---------|
| `SD` | `System Definition` | `WP - SD.md` | `{project}/SD - {Name}.md` |
| `SPC` | `Spec` | `WP - SPC.md` | `{project}/specs/{date}/SPC - {Name}.md` |
| `PL` | `Plan` | (General only) | `{project}/plans/{date}/PL - {Name}.md` |
| `PIC` | `Pickup` | `WP - PIC.md` | `{project}/pickups/{date}/PIC - {Name}.md` |
| `MN` | `Meeting` | `WP - MN.md` | `01_Notes/Meetings/MN - {date} ({Topic}).md` |
| `PD` | `Spec` | (General only) | `{project}/concepts/{date}/PD - {Name}.md` |
| `FD` | `Feature Definition` | (General only) | `{project}/specs/{date}/FD - {Name}.md` |
| `DD` | `Plan` | (General only) | `{project}/designs/{date}/DD - {Name}.md` |
| `SO` | `Plan` | (General only) | `{project}/structures/{date}/SO - {Name}.md` |
| `RE` | `Report` | `WP - RE.md` | `{project}/reports/{date}/RE - {Name}.md` |
| `EB` | `Report` | `WP - RE.md` | `{project}/reports/{date}/EB - {Name}.md` |
| `CAM` | `Campaign` | (General only) | `{project}/campaigns/CAM - {Name}.md` |
| `MRM` | `Report` | (General only) | `01_Notes/Reports/MRM/MRM - {YYYY-MM}.md` |
| `WRM` | `Report` | (General only) | `01_Notes/Reports/WRM/WRM - {YYYY}-W{ww}.md` |

`{project}` = `02_Projects/<project-name>/`
`{date}` = today's date (YYYY-MM-DD)

Cross-cutting PICs (no project) go to `01_Notes/Pickups/{date}/`.

## SPC Tier Caps (mandatory for type=SPC)

Specs must match the size of the defect or feature surface. Oversized specs are scope creep made permanent. Before drafting any SPC, declare the tier and cap the FR count. This is enforced.

| Tier | FR cap | When to use |
|------|--------|-------------|
| `brief` | ≤ 5 FRs | Single-defect fixes, bounded improvements, single-function changes. Most specs are brief. |
| `standard` | ≤ 10 FRs | New features touching 2-4 surfaces, or fixes that legitimately span multiple modules. |
| `comprehensive` | unbounded | New systems, major architectural work, multi-phase initiatives. Requires explicit reasoning in frontmatter (`comprehensive_reason: <one sentence>`). |

**Default tier is `brief`.** Drafting a spec at standard or comprehensive requires explicit user agreement before drafting begins. If the user has not specified a tier and the request sounds like a fix, draft as brief.

**Mid-draft enforcement:** If you find yourself wanting to add an FR-6 to a brief spec, STOP. The brief target was wrong, OR the new FR is scope creep. Use AskUserQuestion to surface the tension: "Spec was scoped as brief (≤5 FRs). Adding FR-6: {description}. Should this become a standard spec, or should FR-6 be moved to a separate future-work spec?" Do not silently expand.

**Ask the tier question explicitly** before starting any SPC draft if the user has not stated it. Example AskUserQuestion: "What tier is this spec? Brief (≤5 FRs, single-surface fix), Standard (≤10 FRs, multi-surface feature), or Comprehensive (unbounded, requires reasoning)?"

This rule exists because a past session drafted a 26-FR spec for a 5-FR fix. The bloat was the entire failure mode, encoded in one artifact. Tier caps make that fail loudly during drafting instead of silently shipping. See the relevant agent lesson on spec scope.

## Step 3: Load type template

Read the type-specific template from `templates/{TYPE}.md` within this skill directory. The template defines:
- Section structure (what sections to include and their order)
- Type-specific workflow steps (interviews, verification, codebase exploration)
- Type-specific writing rules beyond the general profile
- Reference files to read (from `references/` directory)

Follow the template instructions exactly. The template is the authority on type-specific behavior.

## Step 4: Write the file

Create the file at the routing path from the lookup table. Create directories if needed.

Standard frontmatter block (all types):

```yaml
---
date created: YYYY-MM-DD
tags: [<type-tag>, <project-tag>]
category: <from lookup table>
---
```

Types may add fields (SD adds `version`, PIC adds `status`/`goal`/`pickup_date`, SPC adds `status`/`source`). See templates for type-specific frontmatter.

## Step 4b: Named entity verification (inline)

The General writing profile (`WP - General.md`) contains a "Named entity verification" section with the full procedure. Follow it during Step 4, not after. Verify each person's full name, email, and role at the moment you write them, before moving to the next sentence. If any entity cannot be confirmed via vault grep, use first name only and mark `[UNVERIFIED]`.

This step exists because name fabrication is undetectable by the reader. Every error caught in past sessions was a plausible-sounding name constructed from nearby context. The checks are mechanical: grep the vault, confirm the match, move on.

## Step 5: Post-creation

After writing, perform type-specific post-steps from the template (e.g., PIC logs to PJL, MN links in daily note, SPC runs review gate). Then report the file path.

## Notes

- **Update mode.** If the user says "update the spec" or "add to the PIC", this is an update, not a create. For SPC, read `references/update-spec.md`. For PIC, merge into the existing open PIC. For other types, read the existing file and apply changes.
- **Retire old skills.** This skill replaces create-sd, create-spec, create-pickup, create-MN, create-concept-brief, design, and structure. Those skills should be removed once this one is validated.
