# Oracle Create

Create a new oracle (NotebookLM research notebook) for a project or sub-domain. Populates it with deep research, produces a grounding report, and registers the oracle in the project's PJL frontmatter.

Use this skill when the user says "create oracle", "oracle create", "set up an oracle", "research this domain", or when `/create-sd`, `/create-note SPC`, `/design`, or `/grill` prompts for oracle creation.

Governed by [[SD - Oracle System]]. The oracle informs, the user decides. No silent decisions.

## Steps

### Step 0: Check for Existing Oracle

Read the project's PJL file and check for an `oracles:` frontmatter field.

If an oracle already exists for the same scope:
- Surface it: "This project already has an oracle: {name} ({source_count} sources, created {date}). Want to expand it with `/oracle-research` instead of creating a new one?"
- If the user wants to proceed anyway, continue.

### Step 1: Gather Context

Ask the user (via AskUserQuestion):
1. What domain or system is this oracle for? (e.g., "knowledge management systems", "menu database design", "employee interview platforms")
2. What specific questions should the research answer? (e.g., "How do existing KBs handle versioning?", "What are established patterns for bitemporal data?")

If invoked from another skill (create-spec, create-sd, etc.), infer the domain from the spec/SD context and confirm with the user rather than asking from scratch.

### Step 2: Create Notebook

```
mcp__notebooklm-mcp__notebook_create(title="Oracle - {Project} - {Scope}")
```

Tag the notebook for human discoverability in the NLM UI:
```
mcp__notebooklm-mcp__tag(action="add", notebook_id="{id}", tags="{project},{scope}")
```

### Step 3: Run Deep Research

Use the user's domain description and questions to construct research queries.

```
mcp__notebooklm-mcp__research_start(
  notebook_id="{id}",
  query="{domain research query}",
  mode="deep"
)
```

Poll for completion:
```
mcp__notebooklm-mcp__research_status(notebook_id="{id}", poll_interval=10, max_wait=300)
```

Import discovered sources:
```
mcp__notebooklm-mcp__research_import(notebook_id="{id}", task_id="{task_id}")
```

If the user provided specific URLs or references, add them directly:
```
mcp__notebooklm-mcp__source_add(notebook_id="{id}", source_type="url", url="{url}")
```

### Step 4: Synthesize Grounding Report

Query the populated notebook for a grounding synthesis:

```
mcp__notebooklm-mcp__notebook_query(
  notebook_id="{id}",
  query="Based on all sources, provide a comprehensive synthesis of: (1) established patterns and industry standards for {domain}, (2) common approaches and their tradeoffs, (3) known pitfalls and antipatterns, (4) key frameworks and theoretical foundations, (5) open questions the sources disagree on or don't fully answer."
)
```

### Step 5: Write Grounding Report

Resolve the project's reports directory. Create a dated subfolder if needed:
```
{vault_root}/{paths.projects}/{project}/reports/YYYY-MM-DD/
```

Write `ARE - {Domain} Grounding Report.md` with this frontmatter:

```yaml
---
date created: YYYY-MM-DD
tags: [grounding-report, oracle, {project-tag}]
category: Report
source: "oracle-create skill"
oracle_id: "{notebook_id}"
oracle_name: "Oracle - {Project} - {Scope}"
---
```

Report structure:
- **Domain Overview** - What the world knows about this domain
- **Established Patterns** - Industry standards and proven approaches
- **Common Pitfalls** - What goes wrong and why
- **Key Frameworks** - Theoretical foundations relevant to design work
- **Key Sources** - Annotated list of the most valuable sources
- **Open Questions** - What the research didn't fully answer

### Step 6: Register in PJL

Read the project's PJL file. Add or update the `oracles:` frontmatter field:

```yaml
oracles:
  - id: "{notebook_id}"
    name: "Oracle - {Project} - {Scope}"
    scope: "{scope}"
    created: "YYYY-MM-DD"
    sources: {count}
    grounding_report: "[[ARE - {Domain} Grounding Report]]"
```

If the PJL has no `oracles:` field yet, add it to the frontmatter.

### Step 7: Present to User

Summarize what was created:
- Oracle name and scope
- Number of sources discovered and imported
- Key findings from the grounding report (3-5 bullet points)
- Link to the full grounding report
- "The oracle is ready. Query it anytime with `/oracle-ask`."

## Error Handling

- **NLM auth failure:** Attempt `mcp__notebooklm-mcp__refresh_auth()` once. If that fails, tell the user: "Oracle auth expired. Run `nlm login` in your terminal, then retry." Do not write partial state to PJL.
- **Research timeout:** If `research_status` times out after 5 minutes, tell the user research is still running and they can check back. Do not proceed to Step 4 with an incomplete notebook.
- **Empty research results:** If research discovers 0 sources, tell the user and offer to add sources manually via URLs. Do not write an empty grounding report.
- **Any NLM call failure:** Surface the specific error to the user. Exit cleanly. No partial oracle state in PJL.
