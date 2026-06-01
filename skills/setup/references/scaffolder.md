# Scaffolder

**Called from:** SKILL.md Step 2 (after report-renderer.md returns)
**Input:** `APPROVED_PROFILE` — user-approved profile (Contract 3); `vault_root` — absolute path to target vault (from Step 1 preflight)
**Output:** None — side effects only (folders created, files written, CLAUDE.md updated)

---

## Instructions

### 1. Initialize Rollback Infrastructure

Before touching anything in the vault, set up the rollback mechanism.

**Snapshot the current vault state:**

```bash
find "<vault_root>" -not -path "*/.obsidian/*" \( -name "*.md" -o -name "*.json" -o -name "*.base" \) \
  | sort > /tmp/setup-pre-scaffold-snapshot.txt
```

**Create the rollback log** using the Write tool at `<vault_root>/.setup-rollback.json`:

```json
{ "started_at": "<ISO timestamp>", "vault_root": "<vault_root>", "status": "in_progress", "operations": [] }
```

**Create the backups directory:**

```bash
mkdir -p "<vault_root>/.setup-backups"
```

After each operation below, append a record to the `operations` array in `.setup-rollback.json`:

```json
{ "type": "<created|modified|backed_up>", "path": "<relative path in vault>", "timestamp": "<ISO timestamp>" }
```

Use `"created"` for new files/dirs, `"backed_up"` for backup copies, `"modified"` for edits to existing files (always preceded by a `backed_up` entry). Log `created` entries before their contents so reverse-replay deletes them correctly.

---

### 2. Create Project Folders

For each project in `APPROVED_PROFILE.approved_projects`:

```bash
mkdir -p "<vault_root>/Projects/<project.name>"/{specs,plans,reports,reviews}
```

Append one `created` entry per project (top-level directory only — sub-dirs are removed with it on rollback).

---

### 3. Generate Project CLAUDE.md Files

For each project in `APPROVED_PROFILE.approved_projects`, write `<vault_root>/Projects/<project.name>/CLAUDE.md` using the Write tool. Append a `created` entry per file.

**Template:**

```markdown
---
date created: <YYYY-MM-DD>
tags: [agents, <project.name in lowercase-kebab-case>]
category: Reference
---

# <project.name> — Agent Context

## Project Overview

<project.description>

## Repos

<One line per repo detected for this project:>
- `<repo path>` — <primary_language>, <project_type>

Omit section if no repos were detected for this project.

## Key Tools

<Tools from APPROVED_PROFILE.tools relevant to this project (list all if none are clearly project-specific).>

## Routing Rules

- Specs → `Projects/<project.name>/specs/YYYY-MM-DD/`
- Plans → `Projects/<project.name>/plans/YYYY-MM-DD/`
- Reports → `Projects/<project.name>/reports/YYYY-MM-DD/`
- Code changes → `~/Repos/<primary repo name>/` — never inside the vault

## Notes

_Add project-specific agent guidance here as you work._
```

---

### 4. Inject Custom Prefixes into CLAUDE.md

Skip this step if `APPROVED_PROFILE.approved_prefixes` is empty.

**Back up CLAUDE.md first:**

```bash
cp "<vault_root>/CLAUDE.md" "<vault_root>/.setup-backups/CLAUDE.md"
```

Append `backed_up` then `modified` entries to the rollback log.

**Read the current CLAUDE.md** using the Read tool. Locate the prefix table — it begins with:

```
| Prefix | Type | Example |
```

Each row follows the format:

```
| `XX` | Type description | `XX - Example filename.md` |
```

**Insert each approved custom prefix in alphabetical order** by code (uppercase comparison). Find the row whose prefix sorts just before the new code, and insert after it. Format new rows to match existing ones:

```
| `<CODE>` | <description> | `<CODE> - <plausible example filename>.md` |
```

Example filename: derive from the description — `BDG` / "Budget and financial documents" → `BDG - Q1 Budget.md`.

