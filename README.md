# Ariel's skills

My agent skills for Claude Code and Codex, plus a setup skill that prepares any repo with my engineering standards and the third-party skills that fit its stack.

## Install

```bash
npx skills@latest add ArielDelRio/skills -a claude-code codex
```

Add `-g` to install for your user instead of the current project. Update later with `npx skills@latest update`.

## Set up a repo

In the repo, run `/setup-ariel-skills` (Claude Code) or `$setup-ariel-skills` (Codex). It:

1. Detects the stack and proposes **profiles** (`core`, `architecture`, `typescript`, `web-ui`, `react`, `workers`, `vitest`, `playwright`).
2. Shows a draft of everything it will write and waits for your confirmation.
3. Writes a managed block into `AGENTS.md` / `CLAUDE.md`, copies the applicable standards into `docs/standards/`, and installs the profile skills at project level, recorded in `skills-lock.json`.
4. Verifies links, installed skills, and the repo's check commands.

Re-running it is safe: it only changes its own managed block, shows diffs for edited standards, and never updates third-party skills on its own. See [PROFILES.md](./skills/engineering/setup-ariel-skills/PROFILES.md) for what each profile installs.

## Skills

### Engineering

User-invoked:

- **[setup-ariel-skills](./skills/engineering/setup-ariel-skills/SKILL.md)**: Prepare a repo with my standards, agent instructions, and stack-specific skills.

## Develop

```bash
git clone https://github.com/ArielDelRio/skills && cd skills
scripts/link-skills.sh
```

Links every skill into `~/.claude/skills` and `~/.agents/skills`, so edits here apply immediately.

## License

MIT
