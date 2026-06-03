---
name: han-sweep
description: Sweep all handoff (HAN) documents across the vault, classify each by live/torn-down/unclaimed/closed status, cross-check the "live" ones against actually-running processes to catch stale markers, then read each non-closed HAN's watched decision lanes (Clarifications + Completions) to surface what needs a decision, what is ready to close, what is blocked, and what to dispatch next. Produces a handoff-board digest. Also carries the codified fswatch decision-signal watcher (the sole monitoring mechanism; fswatch is a hard requirement, no polling fallback). Use when the user says "han-sweep", "/han-sweep", "sweep the handoffs", "sweep the HANs", "what's the state of the handoffs", "which handoffs are active", "what's next on the HANs", "what handoffs need me", "handoff board", "orchestrator sweep", or any variation of reviewing the in-flight handoff portfolio. Read-only by default; only writes when explicitly in orchestrator mode reconciling into a meta-plan.
---

# HAN Sweep: handoff board + next-steps review

Read every handoff document, figure out which are genuinely in flight vs stale vs done, and surface what actually needs the operator (or the orchestrator) right now. This is the orchestrator's recurring "where do all my delegations stand" pass, extracted so it does not get re-derived each session.

## When to use

- Start of an orchestrator turn, to refresh the board before deciding what to dispatch.
- Any time the operator asks "what's active / what's next / what needs me" across handoffs.
- After a coordinator reports back, to reconcile and decide closure or re-dispatch.

It complements `/pickup` (which loads ONE PIC/HAN to work) and the meta-orchestrator resume (which is the full meta-plan reconcile). `/han-sweep` is the fast portfolio read: all handoffs, current state, what is owed.

## Path Resolution

Read `~/.claude/wfk-paths.json`. Use `vault_root` and `paths` to resolve directories. If missing, default to `Work Vault/` and warn once.

## Step 1: enumerate every HAN

Find all `HAN - *.md` under the vault root. For each, read the frontmatter fields: `status`, `work_state`, `coordinator_status`, `coordinator_team`, `related_pl`, `orchestrator_contact`, `result_drop`, `project`, and any `related_pic` / `related_implementation_pl`.

Filenames contain spaces, so quote paths or use a `while IFS= read -r` loop, never an unquoted `for`.

## Step 2: classify each HAN

- **CLOSED** (`status: closed`): count only, drop from the active board.
- **LIVE** (`status: active` + `coordinator_status: live`): a coordinator session holds it.
- **TORN-DOWN** (`status: active` + `coordinator_status: torn-down`): the workgroup wrapped or paused; the HAN is awaiting orchestrator closure or a gated re-dispatch.
- **UNCLAIMED** (`status: active` + `coordinator_status: unclaimed`/empty): authored, ready to dispatch.
- **TRANSFER / LEGACY** (non-closed status, no `coordinator_status` / `orchestrator_contact`): a plain transfer handoff or an old sprint HAN, not part of the delegation system.

Tag each delegation HAN (`orchestrator_contact` + `related_pl` + the watched `## Clarifications` + `## Completions` lanes present; legacy delegations may carry `## Clarification requests`) vs transfer/legacy.

## Step 3: live-process cross-check (stale-marker detection)

For every HAN marked `coordinator_status: live`, check for its workers:

```bash
ps -ef | grep -- '--team-name <coordinator_team>' | grep -v grep
```

