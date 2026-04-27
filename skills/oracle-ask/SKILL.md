# Oracle Ask

Query an existing oracle for design guidance. Surfaces real-world context as a proposition for the user to evaluate.

Use this skill when the user says "ask the oracle", "oracle ask", "check with the oracle", "what does the oracle say", or when called inline from other skills (create-spec, design, grill, create-plan, implement) at design decision points.

Governed by [[SD - Oracle System]]. The oracle informs, the user decides. No silent decisions.

## Steps

### Step 1: Find the Oracle

Read the current project's PJL frontmatter for the `oracles:` field.

**If no PJL is found or no `oracles:` field exists:**
- "This project has no oracle. Want to create one with `/oracle-create`?"
- If the user declines, exit.

**If one oracle exists:**
- Use it.

**If multiple oracles exist:**
- Present the list via AskUserQuestion: "Which oracle should I query?" with each oracle's name and scope as options.

### Step 2: Query the Oracle

```
mcp__notebooklm-mcp__notebook_query(
  notebook_id="{oracle_id}",
  query="{user's question}"
)
```

If this is a follow-up to a previous query in the same session, use `conversation_id` to maintain context:
```
mcp__notebooklm-mcp__notebook_query(
  notebook_id="{oracle_id}",
  query="{follow-up question}",
  conversation_id="{previous_conversation_id}"
)
```

For complex synthesis queries that may timeout, use the async path:
```
mcp__notebooklm-mcp__notebook_query_start(notebook_id="{oracle_id}", query="{question}")
mcp__notebooklm-mcp__notebook_query_status(notebook_id="{oracle_id}", poll_interval=5, max_wait=120)
```

### Step 3: Surface as Proposition

Format the response using the standard oracle proposition format:

> **Oracle ({source_count} sources):** {insight}
> *Sources: {citation 1}, {citation 2}*
> {question or decision prompt to user}

**When called standalone:** Present the proposition and let the user respond.

**When called inline from another skill:** Present the proposition as context before the skill's own question. Example in `/create-spec`:

> The oracle suggests knowledge base systems typically use a three-tier taxonomy (category > topic > article) with flat navigation at the top level.
> *Sources: NN/g taxonomy research, Confluence IA patterns*
>
> How do you want to structure the KB hierarchy?

The oracle's suggestion frames the question but does not constrain the answer.

## Standalone Usage

When the user invokes `/oracle-ask` directly:

1. Find the oracle (Step 1)
2. If the user provided a question in the invocation (e.g., `/oracle-ask how do existing systems handle versioning?`), use it directly
3. If no question was provided, ask via AskUserQuestion: "What do you want to ask the oracle?"
4. Query and surface (Steps 2-3)
5. Ask: "Want to ask a follow-up?" If yes, loop with `conversation_id`. If no, done.

## Inline Usage (from other skills)

When another skill calls oracle-ask programmatically:

1. The calling skill provides the project context and question
2. Skip AskUserQuestion for the question (the calling skill already knows what to ask)
3. Query and return the formatted proposition to the calling skill
4. The calling skill incorporates it into its own output

## Error Handling

- **NLM auth failure:** Attempt `mcp__notebooklm-mcp__refresh_auth()` once. If that fails: "Oracle auth expired. Run `nlm login` in your terminal. Proceeding without oracle input."
- **Query timeout:** "Oracle query timed out. The notebook may be processing a large source set. Try again in a minute, or proceed without oracle input."
- **Empty response:** "The oracle returned no relevant results for this query. The sources may not cover this topic. Consider expanding the oracle with `/oracle-research`."
- **Oracle not found (notebook deleted):** "The oracle registered in PJL (ID: {id}) no longer exists in NotebookLM. It may have been deleted. Create a new one with `/oracle-create` or remove the stale entry from PJL."

In all error cases, the skill exits gracefully and the calling workflow continues without oracle input. The oracle is advisory, never blocking.
