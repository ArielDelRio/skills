<!-- setup-ariel-skills v<version> -->
# Engineering standards

This file indexes this repository's coding standards; the standards themselves live in `docs/standards/`. `code-review` reads it as a standards source, and `retro` adds judgement-call rules to it.

These documents define this repository's engineering conventions. Consult the applicable standard before changing or reviewing the affected code. Each standard states its scope and verification criteria; distinguish the intended architecture from the current implementation.

| Standard | Read when |
| --- | --- |
| [Clean Architecture](docs/standards/clean-architecture.md) | Adding or changing business behavior, designing module boundaries, integrating a platform, or reviewing dependencies between business logic and technology. |
| [Software design philosophy](docs/standards/software-design-philosophy.md) | Designing or changing functions, classes, module interfaces, error handling, or design comments; refactoring or reviewing code for complexity. |
| [Testing](docs/standards/testing.md) | Deciding which tests a change or project needs, proposing end-to-end tests, judging whether a suite checks behavior, or adding a specialized test type. |

## Rules

Short judgement-call rules that do not fit an existing standard go here, one bullet each.

## Adding standards

Create one focused English document per topic in `docs/standards/` and add it to this index with a concrete applicability condition. Include actionable rules, examples where useful, and verification criteria. Link existing authoritative configuration or documentation instead of copying it. Record the rationale and history of individual decisions in ADRs; standards describe the conventions agents must apply.

Project standards take precedence over general examples in third-party skills.

## UI design guidance

When building new UI or substantially reshaping an existing screen, use the `frontend-design` skill, and review the result with the `web-design-guidelines` skill. Ground visual choices in this product's real workflows and preserve established UI conventions when extending a screen.