Interpret carefully. The `--team-name` match finds active WORKER subagents, NOT the coordinator's own interactive session:
- **Workers present** means genuinely live (actively building).
- **No workers + the checkpoint log shows the coordinator wrapped / handed back / complete** means a **STALE marker**, flag for correction (flip to `torn-down`/`closed`).
- **No workers + the coordinator is mid-task** (operator's interactive session, just between worker dispatches) means a live coordinator, momentarily idle; **NOT stale**.

State the caveat in the digest: absence from the process list means "no active workers," not "dead coordinator." Frontmatter is coordinator-written and can lag; the process check + the checkpoint log are the verification. Trust the artifact + process over a status field.

## Step 4: read what each non-closed HAN needs

For each LIVE / TORN-DOWN / UNCLAIMED delegation HAN, read the protocol fields first, then the watched lanes:

- **`work_state:`** tells you who the HAN is waiting on (AWAITING-OPERATOR / AWAITING-ORCHESTRATOR / WORKING / WAITING-ON-TEAMMATES / COMPLETE) without reading any chat.
- **`## Clarifications` (WATCHED).** Each `### [OPEN]` entry (legacy: a numbered request with no inline answer) needs a ruling; the coordinator may be PAUSED on it. Read its `audience:` (operator | orchestrator) and `first-seen:` timestamp. The decision-signal watcher (below) fires on each new `### [OPEN]`; this on-demand sweep is the manual portfolio read of the same lanes.
- **`## Completions` (WATCHED).** Each `### [DONE]` entry needs done-criteria verification + closure; note its `result_drop:`.
- **`## Checkpoint log` (NOT watched).** Read only for narrative context, never as the decision signal. A decision parked here is structurally invisible; do not treat checkpoint churn as a clarification or completion.
- **Perishable / operator-action item** (an elicitation to schedule, a token to rotate, a shared-resource window to broker) goes surfaced to the operator.

Spot-check load-bearing claims against live state where cheap (a "done" claim, a status the digest will assert). Do not transcribe a coordinator's self-report as fact for incident-critical or irreversible items.

## Step 5: produce the digest

Lead with what needs action, then the board. Suggested shape:

```
## Handoff board (as of <time>)

### Needs you / the orchestrator now
- <HAN>: OPEN clarification: <one line> (coordinator paused)
- <HAN>: COMPLETE, ready to close: <one line>
- <HAN>: operator action: <perishable item>

### Live (workers running)
- <team> | <HAN> | <phase / last checkpoint>

### Live coordinator, idle between dispatches
- <team> | <HAN>

### Torn-down (awaiting closure or re-dispatch)
- <HAN> | gate: <what it waits on>

### Unclaimed (dispatchable)
- <HAN> | <one-line scope>

### Stale markers (flag / correct)
- <HAN> | marked live, no workers + complete, should be <status>

### Transfer / legacy (non-delegation)
- <HAN>

### Recommended next
<one or two concrete moves, with the reason>
```

Keep it scannable. Translate technical state into the consequence; do not dump file paths or task IDs into the digest.

## Step 6: reconcile (orchestrator mode ONLY)

If the operator is acting as the meta-plan orchestrator (a `related_pl` points at a coordination meta-plan and the operator is in that seat), optionally mirror state changes into that meta-plan:
- Flip confirmed-stale `live` markers to `torn-down`/`closed` on the HAN.
- Close HANs whose done-criteria are verified met.
- Mirror closures + the live board into the meta-plan's active-HAN index + append one Update-log entry.

Honor the live-write discipline: a HAN being actively written by its coordinator should not be raced. Record the decision in the meta-plan and point the coordinator at it, or wait. Read the HAN with the Read tool immediately before any Edit (the vault syncs across machines and the on-disk copy can change under you).

**Outside orchestrator mode this skill is READ-ONLY.** It reports the board, it does not flip statuses.

## The decision-signal watcher (codified, parameterized)

The watcher is the mechanism that lets the orchestrator stay idle between events and wake exactly when a HAN needs it. It is a generic, parameterized pattern, NOT a one-off command relaunched from a recorded line.

**What it watches:** the set of `HAN - *.md` files under `vault_root` whose lifecycle `status` is not `closed` (the ACTIVE delegation set). Parameterize the watch over that set; it is recomputed at each full sweep, never hand-edited.

**What fires it:** a NEW decision-signal marker, and only that. A decision signal is a new `### [OPEN]` in `## Clarifications`, a new `### [DONE]` in `## Completions`, or a ruling flip (`[OPEN]` to `[ANSWERED]`) in a HAN you are coordinating against. The watcher does NOT fire on `## Checkpoint log` edits, on frontmatter-only churn, or on a re-sync that rewrites the file without adding a marker.

**`fswatch` is a HARD REQUIREMENT (DD-24 / DD-25).** The watcher is event-driven on `fswatch`; there is NO polling fallback and NO graceful degradation. Resolve the binary via PATH, never a hardcoded path: `WATCH_BIN="$(command -v fswatch || echo "$(brew --prefix 2>/dev/null)/bin/fswatch")"`. This works on both Apple-silicon (`/opt/homebrew`) and Intel (`/usr/local`) Macs. Packaging (INSTALL.md) lists `fswatch` as a required dependency.

**Fail-loud, never degrade.** If `fswatch` cannot be resolved or is not executable (`[ -x "$WATCH_BIN" ]` fails), or if the watcher process dies while monitoring, do NOT silently continue and do NOT fall back to a `find`/poll loop. Stop and surface a HARD, visible error to the operator that names the problem and the fix, for example: `MONITORING DOWN: fswatch is not installed or not on PATH. The HAN watcher cannot run. Install it (brew install fswatch) and restart the watcher.` Monitoring without `fswatch` is not a degraded mode; it is no monitoring, and a silent no-op watcher is the exact failure to prevent. The orchestrator/operator must know immediately.

**The mechanism (fswatch event + marker-diff detector):**
1. **On startup, run one full marker snapshot.** Sweep every active HAN (Steps 1-5), record each HAN's decision-signal marker set to `~/.claude/state/han-sweep-markers/<han-hash>`, and surface anything already `### [OPEN]` / `### [DONE]` so nothing already pending is masked. Then begin watching.
2. **Watch the active HAN set with `$WATCH_BIN` (`fswatch`)** over the directories holding those files. A raw file-change event is a CANDIDATE, not a fire.
3. On a candidate, run the marker-diff detector against the stored snapshot: `grep -nE '^### \[(OPEN|DONE|ANSWERED)\]' "<han>"` and diff the marker set against `~/.claude/state/han-sweep-markers/<han-hash>`.
4. **Fire only if a marker was ADDED or an `[OPEN]` flipped state.** If the diff is empty (the file changed but no decision-signal marker did, i.e. checkpoint or frontmatter churn), do NOT fire; refresh the snapshot and keep watching.
5. On a fire, hand the changed HAN to the full Step 4 read + the Step 6 auto-rule-vs-escalate gate (**auto-answer routine technical/coordination clarifications inline; SURFACE, never auto-decide, irreversible / outward-facing / scope-expansion clarifications, completions to verify-and-close, and stale markers**), fire the human push on the qualifying events (a genuine human-judgment decision surfaced, or work complete; see the orchestrator skill's "Human push"), then update the snapshot.

**Why a marker-diff and not a content hash:** a whole-file or whole-region content hash re-fires on every progress edit and every re-sync (over-fire noise), and a header-set hash misses an append made under an existing header (under-fire). Keying on the decision-signal marker set fires on exactly the events that need the orchestrator and is silent on churn.

**Coverage invariant (HARD RULE, never violate to cut noise):** never drop an ACTIVE delegation HAN off the watch set to quiet it. Over-fire is fixed by sharpening the detector (marker-diff, settle-debounce) and reducing the fire RATE, never by reducing coverage. A HAN removed from the watch to stop noise goes BLIND to the next real clarification; that is the failure this rule exists to prevent. If the watcher is noisy, fix the detector; if it is silent, widen the detector, never the opposite. This invariant plus the atomic HAN-write (DD-23) plus claim-first is the complete primary path: a real decision always lands as a durable `### [OPEN]` marker in a never-dropped HAN, and the watcher always fires on it. There is no separate backstop, and none is needed, because the failure that would have motivated one (a dropped or silently-missed HAN) is prevented at the source by never-dropping + correct firing + fail-loud.

**The watcher never triggers heavy infrastructure work** (container exec, remote shell, DB writes): the fswatch event, the `grep` marker-diff, and the local snapshot write are local-only. The away-channel push on a fire is a single `PushNotification`, not infrastructure work.

## Notes

- This is a portfolio read, not a deep dive. For one handoff's full context, `/pickup` it.
- The single most valuable thing this catches is the **stale `live` marker**, a coordinator that finished or died without flipping its status. The process cross-check is what surfaces it.

## Local Customizations

If `LOCAL.md` exists in this skill directory, load and follow it after these instructions.
