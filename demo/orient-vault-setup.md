# Demo Vault Setup

Run this setup before the demo to make Scenario A land properly.

## What to Set Up

### 1. Create a daily note for "yesterday"

Create `vault/Daily/DN - 2026-04-08.md` with this content:

```markdown
---
date created: 2026-04-08
tags: [daily]
category: Daily Note
---

# Wednesday, April 8, 2026

## Worked On

### Calibration Prep
- Reviewed 12 calibration packets for Q1 cycle — all Exceeds and Meets ratings need cross-team validation
- Set up calibration session for Taylor Chen with Jordan Kim and Marcus Rivera

### GROW Program
- Reviewed White Glove session script with Liuba — flagged 5 risks for follow-up
- Confirmed April 14 enablement session with Superhuman

### Metro Project
- Sent kickoff materials to 7 DRIs
- Awaiting reference examples before building project hub
```

### 2. Create an open pickup

Create `vault/Pickups/PIC - Taylor Chen Comp Analysis.md`:

```markdown
---
date created: 2026-04-08
tags: [pickup]
category: Pickup
status: open
project: "Calibration Q1 2026"
---

# PIC - Taylor Chen Comp Analysis

## Context
Taylor Chen's calibration is scheduled for April 9. Rating is expected to land at Exceeds — comp analysis needs to be done after the session.

## What Was Done
- Pre-read the calibration packet
- Confirmed Exceeds is the expected outcome

## What Needs to Happen Next
1. Run the calibration session with Jordan Kim and Marcus Rivera
2. Lock the rating and comp recommendation
3. Send comp analysis to Finance by April 11

## Blockers or Dependencies
- None — meeting is confirmed
```

### 3. Make sure agents.md is filled in

The "who am I" section should be filled in:

```
Name: Ellen Wolf
Role: Director, People Operations
Team: People Team
Manager: Brady
Key stakeholders: Jordan Kim, Marcus Rivera, Leah
```

---

Once these are in place, `/orient` will surface the open pickup and the week's context. That's Scenario A.
