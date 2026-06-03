---
name: intake
description: Evaluate incoming materials (files, directories, data) and triage them into the Work Vault's project structure — matching to existing projects or proposing new ones. Use this skill whenever the user points you at files to organize, says "intake these", "file these", "where do these go", "organize these into the vault", "I got files from [someone]", "process these materials", drops a path and says "figure out where this goes", or has external documents (specs, reports, data, reference material) that need a home in the project structure. Also trigger when the user receives deliverables from collaborators (a manager, a teammate, a contractor) and wants them properly filed as reference material for future work. Even casual requests like "someone sent me some stuff, here" or "put these somewhere useful" with a file path should trigger this skill.
---

# Material Intake

You are triaging incoming materials into an Obsidian-based Work Vault. Your job is to read the materials, understand them, figure out where they belong in the existing project structure, and get the user's approval before placing them.

## Path Resolution

Read `~/.claude/wfk-paths.json` at startup. Use `vault_root` and `paths` to resolve directory references (e.g., `{paths.projects}/` for the project tree). If the file doesn't exist, use defaults and warn once.

## The Work Vault

The vault lives at `<VAULT_ROOT>/`. Projects are under `02_Projects/` and organized into umbrella groups ({{ORG}} Apps, {{ORG}} Intelligence, Infrastructure, Restaurant Ops) and standalone projects. Every project follows a standard structure:

```
02_Projects/<group>/<project-name>/
├── CLAUDE.md
├── lessons.md
├── specs/
│   └── YYYY-MM-DD/
├── plans/
│   └── YYYY-MM-DD/
├── reports/
│   └── YYYY-MM-DD/
└── reviews/
    └── YYYY-MM-DD/
```

Before you do anything, scan the current project structure so you know what exists:

```bash
find "<VAULT_ROOT>/02_Projects" -maxdepth 3 -type d | head -80
```

Also read the vault's `CLAUDE.md` and `AGENTS.md` for any routing rules or conventions that might affect placement.

## Step 1: Read and Understand the Materials

Read every file the user pointed you at. For directories, list the contents and read each file. As you go, build a mental model of:

- **What each file is about** — the domain, the purpose, the level of detail
- **Who produced it and why** — context about the source helps with filing
- **How the files relate to each other** — are they parts of a whole? Independent topics? Different levels of detail on the same subject?
- **Whether any single file covers multiple distinct topics** — these may need splitting

Take your time here. A good triage depends on actually understanding the content, not just skimming titles.

## Step 2: Match Against Existing Projects

For each piece of material (or logical group of related materials), ask yourself:

1. Does this clearly belong to an existing project? Check not just by name but by reading the project's `CLAUDE.md` to understand its scope.
2. Is this adjacent to an existing project but not quite within its scope? Maybe it extends an existing project's mandate.
3. Is this something entirely new that needs its own project?

When matching, consider:
- The project's stated scope in its `CLAUDE.md`
- Related specs and plans already in the project
- The umbrella group the project sits under — does the material fit that group's theme?
- Whether other projects depend on or relate to this material

## Step 3: Handle Multi-Topic Files

If a single file covers multiple distinct topics that map to different projects, plan to split it. Each split should:
- Be a complete, self-contained document
- Preserve all relevant context from the original (don't lose shared preamble or cross-references)
- Get a clear filename that reflects its specific content

## Step 4: Present Your Assessment

Present a detailed analysis to the user. For each file or group of files, explain:

- **What it contains** — a concise summary of the material
- **Where you'd place it** — the specific project path and why
- **Whether it's an existing project or new** — and if new, what the project would be called and which umbrella group it fits under
- **Any files that need splitting** — what the splits would be and where each piece goes
- **Confidence level** — flag anything you're uncertain about

Format the assessment clearly so the user can scan it quickly. Group related files together rather than listing each one independently when they obviously belong to the same project.

## Step 5: Clarify Before Acting

After presenting your assessment, ask the user one question at a time about anything you're unsure of. Common things to clarify:

- Whether a new project should be standalone or under an umbrella group
- The preferred name for a new project directory
- Whether a borderline file belongs to project A or project B
- Whether the user wants to handle a multi-topic file differently than you proposed

Do not proceed until the user gives you the go-ahead. A simple "looks good" or "do it" is sufficient.

## Step 6: Execute the Filing

Once approved, do the work:

### For existing projects:
1. Create a source material subfolder if one doesn't exist. Name it after the source — e.g., `<Sender> Files/`, `<Team> Specs/`, or whatever makes sense for who sent the material.
2. Copy the original files into that subfolder, preserving them exactly as-is.

### For new projects:
1. Create the project directory under the appropriate umbrella group (or as a standalone under `02_Projects/`).
2. Create the full scaffold:
   ```
   project-name/
   ├── CLAUDE.md
   ├── lessons.md
   ├── specs/
   ├── plans/
   ├── reports/
   └── reviews/
   ```
3. Write a starter `CLAUDE.md` that captures the project's scope based on what you learned from the materials. Include a brief description of what the project is, its key domains, and any known dependencies on other projects. Follow the style of existing project CLAUDE.md files in the vault.
4. Write an empty `lessons.md` with the standard template.
5. Create the source material subfolder and copy the originals in.

### For split files:
1. Split the original into separate files, each self-contained.
2. Place each split file in the appropriate project's source material subfolder.
3. Also keep a copy of the unsplit original alongside the splits so nothing is lost.

### Frontmatter and naming:
- Source material files keep their original names — do not rename or add prefixes. These are reference materials, not vault-native documents.
- If you create any new vault-native documents (like the CLAUDE.md), follow the vault's frontmatter and naming conventions.

## Step 7: Suggest Next Steps

After filing is complete, briefly suggest logical next actions for each project that received materials. Tailor suggestions to the material's readiness:

- **Spec-ready material** (detailed requirements, user stories, technical specs): suggest `/create-note SPC` to formalize it
- **Early-stage ideas** (overviews, placeholders, rough briefs): suggest the user review the material and flesh it out before spec'ing
- **Data or reference material** (datasets, API docs, research): note that it's filed and available for when the relevant project needs it
- **Material that raises questions**: suggest specific questions the user might want to ask the source (e.g., "App 3 is marked as a placeholder — worth asking the sender for more detail before spec'ing")

Keep this brief — a sentence or two per project. The user will decide what to prioritize.
