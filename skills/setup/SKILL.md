---
name: setup
description: >-
  First-run setup for the Workflow Kit vault. Scans the user's machine to auto-discover
  their work environment, builds a profile, scaffolds the vault with project folders,
  custom prefixes, and daily note templates. Use this skill when the user says "setup",
  "set up", "configure the vault", "first time setup", "run setup", or when this is a
  fresh clone of the workflow-kit repo with no workflow-kit.config.json.
---

# Workflow Kit — First-Run Setup

Set up a fresh Workflow Kit vault in 6 steps. This should take about 5 minutes.

## Step 1 — Check Prerequisites

Verify silently (don't ask the user):
- `uname` returns Darwin (macOS) or detect Windows via `$env:OS` or `OSTYPE`
- `which claude` or `where claude` succeeds
- `which git` or `where git` succeeds
- Obsidian installed (warn if missing but continue)

If a prerequisite is missing, **guide the user** instead of just failing:
- **Git missing (macOS):** "Run `xcode-select --install` to install git, then restart your terminal."
- **Git missing (Windows):** "Download git from https://git-scm.com, install it, then restart your terminal."
- **Claude Code not in PATH:** "Claude Code is installed but not in your system PATH. Try restarting your terminal. On Windows, you may need to add it to your PATH manually."
- **Obsidian missing:** Warn but continue. "You can install Obsidian from https://obsidian.md to browse your vault."

## Step 2 — Auto-Discovery

Use `AskUserQuestion` to ask: **"What's your name?"**

Then check the scanner's `system_language` result. If the system language is not English, ask: **"Your system language is [language]. Would you like me to communicate in [language]?"** If yes, save the preference to `CLAUDE.md` and switch immediately. Continue the rest of setup in the user's preferred language.

Then read `references/scanner.md` and follow its instructions.
Store the scan output as `SCAN_RESULT`.

If `SCAN_RESULT.blank_slate` is true:
  Read `references/profile-generator.md` → section "Blank-Slate Interview Fallback" and follow only those instructions.
Else:
  Read `references/profile-generator.md` and follow its instructions.

Store the profile output as `PROFILE`.

Read `references/report-renderer.md` and follow its instructions.
Store the approved profile as `APPROVED_PROFILE`.

If the user rejected the report and chose "start over":
  Read `references/profile-generator.md` → section "Blank-Slate Interview Fallback"
  Re-run `references/report-renderer.md` with the interview-generated profile.

Now execute vault scaffolding:

1. **Confirm project folder names** before scaffolding. Show the user the proposed project list with names and ask: "I'm going to create these project folders. Want to rename any before I set them up?" Present them as a numbered list. If names are abbreviations or unclear, suggest a clearer name: "I found 'ORF' - should I name this 'Operations - Restaurant Finance' or something else?" Always lead with your recommendation.
2. Read `references/scaffolder.md` and follow its instructions (uses `APPROVED_PROFILE`).
3. Read `references/bases-generator.md` and follow its instructions (uses `APPROVED_PROFILE`).
4. If `APPROVED_PROFILE.approved_migrations` is non-empty:
   Read `references/migrator.md` and follow its instructions.

**Presentation rule (applies to all user-facing choices in setup):** When presenting options, lead with a recommendation and a concrete example. Not "Option A: Date-based. Option B: Topic-based." Instead: "I'd suggest date-based folders (like `reports/2026-04-01/`) because it prevents version confusion. You can also do topic-based if you prefer. Which works better for you?"

## Step 3 — Generate Config

Detect the vault root (the directory containing this SKILL.md's parent `skills/` folder, or the current working directory if it contains `CLAUDE.md`).

### 3a. Vault config

Create `workflow-kit.config.json` in the vault root:

```json
{
  "user_name": "<from APPROVED_PROFILE.user_name>",
  "role": "<from APPROVED_PROFILE.role>",
  "role_secondary": "<from APPROVED_PROFILE.role_secondary, or null>",
  "role_confidence": <from APPROVED_PROFILE.role_confidence>,
  "vault_root": "<absolute path to vault>",
  "setup_date": "<today YYYY-MM-DD>",
  "repo_url": "https://github.com/YOUR_USERNAME/workflow-kit",
  "profile_ref": "<from APPROVED_PROFILE.profile_report_path>",
  "projects": ["<from APPROVED_PROFILE.approved_projects[].name>"],
  "tools": ["<detected tools from scan>"],
  "custom_prefixes": ["<from APPROVED_PROFILE.approved_prefixes[].code>"]
}
```

### 3b. Runtime path config

Create `~/.claude/wfk-paths.json`. This file tells all WFK skills where vault directories are. Skills read it at startup so they work regardless of vault naming or structure.

```json
{
  "vault_root": "<absolute path to vault>",
  "paths": {
    "daily_notes": "<notes_dir>/Daily",
    "meetings": "<notes_dir>/Meetings",
    "reports": "<notes_dir>/Reports",
    "pickups": "<notes_dir>/Pickups",
    "work_logs": "<notes_dir>/Work Logs",
    "weekly": "<notes_dir>/Weekly",
    "projects": "02_Projects",
    "operations": "03_Operations",
    "reference": "04_Reference",
    "system": "05_System",
    "media": "06_Media"
  }
}
```

Path values are relative to `vault_root`. `<notes_dir>` defaults to `01_Notes` but should match the scaffolder's output if the user renamed it during Step 2.

**If `~/.claude/wfk-paths.json` already exists** (re-running setup), back up the existing file to `~/.claude/wfk-paths.json.bak` before overwriting, and warn the user.

> Note: `setup.sh` also writes a default `wfk-paths.json` on install (write-only-if-absent) so the kit works before `/setup` is ever run. This step refines it with the interview-confirmed vault layout.

## Step 4 — Install Skills and Agents

Copy every skill directory from the vault's `skills/` folder to `~/.claude/skills/`, and every agent profile from `agents/` to `~/.claude/agents/`:

```bash
for skill_dir in <vault_root>/skills/*/; do
  skill_name=$(basename "$skill_dir")
  cp -r "$skill_dir" ~/.claude/skills/"$skill_name"
done

if [ -d <vault_root>/../agents ] || [ -d <repo_root>/agents ]; then
  mkdir -p ~/.claude/agents
  cp <repo_root>/agents/*.md ~/.claude/agents/ 2>/dev/null || true
fi
```

Count and report: "Installed {N} skills and {M} agents."

## Step 4.5 — Save Onboarding Preferences Log

Create a preferences log at `<vault_root>/04_Reference/REF - Onboarding Preferences.md` that captures every preference expressed during setup:

```markdown
---
date created: <today>
tags: [reference, onboarding, preferences]
category: Reference
---

# Onboarding Preferences

Captured during setup on <today>. Future sessions should read this file to avoid re-asking.

## Language
- Preferred language: <language or "English (default)">

## Role
- Role: <APPROVED_PROFILE.role>
- Confidence: <APPROVED_PROFILE.role_confidence>

## Projects
<list of approved project names>

## File Organization
- Cloud storage: <provider and path, or "local only">
- Naming: <any preferences expressed during folder confirmation>

## Other Preferences
<any other preferences expressed during the session>
```

This file is the solution to the "preferences lost between sessions" problem. Future `/orient` sessions should read it.

## Step 5 — Create Onboarding Pickups

Create files in `<vault_root>/Notes/Pickups/`:

**Priority order matters.** `/pickup` should offer these in order. The first PIC should match the user's most immediate need, not a generic tutorial.

### PIC - Review and Organize Your Files.md

**Only create this PIC if** the scan found files to migrate or the user has cloud storage with work files. This is the most common first-day need - users want to tame existing chaos before creating new content. **This should be priority 1 when it applies.**

```markdown
---
date created: <today>
tags: [pickup, onboarding]
category: Pickup
status: open
priority: 1
---

# Review and Organize Your Files

Setup found files across your system. Let's get them organized before diving into new work.

## What to Do

Tell Claude: "Let's organize my files" or run `/intake`.

Point Claude at a folder (Documents, OneDrive, etc.) and it will:
1. **Scan** for work files (docs, spreadsheets, notes, PDFs)
2. **Propose** where each belongs in your vault's project structure
3. **Copy** files into the right location (originals are never moved)
4. **Add metadata** so Obsidian can track them

Start with one folder. See how it feels. Then do more.
```

### PIC - Customize Your Role Profile.md

Always create this PIC. **Priority 1 if no files to organize, otherwise priority 2.**

```markdown
---
date created: <today>
tags: [pickup, onboarding]
category: Pickup
status: open
priority: 1
---

# Customize Your Role Profile

Your vault was set up with the **<APPROVED_PROFILE.role>** role (confidence: <APPROVED_PROFILE.role_confidence>). The auto-discovery system built your initial profile from what it found on your machine. Let's refine it to match how you actually work.

Your discovery report is saved at: [[<APPROVED_PROFILE.profile_report_path>]]

## What to Do

Tell Claude: "Let's customize my role profile."

Claude will ask you about:
- **Your responsibilities** — What do you own? What do you deliver?
- **Your tools** — What software, services, and systems do you use daily?
- **Your team** — Who do you work with? Who do you report to?
- **Your preferences** — How do you like information presented? Detailed or concise? Tables or prose?

Based on your answers, Claude updates the vault's agent configuration so future sessions are tailored to you.

## When You're Done

This pickup closes automatically when your profile is saved. You'll notice Claude adapts its communication style and suggestions going forward.

**Next:** Work through "PIC - Migrate Existing Work" (if created) or jump straight to "PIC - Your First Spec."
```

### PIC - Your First Spec.md

Always create this PIC. Priority is always last (2 or 3 depending on whether the file review PIC was created). If `APPROVED_PROFILE.approved_projects` is non-empty, reference the first project as a suggested spec target.

```markdown
---
date created: <today>
tags: [pickup, onboarding]
category: Pickup
status: open
priority: 3
---

# Your First Spec

This is where the system clicks. You're going to describe something you actually want to do, and Claude will help you plan it out.

## What to Do

1. **Think of something you need to do.** A project, a process improvement, a document to write, a feature to build — anything structured. <If projects were discovered: "Your vault already has a **<first project name>** project folder — you could start there.">

2. **Tell Claude:** "I want to create a spec for..." or run `/create-note SPC`

3. **Answer Claude's questions.** It will interview you about what you're trying to accomplish, who it's for, what success looks like, and what could go wrong. This usually takes 5-10 minutes.

4. **Review the spec.** Claude produces a structured document with requirements, acceptance criteria, and open questions. Read it — does it capture what you had in mind?

5. **(Optional) Run the review.** Tell Claude `/review-spec` and it dispatches a 3-agent team to check the spec for gaps and risks. This is powerful for complex work but optional for simple tasks.

6. **(Optional) Create the plan.** Tell Claude `/create-note PL` and it breaks the spec into phases with tasks and milestones.

## Why This Matters

The Spec > Plan pipeline is the core of this system. Once you've done it once, you'll use it for everything — and Claude remembers the context across sessions.
```

## Step 6 — Report Success

Tell the user:

```
Setup complete!

- Profile: <APPROVED_PROFILE.role> (<APPROVED_PROFILE.role_confidence * 100>% confidence)
- Projects created: <count of APPROVED_PROFILE.approved_projects> (<list names>)
- Custom prefixes added: <count> (<list codes>)
- Config saved to <vault_root>/workflow-kit.config.json
- Discovery report saved to <APPROVED_PROFILE.profile_report_path>
- {N} skills installed to ~/.claude/skills/
- <2 or 3> onboarding pickups created in Notes/Pickups/
<If migration ran:>
- <count> files migrated — see Notes/migration-log-<today>.md

Next steps:
1. Open this folder in Obsidian (if you haven't already) and click Trust
2. Type /pickup to start your first onboarding task
```
