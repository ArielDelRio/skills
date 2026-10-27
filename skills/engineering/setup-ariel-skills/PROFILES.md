# Profiles

A **profile** bundles what a repo gets for one part of its stack: skills to install, standards to copy, managed-block sections, and toolchain offers. Install only what a detected or accepted profile lists, so a backend repo never receives UI guidance and a Python repo never receives TypeScript tooling.

A skill that already reaches the agent from a user-level install or plugin is skipped by default (see Section B of `SKILL.md`). Sources were reviewed when added. The installed revision of each skill is recorded by hash in the target repo's `skills-lock.json`.

## core

Always on.

- **Detect**: any repo.
- **Skills**: `writing-for-agents` from `mattpocock/skills` (used by `curate-agents-md`); `software-design-philosophy` from `wondelai/skills`.
- **Standards**: `README.md`, `software-design-philosophy.md`.
- **Block sections**: Language, Engineering standards, Verification.

## architecture

- **Detect**: an application or service where business behavior meets platform integrations (HTTP handlers, database access, queues, UI state). **Not detected** for libraries, CLIs, config repos, and script collections. **Ambiguous** for a small app with little business logic: ask.
- **Skills**: `architecture-patterns` from `wshobson/agents`.
- **Standards**: `clean-architecture.md`.

## typescript

- **Detect**: `tsconfig.json`, or `typescript` in dependencies.
- **Skills**: `ultracite` from `haydenbleasel/ultracite`, only when Ultracite is configured (an `ultracite` dependency, or a Biome / Oxlint / ESLint config extending `ultracite`) or adopted in this run.
- **Block sections**: in Verification, the type check (`npx tsc --noEmit`, or the repo's own `typecheck` script) and the lint/format scripts.
- **Toolchain offer**: when no linter or formatter is configured, offer `npx ultracite@latest init` (it asks for backend and integrations interactively; let the user answer). When ESLint or Prettier is configured, offer nothing unless the user asks to migrate.

## web-ui

- **Detect**: a UI framework dependency (`react`, `vue`, `svelte`, `solid-js`, `@angular/core`), or HTML entry points with app code.
- **Skills**: `frontend-design` from `anthropics/skills`; `web-design-guidelines` from `vercel-labs/agent-skills`.
- **Standards**: the UI design guidance section of `README.md`.

## react

- **Detect**: `react` in dependencies.
- **Skills**: `vercel-react-best-practices` from `vercel-labs/agent-skills`.

## workers

- **Detect**: `wrangler.toml`, `wrangler.json`, `wrangler.jsonc`, or `wrangler` in dependencies.
- **Skills**: `workers-best-practices` from `cloudflare/skills`.
- **Block sections**: in Verification, note that local runs do not verify bindings or the deployed runtime.

## vitest

- **Detect**: `vitest` in dependencies.
- **Skills**: `vitest` from `antfu/skills`.
- **Block sections**: Testing.
- **Writes**: `docs/testing.md` when missing.

## playwright

- **Detect**: `@playwright/test` in dependencies, or a `playwright.config.*`.
- **Block sections**: Testing.
- **Writes**: `docs/testing.md` when missing, including the browser install command and where reports go.
