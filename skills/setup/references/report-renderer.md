# Report Renderer

**Called from:** SKILL.md Step 2
**Input:** `PROFILE` — structured profile from profile-generator.md (Contract 2)
**Output:** `APPROVED_PROFILE` — user-approved profile with approved/rejected sections (Contract 3)

---

## Instructions

### 1. Resolve Low-Confidence Items

Before rendering the report, check `PROFILE` for items with confidence between 50–79%. For each low-confidence item, ask a **targeted** clarifying question using `AskUserQuestion`. Do not ask generic questions — reference the specific evidence.

**Projects (50–79% confidence):**
Ask which are active. Example:

```
I found these repos but I'm not sure which ones you actively work on:
1. repo-alpha (last commit 45 days ago)
2. repo-beta (last commit 12 days ago)
3. repo-gamma (no recent commits)

Which of these are active projects you want in your vault?
```

Options should list the specific project names. Include "All of them" and "None of them" as options.

**Prefix mappings (50–79% confidence):**
Ask whether the detected document type is correct. Example:

```
I found 4 Excel files with "Budget" in the name. Should I create a custom prefix BDG for budget documents?
```

Options: "Yes, create BDG prefix", "No, skip it", "Use a different prefix (I'll type one)"

**Role inference (50–79% confidence):**
Ask the user to confirm. Example:

```
Based on your repos and tools, you look like a Developer — but I also found meeting notes and project specs suggesting Project Manager responsibilities. Is that right?
```

Options: List the detected roles individually + "Yes, both" + "Neither — I'll describe my role"

**Migrations (50–79% confidence):**
For ambiguous file assignments, ask where the file belongs. Example:

```
I found "API Design Notes.md" — it could belong to {{ORG}} Apps or Infrastructure. Where should it go?
```

Options: List candidate projects + "Skip this file"

After resolving all low-confidence items, update the confidence scores in `PROFILE` to reflect user answers (set confirmed items to 1.0, rejected items are removed).

---

### 2. Render the Discovery Report

Output the discovery report as structured text directly in the terminal. Use the exact section format below. Replace placeholder values with actual data from `PROFILE`.

```
═══════════════════════════════════════════════════════════
                    DISCOVERY REPORT
═══════════════════════════════════════════════════════════

YOUR PROFILE
─────────────────────────────────────────────────────────
  Role:        <role> (confidence: <N>%)
               <role_secondary, if present> (secondary)
  Evidence:    <role_evidence>
  Tools:       <comma-separated tools list>

PROPOSED PROJECTS (<count> items)
─────────────────────────────────────────────────────────
  #  Project              Description                          Confidence
  1  <name>               <description>                        <N>%
  2  <name>               <description>                        <N>% ⚠ low
  ...

PROPOSED PREFIXES (<count> standard + <count> custom)
─────────────────────────────────────────────────────────
  Standard mappings (already in your prefix table):
    <detected_type> → <PREFIX>

  Custom proposals:
    <PREFIX>  <description>  (evidence: <evidence>)

DAILY NOTE SECTIONS (<count> sections)
─────────────────────────────────────────────────────────
  • <section name>
  • <section name>
  ...

PROPOSED MIGRATIONS (<count> files)
─────────────────────────────────────────────────────────
  #  Source                              Destination                    Prefix
  1  <source path>                       <destination path>             <PREFIX>
  2  <source path>                       <destination path>             <PREFIX> ⚠ low
  ...

  (migrations copy files — originals are never moved or deleted)

═══════════════════════════════════════════════════════════
```

**Formatting rules:**

- Items with confidence 50–79% display a `⚠ low` flag (these should have been resolved in step 1, but flag any that remain).
- If a section has zero items, show the section header with "(none)" beneath it.
- Truncate long file paths to show `~/.../<last two segments>` if they exceed 50 characters.
- Show item counts in each section header.
- The report must be human-readable by someone unfamiliar with the system (per NFR-2).

---

### 3. Batch Approval

After rendering the report, use `AskUserQuestion` to ask for the user's decision:

```
How would you like to proceed?
```

**Options:**
1. `Approve all — build my vault with everything above`
2. `Review by section — I want to approve/reject individual sections`
3. `Start over — this doesn't look right, let me describe my work instead`

#### Option 1: Approve All

Accept the entire `PROFILE` as-is. All projects, prefixes, migrations, and daily note sections are approved. Proceed to step 4 (Persist Report) and step 5 (Build APPROVED_PROFILE).

#### Option 2: Review by Section

Present each section for individual approval using `AskUserQuestion`. Ask one section at a time, in this order:

**Projects:**
```
Proposed projects: <list project names>
```
Options: "Approve all projects", "Reject all projects", then one option per project to toggle: "Remove <project name>"

If the user removes specific projects, confirm the remaining set:
```
Keeping: <remaining projects>. Correct?
```
Options: "Yes", "Let me adjust again"

**Custom Prefixes:**
```
Custom prefixes proposed: <list PREFIX - description>
```
Options: "Approve all prefixes", "Reject all prefixes", then one option per prefix: "Remove <PREFIX>"

