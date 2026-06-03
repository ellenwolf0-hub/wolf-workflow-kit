---
name: explain
description: >-
  Break down complex documents, topics, or recent conversation context into clear,
  contextualized explanations. Use this skill when the user says "explain", "break
  this down", "what does this mean", "help me understand", "walk me through this",
  "summarize this spec", "what is this plan saying", or passes a file path to
  explain. Also trigger when the user seems confused or asks clarifying questions
  about a complex topic being discussed. Works with any document type (SPC, PIC,
  PL, RE, ADR, IR, SO, DD) or conversational topics.
---

# Explain

Distill complex documents or topics into clear, contextualized explanations. Not dumbed down -- consolidated, condensed, and anchored to what the user is working on.

## Routing

- **With a file path argument:** Read the file, identify its type and project, load context, produce the explanation.
- **With a topic argument** (e.g., "explain signal accumulator"): Find relevant files via grep/glob, synthesize, explain.
- **No argument:** Explain whatever is being discussed in the current conversation. Scan recent messages for the complex topic, decision, or output that needs clarification.

## Context Loading

Before explaining, ground yourself in the user's world:

1. **Identify the project** from the file path or conversation context. Read that project's `CLAUDE.md` if it exists.
2. **Read related artifacts** -- if explaining a plan, read its source spec. If explaining a spec, check for review artifacts. If explaining a PIC, read the referenced key files. Follow one level of wikilinks.
3. **Check the SOD** if today's exists -- what is the user working on right now? Frame the explanation in terms of their current priorities.

Don't over-load. One level of context is enough -- the goal is framing, not exhaustive research.

## Output Format

### For Documents (SPC, PL, PIC, RE, ADR, IR, etc.)

**Executive Summary** -- one paragraph, 3-4 sentences. What this document is, why it exists, what it concludes or proposes. Written as if briefing someone who has 30 seconds.

**What This Means for You** -- 2-3 bullets connecting this document to the user's current work. What decisions does it drive? What does it unblock? What should the user do with this information?

**Section Breakdown** -- for each major section of the document:
- **Section name** -- 1-2 sentence distillation of what it says
- Skip sections that are boilerplate (frontmatter, standard headers) unless they contain surprising content

**Key Decisions / Findings / Risks** -- pull out the items that matter most. Decisions made, risks identified, open questions, dependencies. Table format if 3+.

**What's Missing or Unclear** -- if you notice gaps, contradictions, or ambiguities, flag them briefly. The user benefits from knowing what the document doesn't address.

### For Topics (conceptual explanations)

**In One Sentence** -- the concept distilled to its essence.

**How It Works** -- the mechanism explained concisely. Use the user's project as the concrete example rather than abstract descriptions.

**Where It Fits** -- how this concept relates to what the user is building. What touches it upstream, what depends on it downstream.

**Key Relationships** -- if the topic involves multiple interacting concepts, show how they connect. Brief list or simple diagram, not a textbook.

### For Conversation Context (no argument) — "What We're Doing and Why"

When called with no argument, the default is a situational briefing of the current work, not a topic explainer. Scan recent messages and produce:

**In one sentence** — what we're actually doing right now, framed around the user's goal (not the mechanics).

**The Backstory** — 1 short paragraph explaining *why* this work exists. What changed, what problem it solves, what the prior state was. Anchor to concrete systems/files the user has been touching this session.

**What I've Done So Far (no help needed)** — checklist of completed steps with a one-line "why it mattered" per item. Mark each ✅. This tells the user what they can stop worrying about.

**What's Left — and Why I Need You** — a table with columns: Step | What happens | Why you. Be explicit about *which specific actions require the human* (browser checks, web UI toggles, physical hardware, judgment calls, external accounts) vs. what the agent can drive autonomously.

**The Split** — two short lines:
- **I can drive:** concrete list of commands/actions the agent will take
- **You have to do:** concrete list of things only the user can do

**Current Gate** — one sentence naming the single thing blocking progress right now, and what answer/action unblocks it.

This format exists because mid-task "explain" calls almost always mean "I lost the thread — remind me what we're doing, what's done, and what you need from me." Answer that question directly.

If the conversation is *not* about an in-progress task (e.g., the user is asking about a concept that came up), fall back to the Topic format instead.

## Principles

- **Contextualize, don't genericize.** "The Signal Accumulator stages your unresolvable email signals" is better than "A staging system for signals."
- **Lead with impact.** Start with what matters to the user, then explain the mechanism. Not the other way around.
- **Preserve precision.** Don't lose technical accuracy for readability. Use the correct terms -- just make sure they're connected to things the user already knows.
- **Be honest about complexity.** If something is genuinely complex with no shortcut, say so. Don't pretend 5 interacting systems can be explained in 2 sentences.
- **Skip the obvious.** Don't explain what the user clearly already understands from context. Focus on the parts that are new, surprising, or non-obvious.
