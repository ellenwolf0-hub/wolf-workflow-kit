# Plan-to-Plane: Create Plane Project from Approved Plan

This reference is auto-chained from `/create-plan` after the user approves the plan document. It creates a Plane project with modules, phase labels, and work items from the approved plan.

**IMPORTANT:** Use REST API via Python `urllib` for all Plane calls — NOT MCP. MCP writes don't persist (lesson L20).

## Infrastructure

| Item | Value |
|:-----|:------|
| External URL | `https://YOUR_PLANE_URL` |
| API base | `https://YOUR_PLANE_URL/api/v1/workspaces/YOUR_WORKSPACE` |
| Workspace slug | `YOUR_WORKSPACE` |
| API key | `YOUR_PLANE_API_KEY` |
| Auth header | `X-Api-Key: YOUR_PLANE_API_KEY` |

## Step 1 — Check Registry

1. Read the Project Registry table in `Documentation/Agent Workflows/Plane Development Workflow.md`
2. Does a Plane project already exist for this project? If yes, use the existing project ID — do NOT create a duplicate

## Step 2 — Create or Reuse Project

- If no project exists: `POST /projects/` with `name`, `identifier` (3-letter), `description`, `network: 2`
- If project exists: use the existing project ID from the registry

## Step 3 — Enable Modules

Ensure `module_view: true` on the project via PATCH if needed.

## Step 4 — Query States

`GET /projects/{pid}/states/` — get IDs for Backlog, Todo, In Progress, Done. States are per-project — **never hardcode state IDs**.

## Step 5 — Create Module

`POST /projects/{pid}/modules/` with:
- `name`: spec name (without "SPC - " prefix)
- `status`: `planned`
- `description`: one-line from spec purpose

Module status values: `planned`, `in-progress`, `completed` (NOT `started`).

## Step 6 — Create Phase Labels

`POST /projects/{pid}/labels/` for each phase:
- Format: `{IDENTIFIER} Phase {N} - {Phase Name}` (e.g., `AMS Phase 0 - Prerequisites`)

## Step 7 — Create Work Items

`POST /projects/{pid}/issues/` for each task from the plan's task tables:

- `name`: **MUST use phase-prefixed ID format** — `P{phase}.{number} — {task description}` (e.g., `P0.1 — Run schema migration`, `P3.4 — Integrate widget into dashboard`). This is mandatory so the Plane board is scannable.
- `description_html`: `<p>{task details, dependencies, relevant gotchas}</p>`
- `state`: **(HARD RULE)** Phase 0 tasks → **Todo** state. ALL other phases → **Backlog** state. No exceptions. Issues are promoted to Todo only when their phase starts and dependencies are satisfied.
- `label_ids`: `[{phase_label_id}]`

## Step 8 — Add Items to Module

`POST /projects/{pid}/modules/{mid}/module-issues/` — batch add all created issues.

Note: the endpoint is `/module-issues/`, not `/issues/`.

## Step 9 — Update Registry & Routing Manifest

1. If this is a new project, add it to the Project Registry table in the Plane Development Workflow doc
2. Write or verify the routing manifest entry in the plan document's frontmatter (`plane_url` field)

## Step 10 — Report Back

After everything is created:

1. Confirm the plan document path and link to it
2. Report Plane project details:
   - Project URL: `https://YOUR_PLANE_URL/YOUR_WORKSPACE/projects/{pid}/`
   - Module created, issue count, phase label count
3. Remind the user of any Critical/Warning issues from the review that are still unresolved

## Gotchas

- State IDs are per-project — always query `GET /states/` first
- Use the external URL (through Traefik), not container IP
- Use Python `urllib` for API calls if curl has unicode issues (L14)
- Check if project is archived before creating issues (L8)
- REST API PATCHes trigger live browser updates automatically via SSE bridge (L15)
- Do NOT create a duplicate project if one already exists — always check registry first
