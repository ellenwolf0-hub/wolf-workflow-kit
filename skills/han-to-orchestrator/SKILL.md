---
name: han-to-orchestrator
description: >-
  Bottom-up registration: bring a freestanding solo session's in-flight work into an
  existing coordination meta-plan's fold. It distills the current conversation into a
  delegation handoff (HAN) in the structured protocol format, binds it to a chosen
  meta-plan with the delegation signals (related_pl + orchestrator_contact) so the
  orchestrator tracks it, then claims the HAN and continues under the coordinator
  playbook (the registering session BECOMES the coordinator, since it is already
  mid-work). It is the inverse of the top-down, orchestrator-authored HAN. Trigger on
  "HAN-to-orchestrator", "/HAN-to-orchestrator", "register this work", "register with
  the orchestrator", "bring this under the meta-plan", "this belongs to the
  orchestrator", "file this as a handoff", "bottom-up handoff", "adopt my in-flight
  work into the meta-plan", or any variation of "I started this freestanding and it
  turns out to belong to a coordinated goal." For first-run meta-plan setup use
  meta-plan-init; for running an orchestrator-issued HAN use the coordinator playbook
  (meta-coordinator).
---

# HAN-to-orchestrator: bottom-up registration

This skill is the **bottom-up** path into the Coordinated Pipeline Execution system. The normal (top-down) flow is: the orchestrator decomposes a goal, authors a delegation handoff (HAN), and a fresh session picks it up as coordinator. But work often starts the other way: a freestanding solo session is already mid-work and only later realizes the work belongs to a coordinated goal. Without a bottom-up path that work stays invisible to the orchestrator, or has to be re-authored by hand.

`/HAN-to-orchestrator` closes that gap. The session you are in **right now** has been doing real work. This skill (1) distills that work into a HAN in the structured protocol format, (2) binds it to an existing meta-plan with the delegation signals so the orchestrator discovers and tracks it, and (3) per the resolved fork Q-8, has **this same session become the coordinator** for the HAN it just registered (it is already mid-work, so it claims, posts the first checkpoint, and continues under the coordinator playbook).

It is the inverse of `meta-plan-init` Step 4 (which the orchestrator/front-door uses to author a HAN top-down). The HAN contract, the structured protocol fields, and the coordinator playbook are all reused unchanged.

## Preconditions (what this skill assumes)

- You are in a **live session that has been doing the work** to be registered. The conversation context and the work artifacts (edited files, the project log, git activity) are your source material for the distillation. If the session has done nothing yet, there is nothing to register; use `meta-plan-init` or the top-down flow instead.
- A coordination **meta-plan already exists** for some project (a `PL - *Meta-Plan*.md` with frontmatter `agent: meta-orchestrator`). If none exists, this skill cannot bind the work; it routes you to `/meta-plan-init` (Step 2).

## Step 0: Resolve paths

1. Read `~/.claude/wfk-paths.json` for `vault_root` and `paths`. If it is missing, ask the operator for the notes-vault root and the projects directory, and proceed with those.
2. Note today's date (for the HAN's dated pickups subfolder and timestamps).

## Step 1: Distill the in-flight work into the HAN fields

Gather what this session has actually done, then PROPOSE the HAN's load-bearing fields. Do not fabricate: every field is grounded in the conversation or a verifiable artifact, and the mission + done-criteria wording is confirmed with the operator before the write (capture, do not invent).

Sources, in priority order:
1. **This conversation.** What was the session asked to do, what has it built or decided, what is still open. This is the spine of the distillation.
2. **Work artifacts touched this session:** edited/created files (check `git status` / recent `git log` in the work repo), the project log (PJL or equivalent), any output files. These ground the "verified live state" and the bracket.
3. **The project context** (`CLAUDE.md` / `lessons.md`, related spec/plan) for the standing constraints that apply.

From this evidence, draft each structured-HAN field (read `templates/first-han.md` from the `meta-plan-init` skill directory for the exact shape; this skill emits the SAME structure so a watcher / coordinator parse it identically):
- **Mission:** one or two sentences on what shipping this in-flight slice looks like, plus any operator-locked decisions already made this session (so they are not relitigated).
- **Verified live state:** the load-bearing facts a reader needs so they do not re-derive them: file paths, IDs, current statuses, what is already built vs pending. Grounded on today's date and spot-checkable.
- **Bracket / phased plan:** the bounded surface and the remaining ordered phases (the work already done is "verified live state"; the bracket is what is LEFT).
- **Hard constraints + anti-scope:** standing operational constraints (shared-infrastructure rate/serial limits, teardown of spawned workers, push-is-not-deploy, environment declaration when work spans environments) plus this slice's specific bounds and what is explicitly OUT.
- **Done criteria:** what must be produced to call this slice complete.

Confirm the **mission** and **done criteria** wording with the operator via AskUserQuestion before writing (these two anchor every later "is this still in scope / is this done?" decision). Draft the rest; reserve the operator's attention for those two.

## Step 2: Pick the meta-plan to bind to

The HAN must point at an orchestrator's meta-plan via `related_pl`; that is the signal the orchestrator sweeps on to discover and track it.

1. **Detect candidate meta-plans.** Glob the projects path for `PL - *Meta-Plan*.md` with frontmatter `agent: meta-orchestrator` and lifecycle `status: Active` (skip closed ones).
2. **Resolve to one:**
   - **Exactly one active meta-plan:** bind to it. State which one, in plain language, before writing.
   - **More than one:** present them as text (project + goal one-liner each), then ask the operator which to bind to via AskUserQuestion. Do not guess.
   - **None:** there is no orchestrator to register with. Tell the operator plainly and route them to `/meta-plan-init` to stand one up first. Stop here; do not author an orphan HAN.

