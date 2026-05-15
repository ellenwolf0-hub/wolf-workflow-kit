# PIC Template - Pickup

## Frontmatter additions

```yaml
status: open
project: "<project name>"
goal: "<RM goal name or 'Unaligned'>"
pickup_date: "YYYY-MM-DD"  # next workday, skip weekends
```

Tags: `[pickup, <project-tag>]`

## Pre-creation gates

### Check for existing open PICs
Search the target project's pickups directory. If an open PIC covers the same domain, ask: merge or create separate? One PIC per active workstream.

### PJL entry gate (MANDATORY)
Check `02_Projects/<project>/PJL - <Name>.md` for today's date heading. If no PJL entry exists, STOP. Tell user to run `/log-work` first. Hard gate, not a warning. Exception: cross-cutting work with no project.

### Roadmap awareness
Read current RM. Identify which goal this PIC serves. If open PIC count >= 7, present options: merge, log to PJL only, or create anyway. Tag with `goal:` field.

## Section structure

1. **Context** - 2-3 sentences for zero-context reader
2. **What Was Done** - Verified bullet list with evidence (hashes, counts, test results). Mark unverified claims.
3. **What Needs to Happen Next** - Numbered, specific, actionable steps. Executable without conversation history.
4. **Known Issues** - Bugs, edge cases, inconsistencies. Mandatory section. "None identified" if empty.
5. **Key Files** - Wikilinks and paths, confirmed to exist via Glob/ls. Grouped by type.
6. **Blockers or Dependencies** - Hard/soft/external. "None identified" if empty.
7. **Operational Dependencies** - (Infra/deploy work only) What, where configured, survives rebuild?, how to verify.
8. **Verified State** - Timestamps on verified claims. Omit for pure code/design work.
9. **Session Notes** - Preferences, decisions, gotchas, discrepancies.

## Verification workflow

Before writing, verify all system state claims:
- Container status: `docker ps` via SSH
- DB schema: `\dt` / `\d table`
- Git state: `git status`, `git log`
- Endpoints: curl health/data endpoints
- File existence: Glob/ls

Record what's actually true, not what the conversation claimed. Note discrepancies in Session Notes.

## Post-creation

1. Log session-end entry to PJL
2. Present brief summary (not the full PIC): topic, path, step count, known issues count, key verified fact
3. Check if this supersedes an older PIC on the same topic
