# People Team Workflow Kit

An AI workflow system for HR and People Ops teams — built for Grammarly's People team, adaptable for any org.

Install in under 5 minutes. Run your first daily loop in under 30 minutes.

---

## What It Does

Six skills that work together across your day:

| Skill | What it does | When to use |
|-------|-------------|-------------|
| `/orient` | Loads your context, surfaces open pickups | Start of every session |
| `/meet` | Captures meeting decisions and action items from Granola | After any meeting |
| `/closeout` | Logs your work, creates tomorrow's pickups | End of every session |
| `/prep` | Pre-meeting brief with context and open decisions | Before important meetings |
| `/draft` | Drafts comms in your voice from meeting context | When writing Slack/email/docs |
| `/weekly` | Rolls up your week into a summary | Friday afternoons |

Skills share context — what `/meet` captures, `/prep` surfaces next time. What `/closeout` saves, `/orient` finds tomorrow.

---

## Quick Install

**Requirements:** Mac with Homebrew, Obsidian (free), Claude Code CLI

```bash
git clone https://github.com/YOUR-ORG/people-workflow-kit.git
cd people-workflow-kit
bash setup.sh
```

The script will:
1. Install Claude Code CLI (if not already installed)
2. Walk you through MCP auth (Slack, Granola, Coda, Zoom)
3. Open your pre-configured Obsidian vault
4. Run your first `/orient` to confirm everything works

**Total install time:** under 5 minutes for the script. Budget 30 minutes for setup + first session.

---

## First Run

After install, open a terminal in the `vault/` directory and run:

```
/orient
```

Claude will ask you to fill in your name, role, and team in `agents.md`. Do that once — it personalizes every session from then on.

---

## Zapier Automations (Optional but Powerful)

Connect your skills to Slack and Coda without any code. See [`zapier/README.md`](zapier/README.md) for setup.

What's possible:
- `/prep` → Slack DM to you 10 minutes before a meeting
- `/meet` → decisions + action items auto-posted to your team Slack channel
- `/closeout` → work log auto-added to shared Coda tracker

---

## Cheat Sheet

See [`CHEATSHEET.md`](CHEATSHEET.md) for a one-page reference you can print and keep at your desk.

---

## For IT / Setup Help

All secrets are stored via environment variables or MCP auth flows — nothing is hardcoded in this repo. See `setup.sh` for details.
