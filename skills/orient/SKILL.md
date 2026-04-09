---
name: orient
description: >-
  Load vault context and get oriented for the session. Use at the start of every
  day, after any break, or when the user says "orient", "/orient", "what's open",
  "what do I have going on", "get me up to speed", "what was I working on", or
  "start up". Also trigger after context compaction — always re-read the config
  chain even in continued sessions.
---

# Orient — Session Startup

Load the configuration files and context that tell you how to operate in this workspace. Without this step you'll miss role context, interaction preferences, and open work that carries over from the last session.

**Arguments:** $ARGUMENTS — Optional. If a specific project or topic is provided, surface context relevant to that area specifically.

## Step 1 — Get the Date

Run `date` to anchor your context temporally. Day of week matters — Monday orients differently than Friday.

## Step 2 — Read `agents.md`

Read `agents.md` in the vault root. This is the user's profile:
- Name, role, team, manager, key stakeholders
- Current priorities
- Interaction preferences (how they like questions asked, response style)
- Available skills and vault structure
- Zapier webhook URLs (if configured)

Load it fully. Every preference here applies to every response in this session.

## Step 3 — Read `lessons.md`

Read `lessons.md` in the vault root. These are hard-won context clues from past sessions.

Pay attention to anything that:
- Flags a recurring pattern (e.g., "always lead with growth before development")
- Warns about a known failure mode
- Describes how to handle a specific type of work

Don't recite lessons back — just let them inform how you behave.

## Step 4 — Check for Today's Daily Note

Look for `Daily/DN - YYYY-MM-DD.md` using today's date from Step 1.

**If it exists:** Read the `## Today's Focus` and `## Open Pickups` sections. Note any items that are already set.

**If it doesn't exist:** Create it from the Daily Note template at `templates/Daily Note.md`. Use today's date. Don't announce that you created it — just do it and continue.

## Step 5 — Find Open Pickups

Glob `Pickups/*.md` and read the frontmatter of each file. Filter to `status: open` only.

For each open pickup, extract:
- The title (from the filename or `# PIC -` heading)
- The first item under `## What Needs to Happen Next`

If there are no open pickups, note that clearly — it's useful information.

## Step 6 — Surface the Picture

Give a concise summary. The user doesn't need a recitation of everything you read — just what's immediately relevant.

**Format:**

```
Good [morning/afternoon]! Today is [Day, Month D].

Open pickups:
• [PIC name] — [one-line: what needs to happen next]
• [PIC name] — [one-line: what needs to happen next]

[If none]: No open pickups. Clean slate today.

[If today's focus is set in the daily note]:
Today's focus already set:
• [item]
• [item]

What do you want to work on?
```

Keep it under 15 lines. If the user provided a topic in $ARGUMENTS, lead with context relevant to that topic.

## Quality Rules

- Never fabricate pickup content. If a file doesn't have a `## What Needs to Happen Next` section, say "next step unclear" rather than guessing.
- If `agents.md` has no name filled in (still says "[Your name]"), note it: "Heads up — agents.md isn't personalized yet. Fill in your name and role to get better context in every session."
- Don't read out the full lessons.md or agents.md — just confirm they're loaded.
- If lessons.md is empty or only has the starter template, don't surface it at all.
