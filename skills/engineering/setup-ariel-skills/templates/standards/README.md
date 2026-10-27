<!-- setup-ariel-skills v<version> -->
# Engineering standards

These documents define this repository's engineering conventions. Consult the applicable standard before changing or reviewing the affected code. Each standard states its scope and verification criteria; distinguish the intended architecture from the current implementation.

| Standard | Read when |
| --- | --- |
| [Clean Architecture](clean-architecture.md) | Adding or changing business behavior, designing module boundaries, integrating a platform, or reviewing dependencies between business logic and technology. |
| [Software design philosophy](software-design-philosophy.md) | Designing or changing functions, classes, module interfaces, error handling, or design comments; refactoring or reviewing code for complexity. |

## Adding standards

Create one focused English document per topic and add it to this index with a concrete applicability condition. Include actionable rules, examples where useful, and verification criteria. Link existing authoritative configuration or documentation instead of copying it. Record the rationale and history of individual decisions in ADRs; standards describe the conventions agents must apply.

Project standards take precedence over general examples in third-party skills.

## UI design guidance

When building new UI or substantially reshaping an existing screen, use the project-installed [frontend-design skill](../../.agents/skills/frontend-design/SKILL.md), and review the result with [web-design-guidelines](../../.agents/skills/web-design-guidelines/SKILL.md). Ground visual choices in this product's real workflows and preserve established UI conventions when extending a screen.