Record the chosen PL's wikilink for `related_pl`.

## Step 3: Write the HAN (structured protocol, bound to the meta-plan)

Read `templates/first-han.md` from the `meta-plan-init` skill directory and instantiate it for the in-flight work. The HAN is a **structured communication protocol**, not prose; emit the watched lanes and protocol fields exactly so peers parse them deterministically.

Frontmatter (the delegation signals + protocol fields):
- `category: Handoff`, `type: Handoff`, `status: active` (lifecycle).
- `work_state: WORKING` (the session is mid-work and about to keep going).
- `coordinator_status: unclaimed`, `coordinator_team: ""` (Step 4 flips these atomically when this session claims).
- `result_drop: ""` (set to a concrete durable-conclusion path when the work warrants one).
- `related_pl:` the chosen meta-plan wikilink from Step 2 (the discovery signal).
- `orchestrator_contact:` a short note recording this as a bottom-up registration, e.g. `registered bottom-up via /HAN-to-orchestrator on <date>; this doc is the channel back to the meta-plan`.
- `project:` the project name.

Body: fill **Mission** (+ locked decisions), **Verified live state**, **Bracket / phased plan**, **Hard constraints + anti-scope**, and **Done criteria** from Step 1. Leave the watched lanes `## Clarifications` and `## Completions` empty (`(none yet)`), and the not-watched `## Checkpoint log` empty (the claim in Step 4 writes the first entry).

Write to the project's pickups directory under a dated subfolder, per the host vault's routing (`<project>/pickups/<date>/HAN - <Name>.md`). Report the path.

**Idempotency.** If a HAN for this same in-flight work already exists and points at this meta-plan, do NOT author a duplicate. Refresh that HAN's verified-state / bracket instead and continue to Step 4 against it.

**Who writes the meta-plan?** This skill does NOT edit the meta-plan PL body. The orchestrator owns the PL (SD Principle 8, one session one role); it discovers this HAN by globbing handoffs whose `related_pl` points at its PL and mirrors it into its Status Board + Active-delegation-handoffs index on its next sweep (its R7 outside-state-change duty). Setting `related_pl` is the complete registration signal. If the operator wants the orchestrator to see it immediately rather than on its next run, tell them to run the orchestrator (the daily driver or a `/pickup` of the meta-plan) so it sweeps now.

## Step 4: Become the coordinator (Q-8: the registering session continues)

Per the resolved fork Q-8, the registering session is already mid-work, so it does not file-and-stop: it **becomes the coordinator** for the HAN it just registered and continues under the coordinator playbook. The hard precondition is claim-first (DD-23a): a HAN doing live work while `coordinator_status: unclaimed` is itself an orchestrator ALERT, so claim BEFORE any further work.

1. **Claim-first collision guard (DD-17/DD-23).** Read `coordinator_status`. For a HAN you just authored it is `unclaimed`, so this is a no-op; but if you arrived here via the idempotency refresh path and it is already `live`, `ps -ef | grep` the `coordinator_team`. If a live coordinator process exists, another session is already coordinating this work; do NOT double-claim (SD Principle 8). Warn the operator and stop. Proceed only when `unclaimed` or no live coordinator process is found.
2. **Claim atomically.** In ONE edit: set `coordinator_status: live`, set `coordinator_team:` to this workgroup's name, set `work_state: WORKING`, and append the first `## Checkpoint log` entry (timestamp, "registered bottom-up + claimed as coordinator", the phase being entered; one or two lines). This single write clears the unclaimed-but-live ALERT condition.
3. **Hand off to the coordinator playbook.** From here this session runs the **meta-coordinator** playbook: honor the HAN's embedded bracket, decompose the remaining phases, stand up a workgroup of worker subagents (via `TeamCreate`, never bare background agents) for the building, validate their output with independent I/O proof, post LEAN progress to the watched lanes, and escalate genuine decisions through the atomic blocked-state write. The work already done this session is "verified live state" in the HAN; the coordinator role now drives the remaining bracket to done.

If the `meta-coordinator` skill is installed, follow its playbook directly. The transition is seamless: the same operator-facing session that distilled the work is now its coordinator, with the work durably registered so the orchestrator tracks it.

## What this skill does NOT do

- **Author an orphan HAN.** No meta-plan to bind to means no registration; route to `/meta-plan-init` (Step 2).
- **Edit the meta-plan PL.** The orchestrator owns it and reconciles this HAN in on its sweep via the `related_pl` signal (Step 3).
- **Fabricate the work.** Every HAN field is grounded in the conversation or a verifiable artifact; mission + done-criteria are operator-confirmed.
- **File-and-stop.** Per Q-8 the session continues as coordinator; it does not register and abandon the work mid-flight.
- **Double-claim a HAN already coordinated by a live session** (claim-first collision guard, Step 4).

## Notes

- **Inverse of top-down.** `meta-plan-init` Step 4 and the orchestrator author HANs top-down (decide-then-dispatch); this skill registers them bottom-up (already-doing-then-bind). Same HAN contract, same protocol fields, same coordinator playbook on the far side.
- **Self-contained shape source.** The structured-HAN shape lives in `meta-plan-init/templates/first-han.md`; this skill reuses it so the registered HAN is byte-compatible with the watcher, the status marker, and the coordinator's claim flow.

## Local Customizations

If `LOCAL.md` exists in this skill directory, load and follow it after these instructions. Local instructions override upstream where they conflict.
