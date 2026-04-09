---
name: end-day
description: >-
  Aggregate the day's work into an EOD report and generate tomorrow's SOD (agent
  context document). Use when the user says "end day", "end of day report", "EOD",
  "wrap up the day", "day summary", or "end-day". This is different from /closeout
  (which wraps a single session and creates PICs) — end-day aggregates ALL sessions
  into the day's official record and prepares tomorrow's agent context. Run after the
  last /closeout of the day.
---

# End of Day — Daily Aggregation Report

The EOD is the **official record of what happened today**. It aggregates all closeout entries from the daily note, sweeps external sources for anything uncaptured, and prepares tomorrow's SOD — the context document that `/orient` loads at session start.

On Fridays, this skill also produces an **EOW** (End of Week) roll-up. On the last workday of the month, it also produces an **EOM** (End of Month).

## Step 1 — Gather Today's Context

Read in parallel. Skip missing files silently. Vault root is defined in `agents.md`.

1. **Today's daily note** — `Daily/DN - {today}.md`
   - Extract the full `## Worked on` section (what closeouts wrote)
   - Extract `## TODO` to check completion
   - Extract `## Meetings` for meeting references
2. **Today's SOD** — `Reports/SOD/SOD - {today}.md`
   - Read the Priorities and Suggested Start sections
   - This is the intent baseline — what was planned vs. what happened
3. **PICs created today** — glob `Pickups/PIC - *.md` where `date created` = today
4. **PICs closed today** — glob for PICs where `closed_date` = today
5. **Most recent EOW** — `Reports/EOW/` directory, most recent file
   - For week-level context and WTD window calculation

## Step 2 — Context Sweep

Cast a net across external sources to catch what happened outside of terminal sessions. Run both in parallel.

### 2a: Granola Scan

Use the Granola MCP to list today's meetings.

For each meeting today:
- Check if a meeting note (`MN - YYYY-MM-DD (Topic).md`) already exists in `Meetings/`
- If no MN exists: pull the Granola transcript and invoke `/meet` to generate one
- Extract open action items and commitments made (by you or others)
- Cross-reference against `## Worked on` in the daily note — only flag items NOT already captured

If Granola MCP is unavailable, note it and continue without it.

### 2b: Slack Scan

Scoped searches only — do NOT scan all channels broadly.

- Search for @mentions of you in the last 24 hours
- Search for messages you've flagged/saved but haven't responded to
- Focus on channels listed in your `agents.md` under `People Ops focus areas`
- Only surface NEW items not already in the daily note

### 2c: Consolidate

Collect all uncaptured items. For each:
- Which project or initiative does it belong to?
- Does an open PIC already cover it? If not, flag for PIC creation in Step 5.

If sweep finds nothing new, note "Sweep clean" and continue.

## Step 3 — Synthesize the EOD

Build the report. Keep it **under 350 words** — this gets loaded into tomorrow's SOD context.

```markdown
---
date created: {today}
tags: [report, eod]
category: Report
type: EOD
period: {today}
---

# EOD - {Month Day, YYYY}

## What Happened
{3-5 sentences. What was accomplished across all sessions today. Group by
project/initiative — not by session or time. Name specific artifacts produced
(specs, plans, meeting notes, decisions, drafts). Be concrete: "shipped X" not
"worked on X." Include any meaningful sweep findings (meetings that produced
decisions, Slack threads that led to action).}

## Priority Check
{Compare today's work against the SOD priorities.}
- **[Priority name]**: hit / partial / missed — one-line explanation
{If no SOD existed today: "No SOD priorities were set."}

## What Went Well
{2-3 bullets. Patterns worth repeating.}

## What Didn't
{2-3 bullets. Friction, time sinks, avoidable mistakes. Be honest — this
feeds your own process improvement. If nothing: "Clean day."}

## Goal Discovery
{Based on today's work patterns, what are you clearly working toward?
Propose 2-3 goals as checkboxes — user confirms which to carry forward.}
- [ ] **Proposed goal** — evidence (what you saw today that suggests this)
- [ ] **Proposed goal** — evidence
{Carry forward any confirmed goals from previous EODs rather than re-proposing.}

## Carry Forward
{PICs created today, grouped by project. One line each with the key next step.
If none: "Nothing deferred — all work completed or already tracked."}
```

Save to `Reports/EOD/EOD - {today}.md`. Create the directory if it doesn't exist.

## Step 4 — Present to User

Show the full EOD and call out Goal Discovery specifically:

> "Here are the goals I think you're working toward. Confirm the ones that are right, and I'll carry them into tomorrow's SOD."

User responds with which to keep. Update the EOD to check the confirmed ones, then continue to Step 5.

## Step 5 — Generate Tomorrow's SOD

