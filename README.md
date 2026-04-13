# Wolf Workflow Kit

**Built by Ellen Wolf — Grammarly People Ops**

An AI-powered operating system for People teams. Install once, use every day. Built on Claude Code with Granola, Slack, and Coda integrations.

> Adapted from the original workflow-kit architecture. All credit for the underlying system design goes to the source — this is the People Ops edition, rebuilt for how People teams actually work.

---

## What This Actually Is

This isn't a chat tool. It's an accumulating intelligence system.

Every meeting you capture, every project you document, every session you close out — it all becomes context that persists and compounds. Claude doesn't forget between sessions. By week two, it knows your priorities, your stakeholders, your open action items, and your working style without you having to re-explain them.

The core loop is three commands:

```
/orient    ← start of every session
/meet      ← after every meeting
/closeout  ← end of every session
```

`/closeout` isn't a to-do list. It's a paper trail of what you accomplished — decisions made, artifacts created, work shipped. Pickups for unfinished work get created automatically and surface in the next `/orient`. The more you use it, the smarter it gets.

---

## Skills

### Daily Loop (start here)
| Skill | What it does |
|-------|-------------|
| `/orient` | Start of session — loads vault context, surfaces open pickups, reads period reports |
| `/meet` | Post-meeting capture — pulls Granola transcript, generates structured note with decisions |
| `/closeout` | End of session — logs what you did, creates pickup docs, sets up tomorrow |
| `/end-day` | Full day wrap — Granola sweep, Slack sweep, EOD + SOD reports |

### Context Management
| Skill | What it does |
|-------|-------------|
| `/pickup` | Load a specific PIC and get oriented on what's next |
| `/log-work` | Log what you just did to the daily note |
| `/park` | Set aside in-progress context to return to later |
| `/recap` | Summarize what's happened in the current session |
| `/create-pickup` | Create a PIC document for any open item |

### Meeting Workflow
| Skill | What it does |
|-------|-------------|
| `/prep` | Pre-meeting brief — surfaces past context, open decisions, and suggested agenda |
| `/draft` | Write a Slack message, email, or talking points in your voice |
| `/weekly` | Friday afternoon rollup — week summary by project, with manager update draft |

### Diagnostics
| Skill | What it does |
|-------|-------------|
| `/assess` | Cross-source sweep — Granola + Slack + Coda + vault, surfaces what's actually happening |

### Project Workflow
| Skill | What it does |
|-------|-------------|
| `/create-spec` | Guided interview → tiered spec document (Brief / Standard / Full) |
| `/review-spec` | 3-perspective review before planning — catches gaps and open decisions |
| `/plan-spec` | Reviewed spec → phased implementation plan with acceptance criteria |
| `/create-agent` | Dispatch a specialized agent to do research or drafting autonomously |

### Kit Management
| Skill | What it does |
|-------|-------------|
| `/onboard` | First-session setup — imports context from Coda/Granola, builds real agents.md |
| `/learn` | Capture a reusable lesson or rule from the session into lessons.md |
| `/update-wfk` | Sync your local kit with GitHub — pull updates, push improvements |

---

## Install

**Requirements:** Mac, Homebrew, Obsidian (free), Claude Code CLI

```bash
git clone https://github.com/ellenwolf0-hub/wolf-workflow-kit.git
cd wolf-workflow-kit
bash setup.sh
```

**Total time:** under 5 minutes for the script. Budget 15 minutes to fill in your profile and run your first session.

---

## First Session

After setup, open a new terminal and run:

```bash
claude --dangerously-skip-permissions
```

Then run `/onboard` to load your existing work context from Coda and Granola, and build a real `agents.md` profile. This is what makes session 1 feel like session 10.

Once that's done, run `/orient`. Claude will greet you by name, surface open items, and ask what you want to work on.

---

## The Ramp-Up Path

**Week 1 — The Loop**
`/orient` every morning. `/meet` after every meeting. `/closeout` every evening. Get comfortable with how context carries forward before adding more.

**Week 2 — Add Pickups**
Use `/pickup` to resume yesterday's context. Use `/log-work` mid-session when you complete something significant. Run `/learn` when something worth remembering happens.

**Week 3 — Add Project Structure**
Use `/create-spec` for any initiative that needs more than a Slack thread. Use `/review-spec` before you present anything. Use `/plan-spec` to turn a spec into a task list with acceptance criteria.

**Week 4+ — Full Power**
`/prep` before every important meeting. `/draft` instead of staring at a blank message. `/create-agent` when you need a research pass done while you're in another meeting. `/end-day` for a full EOD report with Granola + Slack sweep. `/assess` when you need to cut through noise and find out what's actually happening.

---

## Vault Structure

```
vault/
├── agents.md          ← your profile and preferences (fill this in first)
├── lessons.md         ← lessons that build over time via /learn
├── Daily/             ← DN - YYYY-MM-DD.md
├── Meetings/          ← MN - YYYY-MM-DD (Topic).md
├── Pickups/           ← PIC - Topic.md
├── Projects/          ← SPC, PL, PJL files for People Ops initiatives
└── templates/         ← note templates
```

**File prefix conventions:**
- `DN -` daily notes
- `MN -` meeting notes
- `SPC -` specs
- `PL -` plans
- `PIC -` pickup docs
- `PJL -` project logs (deep cross-session context for active projects)

---

## Zapier Automations (Optional)

Connect skills to Slack and Coda without any code. See [`zapier/README.md`](zapier/README.md).

- `/prep` → Slack DM to you 10 minutes before a meeting
- `/meet` → decisions + action items posted to team Slack channel
- `/closeout` → work log row added to shared Coda tracker

---

## Integrations

| Integration | How to connect | What it enables |
|-------------|----------------|-----------------|
| **Granola** | Sign in to the Granola app | `/meet` pulls transcripts automatically |
| **Slack** | `claude mcp add --transport sse slack https://mcp.slack.com/sse` | Read/write Slack from skills |
| **Coda** | Add `CODA_API_TOKEN` to `~/.zshrc` | `/assess` and `/onboard` pull Coda docs |

All integrations are optional. Skills degrade gracefully when an integration isn't connected.

---

## Built With

- [Claude Code](https://claude.ai/code) — the terminal interface
- [Granola](https://granola.ai) — meeting transcripts
- [Obsidian](https://obsidian.md) — the vault / memory layer
- [Zapier](https://zapier.com) — no-code automation bridge
- [Slack](https://slack.com) + [Coda](https://coda.io) — team output destinations
- [Warp](https://warp.dev) — recommended terminal (friendlier for new users)
