# Ariel's skills

My agent skills for Claude Code and Codex, plus a setup skill that prepares any repo with my engineering standards and the third-party skills that fit its stack.

## Install

```bash
npx skills@latest add ArielDelRio/skills -a claude-code codex
```

Add `-g` to install for your user instead of the current project. Update later with `npx skills@latest update`.

## Set up a repo

In the repo, run `/setup-ariel-skills` (Claude Code) or `$setup-ariel-skills` (Codex). It:

1. Runs `curate-agents-md`, so `AGENTS.md` is the single instruction file and `CLAUDE.md` only imports it.
2. Detects the stack and proposes **recommendations** per stack (`core`, `architecture`, `testing`, `typescript`, `web-ui`, `react`, `workers`, `vitest`, `playwright`, `mutation`, `property-based`), each one optional.
3. Shows a draft of everything it will write and waits for your confirmation.
4. Writes a managed block into `AGENTS.md`, writes `CODING_STANDARDS.md` with the applicable standards in `docs/standards/`, and installs the recommended skills at project level, recorded in `skills-lock.json`.
5. Sets up [Matt Pocock's workflow](./skills/engineering/setup-ariel-skills/MATT-WORKFLOW.md) (grill, implement, code-review, pr, retro): offers to install his skills, runs his setup here, and writes its block into `AGENTS.md`.
6. Verifies links, installed skills, the repo's check commands, and that each workflow step is ready.

Re-running it is safe: it only changes its own managed block, shows diffs for edited standards, and never updates third-party skills on its own. See [RECOMMENDATIONS.md](./skills/engineering/setup-ariel-skills/RECOMMENDATIONS.md) for what each recommendation installs.

## Skills

### Engineering

User-invoked:

- **[setup-ariel-skills](./skills/engineering/setup-ariel-skills/SKILL.md)**: Prepare a repo with my standards, agent instructions, and stack-specific skills.

Model-invoked:

- **[curate-agents-md](./skills/engineering/curate-agents-md/SKILL.md)**: Make `AGENTS.md` the single source of agent instructions and audit it. Also runs on its own when you ask to review or clean up `AGENTS.md`.

## Develop

```bash
git clone https://github.com/ArielDelRio/skills && cd skills
scripts/link-skills.sh
```

Links every skill into `~/.claude/skills` and `~/.agents/skills`, so edits here apply immediately.

## License

MIT
