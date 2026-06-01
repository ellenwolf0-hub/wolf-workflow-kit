# Migrator

**Called from:** SKILL.md Step 2 (after scaffolder completes)
**Input:** `APPROVED_PROFILE` — specifically `approved_migrations[]` array
**Output:** None (side effects: files copied to vault, migration log created)

---

## Instructions

Process every entry in `APPROVED_PROFILE.approved_migrations`. For each file:
1. Classify → determine prefix
2. Copy + rename to destination
3. Inject or merge frontmatter
4. Log the operation

Files in `APPROVED_PROFILE.rejected_migrations` are skipped entirely — do not copy them.

---

## Step 1 — File Classification

Determine the correct prefix for each source file. Apply rules in this order; stop at first match.

### Primary Signal: Filename / Path Keywords

| If the filename or parent directory contains... | Assign prefix |
|--------------------------------------------------|---------------|
| `meeting`, `standup`, `sync`, `call`, `1:1`, `interview`, `MN` | `MN` |
| `report`, `audit`, `evaluation`, `analysis`, `research`, `RE`, `assessment` | `RE` |
| `spec`, `requirement`, `SPC`, `design doc`, `PRD` | `SPC` |
| `plan`, `roadmap`, `PL`, `implementation`, `sprint plan` | `PL` |
| `incident`, `outage`, `postmortem`, `IR` | `IR` |
| `reference`, `REF`, `runbook`, `guide`, `handbook` | `REF` |
| `initiative`, `IN`, `program` | `IN` |
| `pickup`, `PIC`, `next session`, `context doc` | `PIC` |
| `daily`, `DN`, `journal`, `log` (at top level, not inside a project) | `DN` |
| `retro`, `retrospective`, `RET` | `RET` |
| `transcript`, `TR` | `TR` |
| `tasting`, `TA` | `TA` |
| `weekly`, `WS`, `week summary` | `WS` |
| `handoff`, `HAN` | `HAN` |
| `feature request`, `FR` | `FR` |
| `work log`, `WL`, `implementation log` | `WL` |

### Secondary Signal: File Extension

If no keyword match, classify by extension:

| Extension | Default prefix |
|-----------|---------------|
| `.md` | `RE` (generic report/note — will be confirmed via content sample) |
| `.xlsx`, `.csv`, `.numbers` | Use custom prefix from `APPROVED_PROFILE.approved_prefixes` if the file's custom prefix was approved; otherwise `RE` |
| `.pdf` | `RE` |
| `.docx`, `.doc` | `RE` |
| `.pptx`, `.ppt`, `.key` | `RE` |
| `.txt` | Sample content (see below) |
| No extension | Sample content (see below) |

### Tertiary Signal: Content Sampling (ambiguous files only)

For `.md`, `.txt`, and no-extension files that have no keyword match, read the first 50 lines:

- If content contains `## Agenda`, `attendees:`, `present:`, `action items:` → `MN`
- If content contains frontmatter `category:` field → use that value to look up prefix in the category→prefix table below
- If content opens with a problem statement or numbered requirements → `SPC`
- If content opens with a phase/task breakdown or timeline → `PL`
- If still ambiguous after 50 lines → mark `confidence: low`, flag as ambiguous, skip (do not migrate without user decision — these were already surfaced in the discovery report per FR-36)

### Category → Prefix Map (for existing frontmatter)

| Frontmatter `category` value | Prefix |
|-----------------------------|--------|
| `Meeting` | `MN` |
| `Report` | `RE` |
| `Spec` | `SPC` |
| `Plan` | `PL` |
| `Daily Note` | `DN` |
| `Reference` | `REF` |
| `Initiative Log` | `IN` |
| Any other value | `RE` (default) |

### Binary and Unsupported Files

Skip and log (do not copy) if:
- File has a binary extension: `.png`, `.jpg`, `.jpeg`, `.gif`, `.svg`, `.mp3`, `.mp4`, `.mov`, `.zip`, `.tar`, `.gz`, `.dmg`, `.app`, `.exe`
- File size > 10 MB
- File has no extension and content sampling fails (unreadable bytes)

---

## Step 2 — Copy and Rename

### Build the destination path

1. **Get target folder** from `approved_migrations[i].destination` (set by profile generator from project assignment — see Step 5 below for the assignment logic used during profile generation)
2. **Apply prefix:** rename the file as `<PREFIX> - <original_filename_without_prefix>.md`
   - Strip any existing prefix if the source already uses the standard format (`XX - Name.md`)
   - Preserve the original name otherwise: `Budget Q1.xlsx` → `BDG - Budget Q1.xlsx`
