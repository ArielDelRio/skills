# Changelog

## 0.7.1

Fixes from the second end-to-end run (Home Hub, 0.6.0 to 0.7.0):

- The draft is its own message with full files and diffs, written before the confirmation question.
- Row order is not a change: existing rows stay, new rows are appended. The Testing row moves last in the template.
- Exploration checks the language of `README.md`, `docs/`, and comments, and the draft proposes exceptions for differences.

## 0.7.0

Fixes from the first end-to-end run (Home Hub, 0.5.0 to 0.6.0):

- The draft must show new files in full and changes as diffs; a summary is not a draft.
- Sections are asked one at a time, and `curate-agents-md` approvals finish before exploration instead of being batched with setup questions.
- Every standard gets an **Adoption in this repo** section, not only architecture standards.
- Ask before installing dependencies needed by verification commands.
- The Language section records intentional exceptions (such as a user-facing README in another language).
- `curate-agents-md`: guidance on maintaining the instruction file is not a no-op, and pointers to non-obvious files are navigation, not a cache.

## 0.6.0

- "Profiles" are now called **recommendations** (`RECOMMENDATIONS.md`).
- New `testing` standard, always recommended and aligned with Matt's `tdd`: test levels, critical-journey selection for end-to-end tests, mutation testing as a suite-quality signal, and when each specialized test type pays off.
- New recommendations: `testing`, `mutation` (StrykerJS, mutmut, cargo-mutants, Gremlins, PIT; report-only on changed code), `property-based`.
- `playwright` adds a journey review that lists critical journeys and which are covered.
- Research behind it: `docs/research/testing-strategies.md`.

## 0.5.0

- Adopt equivalent unmarked sections in `AGENTS.md` (language, standards, verification, testing) into the managed block instead of appending a duplicate. `curate-agents-md` reports such sections when run on its own.

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
