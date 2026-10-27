# Changelog

## 0.2.0

- New step 0: run `curate-agents-md` first, so `AGENTS.md` is the single instruction file and `CLAUDE.md` only imports it. The managed block always goes into `AGENTS.md`.
- Recommend running `setup-matt-pocock-skills` before this skill, and re-running `curate-agents-md` if it ran after.
- Skip profile skills that already reach the agent from a user-level install or plugin, to avoid duplicates.
- `core` adds `writing-for-agents` from `mattpocock/skills`.

## 0.1.0

- Initial version: profiles `core`, `architecture`, `typescript`, `web-ui`, `react`, `workers`, `vitest`, `playwright`; managed block in `AGENTS.md` / `CLAUDE.md`; standards for Clean Architecture and software design philosophy.
