<!-- setup-ariel-skills v<version> -->
<!-- aligned-with: mattpocock/skills skills/engineering/tdd 3f599139104dfceabc7754eeb91319802f85e042 -->
# Testing

## Scope and authority

Apply this standard when deciding which kinds of tests a change or a project needs, when proposing end-to-end tests, and when judging whether a suite actually checks behavior. How to write each test (the red-green loop, seams, mocking, anti-patterns) belongs to the `tdd` skill; reproducing a bug belongs to `diagnosing-bugs`. This standard covers what those leave out: the mix of test levels, which journeys deserve end-to-end tests, suite quality, and specialized test types.

## Test levels

Push each test as far down as it can go. A unit or integration test at a seam is the default; end-to-end tests are few and cover journeys, not rules. When an end-to-end test finds a bug no lower-level test caught, add the lower-level test too.

Structure tests around behavior, not around the production code's structure. One test file per production class mirrors the code and makes tests break on refactors.

Sources: [The Practical Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html), [The Testing Trophy](https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications), [Test Contra-variance](https://blog.cleancoder.com/uncle-bob/2017/10/03/TestContravariance.html).

## End-to-end journeys

End-to-end tests protect the **critical journeys**: the user paths that define the product's core value, whose failure would be an incident. To choose or review them:

1. Inventory entry points: routes, auth flows, forms that write data, payments and external integrations.
2. List candidate journeys: sign-in, the main create/read/update path, submission or checkout.
3. Drop the logic lower-level tests already cover. Keep what needs the real browser and server together: routing, auth cookies, hydration, cross-page state.
4. Rank by user impact and likelihood of wiring breakage. Keep three to five, one happy path each; edge cases go down a level.
5. For each, state the preconditions (seeded data, account), the auth strategy, the third-party calls to mock, and the user-visible assertion.
6. Confirm the list with the user before writing any test.

Record the confirmed journeys, and whether each is covered, in `docs/testing.md`.

For Playwright: locate by role and accessible name first, use web-first assertions, isolate every test, mock only what the project does not control, keep saved auth state in a Git-ignored `playwright/.auth/`, and prefer fixtures over `beforeEach`. See [Playwright best practices](https://playwright.dev/docs/best-practices) and [authentication](https://playwright.dev/docs/auth).

## Suite quality: mutation testing

Coverage shows which code ran, not which behavior was checked. Mutation testing makes small changes to production code (flipping `<` to `<=`, removing a call) and reruns the tests; a **surviving mutant** is a change no test noticed.

- Scope runs to changed code; whole-repo runs are slow and belong on a schedule, if anywhere.
- Treat a survivor on a changed line as a review finding: either a missing test (the next red test for `tdd`) or a test that executes code without asserting on it.
- Start report-only. Record the baseline score, then fail the build only on a drop below it. A universal threshold has no basis.
- Ignore equivalent mutants (changes that cannot alter behavior) once confirmed.

Sources: [Uncle Bob, Mutation Testing](https://blog.cleancoder.com/uncle-bob/2016/06/10/MutationTesting.html), [State of Mutation Testing at Google](https://research.google/pubs/state-of-mutation-testing-at-google/), [Stryker mutant states](https://stryker-mutator.io/docs/mutation-testing-elements/mutant-states-and-metrics/).

## Specialized test types

Each type earns its place only under its condition. Propose it when the condition holds; skip it otherwise.

| Type | Use when | Skip when |
| --- | --- | --- |
| Property-based | Parsers, serializers (round-trip), pure transformations, invariants that hold for all inputs. | UI glue, thin CRUD, no statable invariant. |
| Fuzzing | Code that reads untrusted bytes: decoders, parsers, protocol handlers. | Business logic without a crash oracle; use properties instead. |
| Contract (Pact) | Several services you own call each other over HTTP or messages. | A monolith, or a public API with unknown consumers. |
| Snapshot | Large generated output whose changes are reviewed in code review. | Updates get accepted without reading them. |
| Visual regression | Stable UI (design systems, marketing pages) with baselines from one pinned CI environment. | Fast-changing UI or baselines taken on mixed machines. |
| Approval | Getting untested legacy code under test before refactoring it. | New code where literal assertions are clear. |
| Type tests | A published library whose types are part of its contract. | Application code. |

## Verification

- Every new behavior has a test at an agreed seam, per `tdd`.
- Each confirmed critical journey has an end-to-end test, or `docs/testing.md` marks it as missing.
- When mutation testing is configured, changed lines have no unexplained survivors.
- Specialized test types appear only where their condition in the table holds.

## Supporting skills

- `tdd`: how each test is written. Where this standard and `tdd` overlap, `tdd` governs the individual test and this standard governs the mix.
- `diagnosing-bugs`: feedback loops for reproducing bugs, including property and fuzz loops.
- `vitest`, `playwright-cli`: tool references when installed.
