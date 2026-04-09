# Demo Script — People Team Workflow Kit

**Target runtime:** Under 5 minutes
**Loop:** Scenario A → Scenario C → Scenario D
**Setup:** Complete `orient-vault-setup.md` before the demo

---

## Opening (30 seconds)

> "Every People team professional I know has the same problem: information lives in their head, in old meeting notes, in Slack threads nobody can find. We spend more time recreating context than actually doing the work. What if your tools remembered for you?"

Open your terminal. Have the vault open in Obsidian in the background (visible but not in focus).

---

## Scenario A — "The Morning Reset" (~60 seconds)

**What you type:**
```
/orient
```

**What should happen:**
- Claude reads your profile from agents.md
- Surfaces today's date, open pickups (Taylor Chen comp analysis)
- Shows context from yesterday's work (calibration prep, GROW, Metro)
- Asks what to work on

**What to say while it runs:**
> "I just opened my terminal. I didn't write any of this — it pulled from my notes. It knows I have a pending comp analysis for Taylor Chen from yesterday's setup work. It knows what I was working on last week."

**Aha moment to call out:**
> "Context that would've been lost over a weekend — or even overnight — is just there. No catch-up email to yourself. No 'what was I doing?' moment."

---

## Scenario C — "The Meeting That Writes Itself" (~90 seconds)

**What you type:**
```
/meet
```

**What should happen:**
- Claude searches Granola for recent meetings
- **If Granola finds the calibration meeting:** It presents it for confirmation, then generates the note
- **If Granola doesn't find it (fallback):** Say "Granola didn't capture that one" → paste the content from `demo/transcript-calibration-taylor-chen.txt`

**Expected output — meeting note saved to vault:**

```
## Decisions

| Decision | Owner | Date |
|----------|-------|------|
| Rating: Exceeds | Ellen | 2026-04-09 |
| Merit increase: 6% | Jordan Kim | 2026-04-09 |
| Promotion deferred to Q3 calibration | Team | 2026-04-09 |

## Action Items

- [ ] Jordan Kim: Comp analysis → Ellen by Friday April 11
- [ ] Ellen: Coaching 1:1 with Taylor — week of April 14

## Open Questions

- Promotion readiness: not enough signal on strategic leadership dimension yet. Flag for Q3.
```

**What to say while it runs:**
> "I just finished the calibration. I type /meet. It pulled the transcript from Granola — I didn't have to copy anything. Watch what it produces."

**Aha moment to call out:**
> "The decisions are here, in their own section, with owners. Not buried in a 2-hour transcript. Not in someone's head. Next time I meet with Taylor's team, /prep will surface these decisions automatically. That's the loop."

---

## Scenario D — "Zapier Does the Filing" (~60 seconds)

**What to say immediately after /meet completes:**
> "Here's where it gets interesting for the team. Watch your phone."

**What should happen:**
After /meet completes, the Zapier webhook fires automatically → Slack DM arrives with meeting decisions and action items.

Show the Slack DM on your phone or pull it up in Slack on screen.

**What to say:**
> "I didn't send that. The skill did. Now imagine that going to your whole team channel — every calibration decision, every action item, automatically filed. Teammates who never open the terminal get the output anyway."

**Aha moment to call out:**
> "The value doesn't require adoption. You use the kit, and everyone around you benefits."

---

## Closing (30 seconds)

> "This is the Tier 1 loop — orient, meet, closeout. Three commands, 5 minutes to install. There's a whole second tier — pre-meeting prep, draft communications, weekly summaries — but you don't need any of that for this to be useful on day one."

> "The kit is on GitHub. Setup script takes under 5 minutes. The cheat sheet is one page. We built this for People team members who don't want to become power users — they just want to stop losing context."

---

## Fallback Procedures

| Problem | What to do |
|---------|-----------|
| Granola doesn't find the meeting | "Let me show you the fallback" → paste transcript from demo/transcript-calibration-taylor-chen.txt |
| Zapier doesn't fire in 30 seconds | "The webhook can take a moment" → show a screenshot of a previous successful run |
| Claude gives a weird response | Stay calm, correct it naturally: "Let me be more specific — /meet on the calibration session we just ran" |
| Terminal font too small | Cmd+= to zoom in before demo starts |

---

## Pre-Demo Checklist (30 min before)

- [ ] Run `orient-vault-setup.md` steps — daily note + pickup in place
- [ ] Confirm Granola has today's calibration transcript (or have fallback txt ready)
- [ ] Test Zapier webhook: `curl -X POST "$ZAPIER_MEET_WEBHOOK" -H "Content-Type: application/json" -d '{"meeting":"Test","date":"today","decisions":[],"action_items":[],"open_questions":[]}'`
- [ ] Slack DM confirms webhook is live
- [ ] Terminal font size visible from back of room (Cmd+= until comfortable)
- [ ] Demo vault loaded in the terminal's working directory
