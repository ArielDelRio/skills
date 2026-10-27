<!-- setup-ariel-skills v<version> -->
<!-- aligned-with: wshobson/agents plugins/backend-development/skills/architecture-patterns be57c0b2e3c05c528ca6132b87410b385718775f -->
# Clean Architecture

## Scope and adoption

Apply this standard when implementing or changing business behavior, defining module boundaries, integrating technology, or reviewing dependencies. The target is a lightweight Clean Architecture with ports and adapters inside one application.

This is the target architecture, not a description of the current code. Evolve affected code incrementally while preserving its behavior and contracts. Reading this standard does not require a repository-wide migration.

## Dependency rule

Source dependencies point toward the business core:

```text
HTTP / RPC / UI adapters -> application use cases -> domain
Persistence adapters     -> application ports and domain types
Composition root         -> use cases and concrete adapters
```

Domain and application code must not import web frameworks, runtime bindings, database clients, ORM models, HTTP request/response objects, transport descriptors, browser storage, or concrete adapters. A use case calls an external capability through an interface it owns; the adapter implements that interface.

## Responsibilities

| Boundary | Owns | Example |
| --- | --- | --- |
| Domain | Entities, value objects, invariants, state transitions, domain errors | An order cannot ship before payment is captured; quantity must be positive. |
| Application | Use cases, input/output types, authorization policies, coordination of external capabilities | Place an order for an authenticated actor with an expected version and an idempotency key. |
| Ports | Small interfaces describing the capabilities a use case requires | Load an order; commit a guarded state change together with its audit event. |
| Adapters | Input parsing, transport error mapping, persistence mapping, SQL and platform APIs | Translate request payloads; implement atomic writes against the database. |
| Composition | Construction and connection of concrete dependencies | Supply the database adapter and clock to the use cases. |

Authenticate at the platform boundary and pass explicit actor information inward. Enforce business authorization in the application layer; domain objects do not inspect tokens or cookies.

## Models and validation

Use classes (or the language's equivalent) for entities and value objects that encapsulate meaningful behavior and protect invariants. Constructors or factories establish valid state, and methods enforce valid transitions. Use plain data types and functions where there is no lifecycle or invariant to encapsulate.

Parse untrusted input at the adapter boundary. Enforce business invariants inside the core as well, so direct use-case calls cannot bypass them. Boundary validation may give earlier feedback; it never becomes the only enforcement of a business rule.

Use explicit input/output types and domain errors across boundaries. Map stored records to domain models in persistence adapters, and map domain errors to transport responses in transport adapters. Preserve existing public names, arguments, and user-facing messages through those mappings.

Supply time and identifier generation through small injected capabilities when a use case needs them. Keep platform access and nondeterministic calls outside domain behavior.

## Persistence and consistency

Define persistence ports around business operations and the guarantees they require. Keep SQL, prepared statements, ORM types, and transaction handles inside adapters.

A mutation port expresses the atomicity its use case requires: optimistic version checks, duplicate prevention, idempotency, audit recording, and stored responses as appropriate. A read followed by a separate save cannot replace an atomic guarded write; concurrent callers must keep the existing guarantees. Every adapter implementing a port satisfies the same contract, including conflicts and retries.

## Keep the structure small

Group code by business capability: `<capability>/domain/`, `<capability>/application/` (including ports), and `<capability>/adapters/`, created only as real code moves into them. Framework route files can remain transport adapters at the locations the framework requires.

Inject dependencies explicitly through constructors or function parameters, and wire concrete implementations outside the core. Introduce abstractions for external capabilities or meaningful variation; ordinary internal calls stay direct. Add generic repositories, dependency injection containers, event buses, CQRS, or separate services only when a concrete requirement justifies their cost.

Apply [Software design philosophy](software-design-philosophy.md) within these boundaries: each layer provides a distinct abstraction and hides meaningful complexity. Keep platform isolation while removing forwarding layers that add nothing.

## Verification

For each affected operation:

- Verify domain invariants and use-case outcomes with deterministic tests that need no framework server, database, or network; use in-memory port implementations where persistence is involved.
- Exercise persistence contracts with integration tests for atomic conflicts, duplicate prevention, audit behavior, and idempotent retries when affected. In-memory tests do not establish the real database's transaction behavior.
- Check that transport mappings preserve existing names, arguments, results, and error behavior.
- Inspect imports to confirm domain and application code depend only inward and on platform-independent capabilities.

Validate runtime bindings and authentication when those integrations change.

## Supporting skill and references

Use the `architecture-patterns` skill when designing or refactoring these boundaries. Adapt its examples to this repo's language and the scope above; its advanced patterns (bounded contexts, anti-corruption layers, domain events, outbox) are optional reference material for when a concrete requirement calls for them.

Where the skill and this standard differ, this standard wins:

| Skill | This standard |
| --- | --- |
| Every layer boundary is crossed through an abstract interface. | Interfaces for external capabilities and meaningful variation; ordinary internal calls stay direct. |
| Generic CRUD repositories (`find`, `save`, `delete`). | Ports shaped around business operations, with the atomicity each use case needs. A read followed by a save does not replace a guarded write. |
| Ports live in `domain/interfaces/`. | Ports belong to the application layer that uses them. |
| Top-level `domain/`, `use_cases/`, `adapters/` folders. | Grouped by business capability, created as real code moves in. |
| A dependency injection container wires the graph. | Explicit constructor or parameter injection at a composition root; a container only when justified. |
| Swapping implementations motivates ports. | Isolating a platform dependency justifies a port, even with one implementation. |

When the repo has a `GLOSSARY.md`, its terms are the ubiquitous language for entities, value objects, and use cases.

- [The Clean Architecture, Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Hexagonal Architecture, Alistair Cockburn](https://alistair.cockburn.us/hexagonal-architecture)
- [Architecture Patterns skill source](https://github.com/wshobson/agents/tree/main/plugins/backend-development/skills/architecture-patterns)
