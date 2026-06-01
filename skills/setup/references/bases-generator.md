# Bases Generator

**Called from:** SKILL.md Step 2 (after scaffolder.md completes)
**Input:** `APPROVED_PROFILE` — approved profile with `role`, `role_secondary`, `approved_projects[]`, `vault_root`
**Output:** None (side effects: `.base` files written, daily note template updated)

---

## Instructions

### 1. Locate Summaries Directory

Check `<vault_root>/05_System/Summaries/`. If absent, check `<vault_root>/Summaries/`. If neither exists, create `<vault_root>/05_System/Summaries/`. All `.base` files go here.

---

### 2. Universal Bases (Always Generated)

**`Recent Reports.base`:**
```yaml
properties:
  date created:
    displayName: Created
views:
  - type: table
    name: Recent Reports
    filters:
      and:
        - or:
            - Category == "Report"
            - Category == "Incident Report"
        - '!file.name.contains("Template")'
        - '!file.path.contains("data.nosync")'
        - now() - file.mtime < "7d"
    sort:
      - property: date created
        direction: DESC
    limit: 10
    columnSize:
      file.name: 476
      note.date created: 130
```

**`Open PICs.base`:**
```yaml
properties:
  status:
    displayName: Status
  project:
    displayName: Project
  date created:
    displayName: Created
views:
  - type: table
    name: Open PICs
    filters:
      and:
        - Category == "Pickup"
        - or:
            - status == "open"
            - status == "picked-up"
    sort:
      - property: file.ctime
        direction: DESC
    limit: 10
    columnSize:
      file.name: 350
      note.status: 80
      note.project: 120
      note.date created: 130
```

---

### 3. Per-Project Bases

For each entry in `APPROVED_PROFILE.approved_projects`, write `<ProjectName> Activity.base`.

Template (replace `<ProjectFolderName>` with the exact folder name under `02_Projects/`):
```yaml
properties:
  date created:
    displayName: Created
  category:
    displayName: Type
views:
  - type: table
    name: <ProjectName> — Recent Activity
    filters:
      and:
        - file.path.contains("02_Projects/<ProjectFolderName>")
        - '!file.name.contains("Template")'
        - '!file.path.contains("data.nosync")'
        - now() - file.mtime < "14d"
    sort:
      - property: file.mtime
        direction: DESC
    limit: 15
    columnSize:
      file.name: 400
      note.category: 120
      note.date created: 130
```

---

### 4. Role-Specific Daily Note Sections

| Role | Sections to Add |
|------|----------------|
| Developer | `## PRs/Commits`, `## Active Projects` |
| Manager | `## Delegations`, `## Action Items` |
| Analyst | `## Research Queue`, `## Findings` |
| Operations | `## Checklists`, `## Vendor Contacts` |

For compound roles (`role` + `role_secondary`), merge both sets — primary role sections first.

---

### 5. Update the Daily Note Template

Read `<vault_root>/05_System/Templates/Daily Note Template.md` (fallback: `<vault_root>/Templates/Daily Note Template.md`).

Rewrite the template to match this structure exactly:

```markdown
---
date created: {{date:YYYY-MM-DD}}
tags: daily
category: Daily Note
---
# {{date:dddd, MMMM D, YYYY}}

## Recent Reports
![[Recent Reports.base]]

## Open PICs
![[Open PICs.base]]

[one block per approved project:]
## <ProjectName>
![[<ProjectName> Activity.base]]

---
## TODO
- [ ]

---
## Meetings/Calls
-

---
## Worked on
-

---
[role-specific sections from §4 — one `##` heading per section]

---
## Notes
-
```

If the Bases/Dataview plugin is not confirmed installed, add this comment after the last base embed:
```
<!-- Note: .base files require the Bases or Dataview plugin in Obsidian to render. -->
```

Preserve any existing frontmatter fields not listed above. Do not overwrite content already in `## Worked on`, `## TODO`, or `## Notes` if those sections contain user data (they normally won't in a template, but check).

---

## Return

When all `.base` files are written and the template is updated, return to the calling skill. Log internally: universal bases written (count), per-project bases written (count), template status (updated / already current).
