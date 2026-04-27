# Oracle Research

Expand an existing oracle's knowledge when the project scope grows or new questions emerge. Adds new sources and research to an oracle that was created with `/oracle-create`.

Use this skill when the user says "oracle research", "expand the oracle", "add to the oracle", "research more", or when an oracle query returns thin results and needs more sources.

Governed by [[SD - Oracle System]]. The oracle informs, the user decides.

## Steps

### Step 1: Find the Oracle

Read the current project's PJL frontmatter for the `oracles:` field.

**If no oracle exists:** "This project has no oracle yet. Use `/oracle-create` to set one up first."

**If multiple oracles exist:** Ask which one to expand via AskUserQuestion.

### Step 2: Gather New Research Direction

Ask the user (via AskUserQuestion):
- What new area should the oracle research? (e.g., "We're now looking at allergen tracking patterns" or "Need more on interview question sequencing")

Or accept the direction from the invocation arguments.

### Step 3: Run Additional Research

```
mcp__notebooklm-mcp__research_start(
  notebook_id="{oracle_id}",
  query="{new research query}",
  mode="deep"
)
```

Poll and import as in `/oracle-create`:
```
mcp__notebooklm-mcp__research_status(notebook_id="{oracle_id}", poll_interval=10, max_wait=300)
mcp__notebooklm-mcp__research_import(notebook_id="{oracle_id}", task_id="{task_id}")
```

If the user provided specific URLs:
```
mcp__notebooklm-mcp__source_add(notebook_id="{oracle_id}", source_type="url", url="{url}")
```

### Step 4: Update Ledger

Update the PJL frontmatter entry for this oracle:
- Increment `sources` count
- Add `last_expanded: "YYYY-MM-DD"` field

### Step 5: Optional Synthesis

Ask the user: "Want a synthesis of the new research area, or just the raw sources added?"

If yes, query the oracle for a focused synthesis on the new domain area and append a "Research Expansion" section to the existing grounding report:

```markdown
## Research Expansion: {Topic} (YYYY-MM-DD)

{synthesis of new findings}
```

### Step 6: Confirm

Report what was added:
- Number of new sources imported
- Updated total source count
- Brief summary of what the new sources cover

## Error Handling

Same as `/oracle-create`: auth retry once, surface failures, no partial state updates.
