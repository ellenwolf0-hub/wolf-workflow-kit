# Best Practice — Research & Compare

Research best practices for a given problem from authoritative sources, then present a comparison table of approaches with tradeoffs and a recommendation.

Use this skill whenever the user asks "what's the best practice for X", "how should I handle X", "what's the right approach to X", "best way to do X", wants to compare approaches to a problem, or needs an informed recommendation grounded in real-world practice. Works for any domain - software, infrastructure, operations, management, anything.

## How It Works

### 1. Clarify the Problem

Before researching, make sure the question is specific enough to get useful results. If the user says "best practice for authentication" - that's too broad. Ask one clarifying question to narrow scope (e.g., "For a multi-tenant SaaS app, or a single-org internal tool?"). If the question is already specific, skip straight to research.

### 2. Research (Deep Dive)

Launch 2-3 parallel web search agents to cross-reference sources:

- **Agent 1:** Search for the direct best practice question. Target official documentation, RFCs, style guides, and framework docs.
- **Agent 2:** Search for comparisons, alternatives, and tradeoffs. Target engineering blogs, conference talks, and "X vs Y" discussions.
- **Agent 3:** Search for failure modes and anti-patterns. Target post-mortems, "mistakes we made", and Stack Overflow warnings.

For each source found, note: who wrote it (individual, company, standards body), when (stale advice is dangerous), and whether it's opinion or backed by data/experience.

### 3. Synthesize into Comparison Table

Build a table with this structure:

```
## Best Practice: [Topic]

**Context:** [1-2 sentences restating the specific problem]

| Approach | How it works | Pros | Cons | Best when | Sources |
|----------|-------------|------|------|-----------|---------|
| ...      | ...         | ...  | ...  | ...       | ...     |

**Recommendation:** [Which approach and why, given the user's context]

**Watch out for:** [Common mistakes, anti-patterns, or "it depends" caveats]
```

Rules for the table:
- 2-4 approaches. Not every option that exists - just the ones worth considering.
- "Sources" column links to the actual source (docs URL, blog post, RFC number). No fabricated links.
- "Best when" is the most valuable column - it tells the user which approach fits their situation.
- If sources disagree, say so explicitly. "AWS recommends X, but Google Cloud's SRE book argues Y because Z."

### 4. Adapt to Context

If the user is working in a specific codebase or project, check the current code/config before recommending. A best practice that contradicts an established pattern in the project needs to acknowledge the migration cost. Read `CLAUDE.md` or project context if available.

If the research reveals the user's current approach IS the best practice, say so - don't invent alternatives just to fill a table.