Use the Edit tool to insert the rows in place. Do not rewrite the entire file.

---

### 5. Generate Vault-Root CLAUDE.md

If `<vault_root>/CLAUDE.md` already exists, back it up:

```bash
cp "<vault_root>/CLAUDE.md" "<vault_root>/.setup-backups/CLAUDE.md"
```

Append `backed_up` + `modified` entries. If no existing file, append `created` only.

Write `<vault_root>/CLAUDE.md` using the Write tool:

```markdown
---
date created: <YYYY-MM-DD>
tags: [agents, vault-root]
category: Reference
---

# Vault Root — Agent Context

## Role

**Primary:** <APPROVED_PROFILE.role>
**Secondary:** <APPROVED_PROFILE.role_secondary — omit line if null>

## Tools

<Comma-separated list from APPROVED_PROFILE.tools>

## Projects

<One line per approved project:>
- [[<project.name> agents]] — <project.description>

## Routing Rules

- Specs → `02_Projects/<project>/specs/YYYY-MM-DD/SPC - Name.md`
- Plans → `02_Projects/<project>/plans/YYYY-MM-DD/PL - Name.md`
- Reports → `02_Projects/<project>/reports/YYYY-MM-DD/RE - Name.md`
- Daily notes → `01_Notes/Daily/DN - YYYY-MM-DD.md`
- Code changes → `~/Repos/` only — never put source code in the vault

<Include role-specific rules for each matching role/role_secondary:>
Developer: Link specs to implementation plans. Log PR/commit context to daily note under "PRs/Commits". Runbooks → `04_Reference/Runbooks/`.
Manager/Operations: Meeting notes → `01_Notes/Meetings/`. Delegations → daily note "Delegations" section. SOPs/reference → `04_Reference/`.
Analyst: Cite evidence in reports. Long-lived knowledge → `04_Reference/REF - Name.md`.

## Custom Prefixes

<Include this section only if APPROVED_PROFILE.approved_prefixes is non-empty:>

| Prefix | Description |
|--------|-------------|
| `<CODE>` | <description> |
```

---

### 6. On Failure — Rollback

If any step raises an error, stop and execute rollback immediately.

Read `.setup-rollback.json` and replay `operations` in **reverse order**:

- `"created"` → `rm -rf "<vault_root>/<path>"`
- `"modified"` → `cp "<vault_root>/.setup-backups/<filename>" "<vault_root>/<original path>"`
- `"backed_up"` → `rm "<vault_root>/.setup-backups/<filename>"`

**Verify clean state:**

```bash
find "<vault_root>" -not -path "*/.obsidian/*" \( -name "*.md" -o -name "*.json" -o -name "*.base" \) \
  | sort > /tmp/setup-post-rollback-snapshot.txt
diff /tmp/setup-pre-scaffold-snapshot.txt /tmp/setup-post-rollback-snapshot.txt
```

If the diff is non-empty, report each discrepancy to the user. Then delete rollback artifacts:

```bash
rm -rf "<vault_root>/.setup-backups" "<vault_root>/.setup-rollback.json"
rm -f /tmp/setup-pre-scaffold-snapshot.txt /tmp/setup-post-rollback-snapshot.txt
```

Report the failure with the step and error. Do not return — halt setup.

---

### 7. Success Cleanup

```bash
rm -rf "<vault_root>/.setup-backups" "<vault_root>/.setup-rollback.json"
rm -f /tmp/setup-pre-scaffold-snapshot.txt
```

Print a brief summary:

```
Scaffold complete:
  • <N> project folders created under Projects/
  • <N> project CLAUDE.md files written
  • <N> custom prefixes added to CLAUDE.md   (or "No custom prefixes")
  • Vault-root CLAUDE.md written
```

---

## Return

No output variable. When step 7 is complete, return control to the calling skill and continue with bases-generator.md.

If rollback was triggered (step 6), do not return normally — report the failure and halt setup. The user must re-run `/setup` to retry.
