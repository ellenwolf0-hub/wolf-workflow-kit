---
date created: {today}
category: Design Discussion
source: "[[{spec_filename}]]"
tags: [{relevant_tags}]
status: Draft
---

# DD - {Spec Name} Design Discussion

## Current State
{What exists today. How does the system currently work? What's the starting point?}

## Desired End State
{What should exist after implementation. Concrete description of the target behavior.}

## Coverage Map

Every field, column, payload key, and counter this work touches or produces.
Blank "Gated by" cells are blind spots. Address them before shipping.

| Field / column / counter | Level | Populated by | Gated by | Qual/Quant |
|--------------------------|-------|--------------|----------|------------|

**Levels:** per-signal, per-day, per-batch, per-phase, per-system, per-workflow-protocol.
Pre-ship requires at least one gate at each level the user experiences the system at.

Source: MQ-1, MQ-2, MQ-5, MQ-7 (easy-to-measure crowds out qualitative; blind-dimension scan).

## Approach Options

### Option A: {name}
{Description, tradeoffs, effort estimate}

### Option B: {name}
{Description, tradeoffs, effort estimate}

**Recommendation:** {recommended option with rationale}

## Resolved Decisions
| ID | Decision | Rationale |
|----|----------|-----------|
| DD-1 | {decision} | {why} |

## Open Questions
{Questions whose answers will change the implementation approach. Present to user via AskUserQuestion.}

| ID | Question | Impact | Default if unanswered |
|----|----------|--------|----------------------|
| Q-1 | {question} | {what changes based on answer} | {safe default} |
