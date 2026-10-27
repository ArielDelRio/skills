---
name: setup-ariel-skills
description: "Prepare this repo with my engineering standards, agent instructions, and the third-party skills that fit its stack. Safe to re-run to update."
disable-model-invocation: true
metadata:
  version: "0.2.0"
---

# Setup Ariel's skills

Prepare the current repository so any agent (Claude Code, Codex) works in it with my conventions:

- **Agent instructions**: `AGENTS.md` as the single instruction file (curated first), with a managed block holding language rules, standards discovery, and verification commands.
- **Standards**: `docs/standards/` with the design and architecture conventions that apply.
- **Skills**: project-level third-party skills chosen by **profile** from the detected stack, installed with `npx skills` and recorded in `skills-lock.json`.

This is a prompt-driven skill. Explore, present what you found, confirm with the user, then write. Every write is a **merge** into what exists: local edits survive, conflicts are shown to the user, and a second run on an unchanged repo writes nothing.

The setup version is `metadata.version` above. It is stamped into every file this skill writes, so a later run can tell what an earlier one installed.

## Process

### 0. Curate the agent files

Call the Skill tool with `curate-agents-md` and let it finish, including the user's approval of its changes. Every later step writes into the `AGENTS.md` it leaves behind, with `CLAUDE.md` only importing it.

If `setup-matt-pocock-skills` is among your available skills and `docs/agents/issue-tracker.md` is missing, tell the user that running `/setup-matt-pocock-skills` before this skill is recommended: it writes its `## Agent skills` block into `CLAUDE.md` when that file exists, so running it first lets this step move the block into `AGENTS.md`. Continue if the user prefers to skip it.

### 1. Explore

Read whatever exists; assume nothing:

- Manifests and config: `package.json` (dependencies, scripts, `packageManager`, `engines`), lockfiles, `tsconfig.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `wrangler.toml` / `wrangler.json` / `wrangler.jsonc`, `biome.json`, ESLint / Prettier / Oxlint configs, `vitest.config.*`, `playwright.config.*`.
- `AGENTS.md`: is there already a `setup-ariel-skills` managed block? Which version?
- `docs/standards/` and `docs/testing.md`: present? stamped by this skill? edited since?
- `skills-lock.json`, `.agents/skills/`, `.claude/skills/`: what is already installed at project level, and from which source.
- Your available skills: which profile skills already reach the agent from a user-level install or a plugin (for example, Matt's skills installed globally).
- `.gitignore`: does it ignore `.agents/`, `.claude/`, or `skills-lock.json`?
- Source layout: is there business behavior behind platform integrations (HTTP, database, queues, UI), or is this a library, CLI, or script collection?
- `docs/agents/issue-tracker.md` and whether `setup-matt-pocock-skills` is among your available skills.

Then match the repo against every profile in [PROFILES.md](./PROFILES.md). The completion criterion: each profile is marked **detected**, **not detected**, or **ambiguous**, with the signal that decided it.

### 2. Present findings and ask

Summarise the stack and what this skill already installed (if anything). Then take the sections in order, one answer per section. Lead each with the recommended answer so the user can accept it in a word. Skip a section when exploration already settled it.

**Section A: Profiles.** List detected profiles with their skills, then ambiguous ones with the question that settles them. The user accepts, adds, or drops profiles. `core` is always on.

**Section B: Already available skills.** For each profile skill that already reaches the agent from a user-level install or plugin, recommend **skipping** the project install: the same skill twice shows up twice and can drift. Offer the project install only if the user wants the repo self-contained (cloud agents, other machines).

**Section C: Toolchain offers.** Only the offers listed by accepted profiles in `PROFILES.md` whose preconditions hold (for example, adopting Ultracite when no linter is configured). Each is a separate yes/no. Default is **no** for anything that replaces existing tooling.

**Section D: Version control for skills.** Recommend committing `.agents/skills/`, `.claude/skills/`, and `skills-lock.json` so cloud agents and other machines get the same skills. Ask only if `.gitignore` currently excludes them.

### 3. Draft and confirm

Show the user, before writing:

- The managed block for `AGENTS.md`, built from [templates/agents-block.md](./templates/agents-block.md) with the sections of accepted profiles.
- The list of standards files to create or update, and for each existing one, the diff between it and the new template.
- The exact `npx skills add` commands.
- Any toolchain change accepted in Section C.

Let the user edit the draft. Nothing is written until they confirm.

### 4. Write

**Agent file.** Write into the root `AGENTS.md`. The managed block is delimited by:

```markdown
<!-- setup-ariel-skills:start v<version> -->
...
<!-- setup-ariel-skills:end -->
```

If the markers exist, replace only what lies between them and update the version. Otherwise append the block at the end of the file. Never edit content outside the markers. If text outside the block contradicts it (for example, a different documentation language), point that out to the user instead of changing it.

**Standards.** Copy the templates from [templates/standards/](./templates/standards/) into `docs/standards/` for accepted profiles, replacing `<version>` in the stamp with this skill's version. Without the `architecture` profile, drop the Clean Architecture row from `README.md` and the "Fit with Clean Architecture" section from `software-design-philosophy.md`; without `web-ui`, drop the UI design guidance section. For a file that already exists, compare it with the template, ignoring its **Adoption in this repo** section:

- Identical: leave it.
- Different: show the diff and let the user choose per file between taking the template (keeping the Adoption section) and keeping the local file. Local edits are never discarded without that choice.

After copying, add an **Adoption in this repo** section to each architecture standard: two to four sentences on where current code stands against the target (for example, a module that mixes business rules with SQL), with real paths. Keep `docs/standards/README.md` listing only the standards actually present.

**Testing guide.** When a test or lint profile is accepted and `docs/testing.md` is missing, write it from the repo's real scripts and configs: the commands, what each suite covers, and what local runs cannot verify (bindings, auth, deployed runtime). Read the commands from `package.json` or the equivalent; never invent one.

**Skills.** From the repo root, for each skill of each accepted profile not already in `skills-lock.json`:

```bash
npx skills@latest add <source> --skill <name> -a claude-code codex -y
```

This installs into `.agents/skills/<name>` (read by Codex), links it from `.claude/skills/<name>` (read by Claude Code), and records source and hash in `skills-lock.json`. Skip a skill already present from the same source, and a skill the user chose to skip in Section B. If it is present from a different source, ask which to keep. Updating an installed skill is a separate step: mention `npx skills@latest update -p` to the user rather than running it.

**Toolchain.** Apply only the changes accepted in Section C, using the commands `PROFILES.md` gives.

### 5. Verify

The completion criterion: every check below passes, or its failure is reported to the user with the output.

- Every relative link in the managed block and in `docs/standards/README.md` resolves to an existing file.
- Every skill of every accepted profile appears in `skills-lock.json` and as `.agents/skills/<name>/SKILL.md`, and `.claude/skills/<name>` resolves to it.
- The verification commands written into the managed block run. Report failures; fixing pre-existing failures is outside this skill.
- `git status` shows only the files this run intended to touch.

### 6. Done

Report what was installed (profiles, skills with sources, files written or proposed) in a few lines.

If `setup-matt-pocock-skills` was skipped in step 0, remind the user that it configures the issue tracker, triage labels, and domain docs, which this skill leaves to it, and that `curate-agents-md` should run again afterwards to move its block into `AGENTS.md`.

Re-running this skill later applies a newer version of its templates and installs skills for profiles added since. It never updates third-party skills silently.