The SOD is **agent-facing** — every agent reads it via `/orient` to understand your current state and priorities. It must be fresh, terse, and actionable.

### Determine the WTD Window

- Find the most recent EOW in `Reports/EOW/` — that's the window start
- If no EOW exists, the window starts from the earliest available EOD
- The WTD covers everything from window start through today's EOD

### Gather SOD Context

Read in parallel:
- All EODs within the WTD window
- Open PICs: glob `Pickups/PIC - *.md`, frontmatter only, status: open or picked-up
- Tomorrow's daily note if it exists (for scheduled meetings or TODOs)
- Sweep findings from Step 2 that don't have an open PIC → create PICs via `/create-pickup` now, then include them in Open Work

### Write the SOD

```markdown
---
date created: {next workday}
tags: [report, sod]
category: Report
type: SOD
period: {next workday}
wtd_window_start: {date of last EOW or earliest EOD}
---

# SOD - {Month Day, YYYY}

## Week-to-Date Summary
{3-4 sentences max. What shipped, what's in progress, what stalled. Group by
project, not by day. Agents use this to understand the current state without
reading all previous EODs.}

## Your Priorities
{Confirmed goals from today's EOD + carried from previous EODs.
Agents align their suggestions and recommendations with these.}
- Priority 1
- Priority 2
{If no confirmed goals: "No priorities established yet."}

## Open Work
{PICs grouped by project, one line each: what it is + what's next.}
- **[Project]**: [PIC title] — [next step]
{If open PICs touch a system or project recently built/shipped, flag it:}
⚠️ [PIC topic] touches [system] which was recently shipped — if broken, check
deployment state before investigating from scratch.

## Tomorrow
{TODOs and meetings from tomorrow's daily note. Flag time-sensitive items.
If nothing scheduled: "Nothing scheduled."}

## Suggested Start
{Recommend the best PIC to pick up first: highest priority > blocking other
work > time-sensitive > natural continuation of recent momentum.}
```

Save to `Reports/SOD/SOD - {next workday}.md`.

**Next workday:** Friday → Monday, otherwise next calendar day.

Keep the SOD **under 300 words** — it loads into every agent's context via `/orient`.

## Step 6 — EOW (Fridays Only)

If today is Friday (or the last workday before a weekend), also produce an EOW.

Gather:
- All EODs from this week (`Reports/EOD/EOD - {mon through fri}.md`)
- Most recent SOW if one exists

```markdown
---
date created: {today}
tags: [report, eow]
category: Report
type: EOW
period: {week start} to {week end}
---

# EOW - {Month Day – Month Day, YYYY}

## Week Summary
{4-6 sentences. What shipped, what progressed, what stalled across all
initiatives. This resets the SOD's WTD window — next Monday's orient reads
this instead of individual EODs.}

## Goal Progress
{For each confirmed goal from this week's EODs:}
- **[Goal]**: completed / on track / stalled / dropped — evidence

## Week Retro
### Went Well
{3-4 bullets}
### Didn't Go Well
{3-4 bullets}
### Process Changes
{Concrete changes to carry forward — not vague intentions.}

## Next Week Setup
{What's queued for Monday: open PICs, unfinished goals, upcoming deadlines.}
```

Save to `Reports/EOW/EOW - {YYYY}-W{ww}.md` (ISO week number, e.g., `EOW - 2026-W16.md`).

## Step 7 — EOM (Last Workday of Month Only)

If today is the last workday of the month, also produce an EOM.

Gather: all EOWs from this month.

```markdown
---
date created: {today}
tags: [report, eom]
category: Report
type: EOM
period: {YYYY-MM}
---

# EOM - {Month YYYY}

## Month Summary
{5-8 sentences. Initiatives that shipped, progressed, or stalled. Big picture.}

## Initiative Progress
{For each goal or initiative active this month:}
- **[Initiative]**: status — key milestones hit or missed

## Month Retro
### Wins
{4-5 bullets}
### Losses
{4-5 bullets}
### Systemic Issues
{Patterns that repeated across weeks — these need structural fixes.}

## Next Month Setup
{What carries over. What's new. Feeds next month's planning.}
```

Save to `Reports/EOM/EOM - {YYYY-MM}.md`.

## Constraints

- Always produce the EOD — EOW and EOM are conditional.
- Goal discovery is the key differentiator — don't skip it even on light days.
- Don't duplicate `/closeout`'s work — closeout writes to the daily note and creates PICs; end-day reads what closeout wrote and synthesizes.
- If the daily note's Worked On section is empty, produce a minimal EOD noting it was a light or off day.
- Confirmed goals persist across EODs until completed or explicitly dropped.
- If Granola or Slack MCP is unavailable, note it and produce the best EOD possible from vault context alone.
