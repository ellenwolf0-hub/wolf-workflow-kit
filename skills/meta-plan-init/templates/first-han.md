---
date created: YYYY-MM-DD
tags: [handoff, <project-tag>, in-flight]
category: Handoff
type: Handoff
status: active
project: "<project name>"
related_pl: "[[PL - <Project> Meta-Plan Execution]]"
orchestrator_contact: "<orchestrator session note; this doc is the channel back to the meta-plan>"
---

# HAN — <Name of the first bounded slice>

## How this handoff works (read FIRST)

Dispatch this by starting a fresh session and picking it up; pickup routes it to the coordinator playbook. This is a delegation from [[PL - <Project> Meta-Plan Execution]], not a plain transfer. The coordinator stands up a workgroup of worker subagents to build, validates their output, and reports here. Two-way channel:
- Post LEAN progress to `## Checkpoint log` (newest on top) at phase boundaries and notable findings. Granular detail goes to the project log, not here.
- Escalate decisions beyond the locked scope to `## Clarification requests` and pause that thread. The orchestrator answers inline.

## Mission

<What shipping this slice looks like, in one or two sentences.>

### Locked decisions (do NOT relitigate)

1. <operator-locked choice>

## Verified live state (grounded on <date>)

<The load-bearing facts the coordinator needs so it does not re-derive them: file paths, IDs, current statuses. Spot-checkable.>

## Bracket / phased plan

<The bounded surface and the ordered phases for this slice.>

## Hard constraints + anti-scope

Standing operational constraints (any shared-infrastructure rate/serial limits, teardown of every spawned worker/team, separation of push from deploy, path-routing rules, environment declaration when work spans environments) plus this slice's specific bounds. What is explicitly OUT:
- <out-of-scope item>

## Done criteria

<What the coordinator must produce to call this complete.>

## Checkpoint log

Append newest on top. Format: `### YYYY-MM-DD HH:MM TZ — Phase N — <status>` then 1-4 bullets.

(empty — first entry is the coordinator's)

## Clarification requests

Post numbered questions here and pause the affected thread. The orchestrator answers inline.

(none yet)
