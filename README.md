# Wolf Workflow Kit

**Built by Ellen Wolf — Grammarly People Ops**

An AI-powered operating system for People teams. Install once, use every day. Built on Claude Code with Granola, Slack, and Coda integrations.

> Adapted from the original workflow-kit architecture. All credit for the underlying system design goes to the source — this is the People Ops edition, rebuilt and branded for how Ellen Wolf runs.

---

## What It Does

Skills that work together across your day. Each one reads what the last one wrote — context builds instead of disappearing.

### Daily Workflow
| Skill | What it does |
|-------|-------------|
| `/orient` | Start of session — loads vault context, surfaces open pickups |
| `/pickup` | Load a specific PIC and get oriented on what's next |
| `/log-work` | Log what you just did to the daily note |
| `/closeout` | End of session — log work, create tomorrow's pickups |
| `/end-day` | Full day wrap — Granola sweep, Slack sweep, EOD + SOD reports |

### Meeting Workflow
| Skill | What it does |
|-------|-------------|
| `/meet` | Post-meeting capture — pulls Granola transcript, generates structured note with decisions |
| `/prep` | Pre-meeting brief — surfaces past context and open decisions |

### Project Workflow
| Skill | What it does |
|-------|-------------|
| `/create-spec` | Define a project, program, or initiative formally |
| `/review-spec` | 3-agent review team — catches gaps before you start building |
| `/plan-spec` | Turn a reviewed spec into a phased plan |
| `/create-agent` | Dispatch a specialized agent to do People Ops research or drafting autonomously |

### Context Management
| Skill | What it does |
|-------|-------------|
| `/park` | Set aside in-progress context to return to later |
| `/recap` | Summarize what's happened in the current session |
| `/create-pickup` | Create a PIC document for any open item |

### Communication
| Skill | What it does |
|-------|-------------|
| `/draft` | Write a Slack message, email, or talking points in your voice |
| `/weekly` | Roll up the week's notes into a summary for your manager update |

---

## Quick Install

**Requirements:** Mac with Homebrew, Obsidian (free), Claude Code CLI

```bash
git clone https://github.com/ellenwolf0-hub/wolf-workflow-kit.git
cd wolf-workflow-kit
bash setup.sh
```

**Total time:** under 5 minutes for the script. Budget 30 minutes for your first full session.

---

## The Ramp-Up Path

You don't need everything on day one. Here's how to build up to the full workflow:

**Week 1 — The Loop**
`/orient` every morning. `/meet` after every meeting. `/closeout` every evening. Get comfortable with how context carries forward before adding more.

**Week 2 — Add Pickups**
Use `/pickup` to load yesterday's context instead of re-explaining everything. Use `/log-work` mid-session, not just at closeout.

**Week 3 — Add Project Structure**
Use `/create-spec` for any initiative that needs more than a Slack thread. Use `/review-spec` before you present anything. Use `/plan-spec` to turn a spec into a task list.

**Week 4+ — Full Power**
`/prep` before every important meeting. `/draft` instead of staring at a blank message. `/create-agent` when you need a research pass done while you're in another meeting. `/end-day` to get a real EOD report with a full Granola + Slack sweep.

---

## Zapier Automations (Optional)

Connect skills to Slack and Coda without any code. See [`zapier/README.md`](zapier/README.md).

- `/prep` → Slack DM to you 10 minutes before a meeting
- `/meet` → decisions + action items posted to team Slack channel
- `/closeout` → work log row added to shared Coda tracker

---

## Vault Structure

```
vault/
├── agents.md          ← your profile and preferences (fill this in first)
├── lessons.md         ← context that builds over time
├── Daily/             ← DN - YYYY-MM-DD.md
├── Meetings/          ← MN - YYYY-MM-DD (Topic).md
├── Pickups/           ← PIC - Topic.md
├── Projects/          ← SPC, PL files for People Ops initiatives
└── templates/         ← note templates
```

---

## Built With

- [Claude Code](https://claude.ai/code) — the terminal interface
- [Granola](https://granola.ai) — meeting transcripts
- [Obsidian](https://obsidian.md) — the vault / memory layer
- [Zapier](https://zapier.com) — no-code automation bridge
- [Slack](https://slack.com) + [Coda](https://coda.io) — team output destinations
- [Warp](https://warp.dev) — recommended terminal (less intimidating for new users)