**Daily Note Sections:**
```
Daily note sections: <list sections>
```
Options: "Approve all sections", "Reject all sections", then one option per section: "Remove <section>"

**Migrations:**
```
Proposed migrations: <count> files to copy into your vault
```
Options: "Approve all migrations", "Skip all migrations", "Defer migrations — create a PIC for later"

If the user chooses "Defer migrations", set a `migrations_deferred: true` flag in the output. No migration files are approved, but SKILL.md Step 5 will create a "Migrate Existing Work" PIC.

#### Option 3: Start Over

Return control to SKILL.md with `APPROVED_PROFILE` set to:

```json
{
  "approved": false,
  "start_over": true
}
```

SKILL.md will route to the Blank-Slate Interview Fallback in profile-generator.md. After the interview produces a new `PROFILE`, SKILL.md will re-invoke this file (report-renderer.md) with the interview-generated profile.

**Do not proceed to steps 4 or 5 if the user chose Start Over.**

---

### 4. Persist the Discovery Report

Regardless of approval outcome (Approve All or Review by Section — but NOT Start Over), save the report as a file in the vault root.

**File path:** `<vault_root>/RE - Setup Discovery Report.md`

**File contents:**

```markdown
---
date created: <today's date YYYY-MM-DD>
tags: [setup, discovery]
category: Report
---

# RE - Setup Discovery Report

Generated by `/setup` auto-discovery on <today's date>.

## Profile

- **Role:** <role> (confidence: <N>%)
- **Secondary role:** <role_secondary or "None">
- **Evidence:** <role_evidence>
- **Tools detected:** <comma-separated tools>

## Proposed Projects

| # | Project | Description | Evidence | Confidence | Decision |
|---|---------|-------------|----------|------------|----------|
| 1 | <name> | <description> | <repos/evidence> | <N>% | <Approved/Rejected> |
| ... |

## Proposed Prefixes

### Standard Mappings

| Detected Type | Prefix | Confidence |
|---------------|--------|------------|
| <type> | <PREFIX> | <N>% |

### Custom Proposals

| Prefix | Description | Evidence | Decision |
|--------|-------------|----------|----------|
| <PREFIX> | <description> | <evidence> | <Approved/Rejected> |

## Daily Note Sections

| Section | Decision |
|---------|----------|
| <section> | <Approved/Rejected> |

## Proposed Migrations

| # | Source | Destination | Prefix | Confidence | Decision |
|---|--------|-------------|--------|------------|----------|
| 1 | <source> | <destination> | <PREFIX> | <N>% | <Approved/Rejected/Deferred> |

## Scan Metadata

- **Scan duration:** <scan_duration_ms>ms
- **Spotlight available:** <yes/no>
- **Blank slate:** no
- **Approval method:** <Approve All / Review by Section>
- **Report saved:** <today's date>
```

Use the Write tool to create this file.

---

### 5. Build APPROVED_PROFILE

Construct the `APPROVED_PROFILE` variable from the user's approval decisions. This is the output passed back to SKILL.md and consumed by all downstream steps (scaffolder, bases-generator, migrator, config generation, PIC creation, success report).

**Structure (Contract 3):**

```json
{
  "approved": true,
  "user_name": "<from PROFILE.user_name>",
  "role": "<PROFILE.role>",
  "role_secondary": "<PROFILE.role_secondary or null>",
  "role_confidence": <PROFILE.role_confidence>,
  "approved_projects": [
    {"name": "<project name>", "description": "<description>"}
  ],
  "rejected_projects": [
    {"name": "<project name>", "description": "<description>"}
  ],
  "approved_prefixes": [
    {"code": "<PREFIX>", "description": "<description>"}
  ],
  "approved_migrations": [
    {
      "source": "<absolute source path>",
      "destination": "<relative destination in vault>",
      "prefix": "<PREFIX>",
      "confidence": <N>
    }
  ],
  "rejected_migrations": [
    {
      "source": "<absolute source path>",
      "destination": "<relative destination>",
      "prefix": "<PREFIX>"
    }
  ],
  "migrations_deferred": <true if user chose "Defer migrations", false otherwise>,
  "approved_daily_note_sections": ["<section>", "..."],
  "profile_report_path": "RE - Setup Discovery Report.md"
}
```

**Field rules:**

- `approved` is `true` for both "Approve All" and "Review by Section" flows (even if the user rejected some items within sections).
- `approved_projects` contains only projects the user kept. `rejected_projects` contains any the user removed.
- `approved_prefixes` contains only custom prefixes. Standard prefix mappings are not included — they already exist in the prefix table.
- `approved_migrations` / `rejected_migrations` split based on user decisions. If migrations were deferred, both arrays are empty and `migrations_deferred` is `true`.
- `approved_daily_note_sections` contains only sections the user kept.
- `profile_report_path` is always `RE - Setup Discovery Report.md` (the file saved in step 4).

---

## Return

When complete, return `APPROVED_PROFILE` to the calling skill and continue with the next step.

If the user chose "Start Over", return `{"approved": false, "start_over": true}` — SKILL.md handles the fallback routing.
