---
name: ingest-day
description: >-
  Pull the day's Granola recordings and distill them into a thematic "active
  context" block grouped by project, so SOD/EOD reports and the current session
  start grounded in what was actually said rather than rebuilt from memory. Use
  when the user says "/ingest-day", "ingest the day", "catch me up on today's
  meetings", "what was said today", "pull today's context", "ground me", or at
  the start of a work session to load meeting context. Also called internally by
  /end-day to replace its ad-hoc Granola scan. Reusable extractor: runs standalone
  (morning/any time) and as a sub-step of end-of-day.
---

# Ingest Day — Granola Context Extractor

Turn the day's Granola recordings into one **thematic context block grouped by project/initiative**. This is the shared extractor both `/end-day` (at EOD) and a morning run use, so active context comes from the meetings themselves, not from memory.

**Arguments:** $ARGUMENTS — Optional window override (e.g. `/ingest-day since yesterday`, `/ingest-day today`). Default window is "since last run" (see Step 2).

**Scope decisions (settled 2026-06-03, see [[PIC - SOD-EOD Granola Context Ingest Skill]]):**
- Pull ALL recordings in the window (no folder/tag filter).
- Output is thematic, grouped by project (not per-meeting digests).
- Context only: flag meetings missing an MN, but do NOT create MNs (that stays with `/meet`).

## Step 1 — Self-Heal Granola First (mandatory)

The Granola MCP goes stale (401) because Granola writes tokens to an encrypted store the MCP doesn't read. Do NOT assume a live connection.

1. Before any Granola call, run the decrypt-sync refresh:
   ```bash
   python3 ~/.claude/scripts/granola-refresh.py
   ```
   It's idempotent and fails soft. (`~/bin/granola-refresh` is an obsolete fallback that reads the stale plaintext file — do not use it.)
2. If any Granola MCP call returns a 401 mid-run, re-run the refresh once and retry the call. If it still 401s, stop and tell the user Granola auth needs attention; produce the best context block from whatever was already retrieved.

See [[RE - MCP Reliability Diagnosis]] for the root cause.

## Step 2 — Determine the Window ("since last run")

State marker: `~/.claude/state/ingest-day-last-run.txt` (a single ISO timestamp).

- Create `~/.claude/state/` if it doesn't exist.
- If `$ARGUMENTS` specifies a window ("today", "since yesterday", a date), use that.
- Else read the marker. Window = from that timestamp to now. If the marker is missing (first run), default to since midnight today.
- After a successful run, write the current timestamp to the marker.

## Step 3 — Pull the Day's Recordings

1. List recordings in the window: `list_granola_documents` (and/or `search_granola_events` for the date range). Take ALL of them in the window — no foldering filter.
2. For each recording, pull the substance: prefer the panel/summary (`get_granola_document`); fall back to the transcript (`get_granola_transcript`) when the summary is thin.
3. Skip recordings with no usable content silently (note the count).

## Step 4 — Synthesize the Context Block (thematic, by project)

Group the day's meeting substance by **project/initiative**, matching how SOD/EOD organize ("by project, not by session"). For each project that came up:

```markdown
**[Project / initiative]**
- What moved / what was decided (with the specific detail: names, numbers, dates)
- Open threads or questions surfaced
- Commitments made (by Ellen or others) — owner + what

**Cross-cutting** (anything not project-specific: org signals, people notes, recurring themes)
```

Then a short MN-coverage flag:

```markdown
**Meetings without an MN yet:** [Title (time)], [Title (time)] — run /meet to capture any that need a durable note.
```

Quality rules (same as `/meet`):
- Never invent. Only what was actually said. Preserve specifics (names, numbers, dates, dollar amounts).
- Signal only — skip greetings, small talk, scheduling chatter.
- No em dashes. Tight spacing. Group by project, not by meeting.
- Use Ellen's project taxonomy from `agents.md` (Metro / GROW / White Glove / Comp / WFK / Org Health, etc.) so grouping matches the rest of the vault.

## Step 5 — Deliver the Context Block

**Standalone run (morning / on demand):**
- Print the context block in-session so the live session is grounded.
- Offer to drop it into today's daily note (`Daily/DN - {today}.md`) under a `## Day Context` heading. Don't create a new doc type for it.
- Update the last-run marker (Step 2).

**Called by /end-day:**
- Return the context block for end-day to fold into its EOD synthesis and the next SOD. Do not write a separate file; end-day owns the report output.
- This REPLACES end-day's old ad-hoc Step 2a Granola scan — end-day should call `/ingest-day` instead of running its own scan, so there's a single extractor (no double scan). See the integration note below.

## Integration note for /end-day (org "extend, don't duplicate" rule)

`/end-day` Step 2a currently lists today's meetings and extracts action items itself. When wiring this up, replace that scan with a call to `/ingest-day` and consume the returned block. The MN-generation behavior (end-day calling `/meet` for un-noted meetings) can stay in end-day, fed by this skill's "meetings without an MN" flag. Do not leave both scans running.

## Constraints

- Self-heal Granola before reading; re-sync once on a mid-run 401. Never assume a stable connection.
- Context only — never create MN notes here. Flag the gaps; `/meet` owns capture.
- If Granola is fully unavailable after a re-sync, say so plainly and produce whatever context is available (or none) rather than guessing.
- Keep the block tight enough to load into a report's context (the EOD is capped ~350 words, the SOD ~300) — favor the highest-signal items per project.
