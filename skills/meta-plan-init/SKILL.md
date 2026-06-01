---
name: meta-plan-init
description: >-
  The front door to the Pipeline Coordination system. One guided skill that doubles as
  installer + onboarder + meta-plan builder + first-handoff drafter + launcher. It scans a
  project's recent work for a goal and a candidate work-pile, sorts that pile WITH the
  operator, writes a coordination meta-plan PL and a first delegation handoff (HAN), installs
  the handoff-handling overlays into the create-note and pickup skills, teaches the three
  roles (orchestrator / coordinator / worker) in plain words, and prints exact launch
  instructions. Trigger on "meta-plan-init", "/meta-plan-init", "set up coordination",
  "set up the meta-plan", "bootstrap the pipeline coordination", "onboard me to the
  coordination system", "adopt my existing work into a meta-plan", or any request to stand
  up the coordinated-pipeline-execution layer for a project. Messy-work-adopt is the primary
  path; clean-start is the degenerate case.
---

# Meta-Plan Init — the coordination front door

This skill bootstraps the **Coordinated Pipeline Execution** layer for a project in one guided run. A newcomer installs the plugin, runs this once, and ends with a working meta-plan, a first handoff, the handoff-handling overlays installed, an understanding of the three roles, and exact instructions for how to launch.

You run this **with the operator**, conversationally. It is an interview plus a few file writes, not an autonomous batch job. Surface every genuine decision via AskUserQuestion; do not guess the operator's goal or sort their work-pile silently.

There are two paths. **Messy-work-adopt is the PRIMARY path** (the project already has scattered work to organize). **Clean-start is the degenerate case** (no prior work; cold interview). Detect which applies in Step 1 and degrade gracefully when reporting artifacts are absent.

## Step 0: Resolve paths and target project

1. Read `~/.claude/wfk-paths.json` for `vault_root` and `paths`. If it is missing, ask the operator for the notes-vault root and the projects directory, and proceed with those.
2. Determine the target project: the directory the operator names, or the one implied by the current working directory. If ambiguous, ask via AskUserQuestion (list candidate project dirs you find under the projects path).
3. **Idempotency check.** Look for an existing coordination PL for this project (`PL - *Meta-Plan*.md` with frontmatter `agent: meta-orchestrator`). If one exists, do NOT overwrite it. Offer to adopt/refresh it instead, or to target a different project.

## Step 1: Scan for goal + work-pile (primary path)

Gather evidence so you can PROPOSE a goal and a candidate work-pile rather than asking the operator to author them cold. Read what exists; skip what does not. Sources, in priority order:

1. **Period/priority artifacts** if present: start-of-day / weekly / monthly planning notes (in this vault, SOD/WRM/MRM). These name current goals directly.
2. **Recent activity:** the last several daily notes and the project's log (PJL or equivalent). These show what is actually in motion.
3. **The project's tracked work:** open pickups (`PIC - *.md` non-closed), plans (`PL - *.md`), and specs (`SPC - *.md`) under the project dir. These are the candidate work-pile items.
4. **Project context:** the project's `CLAUDE.md` / `lessons.md` and any system-definition or spec docs that state the project's purpose.

From this evidence:
- **Draft a goal:** one paragraph stating the done-state for this coordination scope. This becomes the meta-plan's anchor for every "is this still relevant?" decision.
- **Draft a candidate work-pile:** the open/in-flight items you found, each as a one-line entry with a wikilink.

**Graceful degradation.** If the period/priority artifacts are absent, fall back to recent activity + tracked work. If those are thin too, say so plainly and move toward the clean-start interview (Step 1b) for whatever is missing. Never fabricate a goal or invent work items; if the evidence is empty, the project is a clean start.

### Step 1b: Clean-start (degenerate case)

If the scan finds essentially no prior work, run a short cold interview instead:
1. AskUserQuestion: what is the goal / done-state of this coordination scope?
2. AskUserQuestion: what are the first 2-5 pieces of work that move toward it?
3. Use the answers as the goal + work-pile. Proceed to Step 2.

## Step 2: Sort the pile WITH the operator

Present the drafted goal and candidate work-pile as text, then sort it together against the deliverable. For each item the operator confirms is in scope, decide WITH them:
- which **stream** it belongs to (the critical-path spine, or a named parallel stream),
- its rough **order / blocked-by** relationship,
- whether it is **stale** (work finished or superseded; the status field just was not flipped),
- whether it is a genuine **decision** that must be made before work can proceed (goes to the decision queue).

Use AskUserQuestion for real choices (one at a time). Confirm the final goal wording with the operator before writing. The output of this step is a sorted set of streams + items + decisions + stale-closures that maps directly onto the meta-plan template's sections.

## Step 3: Write the meta-plan PL

Read `templates/coordination-pl.md` from this skill directory. Instantiate it for the project:
- Fill frontmatter: `date created`, `project`, `goal` (the confirmed paragraph), `status: Active`, `agent: meta-orchestrator`, `last_synced` / `last_orchestrator_run` to today / run #0.
- Fill the Pipeline map, Critical path, Status board streams, Decision queue, Cross-stream entanglements (keep at least one placeholder row even if empty), and Stale-items table from Step 2's sorted set.
- Keep the **Orchestrator resume** block verbatim (the three-role explainer and the HAN-sweep resume protocol are the delegation engine). Seed the **Active delegation handoffs** index with a single `none active` row; the first handoff gets added in Step 4.
- Keep the Orchestrator playbook section verbatim from the template (it is the engine the orchestrator agent applies, including the delegation-handoff sweep step).

