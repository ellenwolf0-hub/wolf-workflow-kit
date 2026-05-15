# Update Spec Sub-Skill

When the user's idea belongs under an existing spec, follow these steps instead of the Create flow.

## Step U1 — Understand the Addition

1. **Read the target spec fully.** You need to know what's already there — every FR, every SAT, every open decision — before you can add to it.

2. **Run a short interview** (interactive mode) focused on the addition:
   - **What are you adding?** (If not already clear from context)
   - **Any new constraints or assumptions?**
   - **Does this change anything that's already in the spec?** (This is the critical question — it determines whether this is additive or contradictory)

3. **Confirm understanding** with a summary:
   > "I'll add the following to SPC - Admin Alert Management System:"
   > - New FRs: [summary]
   > - Scope changes: [if any]
   > - Potential conflicts: [if any]

---

## Step U2 — Update the Spec

### ID Continuity

Find the highest existing ID for each category and continue from there. If the spec has FR-1 through FR-15, new requirements start at FR-16. **Never reuse or renumber existing IDs** — reviews, plans, and Plane issues reference them.

### What to Update

Work through each section and apply changes where relevant:

- **Section 1 (Purpose):** Usually unchanged. Update only if the addition changes the overall purpose.
- **Section 2 (Scope):** Add new in-scope items. If the addition was previously listed as out-of-scope, move it and note the change.
- **Section 3 (Functional Requirements):** Append new FRs with the next available IDs. If the addition is a new feature area, add a new subsection (e.g., `### 3.5 New Feature Area`).
- **Section 4 (NFRs):** Add any new NFRs the addition introduces.
- **Section 5 (Constraints):** Add any new constraints.
- **Section 6 (Assumptions):** Add new assumptions, update any that the addition invalidates.
- **Section 7 (Deliverables):** Add new deliverables.
- **Section 8 (SATs):** Add new acceptance criteria. Include golden examples for quality-dependent additions.
- **Section 9 (Architecture):** Update the diagram if the addition changes the component structure.
- **Section 10 (Risks):** Add any new risks.
- **Section 11 (Open Decisions):** Add new decisions. Resolve any that the addition answers.

### Frontmatter & Change Log

Update the frontmatter:
```yaml
date modified: {today}
status: Draft v{N+1}   # bump version
```

Add or append to the `## Change Log` section at the bottom of the spec:
```markdown
## Change Log
| Date | Version | Change | Source |
|------|---------|--------|--------|
| {today} | v{N+1} | {brief description of what was added/changed} | {source — conversation, meeting note, etc.} |
```

### Handling Contradictions

If the new FRs contradict existing ones:

1. **Flag every conflict explicitly** to the user via `AskUserQuestion`:
   > "FR-16 (new: session-based auth) contradicts FR-5 (existing: JWT auth). Which should win?"
   > 1. Keep FR-5, drop FR-16
   > 2. Supersede FR-5 with FR-16
   > 3. Let me explain — it's more nuanced

2. For superseded FRs, don't delete them. Mark them inline:
   ```
   | ~~FR-5~~ | ~~Authenticate via JWT tokens~~ | ~~v1~~ | *Superseded by FR-16 in v2 — session-based auth* |
   ```

3. Record the decision in the Change Log.

---

## Step U3 — Delta Review

**Immediately** run a focused review on the changes — do NOT ask the user for permission. The review is a mandatory gate, not an optional step.

1. **Invoke `/review-spec {spec_path}` directly** — no confirmation needed. The review agents will see the Change Log and focus on the delta.

2. **Key things the review should catch:**
   - Do the new FRs conflict with existing architectural decisions?
   - Are new assumptions compatible with existing ones?
   - Do new SATs cover the new FRs adequately?
   - Are there downstream impacts the user hasn't considered?

---

## Step U4 — Propagate to Downstream Artifacts

After the spec update is reviewed and approved, check for downstream artifacts that need updating.

### Check for Existing Plan

Search for `PL - *.md` in the same directory as the spec. If a plan exists:

1. **Read the plan** — understand its phase structure and which FRs map to which phases.

2. **Determine the impact:**

   | Scenario | Action |
   |----------|--------|
   | **Additive** — new FRs don't touch existing phases | Append a new phase for the new work. Add a Decision Log entry. |
   | **Contradictory, work NOT started** — affected plan items are in Todo/Backlog | Mark superseded items as `Cancelled` with a note. Add replacement items to the appropriate phase or a new phase. Decision Log entry. |
   | **Contradictory, work DONE** — affected plan items are completed | Do NOT touch completed phases. Add a new "Rework" phase scoped to undo/modify the prior implementation. Decision Log entry noting the rework cost. |

3. **Present the plan changes** to the user before applying:
   > "The plan needs these updates:"
   > - New Phase 4: [description]
   > - Phase 2 item 'Implement JWT middleware' → Cancelled (superseded by FR-16)
   > - Decision Log entry: [summary]

4. **Apply approved changes** to the plan file. Update the Progress Overview table.

### Check for Plane Project

If a Plane project exists for this spec (check the plan file for a Plane project link or the Plane registry):

1. **Create new issues** for the new FRs, linked to a new module if appropriate.
2. **Cancel superseded issues** — move to `Cancelled` state with a comment explaining the spec change.
3. **Add rework issues** if needed — reference the completed issues they're modifying.
4. **Label new issues** with a version tag (e.g., `v2-addition`) to distinguish from original scope.

### No Plan or Plane Project

If no downstream artifacts exist yet, just note it in the TLDR:
> "No plan or Plane project exists yet for this spec. Run `/create-plan` when you're ready to plan."

---

## Step U5 — TLDR & Handoff

Same as Create mode Step 5, but tailored for updates:

1. **Give a TLDR** of what changed:
   > "Here's what was updated in SPC - Admin Alert Management System (v1 → v2):"
   > - **Added:** FR-16 through FR-20 (employee scheduling integration)
   > - **Changed scope:** Moved shift templates from out-of-scope to in-scope
   > - **New SATs:** SAT-10, SAT-11
   > - **Plan impact:** New Phase 4 added, no conflicts with existing phases
   > - **Plane:** 5 new issues created in module "Phase 4 — Scheduling"

2. **Offer next steps** using `AskUserQuestion`:
   > 1. Run /create-plan to create/update the plan
   > 2. Done for now
   > 3. I want to make more changes to the spec
