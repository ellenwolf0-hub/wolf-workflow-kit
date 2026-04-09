---
name: assess
description: >-
  Run a People team diagnostic — sweep Granola, Slack, Coda, and vault context
  to surface the most pressing organizational problems and patterns right now.
  Use when the user says "/assess", "what problems do we have", "what should I
  be paying attention to", "run a diagnostic", "what's going on with the team",
  "where should I dig in", or wants a cross-source snapshot of People team health.
  Best run at the start of a new role, quarter, or any time you need to cut through
  noise and find signal. The output is prioritized findings and a recommended
  first dig-in — not a report for its own sake.
---

# Assess — People Team Diagnostic

Sweep all connected sources and surface what's actually happening — not what's in people's heads, but what shows up in the data: the meetings that keep recurring, the action items that never close, the Slack threads that signal real problems. Produce a prioritized diagnosis and give the user a clear "where to start."

**Arguments:** $ARGUMENTS — Optional: focus area (e.g., `/assess GROW` or `/assess onboarding`). If no argument, run a full diagnostic.

## Step 0 — Orient

Run `date` and read `agents.md` for context on current projects, focus areas, and connected tools. This tells you which channels to scan, which Coda docs to check, and which initiatives are live.

If $ARGUMENTS specifies a focus area, scope the diagnostic to that area throughout. If no argument, cast a wide net and let the signal drive the findings.

## Step 1 — Vault Context Sweep

Read the current state from your own vault — what you already know.

**Open work:**
- Glob `Pickups/PIC - *.md` — read all with `status: open` or `status: picked-up`
  - Group by project/initiative
  - Flag any PIC that's been in `picked-up` status for more than 5 days (stuck work)
  - Note the age of each open PIC — older = more likely to be a real blocker

**Recent activity:**
- Read the last 5 daily notes (`Daily/DN - *.md`, most recent first)
  - What topics appear repeatedly across multiple days? (recurring = real)
  - What started but never got a closeout? (dropped threads)

**Active projects:**
- Glob `Projects/SPC - *.md` and `Projects/PL - *.md`
  - Which projects have a plan but no recent activity? (stalled)
  - Which plans have phases with no completed tasks? (stuck in execution)

**Lessons:**
- Read `lessons.md`
  - Which lessons were added most recently? (fresh pain = current problem)

**Vault finding format:**
```
VAULT: [finding] — [project/area] — [signal: age/frequency/pattern]
```

## Step 2 — Granola Sweep

Use the Granola MCP to pull recent meeting context. Focus on patterns, not individual meetings.

**What to look for:**
- Meetings from the last 2–4 weeks — list them all
- For each: read the Granola document or transcript summary
- Identify:
  - **Topics that appear in 3+ meetings** — these are real issues, not one-time noise
  - **Action items that appear across multiple meetings** — recurring = never resolved
  - **Meetings with no outcomes or decisions** — process waste signal
  - **Escalations** — anything where a senior stakeholder was suddenly pulled in
  - **Absent stakeholders** — recurring meetings where the right people keep not showing up

**If a meeting topic maps to an open PIC or active project in the vault** — flag the connection. If a meeting topic has NO vault representation (no PIC, no project, no meeting note) — that's a gap.

**Granola finding format:**
```
GRANOLA: [finding] — [meeting/topic] — [signal: frequency/pattern/escalation]
```

If Granola MCP is unavailable, note it and skip this step.

## Step 3 — Slack Pulse

Scan People-relevant Slack channels for signal. Check `agents.md` for the channel list — scan the ones listed there. If no channel list exists, default to: People team channel, any active project channels, and your own DMs.

**What to look for in each channel:**
- **Threads with high reply counts** — engagement signals a real issue or decision in flight
- **Messages with reactions but no response from you** — pending decisions or asks
- **@mentions of you or the People team** that haven't been addressed
- **"Quick question" messages that spawned long threads** — sign of unclear policy or process
- **Repeating questions** — same question asked by different people = a documentation or communication gap
- **Urgent-tone messages** (ASAP, by EOD, help, stuck) — pressure signals
- **Long silences on active channels** — disengagement or parallel conversations happening elsewhere

Search for:
- `@[your name]` mentions in the last 2 weeks
- Any flagged/saved messages you haven't acted on
- Key initiative names or project names from your vault — what's being said about them?

