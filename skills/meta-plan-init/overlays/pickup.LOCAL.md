# Pickup — Local Customizations: Handoff (HAN) handling

This overlay adds **handoff (HAN) detection and routing** to pickup. It is self-contained: dropping this file into the skill directory makes pickup surface and route handoffs. Deleting it reverts pickup to PIC-only behavior with no residue.

Handoffs (`HAN - *.md`, `category: Handoff`) are a second pickup surface. A PIC is queued work waiting to start; a **handoff is in-flight work being transferred** to the next session or delegated to a separate coordinator session, usually mid-task. Treat handoffs as first-class alongside PICs, with these differences.

## Detection

During the pickup scan, enumerate handoffs:

`Grep glob="**/HAN - *.md" pattern="^type: Handoff" output_mode="files_with_matches" head_limit=0`

Read lines 1-10 of each match and keep those whose `status:` is NOT `closed`. Status vocabulary: `active` (work in flight) and `closed`. Legacy handoffs may carry other non-closed values (`in-progress`, `re-dispatch-needed`, `build-resumed`); treat anything that is not `closed` as live.

## Surface active handoffs FIRST

Active handoffs outrank PICs in the presentation. An active handoff means live work, possibly being executed by another agent right now. Surface active handoffs at the very top, before any PIC triage cluster. For each, show the handoff name, its `status`, a one-line "what's in flight", and (if the handoff names a team/worker) whether a live process exists, so the operator knows if it is being executed elsewhere vs. waiting to resume. Give each a selection number like any other item.

A handoff being actively run by another coordinator session must not be double-claimed. When in doubt, check for a live worker (`ps -ef | grep` the team name the handoff names) before running it as coordinator.

## Classify: transfer vs. delegation

Before loading any handoff, classify it. The kind determines whether there is a live orchestrator you must communicate with.

- **Transfer handoff.** A session hands its OWN in-flight work to the next session (usually the same operator continuing later). There is no external coordinator. You resume the work and own it outright. No checkpoint/clarification protocol applies.
- **Delegation handoff.** A meta-plan orchestrator has delegated a bounded piece of work to a SEPARATE coordinator session (which the operator starts) and stays in the loop. The orchestrator does not execute; it tracks progress via the HAN and answers questions. The coordinator runs the work through a workgroup. This is a two-way relationship that lasts the life of the work.

**Detect a delegation handoff** by ANY of: an `orchestrator_contact` frontmatter field; a `related_pl` pointing at a meta-plan / coordination PL; a `## Checkpoint log` section; a `## Clarification requests` section; or a "how this works" header naming an orchestrator. If none of these are present, treat it as a transfer handoff. When delegation signals are present, the routing below is MANDATORY for whichever role this session plays.

## Roles and routing

Three roles exist: the **orchestrator** (owns the meta-plan), the **coordinator** (the top-level session that runs one HAN), and the **workers** (subagents the coordinator spawns). Decide which role THIS session plays before doing anything (the HAN header / `orchestrator_contact` usually says).

**Delegation + coordinator role** (the operator started this session and handed you the HAN to run it):
- **Invoke the coordinator playbook skill (`meta-coordinator`).** It carries the full coordinator protocol; do not improvise it from here. In brief, it has you claim the HAN with a lean checkpoint entry, bracket it, stand up a workgroup of worker subagents to do the building, validate their deliverables with I/O proof (you coordinate and validate, you do not solo-implement), post LEAN progress to `## Checkpoint log`, escalate decisions via `## Clarification requests`, and keep the HAN lean (granular detail goes to the project log).
- Before starting, verify no other coordinator is already on it (`ps -ef | grep` the named team).
- You are the top-level instance the operator chats with. You do NOT edit the meta-plan; the orchestrator does.

**Delegation + orchestrator role** (this session owns the meta-plan, the HAN is being run elsewhere):
- Do NOT re-execute the work. Read the `## Checkpoint log` newest-first to learn current state.
- Answer every open `## Clarification requests` item inline, directly beneath the request, with a clear decision (the coordinator is paused on it).
- Reconcile stream-state changes into the meta-plan PL (row state + update-log entry) so the board stays accurate. On a completion checkpoint, verify the done criteria from the evidence, mark the row, and advise the operator on the next dispatch.

**Transfer handoff (either role moot):** resume the work and own it. The rest of normal pickup load-and-work applies.

**Worker:** you do not "pick up" a HAN as a worker; the coordinator spawns you as a worker subagent. That profile governs your behavior.

## Loading a selected handoff

When the selected item is a handoff: read the full HAN, classify it (transfer vs. delegation), then route per the roles above. Skip the PIC-specific triage/complexity machinery for handoffs.
