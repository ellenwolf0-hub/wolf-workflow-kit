# Profile Generator

**Called from:** SKILL.md Step 2
**Input:** `SCAN_RESULT` — structured scan output from `references/scanner.md`
**Output:** `PROFILE` — structured profile object for the report renderer

---

## Instructions

Process `SCAN_RESULT` through the following stages in order. Build the `PROFILE` object incrementally — each stage adds fields to the output.

---

### Stage 1 — Infer Roles

Analyze `SCAN_RESULT` for role signals. Score each role independently (a user can match multiple).

#### Role Signal Table

| Role | Strong Signals (≥30% weight each) | Moderate Signals (15% each) | Weak Signals (5% each) |
|------|-----------------------------------|----------------------------|------------------------|
| **Developer** | Git repos present, IDE installed (VS Code, Cursor, Xcode, IntelliJ), CLI dev tools (`node`, `python`, `go`, `rust`, `docker`, `kubectl`) | Package files in repos (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`), recent commits in last 30 days | Terminal app present, Homebrew installed |
| **Manager** | No repos AND productivity tools dominant (≥3 of: Teams, Slack, Zoom, Outlook), meeting-heavy apps installed | Existing vault with categories like "Meeting", "Initiative", "Delegation" | Calendar apps, PowerPoint/Keynote present |
| **Analyst** | Data tools (Excel, Tableau, Jupyter, R Studio), Python present WITHOUT web frameworks | Spreadsheet-heavy recent files (`.xlsx`, `.csv`), SQL tools installed | Statistics/math packages detected in repos |
| **Operations** | Checklist/SOP documents in recent files, process-oriented vault categories | Vendor/supplier files detected, inventory or scheduling tools | PDF-heavy recent files, forms and templates |

#### Scoring Algorithm

1. For each role, sum the weights of all matching signals from `SCAN_RESULT`
2. Normalize to 0.0–1.0 scale
3. The highest-scoring role becomes `role` (primary)
4. If a second role scores ≥ 0.40 AND is within 0.30 of the primary score, it becomes `role_secondary` (compound role per FR-12)
5. If no second role qualifies, set `role_secondary` to `null`
6. Set `role_confidence` to the primary role's normalized score

#### Evidence String

Build `role_evidence` as a human-readable sentence summarizing the key signals. Example:
> "3 active repos ({{MONOREPO_NAME}}, workflow-kit, radio-tracker); existing vault with specs/plans/reports structure; VS Code and Docker installed"

Include only the top 3–5 most significant signals — don't list every detected item.

---

### Stage 2 — Cluster Projects

Apply entity definitions from the spec to group discovered repos into projects.

#### What Counts as a Project

A project is identified by the presence of any of: `.git/`, `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, or `Makefile` at the directory root.

#### Clustering Rules (apply in order)

1. **Name-prefix grouping:** Repos sharing a name prefix (e.g., `{{MONOREPO_NAME}}`, `flora-admin`, `flora-hub`) → group under a single umbrella project. Use the shared prefix as the project name (e.g., "Flora"). Strip common suffixes like `-monorepo`, `-app`, `-api`, `-web`, `-admin` when naming.

2. **Parent-directory grouping:** Repos in the same parent directory that don't share a name prefix → candidate group. Mark these with `"candidate_group": true` so the report renderer presents them as an option, not a recommendation.

3. **Monorepo detection:** A single `.git/` directory with multiple `package.json` files or workspace configs (`pnpm-workspace.yaml`, `lerna.json`, Cargo workspace in `Cargo.toml`, Go workspace in `go.work`) → one project with sub-areas. Detect sub-areas from workspace structure and list them in the project description.

4. **Orphan repos:** Repos that don't match any grouping pattern → standalone projects. Use the repo directory name (cleaned up: strip hyphens, title-case) as the project name.

#### Project Description Generation

For each project, generate a one-line description by combining:
- Primary language(s) from `SCAN_RESULT.repos[].primary_language`
- Project type from `SCAN_RESULT.repos[].project_type`
- README excerpt from `SCAN_RESULT.repos[].readme_excerpt` (use first meaningful sentence if available)
- Recent commit themes (summarize `SCAN_RESULT.repos[].recent_commits` into a 3–5 word activity description)

Format: `"<What it is> — <evidence summary>"`
Example: `"Full-stack app suite — found 3 repos matching flora-* in ~/Repos/"`

#### Confidence Scoring for Projects

- Name-prefix group with 2+ repos: **0.90–0.95**
- Monorepo with clear workspace config: **0.90–0.95**
- Parent-directory candidate group: **0.55–0.70** (flag as low confidence)
- Orphan repo with README: **0.80–0.85**
- Orphan repo without README: **0.65–0.75**

#### Existing Vault Projects

If `SCAN_RESULT.vaults[]` contains vaults with project-like directory structures (subdirectories under a `Projects/` folder), cross-reference with discovered repos:
- If a vault project matches a repo-based project → merge, prefer the repo-based evidence
- If a vault project has no matching repo → include as a standalone project with description derived from vault structure, confidence 0.60–0.70

---

### Stage 3 — Map Prefixes

Match detected document types from `SCAN_RESULT` to standard prefixes.

#### Standard Prefix Glossary

| Prefix | Type |
|--------|------|
| `DN` | Daily Note |
| `MN` | Meeting Note |
| `RE` | Report |
| `SPC` | Spec |
| `PL` | Plan |
| `REF` | Reference doc |
| `PIC` | Pickup |
| `IN` | Initiative log |
| `TR` | Transcript |
| `TS` | Transcript Summary |
| `QA` | Quality Audit |
| `AIS` | AI Meeting Summary |
| `WS` | Weekly Summary |
| `TA` | Tasting Note |
| `LOG` | Debug/Pipeline Log |
| `ST` | Status/Tool doc |
| `FR` | Feature Request |
| `CO` | Comp (competitor research) |
| `WL` | Work Log |
| `ARE` | Agent Report |
| `RET` | Retrospective |
| `HAN` | Handoff |
| `DD` | Design Discussion |
| `SO` | Structure Outline |
| `IR` | Incident Report |

#### Reserved Prefix List

These prefixes are reserved and must NEVER be proposed as custom prefixes:
`DN`, `MN`, `RE`, `SPC`, `PL`, `REF`, `PIC`, `IN`, `TR`, `TS`, `QA`, `AIS`, `WS`, `TA`, `LOG`, `ST`, `FR`, `CO`, `WL`, `ARE`, `RET`, `HAN`, `DD`, `SO`, `IR`

#### Mapping Process

1. **From existing vaults:** If `SCAN_RESULT.vaults[].prefixes_detected` lists prefixes already in use, map them 1:1 to the standard glossary. These get confidence ≥ 0.95 (already validated by usage).

2. **From recent files:** Classify `SCAN_RESULT.recent_files[]` by extension and filename patterns:
   - `.xlsx` / `.csv` with "budget" in name → financial document type
   - `.pptx` / `.key` → presentation type
   - `.docx` with "SOP" in name → standard operating procedure type
   - `.md` files → analyze filename for prefix patterns (e.g., `MN - `, `RE - `)
   - `.pdf` files → classify by filename keywords

3. **Standard match:** If a detected document type maps cleanly to a standard prefix → add to `prefix_mappings` with the standard prefix and confidence 0.85–0.95.

4. **Custom prefix needed:** If a detected document type has no standard match:
   - Propose a 2–3 letter uppercase prefix
   - Check against the reserved list — if collision, pick the next logical abbreviation
   - Add to `custom_prefixes` with: `code`, `description`, `evidence` (which files triggered this)
   - Confidence for custom prefixes: 0.60–0.80 (always lower than standard matches since they need user validation)

#### Custom Prefix Naming Rules

- 2–3 uppercase letters
- Derived from the document type name (e.g., "Budget" → `BDG`, "Recipe" → `RX`, "Invoice" → `INV`, "Client Note" → `CLN`, "SOP" → `SOP`)
- Must not collide with any entry in the reserved list
- If the obvious abbreviation collides, append or shift a letter (e.g., if `IN` is taken, use `INV` for invoice)

---

### Stage 4 — Score Confidence

Apply confidence thresholds to every item in the profile. Each item already has a confidence score from its stage — now apply display rules.

#### Threshold Table

| Confidence | Behavior |
|-----------|----------|
| ≥ 0.80 | Recommend in the discovery report — no qualification needed |
| 0.50–0.79 | Flag with "low confidence" label; prepare a targeted `AskUserQuestion` for the report renderer to ask (e.g., "I found 5 repos but can't tell which are active — which do you work on?") |
| < 0.50 | Suppress from the report entirely; prepare a general question for the report renderer if the suppressed item might be important |

#### Targeted Questions

For each item scoring 0.50–0.79, generate a `targeted_question` string that:
- States what was found and what's uncertain
- Asks a specific question to resolve the ambiguity
- Can be passed directly to `AskUserQuestion` by the report renderer

Examples:
- Project grouping 0.65: "I found repos `api-server` and `api-docs` in the same directory. Should these be one project or separate?"
- Role inference 0.55: "I see both data analysis tools and some code repos. Do you primarily write code, analyze data, or both?"
- Custom prefix 0.70: "I found several budget spreadsheets. Should I create a `BDG` prefix for budget documents?"

---

### Stage 5 — Propose Daily Note Sections

Based on inferred roles, propose sections for the daily note template.

#### Role-to-Section Mapping

| Role | Sections |
|------|----------|
| **Developer** | PRs/Commits, Active Projects, Code Review Queue |
| **Manager** | Delegations, Action Items, Meetings/Calls, Direct Reports |
| **Analyst** | Research Queue, Findings, Data Sources, Analysis Notes |
| **Operations** | Checklists, Vendor Contacts, Process Updates, Inventory |

#### Universal Sections (always included)

- Worked On (newest-first sub-headings with bullets)
- Meetings/Calls

#### Compound Role Handling

For compound roles, merge the sections from both roles. Remove duplicates (e.g., if both roles include "Meetings/Calls", include it only once). Order: universal sections first, then primary role sections, then secondary role sections.

#### Per-Project Sections

If there are ≤ 5 approved projects, propose a sub-section under "Active Projects" for each. If > 5, propose only the top 3 by recent commit activity and group the rest under "Other Projects."

---

### Stage 6 — Propose Migrations

For each non-target vault and for recent files outside any vault, propose migration entries.

#### Migration Rules

1. **Skip target vault files:** If `SCAN_RESULT.vaults[].is_target_vault` is true, do NOT propose migration for files in that vault. Extract profile signals only (per FR-10a).

2. **Non-target vault files:** For each file in a non-target vault modified in the last 30 days:
   - Classify the file by prefix (using Stage 3 mappings)
   - Assign to a project (using Stage 2 clusters) based on file path, tags, or content
   - Set destination path: `Projects/<project_name>/<file_with_prefix>.md`
   - If classification or project assignment is ambiguous, add to `ambiguous_files` instead

3. **Recent files outside vaults:** For each entry in `SCAN_RESULT.recent_files[]` where `in_vault` is false:
   - Classify by extension and filename
   - Assign to project if possible, otherwise propose placement in a general area
   - Non-markdown files (`.xlsx`, `.pdf`, `.docx`) go to `Projects/<project>/data.nosync/` if large or `Projects/<project>/Data/` if small (< 1MB)

4. **Ambiguous files:** If a file could belong to multiple projects or its document type is unclear:
   - Add to `ambiguous_files` array with the candidate projects/prefixes
   - The report renderer will present these as choices to the user

#### Migration Entry Format

```json
{
  "source": "/absolute/path/to/file",
  "destination": "Projects/<project>/<prefix> - <filename>",
  "prefix": "<PREFIX>",
  "confidence": 0.75,
  "ambiguous": false
}
```

---

### Build the PROFILE Object

Assemble all stage outputs into the final `PROFILE` structure:

```json
{
  "user_name": "<from SCAN_RESULT or previously captured>",
  "role": "<primary role>",
  "role_secondary": "<secondary role or null>",
  "role_confidence": 0.88,
  "role_evidence": "<human-readable evidence string>",
  "projects": [
    {
      "name": "<project name>",
      "description": "<one-line description with evidence>",
      "repos": ["<repo-dir-name>"],
      "confidence": 0.95,
      "candidate_group": false,
      "targeted_question": null
    }
  ],
  "tools": ["<detected tool names>"],
  "prefix_mappings": [
    {
      "detected_type": "<document type>",
      "prefix": "<standard prefix or null>",
      "proposed_custom": null,
      "confidence": 0.90
    }
  ],
  "custom_prefixes": [
    {
      "code": "<PREFIX>",
      "description": "<what this prefix covers>",
      "evidence": "<files that triggered this>"
    }
  ],
  "proposed_daily_note_sections": ["<section name>"],
  "proposed_migrations": [
    {
      "source": "<absolute path>",
      "destination": "<relative vault path>",
      "prefix": "<PREFIX>",
      "confidence": 0.75,
      "ambiguous": false
    }
  ],
  "ambiguous_files": [
    {
      "source": "<absolute path>",
      "candidate_projects": ["<project A>", "<project B>"],
      "candidate_prefixes": ["<PREFIX_A>", "<PREFIX_B>"],
      "question": "<AskUserQuestion text>"
    }
  ]
}
```

---

## Blank-Slate Interview Fallback

This section is invoked when `SCAN_RESULT.blank_slate` is true OR when the user rejected the discovery report and chose "start over."

### When to Use

- `SCAN_RESULT.blank_slate` is `true` (scanner found nothing meaningful — no vaults, no repos, no detectable tools)
- User rejected the discovery report during the approval step

### Interview Process

Ask questions **one at a time** using `AskUserQuestion`. Do not bundle multiple questions.

**Question 1:**
```
What kind of work do you do? Describe your role and daily activities in a sentence or two.
(Examples: "I'm a frontend developer working on React apps", "I manage a restaurant and track inventory", "I'm a data analyst working with financial reports")
```

**Question 2:**
```
What tools do you use daily? List the apps, editors, or services you rely on most.
(Examples: "VS Code, GitHub, Slack, Docker", "Excel, Teams, Outlook, PowerPoint", "Jupyter, Python, Tableau, SQL")
```

**Question 3:**
```
What projects or areas of work are you focused on right now? List 1–5 things you're actively working on.
(Examples: "A mobile app for our restaurant, migrating our database to Postgres", "Q1 budget planning, vendor negotiations", "Customer churn analysis, building a dashboard")
```

### Generating PROFILE from Answers

After collecting answers, build the `PROFILE` object by inference:

1. **Role inference:** Map the work description to the closest role(s) using the same role categories (Developer, Manager, Analyst, Operations). Set confidence to 0.70 (interview-based, lower than scan-based).

2. **Tools:** Parse the tools answer into a list. Match against known tool categories to reinforce role inference.

3. **Projects:** Parse the projects answer into individual projects. For each:
   - Use the user's own name/description
   - Set `repos` to empty (no scan data)
   - Set confidence to 0.75 (user-stated, but unverified)
   - Generate a simple description from the user's words

4. **Prefixes:** Propose only standard prefixes relevant to the inferred role. No custom prefixes from interview alone (not enough signal).

5. **Daily note sections:** Use the role-to-section mapping from Stage 5.

6. **Migrations:** Empty — no source files to migrate in a blank-slate scenario.

Set all evidence strings to reference the interview: `"Based on interview: user described themselves as..."`.

---

## Return

When complete, return `PROFILE` to the calling skill and continue with the next step.