**Slack finding format:**
```
SLACK: [finding] — [channel/thread] — [signal: volume/urgency/gap]
```

If Slack MCP is unavailable, note it and skip this step.

## Step 4 — Coda Check

Scan the Coda docs listed in `agents.md`. If no Coda docs are configured, skip this step and note it.

**What to look for:**
- **Tables with overdue rows** — anything with a due date in the past
- **Status columns showing Red or At Risk** — surface these explicitly
- **Trackers with no recent updates** — staleness = either resolved (good) or abandoned (bad)
- **Action items assigned to others** — are they progressing?
- **Dashboards with missing data** — gaps in tracking signal process breakdowns upstream

**Coda finding format:**
```
CODA: [finding] — [doc/table name] — [signal: overdue/stale/at-risk]
```

## Step 5 — Synthesize the Diagnosis

Bring all findings together. Group by theme, not by source. Look for findings from multiple sources that point to the same underlying problem — those get elevated to the top.

**Scoring each finding:**

| Signal | Adds to Priority |
|--------|-----------------|
| Appears in 2+ sources | High |
| Blocked for 7+ days | High |
| Has downstream dependencies (blocks other things) | High |
| Affects multiple people or teams | High |
| Single source, isolated incident | Low |
| Already has an open PIC | Lower (tracked) |
| No ownership identified | Elevate (unowned = unfixed) |

## Step 6 — Write the Diagnostic Report

```markdown
# People Team Diagnostic — {today}
{Focus area: [area] | Full diagnostic}

## What's Actually Going On

### 🔴 High Priority — Needs Attention Now
{Problems with 2+ source signals, blocked work, or downstream dependencies.}

**[Finding title]**
Signal: [sources it appeared in — Vault + Granola, or Slack + Coda, etc.]
Evidence: [specific concrete evidence — meeting count, days blocked, thread size]
What it means: [one sentence on the underlying problem]
Recommended action: [specific next step]

{Repeat for each High Priority finding. Max 3.}

### 🟡 Watch List — Real but Not Urgent
{Single-source findings, patterns to monitor, emerging issues.}
- [Finding] — [source] — [what to watch for]

### ✅ Things Working Well
{Don't only surface problems. What patterns are healthy?}
- [Positive signal] — [evidence]

## Patterns This Week
{1-3 observations about themes or dynamics you're seeing across sources.
Not just a list of problems — what's the story?}

## Recommended First Dig-In
**Start with: [specific finding]**
Reason: [why this one first — highest impact, most time-sensitive, or blocks other things]
How to dig in: [specific action — run /assess GROW, load PIC X, check Coda table Y, read the Granola note from meeting Z]

## Sources Checked
- Vault: ✅ / ⚠️ (note if limited)
- Granola: ✅ / ⚠️ unavailable
- Slack: ✅ / ⚠️ unavailable
- Coda: ✅ / ⚠️ unavailable / not configured
```

## Step 7 — Present and Offer to Dig In

Show the diagnostic report. Then ask:

> "Here's what I'm seeing. Which area do you want to dig into first?"

Offer the top 3 findings as options:
1. [High Priority finding 1]
2. [High Priority finding 2]
3. [Watch List item or second High Priority]
4. Walk me through all of them

When the user picks an area:
- If it has an open PIC → offer to load it via `/pickup`
- If it has relevant meeting notes → surface the key decisions and action items
- If it has a Coda table → pull the current state
- If it needs investigation → offer to `/create-agent` to do a deeper sweep

## Quality Rules

- **Don't invent findings.** Every finding must come from something you actually read or pulled from an MCP tool. If a source returned nothing, say so.
- **Name specifics.** "The GROW tracker has 4 overdue rows" not "there might be some tracking issues." Vague findings are useless.
- **Signal over volume.** 3 high-signal findings beat 15 low-signal ones. Cut ruthlessly.
- **Cross-source findings come first.** The same problem appearing in Granola AND Slack AND vault is real. Single-source maybe.
- **No findings without action.** Every High Priority finding must have a recommended next step.
- **If nothing alarming turns up:** say so plainly. "Diagnostic is clean — here's what I looked at and what the strongest signal is." A clean diagnostic is useful data.
