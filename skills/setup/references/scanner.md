# Environment Scanner

**Called from:** SKILL.md Step 2
**Input:** None (scans the local machine)
**Output:** `SCAN_RESULT` — structured scan data containing discovered vaults, repos, tools, recent files, and metadata

---

## Instructions

Scan the user's local machine to discover their work environment. Run each section below using the Bash tool. Collect results into the `SCAN_RESULT` structure defined at the end.

**Timeout rule:** If the total scan takes longer than 60 seconds, stop scanning, return whatever results you have so far, and set `scan_timeout: true` in the output.

**Privacy rule (FR-8):** Throughout ALL scanning, never scan or read files from: `~/Library/` (except `~/Library/Mobile Documents/`), `~/.ssh/`, `~/.gnupg/`, `/tmp/`, any `node_modules/` directory, any `.git/objects/` directory. If you encounter a directory containing a `.env` file, do NOT read its contents.

Start by recording the current time for duration tracking:
```bash
date +%s%3N
```

---

### 1. Discover Obsidian Vaults

Search for directories containing `.obsidian/`:

```bash
find ~/Documents ~/Desktop "$HOME/Library/Mobile Documents" -maxdepth 5 -type d -name ".obsidian" 2>/dev/null
```

For each discovered vault (the parent directory of `.obsidian/`):

**a) Count markdown files:**
```bash
find "<vault_path>" -type f -name "*.md" 2>/dev/null | wc -l
```

**b) Sample frontmatter from the first 50 .md files.** Read the first 10 lines of each. If the file starts with `---`, parse the YAML for `tags` and `category` fields. Collect unique categories and tags.

**c) Detect naming prefixes in use:**
```bash
find "<vault_path>" -maxdepth 4 -type f -name "*.md" 2>/dev/null | xargs -I{} basename {} | grep -oE '^[A-Z]{2,4} - ' | sort | uniq -c | sort -rn | head -20
```

**d) Self-vault detection (FR-10a):** Compare each vault's absolute path against the current working directory. If the vault IS the target vault or is nested within it, set `is_target_vault: true`. Still extract profile signals (categories, prefixes, tags) but do NOT include it in migration candidates.

Record each vault:
```json
{
  "path": "/absolute/path",
  "file_count": 1200,
  "categories": ["Daily Note", "Spec", "Report"],
  "tags": ["daily", "meeting"],
  "prefixes_detected": ["DN", "SPC", "RE", "MN"],
  "is_target_vault": false
}
```

---

### 2. Discover Git Repositories

Search standard repo locations:

```bash
for dir in ~/Repos ~/Projects ~/Developer ~/Code ~/src ~/GitHub; do
  [ -d "$dir" ] && find "$dir" -maxdepth 3 -type d -name ".git" 2>/dev/null
done
```

For each repo (parent of `.git/`):

**a) Detect primary language** — check for package files and count source files by extension:
```bash
ls "<repo>"/{package.json,pyproject.toml,Cargo.toml,go.mod,Gemfile} 2>/dev/null
find "<repo>" -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" \) 2>/dev/null | wc -l
find "<repo>" -type f -name "*.py" 2>/dev/null | wc -l
find "<repo>" -type f -name "*.go" 2>/dev/null | wc -l
find "<repo>" -type f -name "*.rs" 2>/dev/null | wc -l
```
Highest file count = primary language. If `package.json` exists, read it for `name` and key dependencies.

**b) Identify project type:**
- `next.config.*` or `dependencies.next` → web app (Next.js)
- `Cargo.toml` → Rust project
- `go.mod` → Go project
- `pyproject.toml` → Python project
- `Dockerfile` present → containerized service
- Only `.md` files → documentation project

**c) Read README excerpt:**
```bash
head -50 "<repo>/README.md" 2>/dev/null || echo ""
```

**d) Recent commits (30 days):**
```bash
cd "<repo>" && git log --since='30 days ago' --format='%s' 2>/dev/null | head -20
```

Record each repo:
```json
{
  "path": "/absolute/path",
  "name": "repo-name",
  "primary_language": "TypeScript",
  "project_type": "web-app",
  "package_files": ["package.json"],
  "readme_excerpt": "...",
  "recent_commits": ["feat: add auth", "fix: CORS"]
}
```

---

### 3. Detect Development Tools

