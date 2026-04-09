---
name: draft
description: >-
  Write a Slack message, email, talking points, or any communication in the
  user's voice. Use when the user says "/draft", "draft a message", "write a
  Slack to", "help me write", "draft an email", "write talking points", or
  provides a communication task. Adapts style from agents.md profile.
---

# Draft — Write Communications

Write ready-to-send communications in the user's voice, using vault context to inform the content.

**Arguments:** $ARGUMENTS — What to draft and for whom (e.g., "draft a Slack to my manager about the Metro delay" or "write talking points for the calibration with Taylor Chen").

## Step 1 — Understand the Task

Parse $ARGUMENTS for:
- **What to write:** Slack message, email, talking points, doc summary, memo, announcement
- **Audience:** Who is this for? (manager, direct report, team, skip-level, external)
- **Goal:** What should happen after they read it? (action, awareness, decision, response)
- **Constraint:** Anything specific (length, tone, must include/exclude something)?

If any of these are unclear, ask — one question at a time.

## Step 2 — Load Context

Before writing, check the vault for relevant context:

- **Relevant meeting notes** — any recent `MN -` files mentioning this person or topic
- **Relevant decisions** — anything in `## Decisions` sections that's relevant
- **agents.md** — user's role, team, stakeholder relationships, communication preferences
- **Slack MCP** — if available, check for any relevant recent thread or DM to inform the draft

Don't invent context. Only use what you can verify from files or the current conversation.

## Step 3 — Write the Draft

Write ready-to-send. Not a template. Not [placeholders]. The actual words.

**Style rules (adapt from agents.md preferences):**
- Match the user's natural register — if they're direct and brief in their examples, be direct and brief
- People Ops communications often need to balance warmth with clarity — don't sacrifice one for the other
- For sensitive topics (comp, PIPs, separations): write clearly first, then offer to soften or harden tone as a second pass
- No corporate filler: "As per my last email", "Circling back", "Just wanted to touch base" — cut all of it

**Format by type:**
- **Slack message:** Conversational, scannable, under 150 words unless the content requires more
- **Email:** Subject line + body. Clear ask in the first or last sentence.
- **Talking points:** Numbered list, each point one sentence, total under 5 points
- **Memo/announcement:** Header, 2-3 paragraphs, clear action or next step at the end

## Step 4 — Present and Iterate

Show the draft and ask: "Does this sound right, or do you want to adjust anything?" Common adjustments:
- "Make it shorter"
- "Soften the tone"
- "Add more context about X"
- "Remove the part about Y"

Apply changes and re-present. Don't ask for confirmation on each small edit — just do it and show the updated version.

## Quality Rules

- Never invent facts. If you don't have the context, say so and ask.
- Flag sensitive content: comp figures, PIP language, legal-adjacent topics. "This mentions compensation — want me to generalize that or keep the number?"
- If pulling from a meeting note, cite it: "Based on the calibration note from April 9..."
