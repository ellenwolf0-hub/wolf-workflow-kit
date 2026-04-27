---
name: dream
description: "Memory consolidation — scan automemory files, merge duplicates, resolve contradictions, prune stale data, convert relative dates to absolute, and tighten the MEMORY.md index. Based on Anthropic's Dream feature (extracted from Claude Code v2.1.84). Use this skill whenever the user says 'dream', 'consolidate memory', 'clean up memory', 'prune memory', 'memory consolidation', '/dream', or mentions that their memory feels bloated, stale, or contradictory. Also trigger when the user is doing end-of-day closeout and wants a memory hygiene pass, or says 'tighten memory', 'memory cleanup', 'dedupe memory'. Even a casual 'my memory is getting messy' should trigger this."
---

# Dream — Memory Consolidation

A reflective pass over your memory files. Synthesize what you've learned recently into durable, well-organized memories so that future sessions can orient quickly.

## Arguments

| Argument | Scope | Memory directory | Index file |
|----------|-------|-----------------|------------|
| *(none)* or `project` | Current project | `~/.claude/projects/<encoded-cwd>/memory/` | `MEMORY.md` in that directory |
| `user` | User-level (all projects) | `~/.claude/memory/` | `MEMORY.md` in that directory |
| `all` | Both scopes | Both directories | Both index files |

Where `<encoded-cwd>` is the current working directory with `/` replaced by `-` and leading `-` (e.g., `-Users-username-Documents-Vaults-Work-Vault`).

Session transcripts are JSONL files in the **project directory** (sibling to `memory/`, not inside it): `~/.claude/projects/<encoded-cwd>/*.jsonl`

If you're running at `user` scope, there are no user-level transcripts — just consolidate what's in the memory directory.

## Phase 1 — Orient

Get the lay of the land before changing anything.

1. `ls` the memory directory to see every file
2. Read `MEMORY.md` to understand the current index — note its line count and size
3. Read each memory file (they're small — usually under 50 lines). Build a mental map: what topics are covered, what types (user/feedback/project/reference), any obvious overlaps or tensions between files
4. If the memory directory is empty or MEMORY.md doesn't exist, say so and stop — nothing to consolidate

The goal here is to understand the full picture before touching anything. Rushing to edit without reading everything is how you create new contradictions.

## Phase 2 — Gather recent signal

Look for information that should update what's in memory. Sources in priority order:

1. **Existing memories that drifted** — facts in memory files that contradict current reality. For example, a project memory saying "using SQLite" when the codebase now uses Postgres, or a feedback memory about a workflow that no longer exists.

2. **Transcript search** — if you suspect a memory might be stale or there's been a recent shift, grep the JSONL transcripts for narrow terms. Never read whole transcript files — they're huge.
   ```bash
   grep -rn "<specific term>" ~/.claude/projects/<encoded-cwd>/*.jsonl | tail -30
   ```
   Look at the last 5-10 sessions worth of transcripts (sort by modification time, take the most recent). You're looking for corrections, preference changes, or new patterns that should update existing memories.

3. **Relative dates** — scan all memory files for relative time references: "yesterday", "last week", "next Friday", "recently", "soon", "a few days ago". These decay in meaning and need to be converted to absolute dates or removed if they're no longer relevant.

## Phase 3 — Consolidate

Now make changes. For each issue you identified, act on it:

### Merge near-duplicates
If two files cover the same topic (e.g., `feedback_testing.md` and `feedback_test_approach.md`), merge them into one file. Keep the better filename. Preserve all non-redundant information from both files. Delete the duplicate.

### Resolve contradictions
If two memories disagree (e.g., one says "use React" and another says "never use React"), determine which is current by checking transcript evidence. Update the correct one, delete the wrong one.

### Fix stale data
If a memory references something that no longer exists (a removed file, a completed project, an outdated preference), either update it to reflect current state or delete it if it's no longer useful.

### Convert relative dates
Replace every relative date with an absolute one. If you can determine the date from context (the memory file's creation date, nearby transcript timestamps), use that. If you can't determine the exact date, note it as approximate: "~2026-03-20". If the date was the entire point of the memory and it's now past, consider whether the memory is still useful.

### Respect memory type conventions
When editing memory files, maintain the frontmatter format from the system prompt's automemory section:
```yaml
---
name: {{memory name}}
description: {{one-line description}}
type: {{user, feedback, project, reference}}
---
```
For feedback and project types, keep the structure: rule/fact, then **Why:** and **How to apply:** lines.

### What NOT to do
- Don't create new memories during consolidation — this is a cleanup pass, not a creation pass
- Don't change the meaning of a memory, only its accuracy and currency
- Don't remove memories just because they seem minor — if they were worth saving, they're probably worth keeping unless actually wrong or stale

## Phase 4 — Prune and index

Update MEMORY.md to be tight and accurate.

**Hard limits:** Under 200 lines, under ~25KB. MEMORY.md is an index, not a dump — each entry should be one line under ~150 characters.

Format: `- [Title](file.md) — one-line hook`

Checklist:
- Remove pointers to files you deleted in Phase 3
- Add pointers to any files that exist but aren't indexed (orphans)
- If an index line is over ~200 chars, it's carrying content that belongs in the topic file — shorten the line, move the detail
- Group entries by type (## Feedback, ## Projects, ## Reference, ## User)
- Resolve any contradictions visible at the index level — if two entries describe conflicting states, the files should already be fixed from Phase 3

## Output

Return a brief summary structured like this:

```
## Dream Summary

**Scope:** project | user | all
**Files scanned:** N memory files, M recent transcripts

### Changes
- **Merged:** file_a.md + file_b.md → file_a.md (reason)
- **Updated:** file_c.md — fixed stale project status
- **Pruned:** file_d.md — referenced completed work from January
- **Date-fixed:** file_e.md — "next Friday" → 2026-03-28
- **Index:** removed 2 stale entries, added 1 new entry, trimmed 3 verbose lines

### No changes needed
- file_f.md, file_g.md — still accurate

**MEMORY.md:** X lines (was Y)
```

If nothing changed, say: "Memory is already clean — no changes needed."

## Local Customizations

If `LOCAL.md` exists in this skill directory, load and follow it after these instructions. Local instructions override upstream where they conflict.
