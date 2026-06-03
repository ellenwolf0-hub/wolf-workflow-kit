# Distill Lessons

Scan resolved IRs and closed retros, extract lessons, and append them to the CLAUDE.md files where future agents will encounter them. Code-specific lessons (file:line references, tuning points, anti-patterns) go to repo CLAUDE.md files. Project-level lessons (process decisions, architectural choices) go to vault project CLAUDE.md files.

Use this skill as part of `/end-day`, or standalone when the user says "distill lessons", "distill IRs", "extract lessons", "update agents from IRs", or "what lessons haven't been distilled".

## Path Resolution

Read `~/.claude/wfk-paths.json` at startup. Use `vault_root` and `paths` to resolve directory references. If missing, use defaults and warn once.

## How It Works

### 1. Find unprocessed artifacts

Load the manifest at `~/.claude/skills/distill-lessons/last-run.json`. If missing, treat all resolved artifacts as unprocessed.

**IRs:** Grep for `resolved: true` or `status: closed` in `**/IR - *.md` under the vault root. Filter to files modified after the manifest's `last_run` timestamp.

**Retros:** Grep for `RET - *.md` or `RET -*.md` under `02_Projects/`. Filter to files created after `last_run`.

If nothing is unprocessed, report "No new resolved IRs or retros since last distill" and exit.

### 2. Extract lessons from each artifact

Read each artifact. For every actionable finding (not narrative background), extract:

```yaml
- dimension: "what output dimension this affects (e.g., title shape, routing, deployment)"
  failed: "what approach didn't work"
  worked: "what approach fixed it"
  anti_pattern: "named anti-pattern if one was identified"
  verification: "how to test this dimension"
  source: "[[IR - Name]] or [[RET - Name]]"
  code_refs: ["file:line references from the artifact"]
  project: "project name from frontmatter or path"
```

Skip findings that are purely observational (no actionable lesson). Skip findings already present in the target CLAUDE.md (deduplicate by checking if the source wikilink already appears in the file).

### 3. Route lessons to targets

**Code repo routing:** If `code_refs` contains paths under `~/Repos/{{MONOREPO_NAME}}/`, find the nearest existing CLAUDE.md in that directory tree. If none exists within 2 levels up, append to the service-level CLAUDE.md (e.g., `services/api/src/engine/CLAUDE.md`). Create a new CLAUDE.md only if no reasonable parent exists.

**Vault routing:** Map `project` to the vault project directory under `02_Projects/`. Append to that project's `CLAUDE.md`. If no CLAUDE.md exists, create one with a minimal stub per vault conventions.

A single lesson can route to both targets if it has both code-specific and project-level content.

### 4. Append using the established template

When appending to a code repo CLAUDE.md, use this format under the relevant dimension heading (create the heading if new):

```markdown
### What we tried that DIDN'T work
- <failed approach>: <why it failed> (source: [[IR/RET - Name]])

### What DID work
- <fix approach> (source: [[IR/RET - Name]])

### Anti-patterns
- <pattern name>: <description> (source: [[IR/RET - Name]])
```

When appending to a vault project CLAUDE.md, use a simpler format under a `## Lessons` section:

```markdown
- **<dimension>**: <lesson summary>. Failed: <what didn't work>. Fix: <what worked>. (source: [[IR/RET - Name]])
```

Do not rewrite existing content. Append only. If the dimension heading already exists, add under it. If a new dimension is introduced, add a new section at the end.

### 5. Update manifest and report

Write the manifest:

```json
{
  "last_run": "YYYY-MM-DDTHH:MM:SS",
  "processed": [
    {"file": "path/to/IR - Name.md", "lessons_extracted": 3, "targets": ["src/api/CLAUDE.md", "src/worker/CLAUDE.md"]},
    ...
  ]
}
```

Report to the user:

```
Distilled N lessons from M artifacts:
- IR - Name: 3 lessons → src/api/CLAUDE.md, src/worker/CLAUDE.md
- RET - Name: 2 lessons → project-docs/CLAUDE.md
Skipped: K findings (observational, no actionable lesson)
Deduplicated: J findings (already in target CLAUDE.md)
```

## Edge Cases

- **IR references code that doesn't exist anymore:** Skip the code routing, still route to vault project CLAUDE.md. Note "code path removed" in the lesson.
- **IR has no file references:** Route to vault project CLAUDE.md only, based on the project frontmatter.
- **Retro contains both code and process lessons:** Split into separate entries, route each to the appropriate target.
- **Multiple IRs for the same incident:** Deduplicate by checking source wikilinks in existing CLAUDE.md content. The first to be processed wins; later ones skip if the same lesson is already written.

## When called from /end-day

Run after the EOD report is written but before `/dream`. Report only the summary line (not the full per-artifact breakdown) to keep EOD output concise. If nothing to distill, output nothing (silent skip).
