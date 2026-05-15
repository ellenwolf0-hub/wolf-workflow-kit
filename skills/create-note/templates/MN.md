# MN Template - Meeting Note

## Frontmatter additions

Tags: `[meeting, <relevant-project-or-domain-tags>]`

## Input

Accept meeting content in any form: raw transcript (VTT, SRT, pasted text), Limitless lifelog data, conversational dictation, unstructured notes, or command arguments. No interview. Work from supplied content.

## Extract structure

From the input, identify:
1. **Date** - from content, filename, or today
2. **Attendees** - only explicitly mentioned. Never infer. Map aliases only when unambiguous.
3. **Topic** - short descriptor for the filename parenthetical
4. **Parts vs single-segment** - distinct temporal segments? (location change, participant change, temporal gap, mode shift). If no clear boundaries, no parts.
5. **Topics** - group related discussion into discrete blocks, each with at least one concrete detail
6. **Per-topic content:**
   - Discussion (hierarchical bullets, **bold** key details, who said what)
   - Decisions (only if explicitly stated, omit if none)
   - Plans (ideas/direction without owner/deliverable, omit if none)
   - Actions (`- [ ] Owner: description`, omit if none)

## Format A: Single-segment (no parts)

```
## Attendees
## Agenda / Topics
### <Topic>
#### Discussion / Decisions / Plans / Actions
```

## Format B: Multi-part (temporal segments)

Parts at `###`, topics at `####`, decisions/actions inline with bold markers.

## Quality rules

- Never invent or embellish. Not said = not in the note.
- Capture reasoning behind decisions, not just decisions.
- Preserve specifics: names, numbers, dates, amounts. Never generalize.
- Skip greetings, wrap-ups, small talk, filler.
- Every bullet carries information worth reviewing later.
- Omit Decisions/Plans/Actions entirely when empty for a topic.

## Post-creation

Link in daily note under `## Meetings/Calls` if it exists:
```
- <Time> <Attendee> - [[MN - YYYY-MM-DD (<Topic>)]]
  - **Key takeaway 1**
  - **Key takeaway 2**
```