Write to the project's plans directory under a dated subfolder, per the host vault's routing (`<project>/plans/<date>/PL - <Project> Meta-Plan Execution.md`). Report the path.

## Step 4: Draft the first delegation handoff (HAN)

Pick the single most-ready bounded slice from the sorted pile (a critical-path item with no blocker, or the operator's choice). Read `templates/first-han.md` and instantiate it:
- Frontmatter carries the delegation signals: `category: Handoff`, `type: Handoff`, `status: active`, `related_pl` pointing at the PL you just wrote, and `orchestrator_contact`. These signals are what make pickup route it to the coordinator playbook.
- Fill Mission (+ any locked decisions), Verified live state, Bracket/phased plan, Hard constraints + anti-scope, and Done criteria from what you and the operator established.
- Leave `## Checkpoint log` and `## Clarification requests` empty (the coordinator writes the first checkpoint).

Write to the project's pickups directory under a dated subfolder (`<project>/pickups/<date>/HAN - <Name>.md`). Then update the PL in three places: (a) set the slice's Status Board row to `DISPATCHED-TO-AGENT` with a wikilink to the HAN; (b) replace the `none active` row in the Active-delegation-handoffs index with a real row (handoff wikilink, State `active`, and what the orchestrator owes on its next sweep); (c) append an Update-log entry. Report the path.

(If the create-note overlay is installed, you may equivalently invoke create-note to author the HAN; the bundled template here keeps this skill self-contained so it works on a fresh machine before any other skill is consulted.)

## Step 5: Install the overlays

The handoff-handling behavior ships as overlay files, never as edits to the create-note / pickup skill bodies, so a kit update never clobbers it and uninstall is a clean delete. Install both:

1. **create-note overlay.** Copy `overlays/create-note.LOCAL.md` (from this skill dir) to `~/.claude/skills/create-note/LOCAL.md`. **Check-then-write:** if a `LOCAL.md` already exists there, do NOT clobber it; show the operator the diff and ask whether to merge or skip.
2. **pickup overlay.** Copy `overlays/pickup.LOCAL.md` to `~/.claude/skills/pickup/LOCAL.md`, same check-then-write rule.
3. **create-note hook.** Confirm `~/.claude/skills/create-note/SKILL.md` ends with the `## Local Customizations` loader footer:
   ```
   ## Local Customizations

   If `LOCAL.md` exists in this skill directory, load and follow it after these instructions. Local instructions override upstream where they conflict.
   ```
   If absent, append it (one-time, idempotent). pickup already ships this hook in its body; verify it is present and add it only if missing.

State to the operator: uninstall = delete the two `LOCAL.md` files (and the create-note hook footer, if you added it); behavior reverts with no residue.

## Step 6: Teach the three roles (plain words)

Explain the system to the operator in plain language, no jargon dump:

- **Orchestrator** — the planner. It owns the meta-plan PL you just created. It never does the work itself: it reads the current state, updates the status board, tells you what to spin up next, and answers questions from coordinators. You talk to it by picking up the meta-plan PL in a session.
- **Coordinator** — the runner. You start a session, hand it a handoff (the HAN), and it runs that one slice: it breaks the work into pieces, spins up worker helpers, checks their output is actually correct, and reports lean progress back into the handoff for the orchestrator to read. The coordinator is who you chat with while a slice is being built.
- **Worker** — the builder. The coordinator spawns workers to do the actual building. Each gets one bounded piece, builds it, and reports back to the coordinator with proof. Workers do not certify their own work; the coordinator validates it.

The handoff (HAN) is the contract that flows between them: the orchestrator writes it, the coordinator runs it and posts checkpoints, the orchestrator reads those checkpoints and reconciles. Keep the handoff lean: it is a decision signal, not a work log.

## Step 7: Print launch instructions

Print exact, copy-pasteable next steps:

1. **To run the orchestrator (plan / decide what's next):** open a new session in this project and pick up the meta-plan PL: `/pickup PL - <Project> Meta-Plan Execution`. It loads as the orchestrator and tells you what to dispatch.
2. **To run the first slice (coordinator):** open a fresh session and pick up the handoff: `/pickup HAN - <Name>`. It routes to the coordinator playbook, which stands up workers and builds the slice. Custom agent profiles load at session start, so start a fresh session for this.
3. Remind the operator: one work-doing session at a time on the critical path; up to two parallel only if they are in different streams and share no files.

## Notes

- **Adopt mode.** If Step 0 found an existing coordination PL, do not re-bootstrap. Offer to refresh the status board from current state and draft a next handoff against the existing PL instead.
- **Zero re-derivation by the operator.** The whole point is that the operator confirms and sorts; the skill drafts. Do the scanning and drafting; reserve the operator's attention for goal wording, scope decisions, and the sort.
- **Self-contained.** Everything this skill needs (PL template, HAN template, overlay install-sources) ships in this skill directory, so it runs on a clean machine before any other coordination component is consulted.
