---
name: setup-ariel-skills
description: "Prepare this repo with my engineering standards, agent instructions, and the third-party skills that fit its stack. Safe to re-run to update."
disable-model-invocation: true
metadata:
  version: "0.7.1"
---

# Setup Ariel's skills

Prepare the current repository so any agent (Claude Code, Codex) works in it with my conventions:

- **Agent instructions**: `AGENTS.md` as the single instruction file (curated first), with a managed block holding language rules, standards discovery, and verification commands.
- **Standards**: `CODING_STANDARDS.md` at the root indexing `docs/standards/`, with the design and architecture conventions that apply.
- **Skills**: project-level third-party skills chosen from **recommendations** that match the detected stack, installed with `npx skills` and recorded in `skills-lock.json`.
- **Workflow**: Matt Pocock's development loop (grill, implement, code-review, pr, retro), with his setup run here and each step checked for readiness.

This is a prompt-driven skill. Explore, present what you found, confirm with the user, then write. Every write is a **merge** into what exists: local edits survive, conflicts are shown to the user, and a second run on an unchanged repo writes nothing.

The setup version is `metadata.version` above. It is stamped into every file this skill writes, so a later run can tell what an earlier one installed.

## Process

### 0. Curate the agent files

Call the Skill tool with `curate-agents-md` and let it finish, including the user's approval of its changes, before step 1. Its questions are asked and answered on their own, never folded into this skill's sections. Every later step writes into the `AGENTS.md` it leaves behind, with `CLAUDE.md` only importing it.

### 1. Explore

Read whatever exists; assume nothing:

- Manifests and config: `package.json` (dependencies, scripts, `packageManager`, `engines`), lockfiles, `tsconfig.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `wrangler.toml` / `wrangler.json` / `wrangler.jsonc`, `biome.json`, ESLint / Prettier / Oxlint configs, `vitest.config.*`, `playwright.config.*`.
- `AGENTS.md`: is there already a `setup-ariel-skills` managed block? Which version?
- `CODING_STANDARDS.md`, `docs/standards/`, and `docs/testing.md`: present? stamped by this skill? edited since? A `docs/standards/README.md` index is the layout of versions before 0.3.0.
- `skills-lock.json`, `.agents/skills/`, `.claude/skills/`: what is already installed at project level, and from which source.
- Your available skills: which recommended skills already reach the agent from a user-level install or a plugin (for example, Matt's skills installed globally).
- Languages: which language `README.md`, `docs/`, and code comments are written in. Where any differ from the Language section of `templates/agents-block.md` (or an existing language policy), Section B of step 3 asks whether each is an intentional exception.
- `.gitignore`: does it ignore `.agents/`, `.claude/`, or `skills-lock.json`?
- Source layout: is there business behavior behind platform integrations (HTTP, database, queues, UI), or is this a library, CLI, or script collection?
- Matt's workflow: which skills in the availability table of [MATT-WORKFLOW.md](./MATT-WORKFLOW.md) are among your available skills, whether his Claude Code plugin is installed, and whether `docs/agents/` already holds his setup's output.

Then match the repo against every recommendation in [RECOMMENDATIONS.md](./RECOMMENDATIONS.md). The completion criterion: each recommendation is marked **detected**, **not detected**, or **ambiguous**, with the signal that decided it.

### 2. Present findings and ask

Summarise the stack and what this skill already installed (if anything). Then take the sections in order: ask one section, wait for its answer, then the next. Batching sections into one prompt hides the later ones behind the first answer. Lead each with the recommended answer so the user can accept it in a word. Skip a section when exploration already settled it.

**Section A: Recommendations.** List the recommended ones (`core`, `architecture`, and every detected one) with their skills and standards, then ambiguous ones with the question that settles them. The user accepts, adds, or drops any of them, `core` included.

**Section B: Already available skills.** For each recommended skill that already reaches the agent from a user-level install or plugin, recommend **skipping** the project install: the same skill twice shows up twice and can drift. Offer the project install only if the user wants the repo self-contained (cloud agents, other machines).

**Section C: Toolchain offers.** Only the offers listed by accepted recommendations in `RECOMMENDATIONS.md` whose preconditions hold (for example, adopting Ultracite when no linter is configured). Each is a separate yes/no. Default is **no** for anything that replaces existing tooling.

**Section D: Version control for skills.** Recommend committing `.agents/skills/`, `.claude/skills/`, and `skills-lock.json` so cloud agents and other machines get the same skills. Ask only if `.gitignore` currently excludes them.

**Section E: Matt's workflow.** Following [MATT-WORKFLOW.md](./MATT-WORKFLOW.md): if any of his workflow skills are missing, recommend installing them (user level by default), then recommend running his setup as part of this run. Two separate yes/no answers. The workflow is the default; the user can opt out of it entirely.

### 3. Draft and confirm

Write the **draft** as its own message, before any confirmation question. The question then asks only whether to apply the draft above; it never stands in for it. The draft contains:

- Equivalent sections found in `AGENTS.md`, and the proposed adoption of each.
- The managed block for `AGENTS.md`, built from [templates/agents-block.md](./templates/agents-block.md) with the sections of accepted recommendations, as a diff against the current block.
- Every file to be created, in full, including its **Adoption in this repo** section.
- Every existing file to be changed, as a diff.
- The exact `npx skills add` commands.
- Any toolchain change accepted in Section C.
- The install command for Matt's skills, if accepted in Section E.
- Each language difference found in step 1, with the proposed exception line for the Language section, for the user to accept or reject.

A summary of what will change is not a draft: the user confirms the actual text. Let them edit it. Nothing is written until they confirm.

### 4. Write

**Agent file.** Write into the root `AGENTS.md`. The managed block is delimited by:

```markdown
<!-- setup-ariel-skills:start v<version> -->
...
<!-- setup-ariel-skills:end -->
```

If the markers exist, replace only what lies between them and update the version. Otherwise, before appending, look for **equivalent sections**: unmarked sections covering the same topic as a block section (a language policy, a pointer to standards, verification commands, a testing pointer), typically left by a manual setup or an earlier tool. For each, propose **adopting** it: its repo-specific facts (extra checks, runtime caveats, language exceptions) move into the corresponding block section, and the unmarked section is removed, so each topic is stated once. Show the result as a diff in step 3. Append the block at the end of the file only after equivalent sections are adopted or the user chose to keep them. Never edit content outside the markers. If text outside the block contradicts it (for example, a different documentation language), point that out to the user instead of changing it.

**Standards.** Copy [templates/CODING_STANDARDS.md](./templates/CODING_STANDARDS.md) to the root and the templates from [templates/standards/](./templates/standards/) into `docs/standards/` for accepted recommendations, replacing `<version>` in each stamp with this skill's version. Without the `architecture` recommendation, drop the Clean Architecture row from `CODING_STANDARDS.md`, and from `software-design-philosophy.md` the "Fit with Clean Architecture" section and the precedence-table row that links it; without `web-ui`, drop the UI design guidance section. Row order in an index or table is not a change: keep existing rows where they are and add new ones at the end. For a file that already exists, compare it with the template, ignoring its **Adoption in this repo** section (and, for `CODING_STANDARDS.md`, its **Rules** section, which `retro` and the user own):

- Identical: leave it.
- Different: show the diff and let the user choose per file between taking the template (keeping the Adoption section) and keeping the local file. Local edits are never discarded without that choice.

Keep each `aligned-with` stamp exactly as the template has it: it records which upstream revision of the supporting skill the standard was checked against.

After copying, add an **Adoption in this repo** section to each standard: two to four sentences on where current code stands against it (for example, a module that mixes business rules with SQL, or journeys without end-to-end tests), with real paths. Keep `CODING_STANDARDS.md` listing only the standards actually present. If a `docs/standards/README.md` index exists, propose merging it into `CODING_STANDARDS.md` and removing it, so standards have one index.

**Testing guide.** When the `testing` recommendation is accepted and `docs/testing.md` is missing, write it from the repo's real scripts and configs: the commands, what each suite covers, and what local runs cannot verify (bindings, auth, deployed runtime). Read the commands from `package.json` or the equivalent; never invent one. Without the `testing` recommendation, drop its row from `CODING_STANDARDS.md`.

**Journey review.** When `playwright` is accepted (or adopted in this run), apply the **End-to-end journeys** procedure of [templates/standards/testing.md](./templates/standards/testing.md) to this repo: list its critical journeys, check which existing end-to-end tests cover each, and present the list with covered or missing. After the user confirms, record it under **Critical journeys** in `docs/testing.md`. Writing the missing tests is outside this skill: offer them as follow-up work for `tdd` or the issue tracker.

**Skills.** From the repo root, for each skill of each accepted recommendation not already in `skills-lock.json`:

```bash
npx skills@latest add <source> --skill <name> -a claude-code codex -y
```

This installs into `.agents/skills/<name>` (read by Codex), links it from `.claude/skills/<name>` (read by Claude Code), and records source and hash in `skills-lock.json`. Skip a skill already present from the same source, and a skill the user chose to skip in Section B. If it is present from a different source, ask which to keep. Updating an installed skill is a separate step: mention `npx skills@latest update -p` to the user rather than running it.

**Toolchain.** Apply only the changes accepted in Section C, using the commands `RECOMMENDATIONS.md` gives.

**Matt's skills and setup.** If accepted in Section E, run the install command, then carry out his setup as described in [MATT-WORKFLOW.md](./MATT-WORKFLOW.md), with its own confirmations.

### 5. Verify

The completion criterion: every check below passes, or its failure is reported to the user with the output.

- Every relative link in the managed block and in `CODING_STANDARDS.md` resolves to an existing file.
- Every skill of every accepted recommendation appears in `skills-lock.json` and as `.agents/skills/<name>/SKILL.md`, and `.claude/skills/<name>` resolves to it.
- The verification commands written into the managed block run. If they need dependencies that are not installed, ask before installing them with the repo's documented install command; installing changes the user's environment. Report failures; fixing pre-existing failures is outside this skill.
- **Drift**: from the repo root, run `bash <this skill's folder>/scripts/check-drift.sh docs/standards/*.md`. For each drifted standard, read the upstream changes it lists, and report whether they contradict the standard, add guidance worth adopting, or are irrelevant. Propose edits to the repo's standard for the first two, and update its stamp to the latest commit once the user accepts or dismisses them. Tell the user when the drift also affects this skill's templates, which are maintained in `ArielDelRio/skills`.
- Unless the user opted out of Matt's workflow, every readiness check in [MATT-WORKFLOW.md](./MATT-WORKFLOW.md) has been run.
- `git status` shows only the files this run intended to touch.

### 6. Done

Report what was installed (recommendations, skills with sources, files written or proposed) in a few lines, then the workflow readiness: one line per step (grill, plan, build, review, ship, improve) with ready or the missing prerequisite.

Re-running this skill later applies a newer version of its templates and installs skills for recommendations added since. It never updates third-party skills silently.
