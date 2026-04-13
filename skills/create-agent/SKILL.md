---
name: create-agent
description: >-
  Dispatch a specialized Claude agent to handle a People Ops task autonomously.
  Use when the user wants an agent to do a research pass, sweep data sources,
  draft something from context, or do background work while they're in a meeting.
  Trigger on "create an agent to...", "spin up an agent", "have an agent handle",
  "run an agent on", or "can an agent do this for me".
---

# Create Agent — People Ops Task Dispatch

Design and dispatch a specialized Claude agent to handle a focused People Ops task. The agent does the work; you review the output.

**Arguments:** $ARGUMENTS — The task to delegate (e.g., "sweep Granola for all GROW mentions this week and summarize them").

## When to Use This

Use `/create-agent` when:
- You need a research pass done while you're in a meeting
- A task requires sweeping multiple data sources (Granola, Slack, Coda, vault) and synthesizing
- You want a first draft of something complex done before you review it
- The task is too long to do interactively but well-defined enough to delegate

Don't use it for quick tasks you can just ask Claude to do directly.

## Step 1 — Define the Task

If $ARGUMENTS is provided, use it as the task definition. If not, ask:

> "What should the agent do? Be specific — the more context you give, the better the output."

Good task definitions include:
- **What to look at:** "Sweep Granola for all meetings mentioning GROW in the last 2 weeks"
- **What to produce:** "Draft a Q1 GROW narrative for the PLT deck"
- **Any constraints:** "Keep it under 1 page, use bullet points, flag anything that needs Ellen's input"

## Step 2 — Design the Agent

Based on the task, determine:

**Data sources to read:**
- Granola MCP — meeting transcripts
- Slack MCP — channel messages and threads
- Coda MCP — docs and tables
- Vault — daily notes, meeting notes, specs, plans

**Output format:**
- Document to write to vault
- Summary to present inline
- Draft to review and edit

**Constraints:**
- Read-only or can it write files?
- Should it ask questions or just produce a first pass?
- Any sensitive data to avoid (real employee names, comp data)?

## Step 3 — Propose the Agent

Present the plan before dispatching:

```
Agent: [Name — e.g., "GROW Sweep Agent"]
Task: [What it will do]
Sources: [What it will read]
Output: [What it will produce and where]
Estimated time: [rough estimate]

Ready to dispatch?
```

Wait for confirmation.

## Step 4 — Write the Agent Prompt

Once confirmed, write a clear, self-contained agent prompt. The agent has no context from this conversation — the prompt must include everything it needs.

Good agent prompts:
- State the goal explicitly: "Your job is to..."
- List exactly what to read: "Read these files: ..."
- Describe the output format in detail
- Specify any constraints: "Do not include real employee names", "Flag anything that needs human review"
- Tell it where to save the output

## Step 5 — Dispatch and Monitor

Dispatch the agent. While it runs, tell the user:
- What the agent is doing
- Where the output will land
- Anything they should do while they wait (or that it'll be ready when they're back)

## Step 6 — Review Output

When the agent completes, present the key output and ask:
- "Does this look right?"
- "Anything you want the agent to refine?"
- "Should I save this to the vault?"

## People Ops Agent Templates

**GROW Sweep:**
> Sweep Granola for all meetings mentioning GROW, White Glove, or talent review in the last [N] weeks. Extract: decisions made, action items with owners, open questions. Produce a bullet-point summary organized by theme. Save to `Projects/GROW/RE - GROW Sweep YYYY-MM-DD.md`.

**Calibration Prep:**
> Read all meeting notes in `Meetings/` that mention [employee name]. Extract the decisions section from each. Produce a calibration pre-brief: prior ratings context, recurring themes, open items, suggested talking points. Present inline.

**Metro Status Sweep:**
> Sweep the project Slack channel for the last 7 days. Extract: updates from DRIs, blockers mentioned, decisions made, open questions. Produce a status summary organized by workstream. Flag anything that needs your input before proceeding. Save to `Projects/RE - Metro Status YYYY-MM-DD.md`.

**Weekly Narrative Draft:**
> Read all daily notes from this week (`Daily/DN - YYYY-MM-DD.md` for Mon-Fri). Read all meeting notes from this week. Produce a weekly narrative for the manager update: what shipped, what's in progress, what's blocked, what needs a decision. Keep it under 300 words.
