# Getting Started — Wolf Workflow Kit

**Built by Ellen Wolf · People Ops, Grammarly**

This guide walks you through your first 15–30 minutes with the Wolf Workflow Kit. Follow it top to bottom and you'll have a working session by the end.

---

## What You're Setting Up

The Wolf Workflow Kit connects Claude — the AI you already use — to your vault of notes, meeting captures, and work context. Instead of typing everything into Claude from scratch every time, Claude reads your vault and picks up where you left off.

**The difference between Claude.ai and Claude Code:**
- **Claude.ai** (what you use now): you type a question, Claude answers. No memory. No files.
- **Claude Code** (what you're installing): Claude lives in your terminal, reads your notes, writes to your files, and runs specialized workflows called skills. Context carries across sessions.

You'll still use Claude.ai for one-off questions. Claude Code is for your workflow.

---

## Before You Start

You need:
- [ ] A Mac (Windows support coming later)
- [ ] Homebrew installed — [brew.sh](https://brew.sh) (run the one-line installer on that page if you don't have it)
- [ ] Obsidian installed — [obsidian.md](https://obsidian.md) (free, takes 2 minutes)
- [ ] Warp terminal — [warp.dev](https://warp.dev) (free, looks like a chat interface — much friendlier than the default Terminal)
- [ ] An Anthropic account — [console.anthropic.com](https://console.anthropic.com) (sign in with your work email; you need API access, not just Claude.ai)

---

## Step 1 — Install the Kit

Open **Warp** (or Terminal if you don't have Warp yet).

Navigate to where you cloned or downloaded the wolf-workflow-kit folder. If you're not sure how to navigate in a terminal, type:

```bash
cd ~/Downloads/wolf-workflow-kit
```

Then run the setup script:

```bash
bash setup.sh
```

The script will:
1. Install Claude Code CLI (the terminal version of Claude)
2. Install all 17 skills into your Claude setup
3. Open the vault in Obsidian

**If Homebrew isn't installed yet:** The script will tell you. Follow its instructions, then run `bash setup.sh` again.

---

## Step 2 — Personalize Your Vault

The vault opened in Obsidian. Find the file called **`agents.md`** — it's in the vault root.

Fill in the "Who Am I" section at the top:

```
Name: [Your name]
Role: [Your title]
Team: [Your team name]
Manager: [Your manager's name]
Key stakeholders: [2-3 people you work with most]

My top priorities right now:
- [Priority 1]
- [Priority 2]
```

This is what Claude reads to understand who you are and how to frame things for you. The more specific you are, the more useful every session becomes.

Save the file. That's it for Obsidian for now.

---

## Step 3 — Start Claude Code

Go back to Warp (or your terminal).

Type this and press Enter:

```bash
claude --dangerously-skip-permissions
```

**What does `--dangerously-skip-permissions` mean?**

By default, Claude Code asks for your approval every time it reads or writes a file — which happens constantly in a workflow session and gets tedious fast. This flag tells Claude Code it can work with your files automatically during the session, without asking each time.

This is safe for the vault folder. Claude isn't accessing anything outside of what's in front of it. Think of it like turning off the "are you sure?" dialog in your OS — useful when you trust what you're doing.

You can always review everything Claude wrote by checking the vault in Obsidian after the session.

---

## Step 4 — Your First Session

You should now see the Claude Code interface in Warp — it looks like a chat window.

**Type this:**

```
/orient
```

Claude will:
1. Read the date
2. Load your `agents.md` profile
3. Load your `lessons.md` context
4. Check for any open pickups (things left from previous sessions)
5. Greet you and tell you what's open

The first time, it'll notice that `agents.md` has your real info now and greet you by name. If it says "agents.md isn't personalized yet," go back to Obsidian and make sure you saved the file.

---

## Step 5 — Try the Loop

Here's the core workflow. Try this after your next meeting:

```
/orient          ← run this at the start of every session
/meet            ← run this after every meeting
/closeout        ← run this at the end of every session
```

**After a meeting, type:**
```
/meet calibration with [person's name]
```

Claude will look for a transcript in Granola (if connected), or ask you to paste one. It'll structure it into a meeting note with decisions, action items, and open questions — saved to your vault.

**At the end of your day, type:**
```
/closeout
```

Claude will scan the session, log what you did to today's note, and create pickup docs for anything unfinished so tomorrow starts clean.

---

## Adding Integrations (Optional)

The kit works on day one without these. Add them when you're ready.

### Granola (meeting transcripts)
Make sure you're signed into the Granola app. Claude Code will find it automatically.

### Slack
In Claude Code, run:
```
claude mcp add --transport sse slack https://mcp.slack.com/sse
```
You'll be redirected to authenticate in your browser.

### Coda
1. Go to coda.io/account → API → Generate token
2. Add to your shell config (`~/.zshrc`):
   ```
   export CODA_API_TOKEN="your-token-here"
   ```
3. Restart your terminal

---

## All 17 Skills

Once you're comfortable with the 3-command loop, here's the full toolkit:

| Command | What it does |
|---------|-------------|
| `/orient` | Start every session with this |
| `/pickup` | Resume a specific open item |
| `/meet` | After any meeting |
| `/prep [meeting]` | Before important meetings |
| `/closeout` | End every session with this |
| `/log-work` | Log what you just did |
| `/park` | Save context to return to later |
| `/recap` | Summarize the current session |
| `/draft` | Write Slack, email, or talking points |
| `/weekly` | Friday afternoon rollup |
| `/assess` | People team diagnostic — what's actually going on |
| `/create-spec` | Formally define a project or initiative |
| `/review-spec` | Catch gaps before planning |
| `/plan-spec` | Turn a spec into a phased plan |
| `/create-agent` | Delegate a task to an autonomous agent |
| `/create-pickup` | Create a pickup doc for any open item |
| `/end-day` | Full day wrap with Granola + Slack sweep |

See `CHEATSHEET.md` for the 4-week ramp-up guide.

---

## If Something Breaks

| Problem | Fix |
|---------|-----|
| `claude: command not found` | Restart your terminal after install |
| `/orient` doesn't respond | Make sure you ran `claude --dangerously-skip-permissions` |
| Granola not pulling | Paste transcript manually when `/meet` prompts |
| Slack not connecting | Check that you authenticated via `claude mcp add` |
| agents.md showing placeholders | Open Obsidian, fill in your name/role, save |
| Any other question | Type your question directly in Claude Code — it'll help |

---

*Questions? Reach out to Ellen Wolf.*
