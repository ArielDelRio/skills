# Changelog

## 0.4.0

- `architecture` is always recommended; every profile, `core` included, is a recommendation the user can decline.
- Standards record the upstream commit of their supporting skill (`aligned-with` stamp) and a precedence table of where they override it.
- New `scripts/check-drift.sh`; verification reports drifted standards and proposes updates.

## 0.3.0

- Run Matt Pocock's setup inside this run (reading his user-invoked `SKILL.md`), writing its block into `AGENTS.md`; offer to install his skills at user level when missing.
- Check readiness of each step of his workflow: grill, plan, build, review, ship, improve.
- Standards index moves from `docs/standards/README.md` to root `CODING_STANDARDS.md`, which `code-review` reads and `retro` extends. Existing indexes are proposed for merge.
- Templates name skills instead of linking `.agents/skills/` paths, which break when a skill is installed at user level.

## 0.2.0

- New step 0: run `curate-agents-md` first, so `AGENTS.md` is the single instruction file and `CLAUDE.md` only imports it. The managed block always goes into `AGENTS.md`.
- Recommend running `setup-matt-pocock-skills` before this skill, and re-running `curate-agents-md` if it ran after.
- Skip profile skills that already reach the agent from a user-level install or plugin, to avoid duplicates.
- `core` adds `writing-for-agents` from `mattpocock/skills`.

## 0.1.0

- Initial version: profiles `core`, `architecture`, `typescript`, `web-ui`, `react`, `workers`, `vitest`, `playwright`; managed block in `AGENTS.md` / `CLAUDE.md`; standards for Clean Architecture and software design philosophy.
