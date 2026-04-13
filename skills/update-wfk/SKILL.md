---
name: update-wfk
description: >-
  Sync the Wolf Workflow Kit between your local machine and GitHub.
  Pull new skills and updates from the repo. Push local improvements back.
  Use when the user says "/update-wfk", "update the kit", "sync my skills",
  "pull the latest skills", or "push my improvements".
---

# Update WFK — Sync Kit with GitHub

Keep your local Wolf Workflow Kit in sync with the GitHub repo. Pull updates to
get new skills and fixes. Push improvements to contribute them back.

**Arguments:** $ARGUMENTS — Optional: `pull`, `push`, `status`, or nothing (will ask).

## Step 0 — Check wfk_role

Read `agents.md` in the vault. Look for a `Kit Role:` field.

- `Kit Role: user` (default) → default action is **pull**
- `Kit Role: developer` → default action is **push**

If no Kit Role is set, default to `user`.

## Step 1 — Determine Operation

If $ARGUMENTS specifies an operation, use it.

Otherwise ask:
> "What do you want to do?
> 1. **Pull** — get the latest skills from GitHub
> 2. **Push** — send my local improvements to GitHub
> 3. **Status** — see what's changed locally vs the repo"

## Pull Flow

### P1 — Check Current State

```bash
cd ~/Documents/wolf-workflow-kit
git status
git log --oneline -5
```

Report: which files have local changes, current branch, commits ahead/behind.

### P2 — Fetch and Preview

```bash
git fetch origin main
git log HEAD..origin/main --oneline
```

Show the user what's incoming: new skills, updated SKILL.md files, README changes.

### P3 — LOCAL.md Protection

Before pulling, check each skill directory for a `LOCAL.md` file.
These contain user customizations that must be preserved across updates.

If any `LOCAL.md` files exist, note them: "I'll preserve your LOCAL.md customizations
in: [list of skills]"

### P4 — Merge agents.md and vault files safely

For `vault/agents.md` and `vault/lessons.md`: **never overwrite**.
These are user data. Only notify if the repo has template changes they might want
to incorporate manually.

For SKILL.md files with no LOCAL.md: update freely.
For SKILL.md files with a LOCAL.md: merge changes above the LOCAL.md marker,
preserve everything below it.

### P5 — Pull

```bash
git pull origin main
```

If conflicts: report them clearly and resolve file by file, always preferring
user data over repo content for vault files.

### P6 — Reinstall Skills

After pulling, reinstall updated skills to Claude's skills directory:

```bash
bash setup.sh --skills-only
```

If `--skills-only` flag doesn't exist, copy manually:
```bash
for skill_dir in skills/*/; do
  skill_name=$(basename "$skill_dir")
  if [ -f "$skill_dir/SKILL.md" ]; then
    mkdir -p "$HOME/.claude/skills/$skill_name"
    cp "$skill_dir/SKILL.md" "$HOME/.claude/skills/$skill_name/SKILL.md"
  fi
done
```

Report: which skills were updated.

## Push Flow (for contributors)

### PU1 — Check Changes

```bash
git diff --name-only
git status
```

Show user exactly what will be pushed.

### PU2 — Classify Changes

Triage each changed file:
- **Safe to push:** new or improved SKILL.md files, README updates, vault templates
- **Review needed:** changes to setup.sh, core config files
- **Never push:** vault files with personal data (agents.md with real name/priorities,
  lessons.md with your specific lessons, meeting notes, pickup docs, daily notes)

Confirm with user before proceeding.

### PU3 — Commit and Push

```bash
git add [approved files only]
git commit -m "[descriptive commit message]"
git push origin main
```

## Status Flow

```bash
cd ~/Documents/wolf-workflow-kit
git status
git log --oneline -10
```

Report:
- Skills installed locally vs in repo
- Files modified locally
- How far ahead/behind the remote
