# Managed block template

Assemble the block from the sections below that accepted recommendations list, in this order. Text in `<angle brackets>` is filled from exploration; remove any bullet that has nothing real to point at. Keep the block short: it is loaded on every turn, so it names where things are and leaves the detail in the linked files.

```markdown
<!-- setup-ariel-skills:start v<version> -->
## Language

Write repository documentation, code comments, commit messages, and PR titles and descriptions in English. Preserve existing API identifiers and the intended language of user-facing content.

## Engineering standards

Before designing, implementing, refactoring, or reviewing code, consult [CODING_STANDARDS.md](CODING_STANDARDS.md) and read the standards whose applicability matches the task. Project standards take precedence over examples in third-party skills.

## Verification

Before reporting a task done, run the checks that apply to the change:

- <check name>: `<command from package.json or equivalent>`

## Testing

See [docs/testing.md](docs/testing.md) for test setup, scope, commands, and what local runs cannot verify.
<!-- setup-ariel-skills:end -->
```

Section rules:

- **Language**: always. If the repo already documents a different language policy outside the block, ask the user which wins before writing.
- **Engineering standards**: always.
- **Verification**: one bullet per real command (type check, lint, format check, unit tests, end-to-end tests). Prefer the repo's scripts over raw tool invocations. Add the `workers` note when that recommendation is on.
- **Testing**: only with a test recommendation.
