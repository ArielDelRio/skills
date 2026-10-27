# Testing strategies for the setup skill

Research date: 2026-10-27. Scope: input for `skills/engineering/setup-ariel-skills/`, which recommends opt-in, stack-specific testing practices and agent skills. Sources are primary (official docs, author blogs/repos, papers). Claims marked "Inference" are mine and not stated by the source.

Baseline that must not be duplicated: Matt Pocock's `tdd` skill (red-green loop, tests through public interfaces at pre-agreed seams, mock only at system boundaries, implementation-coupled / tautological / horizontal-slicing anti-patterns) and `diagnosing-bugs` (build a tight red-capable feedback loop; property/fuzz loops and differential loops as bug repro techniques). Local copies: `~/.agents/skills/tdd/`, `~/.agents/skills/diagnosing-bugs/`; upstream: [mattpocock/skills](https://github.com/mattpocock/skills).

## 1. Mutation testing

### What it is and what it measures

- A tool makes small semantic changes ("mutants") to production code, e.g. inverting conditions or removing calls, and reruns the tests. A mutant is "killed" if a test fails, "survived" if all pass ([Uncle Bob, Mutation Testing](https://blog.cleancoder.com/uncle-bob/2016/06/10/MutationTesting.html)).
- What coverage misses: coverage only shows code executed, not behavior checked. "Pull out all the asserts from your tests, and your coverage remains unchanged!" ([Uncle Bob](https://blog.cleancoder.com/uncle-bob/2016/06/10/MutationTesting.html)). Cosmic Ray's docs say the same: "mutation testing will determine if your tests actually check the behavior of your code" ([Cosmic Ray](https://cosmic-ray.readthedocs.io/en/latest/)).
- Stryker states: Killed, Survived, No coverage, Timeout (counts as detected), Runtime/Compile error (excluded), Ignored. Score = "detected / valid * 100" ([Stryker, mutant states and metrics](https://stryker-mutator.io/docs/mutation-testing-elements/mutant-states-and-metrics/)). Equivalent mutants (changes that cannot alter behavior) have their own page and are the main source of noise (same source).
- Inference: this is the direct counter to the `tdd` skill's "tautological test" anti-pattern. A tautological or assertion-free test executes code (coverage green) but kills few mutants.

### Tools per stack

| Stack | Tool | Key facts |
|---|---|---|
| JS/TS | StrykerJS + `@stryker-mutator/vitest-runner` | `npm i -D @stryker-mutator/vitest-runner`, `"testRunner": "vitest"`. Always uses `perTest` coverage analysis; `vitest.related: true` by default runs only tests related to mutated files (disable if tests reach code indirectly, e.g. through API calls). Browser Mode not supported ([Stryker Vitest runner](https://stryker-mutator.io/docs/stryker-js/vitest-runner/)). |
| Java | PIT (pitest) | Maven goal `mutationCoverage`; `mutationThreshold` "Mutation score threshold at which to fail the build"; `withHistory` / `historyInputFile` / `historyOutputFile` for incremental analysis ([PIT Maven quickstart](https://pitest.org/quickstart/maven/)). |
| Python | mutmut | `pip install mutmut`, `mutmut run`, `mutmut browse`; runs pytest; "only re-tests mutants in functions whose source changed"; needs fork, so Windows requires WSL; config in `[tool.mutmut]` in `pyproject.toml`; `mutate_only_covered_lines` option ([mutmut docs](https://mutmut.readthedocs.io/en/latest/)). |
| Python | Cosmic Ray | Python 3 mutation tool with distributed/concurrent execution tutorials ([Cosmic Ray docs](https://cosmic-ray.readthedocs.io/en/latest/)). Inference: heavier setup than mutmut; reserve for large suites needing distribution. |
| Rust | cargo-mutants | `--in-diff FILE` "tests only mutants that overlap with regions changed in the diff" ([in-diff](https://mutants.rs/in-diff.html)); CI guide recommends `--in-place`, emits GitHub annotations automatically ([CI](https://mutants.rs/ci.html)). |
| Go | Gremlins | `gremlins unleash`; `--diff <git ref>` limits to changed code; `--threshold-efficacy` (exit 10) and `--threshold-mcover` (exit 11) ([unleash flags](https://gremlins.dev/latest/usage/commands/unleash/)). Still 0.x, no backward-compat guarantee, and "doesn't work very well on very big Go modules" ([README](https://github.com/go-gremlins/gremlins)). |
| Go | go-mutesting (avito-tech fork) | Mutators for arithmetic, branches, conditionals, statements; `--exec` custom runner; no diff mode documented ([README](https://github.com/avito-tech/go-mutesting)). |

### Cost and runtime

- "Mutation testing is a computationally expensive process and can take quite some time." PIT's own top advice: "The most effective way to use mutation testing is usually to limit analysis to the code that you are changing" ([PIT FAQ](https://pitest.org/faq/)).
- Uncle Bob found pitest "relatively fast" but had to split runs for a larger project ([Uncle Bob](https://blog.cleancoder.com/uncle-bob/2016/06/10/MutationTesting.html)).
- Gremlins: runs on big modules "can take hours" ([Gremlins README](https://github.com/go-gremlins/gremlins)).
- Main levers: per-test coverage (only run tests covering a mutant; Stryker `coverageAnalysis: "perTest"`, the default) and concurrency (default: cores, or cores-1 above 4) ([Stryker configuration](https://stryker-mutator.io/docs/stryker-js/configuration/)).

### Incremental and diff-based runs

- StrykerJS `--incremental`: stores results in `reports/stryker-incremental.json` and reuses killed mutants whose killing test is unchanged and survivors when no tests changed. Test-change detection is "Full" for Vitest and Jest. It does not detect dependency, env var, or `.snap` changes; `--force` reruns everything in scope. Interrupted runs resume ([Stryker incremental](https://stryker-mutator.io/docs/stryker-js/incremental/)).
- StrykerJS line ranges: `--mutate src/app.js:5-7` ([configuration](https://stryker-mutator.io/docs/stryker-js/configuration/)). Inference: the config reference documents no git-diff option, so diff-scoped runs mean passing changed files (from `git diff --name-only`) to `--mutate`, combined with `--incremental`.
- cargo-mutants PR workflow: `git diff origin/${{ github.base_ref }}.. | tee git.diff` then `cargo mutants --no-shuffle -vV --in-diff git.diff`, with `fetch-depth: 0` ([PR diff](https://mutants.rs/pr-diff.html)). Caveat: incremental runs are "not a substitute for a full test run"; test-only changes trigger no mutants ([in-diff](https://mutants.rs/in-diff.html)).
- Gremlins in CI: `--diff "origin/$GITHUB_BASE_REF"` with `fetch-depth: 0` ([unleash](https://gremlins.dev/latest/usage/commands/unleash/)).
- mutmut is incremental by default at function granularity ([mutmut](https://mutmut.readthedocs.io/en/latest/)).

### CI and code review signal

- Google runs diff-based mutation testing during mandatory code review, skipping uncovered and "uninteresting" lines; used by ~6,000 engineers on ~30% of diffs with coverage ([State of Mutation Testing at Google, ICSE-SEIP 2018](https://research.google/pubs/state-of-mutation-testing-at-google/)). Surviving mutants are surfaced as review findings ([Practical Mutation Testing at Scale](https://arxiv.org/abs/2102.11378)).
- Inference for agents: a surviving mutant on a changed line is a concrete, reviewable finding ("changing `<` to `<=` on line 42 passes all tests"). It works better as review input than as a global gate.
- Stryker Dashboard hosts reports and a score badge via the `dashboard` reporter and `STRYKER_DASHBOARD_API_KEY` ([Stryker dashboard](https://stryker-mutator.io/docs/General/dashboard/)).

### Thresholds

- Stryker defaults: `{ high: 80, low: 60, break: null }`; `break: null` never fails the build ([configuration](https://stryker-mutator.io/docs/stryker-js/configuration/)).
- PIT `mutationThreshold`, Gremlins `--threshold-efficacy` default to off (0) ([PIT](https://pitest.org/quickstart/maven/), [Gremlins](https://gremlins.dev/latest/usage/commands/unleash/)).
- Inference: no source prescribes a universal number. Start report-only (`break: null`), record the baseline score, then set `break` a few points below the baseline to prevent regressions. Do not gate on whole-repo score for diff runs.

## 2. E2E vs integration vs unit

### What the originators say

- Test pyramid: "Mike Cohn came up with this concept in his book _Succeeding with Agile_." Two rules: "Write tests with different granularity" and "The more high-level you get the fewer tests you should have" ([Ham Vocke, The Practical Test Pyramid, martinfowler.com](https://martinfowler.com/articles/practical-test-pyramid.html)).
- Same article on E2E: "you should aim to reduce the number of end-to-end tests to a bare minimum"; "Think about the high-value interactions users will have with your application. Try to come up with user journeys that define the core value of your product"; "Push your tests as far down the test pyramid as you can"; if a higher-level test finds a bug with no lower-level test failing, "you need to write a lower-level test" ([source](https://martinfowler.com/articles/practical-test-pyramid.html)).
- Google: "As a good first guess, Google often suggests a 70/20/10 split: 70% unit tests, 20% integration tests, and 10% end-to-end tests. The exact mix will be different for each team" ([Google Testing Blog, Just Say No to More End-to-End Tests](https://testing.googleblog.com/2015/04/just-say-no-to-more-end-to-end-tests.html)).
- Testing trophy (Kent C. Dodds): layers Static, Unit, Integration, E2E; quoting Guillermo Rauch, "Write tests. Not too many. Mostly integration." Testing is an investment where return is confidence and investment is time; E2E means as little mocking as possible ([The Testing Trophy and Testing Classifications](https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications)).
- Inference: both models agree E2E should be few and cover journeys; they disagree on unit vs integration weight. Matt's `tdd` skill already sides with integration-style tests at agreed seams, so the setup skill only needs the E2E part.

### Playwright best practices (official)

- Test user-visible behavior; "Only test what you control" (mock third-party via the network API); control test data ([Best practices](https://playwright.dev/docs/best-practices)).
- Isolation: "Each test should be completely isolated from another test" (same source).
- Locators: prefer `getByRole`, then `getByText`, `getByLabel`, `getByPlaceholder`, `getByAltText`, `getByTitle`, `getByTestId`; "we recommend prioritizing user-facing attributes and explicit contracts" ([Locators](https://playwright.dev/docs/locators)).
- Web-first assertions retry until the condition holds; avoid `expect(await x.isVisible())` ([Best practices](https://playwright.dev/docs/best-practices)).
- Lint: `@typescript-eslint/no-floating-promises` catches missing `await`; traces over videos for CI failures; don't trace every test (same source).
- Auth: setup project saving `storageState` to git-ignored `playwright/.auth` ("We strongly discourage checking them into private or public repositories"); one shared account for tests without server-side state, one account per worker (`testInfo.parallelIndex`) for tests that modify server state; API login via `request.storageState()` is faster ([Authentication](https://playwright.dev/docs/auth)).
- Fixtures over `beforeEach`: reusable, on-demand, composable; `test.extend`, page-object fixtures, `{ scope: 'worker' }`, `{ auto: true }` ([Fixtures](https://playwright.dev/docs/test-fixtures)).
- CLI: `--only-changed [ref]` runs changed test files; `--last-failed` reruns failures ([CLI](https://playwright.dev/docs/test-cli)).
- Test Agents: `npx playwright init-agents --loop=claude` installs planner (writes Markdown plans to `specs/`), generator, and healer; needs a `seed.spec.ts`; regenerate on Playwright upgrades ([Test agents](https://playwright.dev/docs/test-agents)).

### Procedure for an agent to propose E2E tests

Derived from the sources above (journey selection from [Vocke](https://martinfowler.com/articles/practical-test-pyramid.html), mechanics from [Playwright](https://playwright.dev/docs/best-practices)); the steps themselves are inference.

1. Inventory entry points: routes/pages, auth flows, forms that write data, payment or external integrations, from the router, README, and existing tests.
2. List candidate journeys that "define the core value of your product": sign-in, the main create/read/update path, checkout or submission, and anything whose failure is a production incident.
3. For each journey, check whether lower-level tests already cover the logic. Keep the E2E only for what needs the real browser + server wiring (routing, auth cookies, hydration, cross-page state).
4. Rank by (user impact x likelihood of wiring breakage) and propose 3-5 journeys, not more. Each gets one happy path. Edge cases go down the pyramid.
5. For each proposal state: preconditions (seeded data, account), auth strategy (shared vs per-worker storage state), third-party calls to mock, and the user-visible assertion.
6. Present as a list for the user to confirm, the same way `tdd` confirms seams. Write nothing before confirmation.
7. Optional: if the user wants generation, the Playwright planner/generator can turn confirmed journeys into `specs/*.md` and tests.

## 3. Other test types

| Type | Catches | Pays off | Doesn't pay off | Tools |
|---|---|---|---|---|
| Property-based | Inputs nobody hand-picked; shrinks to minimal counterexample. A property is "an assertion of a relationship between a code's input and output which should hold for all sets of inputs" ([fast-check](https://fast-check.dev/docs/introduction/what-is-property-based-testing/)). | Parsers, serializers (round-trip), pure transforms, invariants, stateful models (rapid state machines). Inference. | UI glue, thin CRUD, code without a stateable invariant. Inference. | TS: fast-check + official `@fast-check/vitest` (`test.prop`) ([ecosystem](https://fast-check.dev/docs/ecosystem/)). Python: Hypothesis `@given` ([docs](https://hypothesis.readthedocs.io/en/latest/)). Rust: proptest ([repo](https://github.com/proptest-rs/proptest)). Go: rapid ([repo](https://github.com/flyingmutant/rapid)). |
| Contract (Pact) | Consumer/provider API drift, without deploying everything; "contract by example" ([Pact docs](https://docs.pact.io/)). | You control both sides; multiple services; want impact of an API change "within minutes" ([convince me](https://docs.pact.io/faq/convinceme)). | Unknown consumers / public APIs: "Pact may not be for you"; use OpenAPI conformance instead ([convince me](https://docs.pact.io/faq/convinceme)). Single-repo monolith (inference). | Pact (JS, JVM, Python, Go, Rust...). |
| Snapshot | Unintended output changes. Snapshots "should be committed alongside code changes, and reviewed as part of your code review process"; Vitest never writes snapshots when `CI` is set ([Vitest snapshot](https://vitest.dev/guide/snapshot)). | Large serialized outputs, generated code, error messages; `toMatchFileSnapshot` for readable artifacts. | When updates get rubber-stamped with `-u`. Inference, and Matt's `tdd` already lists hand-derived snapshots as tautological. | Vitest, Jest, pytest-syrupy (not verified here). |
| Visual regression | Rendering/CSS regressions. `toHaveScreenshot` baselines are per browser and platform; "run tests in the same environment where the baseline screenshots were generated"; `threshold`, `maxDiffPixels`, `stylePath` to hide volatile content ([Playwright visual comparisons](https://playwright.dev/docs/test-snapshots)). | Design systems, stable marketing pages, component libraries. | Fast-changing UI, dynamic data, mixed dev OSes without a pinned CI environment. Inference from same source. | Playwright `toHaveScreenshot`. |
| Fuzzing | Crashes, panics, hangs, security bugs: "can reach edge cases which humans often miss" ([Go fuzzing](https://go.dev/doc/security/fuzz/)). Failing inputs are saved to `testdata/fuzz/` and become regression tests run by plain `go test` (same source). | Parsers, decoders, anything handling untrusted bytes. | Business logic with no crash oracle; use property tests instead. Inference. | Go: native since 1.18, `go test -fuzz`, `-fuzztime` ([Go](https://go.dev/doc/security/fuzz/)). Rust: cargo-fuzz (libFuzzer) ([book](https://rust-fuzz.github.io/book/cargo-fuzz.html)). Python: Atheris, Linux/macOS, Py 3.11+ in current source ([repo](https://github.com/google/atheris)). JS: Jazzer.js with Jest `it.fuzz` ([repo](https://github.com/CodeIntelligenceTesting/jazzer.js)). |
| Approval | Complex outputs as an approved file; lists "Getting _Legacy Code_ under tests"; `*.approved.*` files committed ([ApprovalTests.Java](https://github.com/approvals/ApprovalTests.Java), [approvaltests.com](https://approvaltests.com/)). | Characterization of legacy code before refactoring; reports/rendered text. | Greenfield code where literal assertions are clear. Inference. | ApprovalTests for Java, C#, Python, JS, Go, and more ([approvaltests.com](https://approvaltests.com/)). |

Notes:
- Hypothesis saves failures to `.hypothesis` and replays them, but "We therefore recommend against relying on the database for the correctness of your tests"; pin must-run inputs with `@example` ([replaying failures](https://hypothesis.readthedocs.io/en/latest/tutorial/replaying-failures.html)). proptest writes `proptest-regressions/`, to be committed ([proptest](https://github.com/proptest-rs/proptest)).
- rapid `MakeFuzz` turns a property test into a Go fuzz target ([rapid](https://github.com/flyingmutant/rapid)).
- Type tests: "for application development, you're rarely going to be in a position where testing your types will be worth it", but for widely consumed libraries it is "critical"; Vitest ships `expectTypeOf`/`assertType`; `tsd` is an alternative ([Matt Pocock, How to test your types](https://www.totaltypescript.com/how-to-test-your-types)).

## 4. What Matt Pocock and Robert C. Martin recommend

### Matt Pocock

- `tdd` README: "Test-driven development with a red-green-refactor loop. Builds features or fixes bugs one vertical slice at a time" ([mattpocock/skills](https://github.com/mattpocock/skills)). The current skill text drops refactor from the loop and moves it to review ([local SKILL.md](file:///Users/arieldrio/.agents/skills/tdd/SKILL.md)); his page explains: "Agents almost never did the step, and keeping implementation and review in separate sessions works better" ([aihero.dev/skills-tdd](https://www.aihero.dev/skills-tdd)).
- On compliance: "The loop is worth running even when the agent does not follow it strictly, because the results are still better overall" ([aihero.dev/skills-tdd](https://www.aihero.dev/skills-tdd)).
- Feedback loops for TS agents: typecheck script, Vitest, Husky pre-commit with lint-staged; "If any step fails, the commit is blocked and the AI gets an error message"; "TypeScript catches errors the AI would never find without testing in a browser" ([Essential AI Coding Feedback Loops](https://www.aihero.dev/essential-ai-coding-feedback-loops-for-type-script-projects)).
- `diagnosing-bugs`: "Property / fuzz loop. If the bug is 'sometimes wrong output', run 1000 random inputs" and differential loops, as bug repro techniques ([local SKILL.md](file:///Users/arieldrio/.agents/skills/diagnosing-bugs/SKILL.md)).
- Not found in his primary sources: any recommendation on mutation testing, Pact, visual regression, or E2E suite design. Gap for the setup skill to fill.

### Robert C. Martin

- Three Laws of TDD: "You must write a failing test before you write any production code." / "You must not write more of a test than is sufficient to fail, or fail to compile." / "You must not write more production code than is sufficient to make the currently failing test pass." ([The Cycles of TDD](https://blog.cleancoder.com/uncle-bob/2014/12/17/TheCyclesOfTDD.html)). Same post: specific/generic cycle; refactoring is continuous, not end-of-project.
- Test contra-variance: "The structure of your tests should not be a mirror of the structure of your code." "As the tests get more specific, the production code gets more generic." Mirroring one `XTest` per `X` causes the Fragile Test Problem ([Test Contra-variance](https://blog.cleancoder.com/uncle-bob/2017/10/03/TestContravariance.html)). Inference: consistent with Matt's "test at seams, not internals".
- Mutation testing: verifies "semantic stability"; a team using it to check a test-after suite is reasonable, though he still recommends test-first ([Mutation Testing](https://blog.cleancoder.com/uncle-bob/2016/06/10/MutationTesting.html)).
- Divergence: Uncle Bob keeps refactor inside the minute-cycle; Matt moved it to a separate review session for agents. The setup skill should not re-litigate this; defer to `tdd`.

## Recommendations for the setup skill

General rules (inference, grounded above):
- Everything is opt-in. Detect, propose with one-line "catches / costs", install only on confirmation.
- Do not restate red-green, seams, mocking, or anti-patterns; link to `tdd`. The setup skill adds suite-level quality measurement (mutation), journey selection (E2E), and specialized test types. Per-test design stays in `tdd`; bug repro loops stay in `diagnosing-bugs`.
- Cheapest step first: scoped to changed code, report-only, no CI gate until a baseline exists.

### TypeScript / Vitest

- Detection: `vitest` in `package.json` devDependencies or `vitest.config.*`.
- Mutation (StrykerJS): cheapest step is `npx stryker run --incremental --mutate <changed files>` locally, with `reports/stryker-incremental.json` git-ignored or CI-cached, `break: null`. Skip if tests use Vitest Browser Mode (unsupported). Relation to `tdd`: run after a slice goes green; a survivor on a changed line means the next red test to write, or a tautological test to fix.
- Property-based (fast-check + `@fast-check/vitest`): propose only when detection finds parsers/serializers/pure domain logic (e.g. `parse*`, `serialize*`, `encode/decode` modules). Cheapest step: one round-trip property on one module. Relation: a `tdd` seam can be tested with a property instead of an example; the seam choice stays with `tdd`.
- Snapshots: no new tooling; propose `toMatchFileSnapshot` only for large generated output. Remind that CI never writes snapshots.
- Type tests (`expectTypeOf`): only if the repo publishes a library (`"exports"`/`"types"` in `package.json`, not `"private": true`), per Matt's own guidance.

### Playwright web apps

- Detection: `@playwright/test` in devDependencies or `playwright.config.*`; for proposing adoption: a web framework (Vite, Next, Remix, SvelteKit...) and no E2E runner.
- E2E: run the procedure in section 2; propose 3-5 critical journeys. Cheapest step: an auth setup project with git-ignored `playwright/.auth` plus one happy-path journey on Chromium only. Lint `no-floating-promises`. In PRs, `--only-changed=origin/main`.
- Visual regression: only for stable UI and only if baselines can be generated in one pinned environment (CI). Cheapest step: one `toHaveScreenshot` on a design-system page with `maxDiffPixels`.
- Optional: `npx playwright init-agents --loop=claude` for planner/generator/healer.
- Relation: E2E journeys are a `tdd` seam at the outermost level; `tdd` governs how each is written, the setup skill only proposes which journeys exist.

### Python

- Detection: `pyproject.toml` / `setup.cfg` with pytest.
- Mutation (mutmut): cheapest step `mutmut run` locally (incremental by function by default), `mutate_only_covered_lines = true`. Warn: needs fork, Windows via WSL.
- Property-based (Hypothesis): cheapest step one `@given` test on a parser/validator; commit pinned `@example`s, git-ignore `.hypothesis/`.
- Fuzzing (Atheris): only for code parsing untrusted bytes, Linux/macOS.
- Contract (Pact): only when the repo is one of several services you own and calls/serves HTTP between them.

### Rust

- Detection: `Cargo.toml`.
- Mutation (cargo-mutants): cheapest step `git diff origin/main.. > git.diff && cargo mutants --in-diff git.diff`; full run nightly or on main. Strongest diff support among the tools reviewed.
- Property-based (proptest): commit `proptest-regressions/`.
- Fuzzing (cargo-fuzz): crates parsing untrusted input.

### Go

- Detection: `go.mod`.
- Fuzzing (native): zero dependencies, Go 1.18+. Cheapest step: one `FuzzXxx` on a parser with a seed via `f.Add`; seeds run in plain `go test`. Run `-fuzz` with `-fuzztime` outside the default suite.
- Mutation (Gremlins): `gremlins unleash --diff origin/main`, thresholds left at 0 initially. Flag 0.x status and slowness on large modules.
- Property-based (rapid): optional; `MakeFuzz` bridges to native fuzzing.

### Cross-stack

- Approval tests: propose only when the user asks to refactor untested legacy code (characterization). Relation: precedes the `tdd` loop; it is not part of it.
- Pact: propose only with multiple owned services; otherwise skip.

### Agent skills found on skills.sh

Real results of `npx -y skills@latest find <query>` run from `/tmp` on 2026-10-27 (install counts as reported; contents not reviewed):

- `stryker`: `secondsky/claude-skills@mutation-testing` (436), `citypaul/.dotfiles@mutation-testing` (184), `laurigates/claude-plugins@mutation-testing` (66), `jonmumm/skills@mutation-testing` (34), `managedcode/dotnet-skills@stryker` (31, .NET).
- `mutation`: no mutation-testing skill in top results (matches are GraphQL/DB mutations).
- `playwright`: `microsoft/playwright-cli@playwright-cli` (198.2K, official Microsoft; already installed here as `playwright-cli`), `anthropics/skills@webapp-testing` (189.9K).
- `e2e testing`: `currents-dev/playwright-best-practices-skill@playwright-best-practices` (99K), `wshobson/agents@e2e-testing-patterns` (24.5K).
- `property-based`: `trailofbits/skills@property-based-testing` (7K).
- `pact`: `pactflow/pactflow-agent-skills@pactflow` (137, vendor), `secondsky/claude-skills@api-contract-testing` (480).
- `fuzz`: `samber/cc-skills-golang@golang-testing` (43.7K), no generic fuzzing skill in top results.

Inference: vendor/official publishers (Microsoft, Anthropic, Trail of Bits, PactFlow) are the safer opt-in candidates. Review community mutation-testing skills before recommending; none is from the Stryker team.
