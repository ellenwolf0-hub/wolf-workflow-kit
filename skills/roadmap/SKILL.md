---
name: roadmap
description: >-
  Create or refresh an MRM (Monthly Roadmap) and its WRM (Weekly Roadmap) companion.
  Audits all open work, aligns it to the user's stated strategic goals, triages
  PICs into active/parked/blocked, sets monthly objectives with done definitions,
  derives 3 weekly goals, and produces decision rules for staying focused. See
  the Period Reporting System definition for the full architecture. Use this skill when
  the user says "roadmap", "create roadmap", "refresh roadmap", "strategic plan",
  "what should I focus on", "priority reset", "workload audit", "realign priorities",
  or after a major meeting changes strategic direction. Also use when the
  current MRM is expired (past its month) and orient flags "no current MRM."
---

# Roadmap — Monthly and Weekly Roadmaps

Create a goal-driven MRM (Monthly Roadmap) that maps all active work to the user's
stated objectives, triages open PICs, phases tasks across weeks, and produces a WRM
(Weekly Roadmap) as the operational lever. The MRM is the "why" behind every PIC and
SOD priority. The WRM is the "what this week" derived from it. Per the Period
Reporting System, MRM replaces the old RM + SOM, and WRM replaces the old WF + SOW.

**Design principles:**
- Goal-driven, not project-driven. Work organizes under strategic goals, not project names.
- PICs are the unit of work. The RM references existing PICs, it does not invent tasks.
- Capacity is finite. The skill enforces triage: active vs parked vs blocked.
- Decision rules prevent accumulation. Every RM includes situational rules for handling new requests.
- The WRM is derived from the MRM, never created independently.

## Path resolution

Read `~/.claude/wfk-paths.json` at startup for vault paths. Fall back to defaults if missing.

## Input

Accept one of:
- No argument: full roadmap creation from current state
- `refresh`: update the existing RM with current work state (close completed phases, open new ones)
- `weekly-focus` or `wf`: generate only a new WF from the current RM (for a new week)
- A path to a meeting note (MN): create roadmap incorporating freshly triaged requests

## Step 0: Load context

Read in parallel:

1. **Current MRM** (most recent file in `{vault_root}/01_Notes/Reports/MRM/`). If one exists, note its month and status. A refresh updates it; a new creation supersedes it.
2. **Current WRM** (most recent file in `{vault_root}/01_Notes/Reports/WRM/`). Shows what was planned this week.
3. **Strategic goals** at `{vault_root}/04_Reference/REF - Strategic Goals.md`. These are the goal headings for the RM. If this file does not exist, goals must come from the user.
4. **Request Log** at `{vault_root}/03_Operations/Work REF/Request Log.md` (if exists). Shows all requests and their current status/tier.
5. **Most recent SOD**. Shows today's priorities and open work inventory.
6. **Most recent EOW**. Shows what shipped last week, goal progress, retro findings.
7. **Most recent EOM** (if within first week of month). Shows monthly carry-forwards.

## Step 1: Audit current work

Scan the vault to build a complete inventory. Run these in parallel:

### PICs
Glob `{vault_root}/02_Projects/**/PIC - *.md` and `{vault_root}/02_Projects/**/pickups/**/PIC - *.md`.
For each PIC, read its frontmatter to extract: title, status (open/closed/picked-up), date created, project.
Count totals: open, closed, picked-up.

### Requests
Read the Request Log (if it exists). Count by tier: ACT, SPEC, WATCH, PARK, DONE.
Identify any SPEC-tier requests that have had no activity in 7+ days.

### Project Logs
Glob `{vault_root}/02_Projects/**/PJL - *.md`.
For each PJL, check the most recent date heading. Flag as "stalled" if no entry in the last 7 days.

### Recent daily notes
Read the last 5 daily notes (`DN - *.md` sorted by date). Extract:
- Context switching patterns (how many different projects per day)
- Whether SOD priorities were actually worked on

## Step 2: Confirm strategic goals

Present the audit summary to the user:

```
Workload snapshot:
- [N] open PICs ([X] active, [Y] parked, [Z] blocked)
- [N] Requests ([A] ACT, [B] SPEC, [C] WATCH)
- [N] active PJLs, [M] stalled (no activity >7 days)
- Context switching: avg [N] projects/day over last 5 days
```

Then present the strategic goals. If the strategic goals file exists, show those goals and ask if they're still current. If it doesn't exist, ask the user to state 3-5 goals.

Use AskUserQuestion with multiSelect to confirm which goals are active for this roadmap period. Present each goal as an option with a brief description. The user can also add new goals via "Other."

## Step 3: Align work to goals

For each confirmed goal, scan the open PICs, active requests, and recent PJL entries to find related work. Build a mapping:

| Goal | Related PICs | Related Requests | Recent PJL activity |
|---|---|---|---|

Present the alignment to the user. Flag:
- PICs that don't align to any goal (candidates for parking)
- Goals with no related PICs (need new PICs or the goal is aspirational)
- Requests at SPEC or WATCH tier that could be upgraded if they serve an active goal

Use AskUserQuestion to confirm the alignment. One question: "These [N] PICs don't align to any active goal. Park them?" with multiSelect showing each unaligned PIC.

