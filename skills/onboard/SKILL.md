---
name: onboard
description: >-
  First-session context loader. Run once when first setting up the kit.
  Imports existing work context from Coda and Granola, runs a short interview,
  and builds a real agents.md profile so Claude starts with genuine understanding
  of the user's work — not a blank slate. Use when: "/onboard", "help me get
  started", "let's set up my context", "I want to transfer my context",
  "load my work into this".
---

# Onboard — Context Import & Profile Setup

This skill runs once at the start. The goal: end this session with an `agents.md`
that reflects real work — not a placeholder. The workflow gets smarter every session,
but only if it starts with something real.

**Arguments:** $ARGUMENTS — Optional name of the person being onboarded (if running
on behalf of someone else).

## Why this matters

The Wolf Workflow Kit is an accumulating intelligence system. Every meeting captured,
every project documented, every session closed out — it all becomes context that
carries forward. But session one needs a starting point. Without it, Claude meets
the user fresh every time. This skill loads what already exists so session 1
feels like session 10.

## Step 0 — Read Current State

1. Run `date` to anchor the session
2. Read `agents.md` in the vault — note what's filled in and what's placeholder
3. If `agents.md` looks complete (name, role, priorities all filled in), confirm
   with the user: "Your profile looks set up already. Want me to enrich it with
   context from Coda and Granola, or is this a fresh setup?" Proceed accordingly.

## Step 1 — Guided Interview

One question at a time. Wait for the answer before asking the next.

**Q1:** "What are the 2–3 projects you're most actively working on right now?
Give me a name and one sentence on where each one stands."

**Q2:** "Who are the 2–3 people whose work most affects yours — a manager, a key
stakeholder, a business partner? Just names and their role relative to you."

**Q3:** "What's the one thing that most needs to happen in your work in the next
2 weeks?"

**Q4:** "How do you prefer to work with me? For example: 'give me a draft and I'll
edit', 'ask me questions before writing anything', 'just do it and show me the
result'."

Keep answers brief — this feeds agents.md, not a full interview.

## Step 2 — Pull Context from Coda

If the Coda MCP is connected (`mcp__Coda__search` is available), search for docs
relevant to each project they named:

For each project:
- Search Coda: `search_granola_notes` or `mcp__Coda__search` with the project name
- Look for: trackers, planning docs, decision logs, anything named after the project
- Read the 1–2 most relevant results
- Extract: current status, key decisions made, open questions, names involved

Present findings: "I found these Coda docs that look relevant: [list]. Want me to
pull context from any of these into your profile?"

If Coda MCP is NOT connected, note it and move on:
> "Coda isn't connected yet. You can add it later with `claude mcp add --transport http Coda https://coda.io/apis/mcp`, then run `/mcp` to sign in (no API token needed). Once it's connected, run `/onboard` again to pull your project docs in."

## Step 3 — Pull Context from Granola

If the Granola MCP is connected, search for recent meetings:
- Find meetings from the last 2 weeks related to the projects they named
- Pull decisions and open action items from those meetings
- Note recurring names — these belong in the stakeholders list

If Granola is NOT connected, skip silently.

## Step 4 — Write agents.md

With everything gathered, update `agents.md`. Preserve any existing content that's
already accurate — only update what's incomplete or stale.

```markdown
Name: [name]
Role: [title]
Team: [team]
Manager: [manager]
Key stakeholders: [name — one phrase context for each]

My top priorities right now:
- [Project 1]: [one-line status from interview + Coda context]
- [Project 2]: [one-line status]
- [Project 3]: [one-line status]

How I like to work with Claude:
- [stated preference from Q4]

Active context (loaded: [today]):
[2–3 sentences of the most important current context pulled from Coda/Granola.
What's in motion, what's at stake, who's involved.]
```

Show the draft to the user before writing: "Here's what I'd write to agents.md.
Does this look right?" Apply any corrections, then write.

## Step 5 — Orient and Hand Off

After writing agents.md, give a brief confirmation:

> "Your context is loaded. Here's what Claude now knows:
> - **Active projects:** [list]
> - **Key people:** [list]
> - **Top priority:** [the thing they named]
>
> From here: start every session with `/orient`, run `/meet` after every call,
> and end with `/closeout`. The kit builds its knowledge base automatically
> from there — you don't have to think about it."

Then offer: "Want to run `/orient` now to see what your sessions will look like?"

## Notes

- This skill should feel like a 10-minute conversation, not a form
- Don't ask all 4 interview questions in one message — one at a time
- If the user is non-technical, avoid terms like "MCP", "vault", "agents.md" —
  just say "your profile" and "your notes folder"
- The Coda and Granola pulls are optional enrichment — if both fail, the interview
  alone is enough to produce a useful agents.md
