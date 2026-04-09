# Zapier Setup Guide

Connect your skills to Slack and Coda — no code required.

**Recommended tier:** Zapier Starter (~$20/month, 750 tasks/month). Free tier (100 tasks) runs out in ~11 days with 3 active webhooks at daily use.

---

## Overview

Three automations are available:

| # | Trigger | Destination | Skill |
|---|---------|-------------|-------|
| 1 | `/prep` runs | Slack DM to you | `/prep` |
| 2 | `/meet` completes | Designated Slack channel | `/meet` |
| 3 | `/closeout` completes | Coda work tracker row | `/closeout` |

Set up only the ones you want. Each is independent.

---

## Setup: Each Automation

### Step 1 — Create the Zap

1. Go to [zapier.com](https://zapier.com) → **+ Create → Zaps**
2. **Trigger:** Search "Webhooks by Zapier" → **Catch Hook** → Continue
3. Copy the webhook URL Zapier gives you
4. Set your **Action** (see below for each automation)
5. **Test** then **Publish**

### Step 2 — Add the Webhook URL to Your Environment

Open your `~/.zshrc` (or `~/.bash_profile`) and add:

```bash
export ZAPIER_MEET_WEBHOOK="https://hooks.zapier.com/hooks/catch/YOUR/URL"
export ZAPIER_CLOSEOUT_WEBHOOK="https://hooks.zapier.com/hooks/catch/YOUR/URL"
export ZAPIER_PREP_WEBHOOK="https://hooks.zapier.com/hooks/catch/YOUR/URL"
```

Then run: `source ~/.zshrc`

---

## Automation 1 — `/prep` → Slack DM (10 min before meeting)

**Action in Zapier:** Slack → Send Direct Message
- **To:** yourself
- **Message:** Map these fields from the webhook data:
  - `meeting` — meeting name
  - `attendees` — who's in the room
  - `prior_context` — last meeting summary
  - `decisions_needed` — open items to resolve

**Test payload shape:**
```json
{
  "meeting": "Calibration — Taylor Chen",
  "attendees": ["You", "Taylor Chen"],
  "prior_context": "Last met 2026-03-18. Open decision: comp band for L4.",
  "decisions_needed": ["Finalize rating", "Decide promotion timeline"]
}
```

---

## Automation 2 — `/meet` → Slack Channel

**Action in Zapier:** Slack → Send Channel Message
- **Channel:** Your team channel (e.g., `#people-team-updates`)
- **Message:** Map these fields:
  - `meeting` — meeting name
  - `date` — meeting date
  - `decisions` — array of decisions (what + owner)
  - `action_items` — array of tasks (task + owner + due)

**Test payload shape:**
```json
{
  "meeting": "Calibration — Taylor Chen",
  "date": "2026-04-09",
  "decisions": [
    {"what": "Rating confirmed at Exceeds", "owner": "Ellen"}
  ],
  "action_items": [
    {"task": "Draft promotion brief", "owner": "Ellen", "due": "2026-04-15"}
  ],
  "open_questions": ["Comp band to be confirmed with HR"]
}
```

---

## Automation 3 — `/closeout` → Coda Tracker Row

**Action in Zapier:** Coda → Create Row
- **Doc:** Your team's shared Coda doc
- **Table:** Work log table
- **Fields to map:**
  - `date` → Date column
  - `worked_on` → Work items column
  - `open_items` → Open items column

**Test payload shape:**
```json
{
  "date": "2026-04-09",
  "worked_on": ["Calibration for Taylor Chen", "Drafted comp memo"],
  "open_items": ["Comp band confirmation pending"]
}
```

---

## Testing Your Zaps

After setup, you can test any webhook from the terminal:

```bash
# Test /meet webhook
curl -X POST "$ZAPIER_MEET_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d '{"meeting":"Test Meeting","date":"2026-04-09","decisions":[{"what":"Webhook works","owner":"Me"}],"action_items":[],"open_questions":[]}'
```

If the Slack message appears within 30 seconds, you're good.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Webhook fires but nothing happens | Check that the Zap is **Published**, not Draft |
| Slack message not appearing | Verify the bot has permission to post to that channel |
| Coda row not created | Confirm your Coda API connection is authenticated in Zapier |
| `curl: command not found` | Install via Homebrew: `brew install curl` |