## Step 4: Triage PICs

Classify every open PIC into one of:
- **Active**: serves an active goal, has a clear next step, not blocked
- **Parked**: serves a goal but is not this period's priority (with explicit reason)
- **Blocked**: has an external dependency preventing progress (name the blocker)

Apply the capacity gate: if active PICs exceed 8, flag and ask the user to park more. Present the triage result and get confirmation.

## Step 5: Phase the work

For each active goal, organize its PICs and tasks into phases with week assignments:

1. Read each active PIC's "Next steps" or equivalent section
2. Identify dependencies between PICs (if PIC A's output feeds PIC B)
3. Group into phases: Phase 1 (this week), Phase 2 (next week), Phase 3 (week after)
4. Within each phase, create a task table:

```markdown
| # | Task | PIC / Source | Status | Dependency |
|---|------|-------------|--------|------------|
| 1.1 | [task description] | [[PIC - Name]] | todo | none |
| 1.2 | [task description] | [[PIC - Name]] | todo | 1.1 |
```

Task descriptions come from the PICs' next steps, not invented. If a PIC has no next steps, flag it as needing update.

Add per-goal sections as needed:
- **Known issues**: bugs, edge cases, or risks discovered during audit
- **Supporting infrastructure**: work already done that this goal depends on
- **Parked features**: WATCH-tier items related to this goal

## Step 6: Build parked work section

Organize all non-active work into:
- **Parked PICs** (with reason for each: "blocked on external", "future phase", "not this period")
- **WATCH Requests** (requests not on critical path this period)
- **PARK Requests** (prerequisites or future phases)
- **Stalled PJLs** (no activity >7 days, listed for visibility)

## Step 7: Write decision rules

Generate 3-5 situational decision rules based on the current context. Standard rules:

1. **New request?** Check against Goals 1-N. If it serves an active goal, absorb. If not, WATCH tier.
2. **Infrastructure incident?** Fix if blocking active goals. Otherwise PIC it and continue.
3. **Minor recurring task?** Do in <30 min or park with reason.
4. **Open PIC count exceeds [threshold]?** Triage before adding more.

Add context-specific rules based on deadlines, demos, or constraints identified during audit.

## Step 8: Write the MRM document

Write to: `{vault_root}/01_Notes/Reports/MRM/MRM - {YYYY-MM}.md`

Follow the MRM template at `~/.claude/skills/end-day/templates/mrm-template.md` for structure and frontmatter. The MRM contains: strategic frame paragraph, 3-5 monthly objectives with done definitions, decision rules, systemic landing zones, and carry-forward with objective alignment.

## Step 9: Write the WRM document

Derive the Weekly Roadmap from the MRM's objectives. Write to:
`{vault_root}/01_Notes/Reports/WRM/WRM - {YYYY}-W{ww}.md`

Follow the WRM template at `~/.claude/skills/end-day/templates/wrm-template.md` for structure and frontmatter. The WRM contains: MTD context, 3 weekly goals (each inheriting from an MRM objective with done criteria), in/out scope lists, directives from EOW retro, and Monday frog.

## Step 10: Mark previous MRM/WRM as superseded

If a previous MRM exists for the same month, update its frontmatter: `status: superseded`. Same for previous WRM for the same week.

## Step 11: Present summary

Output a concise summary:

```
MRM created: [[MRM - {YYYY-MM}]]
WRM created: [[WRM - {YYYY}-W{ww}]]

Objectives:
1. [Objective 1] — [N] PICs aligned, [done definition]
2. [Objective 2] — [N] PICs aligned, [done definition]
3. [Objective 3] — [N] PICs aligned, [done definition]

Weekly goals (from WRM):
1. [Goal 1] — done = [criteria]
2. [Goal 2] — done = [criteria]
3. [Goal 3] — done = [criteria]

Triage: [X] PICs active, [Y] parked, [Z] blocked, [W] unaligned
Decision rules: [N] rules set

Orient loads MRM + WRM at session start.
End-day reports goal progress against WRM goals.
SOD inherits priorities from WRM.
```

## Refresh mode

When called with `refresh`:
1. Read the current MRM
2. Re-run Steps 1-4 (audit, confirm goals, align, triage) against current state
3. Update objective progress in-place
4. Recalculate parked work and carry-forward
5. Write updated MRM (same file, bumped version in frontmatter)
6. If the current week's WRM is stale, regenerate it

## Weekly Roadmap only mode

When called with `wrm`:
1. Read the current MRM (error if none exists)
2. Derive 3 weekly goals from MRM objectives
3. Generate a new WRM document for the upcoming week
4. Mark the previous WRM as superseded

## Writing rules

Load and follow `WP - General.md` from Writing Profiles. The RM is a Plan (category: Plan). Task tables use the established column format. No em dashes. Tight spacing. Wikilink all PICs and PJLs.

## Error handling

- **No strategic goals found**: Ask the user. Do not proceed without confirmed goals.
- **No open PICs**: Still create the RM, but flag that goals have no active work and recommend creating PICs.
- **PIC count exceeds 12**: Hard warning. Triage must reduce to 8 or fewer before the RM is finalized.
- **Previous RM still active for current week**: Ask whether to refresh or supersede.
