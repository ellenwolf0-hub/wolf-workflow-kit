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

## Patterns Found
{What patterns, conventions, or existing implementations in the codebase are relevant? Which should be followed? Which should be avoided?}

| Pattern | Location | Follow/Avoid | Why |
|---------|----------|--------------|-----|
| {pattern} | {file/module} | {Follow/Avoid} | {rationale} |

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
