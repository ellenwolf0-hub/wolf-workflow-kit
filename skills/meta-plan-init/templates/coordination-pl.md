---
date created: YYYY-MM-DD
tags: [plan, meta-plan, coordination, pipeline-orchestration]
category: Plan
type: PL
status: Active
project: "<your project>"
agent: meta-orchestrator
goal: "<one paragraph stating the done-state for this coordination scope; this is the anchor for every 'is this still relevant?' decision>"
last_synced: YYYY-MM-DD
last_orchestrator_run: "YYYY-MM-DD (run #0)"
---

# PL - <Project> Meta-Plan Execution

> **This is a coordination plan, not a build plan.** Work is dispatched as individual artifacts / handoffs in other sessions; this plan tracks state across them and the [[meta-orchestrator]] agent uses it as the source of truth for "what to spin up next."
>
> **How to use:** start a fresh session and pick up this PL. The session's main agent (the orchestrator) reads this PL plus current state, updates the Status Board, and produces a "what to do next" digest. The operator decides; the orchestrator updates the plan.

## Orchestrator resume (read first after compaction / fresh session)

This block is the durable orchestrator handoff. Conversation context is disposable; this PL plus the active handoffs' checkpoint logs are the state. To resume: read this section + the Update log (newest entries), then sweep each active handoff's `## Checkpoint log` (newest-first) and `## Clarification requests`, answer open clarifications inline, reconcile completions into the Status Board, and close handoffs whose done criteria are met.

**The delegation system has three roles.** **Orchestrator** = the [[meta-orchestrator]] agent (owns this PL; never executes the work itself). **Coordinator** = the `meta-coordinator` skill (the interactive session the operator starts and hands a handoff; it runs the work through a workgroup, validates the output, and reports lean progress back into the handoff). **Workers** = `meta-plan-worker` subagents the coordinator spawns (they build and report to the coordinator). Handoffs (`HAN - *.md`) are the contract that flows between the three; author them via the create-note HAN type. Any teammate profile must keep `SendMessage` in its tools or coordination breaks.

### Active delegation handoffs (live index)

The in-flight delegations spun off this meta-plan. The orchestrator keeps this table current: when it dispatches a slice it adds a row, when a coordinator checkpoints it updates the State, and when done criteria are met it closes the handoff and clears the row. "Orchestrator owes" is what THIS session must do for that handoff on its next sweep (answer a clarification, verify a completion, advise the operator on the next dispatch).

| Handoff | State | Orchestrator owes |
|---|---|---|
| <wikilink to active HAN, or 'none active'> | <active / picked-up / blocked / complete-awaiting-reconcile / closed> | <the orchestrator's next action for this handoff> |

## Pipeline map

Replace the placeholder below with your project's stages and parallel streams. Stage labels are project-specific; the arrow notation is what the orchestrator parses for the critical-path table.

```
Stage 1: <name the first sequenced stage>
   |
Stage 2: <name the second sequenced stage>
   |
Stage 3: <name the third sequenced stage>

Parallel streams (independent of the spine above):
   <name parallel streams, one per line>
```

## Critical path (the spine)

The sequenced spine the project advances along. Each row is one artifact/slice that must ship to unblock the next.

| # | Item | Status | Blocked by | Unblocks |
|---|------|--------|------------|----------|
| 1 | <first item> | <state> | <blocker or 'None'> | <what it unblocks> |

## Status board

The orchestrator updates this section on every invocation. `state` is the source-of-truth status; `last_check` is when the orchestrator last verified.

**Delegation convention.** When a Stream item is handed to a coordinator session, set its `state` to `DISPATCHED-TO-AGENT` and put a wikilink to the handoff (`HAN - *.md`) in its row. While in that state the orchestrator does not re-derive the item's progress: it reads the handoff's `## Checkpoint log` and answers `## Clarification requests` inline, and mirrors the outcome back into the row when the handoff completes. Add the same handoff to the Active-delegation-handoffs index above.

### Stream A — Critical path (the spine)

| Item | State | Last check | Next action | Notes |
|---|---|---|---|---|

### Stream B — <name a parallel stream>

| Item | State | Last check | Next action | Notes |
|---|---|---|---|---|

(add more `### Stream X` sub-sections per parallel stream)

## Decision queue

Decisions needed but not yet made. The orchestrator surfaces these one at a time when the operator engages.

| # | Decision | Required for | Status |
|---|---|---|---|
| D1 | <one-line decision> | <what it unblocks> | pending |

## Cross-stream entanglements

Warnings the orchestrator consults before recommending any dispatch.

| # | Entanglement | Rule |
|---|---|---|
| E1 | <which streams or artifacts touch each other> | <the discipline that prevents a clash> |

## Stale items to close (operator action)

Items where work is finished or superseded but the artifact's status field has not been flipped yet.

| Item | Why stale | Action | Status |
|---|---|---|---|

## Orchestrator playbook

### On every invocation

1. Read this PL fully (status board, decision queue, entanglements, recent updates).
2. Sweep active delegation handoffs whose `related_pl` points at this PL and whose `status` is not `closed`: read each Checkpoint log newest-first, answer open Clarification requests inline, reconcile progress into the Status Board.
3. Sample the most recent activity for projects in motion (project logs, daily notes, or your equivalent).
4. Update the Status Board's `state` and `last_check` for any item whose status visibly changed.
5. Apply the orchestrator rules below to produce a "what to do next" digest.

### Orchestrator rules

The orchestrator does not invent recommendations; it APPLIES these rules.

**R1 — Critical-path advancement.** If a Stream A item ships, check whether the next Stream A item is unblocked. If yes, recommend dispatching it.
**R2 — Parallel-track dispatch.** If the operator has session capacity, recommend dispatching one ready parallel-stream item with no pending decision blocking it.
**R3 — Decision-queue triage.** If a decision blocks more than one stream, surface it FIRST. If it blocks only one stream and that stream has other ready items, work the others.
**R4 — Entanglement check.** Before recommending ANY dispatch, scan the entanglements table. If the dispatch would violate a rule, surface the conflict instead.
**R5 — Session-count discipline.** Default: ONE session at a time on the critical path; up to TWO parallel sessions only if the second is in a different stream and shares no source files. Do not recommend more than two parallel work-doing sessions.
**R6 — Stale-item closure.** If a stale item is still open when the operator engages, recommend closing it as the first action.
**R7 — Outside state changes.** If an artifact's status changed since `last_synced`, mirror it to the Status Board immediately and note it in the Update log.
**R8 — Cost-gated items stay deferred.** Any item gated on external authorization stays in the queue until both the prerequisite ships AND the operator authorizes.

### Output format

Surface to the operator: critical-path progress (one sentence), count/identity of pending decisions, recommended next dispatch (stream + item + rationale), one parallel item available if capacity allows, any entanglement warnings, any stale closures still open, net status changes since last sync. Close with a single decision prompt ONLY when a decision is genuinely required; otherwise surface the recommendation as a "Next:" sentence.

## Update log

Append-only. Orchestrator appends one entry per invocation, newest on top.

```
### YYYY-MM-DD (run #N)
- <what changed in state since last sync>
- <what got dispatched, closed, or surfaced>
- <any new entanglements or decisions added>
- last_orchestrator_run advanced to YYYY-MM-DD (run #N)
```

## References

- [[meta-orchestrator]] — the agent that picks up this PL
- (add relevant specs, plans, handoffs as they emerge)
