# Recommendations

A **recommendation** bundles what a repo gets for one part of its stack: skills to install, standards to copy, managed-block sections, and toolchain offers. Install only what an accepted recommendation lists, so a backend repo never receives UI guidance and a Python repo never receives TypeScript tooling.

The user accepts or declines each recommendation; nothing is imposed on the repo.

A skill paired with a standard is kept coherent with it: the standard records the upstream commit it was aligned with (`aligned-with` stamp) and a table of where it overrides the skill. `scripts/check-drift.sh` reports when that skill changed upstream since.

A skill that already reaches the agent from a user-level install or plugin is skipped by default (see Section B of `SKILL.md`). Sources were reviewed when added. The installed revision of each skill is recorded by hash in the target repo's `skills-lock.json`.

## core

Always on.

- **Detect**: any repo.
- **Skills**: `writing-for-agents` from `mattpocock/skills` (used by `curate-agents-md`); `software-design-philosophy` from `wondelai/skills`.
- **Standards**: `README.md`, `software-design-philosophy.md`.
- **Block sections**: Language, Engineering standards, Verification.

## architecture

- **Detect**: always recommended. Note the fit when presenting it: strong for an application or service where business behavior meets platform integrations (HTTP handlers, database access, queues, UI state); weak for libraries, CLIs, config repos, and script collections, where the user may prefer to decline.
- **Skills**: `architecture-patterns` from `wshobson/agents`.
- **Standards**: `clean-architecture.md`.

## testing

- **Detect**: always recommended. Fit is strong wherever the repo has, or should have, a test runner.
- **Standards**: `testing.md`.
- **Block sections**: Testing.
- **Writes**: `docs/testing.md` when missing.

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
- **Block sections**: in Verification, the unit test script.

## playwright

- **Detect**: `@playwright/test` in dependencies, or a `playwright.config.*`. **Ambiguous** for a web app without an end-to-end runner: offer adopting Playwright.
- **Block sections**: in Verification, the end-to-end script.
- **Writes**: in `docs/testing.md`, the browser install command, where reports go, and the **Critical journeys** list from the journey review.
- **Journey review**: see step 4 of `SKILL.md`.
- **Toolchain offer**: when no end-to-end runner exists, `npm init playwright@latest`. When Playwright exists without saved auth state and the app has sign-in, an auth setup project writing to a Git-ignored `playwright/.auth/`.

## mutation

- **Detect**: a supported test runner. Fit is strong for repos with business logic and an existing suite; weak for a suite that barely exists, where tests come first.
- **Toolchain offer**, by stack, always report-only and scoped to changed code:

  | Stack | Tool | Cheapest step |
  | --- | --- | --- |
  | TS/JS with Vitest | StrykerJS with `@stryker-mutator/vitest-runner` | `npx stryker run --incremental --mutate <changed files>` with `thresholds.break: null`; Git-ignore `reports/`. Not for Vitest Browser Mode. |
  | Python with pytest | mutmut | `mutmut run` (incremental by function); Windows needs WSL. |
  | Rust | cargo-mutants | `git diff origin/main.. > git.diff && cargo mutants --in-diff git.diff` |
  | Go | Gremlins | `gremlins unleash --diff origin/main`; still 0.x and slow on large modules. |
  | Java | PIT | Maven or Gradle plugin with history files for incremental runs. |

- **Block sections**: in Testing, the mutation command and that it is report-only.
- **Skills**: none. Community mutation-testing skills exist, but none from a tool's maintainers; propose one only after the user reviews it.

## property-based

- **Detect**: modules that parse, serialize, encode, or validate (names like `parse*`, `serialize*`, `encode*`, `decode*`, `*schema*`), or pure domain logic with invariants. Otherwise not detected.
- **Toolchain offer**: TS/JS `fast-check` with `@fast-check/vitest`; Python `hypothesis`; Rust `proptest`; Go `rapid`. Cheapest step: one round-trip or invariant property on one detected module, chosen with the user.
- **Skills**: `property-based-testing` from `trailofbits/skills`, offered for the user to review before installing.
