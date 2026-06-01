# Create Note — Local Customizations: Handoff (HAN) document type

This overlay adds the **Handoff (`HAN`)** document type to create-note. It is self-contained: dropping this file into the skill directory teaches create-note how to author a handoff. Deleting it removes the type cleanly with no residue.

A handoff (`HAN - *.md`, `category: Handoff`) transfers in-flight work to another session. There are two kinds. Decide which before drafting; ask via AskUserQuestion if not obvious.

- **Delegation handoff (default for coordinated/meta-plan work).** A meta-plan **orchestrator** delegates a bounded slice to a separate **coordinator** session that the operator starts. The orchestrator stays in the loop via the HAN. This is the standardized form below; it MUST carry the detection signals (`orchestrator_contact`, `related_pl`, `## Checkpoint log`, `## Clarification requests`) so the pickup overlay routes it to the coordinator playbook and the orchestrator can sweep it.
- **Transfer handoff (light).** A session hands its own work to its future self, with no external orchestrator. Drop `orchestrator_contact` and the Checkpoint/Clarification sections; keep Mission, State, Next steps, Constraints. Use this only when no meta-plan is coordinating the work.

The system: the orchestrator (owns the meta-plan) delegates to a coordinator (the interactive session the operator chats with) which runs worker subagents. Keep the HAN LEAN: it is the orchestrator's decision-signal, not a work log. Granular detail goes to the project log.

## Type entry

Add to create-note's type handling:

| Type | Triggers | Category | Writing Profile | Routing |
|------|----------|----------|-----------------|---------|
| `HAN` | "create HAN", "create handoff", "delegation handoff", "hand this off to a coordinator" | `Handoff` | (General only) | `{project}/pickups/{date}/HAN - {Name}.md` |

Cross-cutting handoffs with no owning project may instead route to `{project}/reports/{date}/HAN - {Name}.md` or a top-level pickups directory, per the host vault's routing conventions. `{date}` = today (YYYY-MM-DD).

## Frontmatter

```yaml
---
date created: YYYY-MM-DD
tags: [handoff, <project-tag>]      # add `in-flight` while active
category: Handoff
type: Handoff
status: active                      # active | closed (legacy non-closed values all read as live)
project: "<project name>"
related_pl: "[[<meta-plan PL>]]"                                  # delegation only
orchestrator_contact: "<orchestrator session note; this doc is the channel back>"  # delegation only
related_pic: "[[<source PIC>]]"                                   # optional
---
```

## Pre-creation (delegation handoffs)

The orchestrator (or operator) authors this. Before drafting:

1. **Confirm the bounded slice.** A delegation handoff is for ONE bounded, monitorable piece of a meta-plan. If it is not bounded, it is not ready to delegate; narrow it or file a pickup instead.
2. **Ground the verified state.** Pull the load-bearing facts the coordinator will need (IDs, schema shapes, file paths, current statuses) so the coordinator does not re-derive them. Cite them in the Verified state section. This is the orchestrator's grounding work.
3. **Lock the decisions.** Capture the operator-locked choices (do-not-relitigate) so the coordinator does not re-open settled questions.

## Body template (delegation)

```markdown
# HAN — <Name>

## How this handoff works (read FIRST)
Dispatch this by starting a fresh session and picking up this HAN; pickup routes it to the coordinator playbook. It is a delegation from <meta-plan>, not a plain transfer. The coordinator stands up a workgroup of worker subagents to build, validates their output, and reports here. Two-way channel:
- Post LEAN progress to `## Checkpoint log` (newest on top) at phase boundaries and notable findings. Detail goes to the project log, not here.
- Escalate decisions beyond the locked scope to `## Clarification requests` and pause that thread. The orchestrator answers inline.

## Mission
What shipping looks like. The locked operator decisions (do-not-relitigate).

## Verified live state (grounded by orchestrator on <date>)
The facts you grounded so the coordinator does not re-derive them. Spot-checkable.

## Bracket / phased plan
The bounded surface and the ordered phases.

## Hard constraints + anti-scope
Standing operational constraints (any shared-infrastructure rate/serial limits, teardown of every spawned worker/team, separation of push from deploy, path-routing rules, environment declaration when work spans environments) plus this slice's specific bounds. What is explicitly OUT.

## Done criteria
What the coordinator must produce to call this complete.

## Checkpoint log
(empty — first entry is the coordinator's; newest on top)
Format: `### YYYY-MM-DD HH:MM TZ — Phase N — <status>` then 1-4 bullets.

## Clarification requests
(empty — coordinator posts numbered questions; orchestrator answers inline)
```

For a **transfer handoff**, keep `# HAN — <Name>`, Mission, State, Next steps, and Constraints; drop the orchestrator-channel header, Checkpoint log, and Clarification requests.

## Logging discipline (bake into the doc)

State it in the "How this handoff works" header: the HAN stays lean. Checkpoint entries are 1-4 lines of decision-relevant signal (phase done/blocked, validation verdict, deviation, decision needed, outcome). Granular build detail goes to the project log. A bloated HAN defeats its purpose.

## Post-creation (delegation)

1. **Update the meta-plan** named in `related_pl`: add or update the status-board row for this item to DISPATCHED-TO-AGENT with a wikilink to this HAN, and append an update-log entry. (The orchestrator owns the meta-plan; this is the one meta-plan edit that authoring a delegation handoff triggers.)
2. **Tell the operator how to dispatch:** start a fresh session and pick up this HAN (it routes to the coordinator playbook). Remind them custom agent profiles load at session start, so the worker subagents the coordinator spawns resolve in that fresh session.
3. Report the file path.

## Notes

- **Update mode.** "update the handoff" = edit in place. The coordinator appends to Checkpoint log / Clarification sections during execution; the orchestrator answers clarifications and flips `status: closed` on reconciliation.
- **Closure.** Default: the coordinator posts a completion checkpoint; the orchestrator verifies done criteria and sets `status: closed`. The handoff is not closed by the worker subagents.