**CLI tools:**
```bash
for tool in node python3 go rustc docker kubectl brew git; do
  which "$tool" >/dev/null 2>&1 && echo "$tool"
done
```

**IDEs:**
```bash
ls /Applications/ 2>/dev/null | grep -iE 'visual studio code|cursor|xcode|intellij|webstorm|pycharm|sublime|nova' | sed 's/\.app$//'
```

---

### 4. Detect Productivity Tools

```bash
ls /Applications/ 2>/dev/null | grep -iE 'slack|teams|zoom|notion|linear|figma|excel|word|powerpoint|outlook|obsidian|todoist|asana|trello|discord' | sed 's/\.app$//'
```

---

### 5. Detect Cloud Storage Directories

Before scanning recent files, discover mounted cloud storage:

```bash
# OneDrive (Windows and Mac)
ls -d ~/OneDrive* "$HOME/OneDrive - "* 2>/dev/null
# Google Drive
ls -d ~/Google\ Drive "$HOME/Library/CloudStorage/GoogleDrive-"* 2>/dev/null
# Dropbox
ls -d ~/Dropbox 2>/dev/null
# iCloud Documents
ls -d "$HOME/Library/Mobile Documents/com~apple~CloudDocs" 2>/dev/null
```

**Windows-specific (PowerShell):**
```powershell
Get-ChildItem "$env:USERPROFILE\OneDrive*" -Directory -ErrorAction SilentlyContinue
```

Record discovered cloud dirs in `cloud_storage`:
```json
{
  "cloud_storage": [
    {"provider": "OneDrive", "path": "/Users/name/OneDrive - Flora Farms"},
    {"provider": "GoogleDrive", "path": "/Users/name/Google Drive"}
  ]
}
```

### 6. Scan Recent Files

Include cloud storage directories in the scan paths alongside Documents and Desktop.

**Try Spotlight first (macOS):**
```bash
mdfind 'kMDItemContentModificationDate >= $time.today(-30)' -onlyin ~/Documents -onlyin ~/Desktop <for each cloud_storage path: -onlyin "path"> 2>/dev/null | grep -iE '\.(md|docx|xlsx|pptx|pdf|csv)$' | head -100
```

**Fallback if mdfind fails, returns nothing, or on Windows:**
```bash
find ~/Documents ~/Desktop <cloud_storage paths> -maxdepth 4 -type f \( -name "*.md" -o -name "*.docx" -o -name "*.xlsx" -o -name "*.pptx" -o -name "*.pdf" -o -name "*.csv" \) -mtime -30 2>/dev/null | head -100
```

**Filter out** files already inside discovered vaults. For each file, check if its path starts with any vault path — if so, exclude it.

Set `spotlight_available` to `true` if mdfind worked, `false` otherwise.

Record each recent file:
```json
{
  "path": "/absolute/path/to/file.xlsx",
  "extension": "xlsx",
  "mtime": "2026-03-25",
  "in_vault": false
}
```

---

### 7. Detect System Language

```bash
# macOS
defaults read NSGlobalDomain AppleLanguages 2>/dev/null | head -3
# Windows (PowerShell)
# (Get-Culture).Name
```

Record as `system_language` (e.g., "es", "en", "fr"). This is used during profile generation to set the user's preferred language.

### 8. Blank-Slate Detection (FR-10)

After all scanning, check:
- `vaults` is empty AND
- `repos` is empty AND
- `dev_tools` has fewer than 2 entries AND
- `recent_files` is empty

If all true → set `blank_slate: true`. This tells SKILL.md to use the interview fallback.

---

### 7. Record Duration

```bash
date +%s%3N
```

Subtract the start time from Step 0 to get `scan_duration_ms`.

---

## Output Format — SCAN_RESULT

```json
{
  "vaults": [ ... ],
  "repos": [ ... ],
  "dev_tools": ["node", "python3", "docker", "git"],
  "ides": ["Visual Studio Code", "Cursor"],
  "productivity_apps": ["Slack", "Teams", "Obsidian"],
  "cloud_storage": [{"provider": "OneDrive", "path": "..."}],
  "recent_files": [ ... ],
  "system_language": "es",
  "scan_duration_ms": 18400,
  "scan_timeout": false,
  "blank_slate": false,
  "spotlight_available": true
}
```

---

## Return

When complete, return `SCAN_RESULT` to the calling skill and continue with the next step in SKILL.md.