3. **Handle collisions:** if the destination filename already exists in the vault:
   - Append `-2`: `MN - Weekly Sync.md` → `MN - Weekly Sync-2.md`
   - If `-2` also exists, append `-3`, and so on up to `-9`
   - If all suffixes are taken, log a warning and skip the file

### Copy operation

```bash
cp "<source_path>" "<destination_path>"
```

**Never use `mv`.** Never delete or modify the source file. (FR-32, SAT-10)

---

## Step 3 — Frontmatter Injection

After copying, inspect the destination file's frontmatter.

### Case A: File has no frontmatter

Add a frontmatter block at the top of the file:

```yaml
---
date created: <YYYY-MM-DD from file mtime>
tags: [migrated]
category: <category from prefix map>
---
```

Get `date created` from the source file's `mtime` using:
```bash
stat -f "%Sm" -t "%Y-%m-%d" "<source_path>"
```

Add project tag if the file was placed in a project folder: `tags: [migrated, <project-slug>]`

### Case B: File has existing frontmatter

Read the existing frontmatter. Add only fields that are absent — **never overwrite existing values** (FR-34):

- If `date created` is missing → add it (from mtime)
- If `tags` is missing → add `tags: [migrated]`; if `tags` exists → append `migrated` to the existing list only if not already present
- If `category` is missing → add it from the prefix map
- All other existing fields → leave exactly as-is

### Wikilink Preservation

Copy `[[link]]` patterns verbatim. Do not rewrite, expand, or resolve any wikilink. (FR-34)

This includes:
- `[[Note Name]]`
- `[[Note Name|Display Text]]`
- `[[Folder/Note Name]]` — copy as-is even if the path won't resolve in the new vault

---

## Step 4 — Project Assignment

The `destination` field on each `approved_migrations` entry already encodes the target path (set during profile generation). Apply the following rules when that field is present:

- **Matched project:** place in `Projects/<project-name>/` — use the subfolder that fits the document type (e.g., `specs/YYYY-MM-DD/` for SPC files, `reports/YYYY-MM-DD/` for RE files)
- **No project match:** place in `Migrated/` at the vault root — this is the holding area for unmatched files
- **Ambiguous (flagged in `approved_migrations[i].ambiguous: true`):** these were already resolved by user approval in the discovery report; use the `destination` field as given

For date subfolders (specs, plans, reports), use the file's `mtime` date, not today's date.

---

## Step 5 — Migration Log

After processing all files, create the migration log at:
```
Notes/migration-log-<YYYY-MM-DD>.md
```
Use today's date. If a log already exists for today (re-run scenario), append to it with a separator line.

### Log frontmatter

```yaml
---
date created: <today>
tags: [migration, setup]
category: Report
---
```

### Log format

```markdown
# Migration Log — <YYYY-MM-DD>

Generated by /setup auto-discovery migration phase.
Source vault(s): <list source vault paths>
Files processed: <N> copied, <N> skipped, <N> warnings

---

## Copied

| Source | Destination | Prefix | Frontmatter Added | Notes |
|--------|-------------|--------|-------------------|-------|
| `/path/to/source/Budget Q1.xlsx` | `Projects/Operations/BDG - Budget Q1.xlsx` | `BDG` | `date created`, `category`, `tags` | — |
| `/path/to/source/Weekly Sync.md` | `Projects/{{ORG}} Apps/MN - Weekly Sync.md` | `MN` | `tags` only (had existing frontmatter) | — |

## Skipped

| File | Reason |
|------|--------|
| `/path/to/large-export.csv` | File size 45 MB — exceeds 10 MB limit |
| `/path/to/image.png` | Binary file — not a document |
| `/path/to/ambiguous-file.md` | Classification confidence < 50% — flagged for user review |

## Warnings

| File | Warning |
|------|---------|
| `/path/to/note.md` | Collision — renamed to `RE - Note-2.md` (original name taken) |
```

Log every file. No file should be processed without an entry — either in Copied or Skipped.

---

## Edge Cases Summary

| Scenario | Behavior |
|----------|----------|
| Binary file (.png, .mp4, .zip, etc.) | Skip + log in Skipped table |
| File > 10 MB | Skip + log in Skipped table |
| No file extension | Sample first 50 lines; if unreadable or still ambiguous → skip + log |
| Duplicate destination filename | Append `-2`, `-3`... up to `-9`; if all taken → skip + log warning |
| File already has all frontmatter fields | Copy as-is; log "no frontmatter changes" |
| Source path no longer exists at copy time | Skip + log warning; continue with remaining files |
| `approved_migrations` is empty | Write log header with "0 files processed" and return immediately |

---

## Return

When all files in `approved_migrations` have been processed and the migration log is written, return to SKILL.md Step 2 continuation. Pass no output variable — migration is complete via side effects.

Report to SKILL.md: total files copied, total skipped, path to migration log.
