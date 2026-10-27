<!-- setup-ariel-skills v<version> -->
# Software design philosophy

## Scope and authority

Apply this standard when designing or modifying functions, classes, module interfaces, error handling, or design comments, and when reviewing or refactoring code for complexity. It operationalizes the central practices of John Ousterhout's *A Philosophy of Software Design*, second edition. It is a project standard, not a reproduction or exhaustive chapter-by-chapter summary of the book.

The goal is to reduce the knowledge needed to understand, use, and change the system. Correct behavior is necessary; a change must also avoid unnecessary complexity. Apply improvements within the task's scope and preserve existing contracts. Existing code is not evidence that these conventions have already been implemented.

## Deep modules and information hiding

A module is any function, class, or package with an interface and implementation. Its interface includes everything callers must know: types, ordering, errors, side effects, units, lifecycle, and consistency guarantees.

A deep module provides substantial useful behavior behind an interface that is easy to understand. Evaluate depth by the work and knowledge it saves callers, never by implementation length or method count. A large dispatcher that exposes database details is not deep merely because it contains much code.

For each new or substantially changed module, identify:

- The concept it represents and the design decisions it owns.
- The knowledge it hides from callers.
- The promises callers can rely on without reading its implementation.

Keep each design decision in one authoritative place. Shared assumptions about storage layouts, normalization, retry rules, or sequencing are information leakage even when the code is not duplicated. Group code by the knowledge it owns; execution phases alone are a poor reason to split a module.

Combine related pieces when doing so localizes shared knowledge and simplifies use. Separate pieces when they represent independent concepts or when application-specific policy can be kept outside a reusable mechanism. A small class or helper earns its place by improving understanding, not by satisfying a size target.

## Simple interfaces, complete responsibilities

Make common operations straightforward. Offer the smallest coherent interface that covers current requirements, with safe defaults for incidental choices. Keep specialized policy near the caller that needs it; keep general mechanisms useful across current callers. Add options only when callers have a real decision to make.

Pull unavoidable complexity into the module that can resolve it correctly. Avoid making every caller coordinate initialization, storage formats, retries, or cleanup. Expose meaningful tradeoffs and failure conditions explicitly rather than hiding them behind surprising behavior.

Each layer must introduce a distinct abstraction. Forwarding methods, parameters passed through many levels, and parallel wrappers with nearly identical interfaces require a concrete justification, such as protocol translation, authorization, or platform isolation. Remove layers that merely rename calls.

Use composition when behavior can be assembled without exposing implementation details. Reserve inheritance for a clear substitutable relationship; prefer sharing implementation behind an interface to making callers understand a class hierarchy.

## Fit with Clean Architecture

When this repo adopts [Clean Architecture](clean-architecture.md), that standard governs dependency direction and platform isolation. This standard governs the quality and depth of the modules within that structure. Preserve domain/application isolation while choosing cohesive interfaces; depth does not justify moving SQL into domain classes.

For example, an order mutation port should let a use case request a guarded business change with a clear result. Its persistence implementation can hide the transaction machinery that commits the mutation, audit event, and idempotent response together. Requiring each caller to invoke `begin`, `checkVersion`, `write`, `audit`, and `completeRequest` leaks sequencing and consistency knowledge. The core still owns business policies and invariants.

A thin HTTP or RPC adapter can be justified by its translation role. The target is simpler overall use, not maximum depth for every individual function. A port isolating an existing platform dependency is justified even with only one production implementation.

## Errors and valid states

Reduce error paths through deliberate semantics and valid-state models. When an operation is naturally idempotent, define a repeated request's outcome explicitly instead of forcing callers to reconstruct success. Preserve the existing operation contract when evolving semantics.

Handle a failure inside a module only when it can recover correctly. Translate errors at the boundary that understands them; aggregate related failures where that simplifies handling without losing actionable information. Never turn authorization failures, version conflicts, invalid business data, or uncertain persistence outcomes into apparent success. Unexpected faults must remain observable.

## Design for readers

Choose precise names that communicate the concept, units, and state. If a useful name or concise description is hard to write, reconsider the abstraction. Keep conventions consistent with neighboring code and the domain glossary when present.

Make control flow and side effects obvious. Use named concepts and explicit results to reduce hidden dependencies. Decompose methods where a helper hides a coherent idea; preserve a readable sequence when splitting would force readers to chase state across many functions. Method length alone is not a design verdict.

Draft the interface contract before implementing a nontrivial abstraction. Document behavior callers cannot infer from types: constraints, ownership, ordering, atomicity, errors, and relevant performance expectations. Comments should explain intent, invariants, or non-obvious reasoning at a different level from the code. Update comments with behavior; avoid narrating assignments and loops. Keep cross-module rationale in one authoritative document and link it where needed.

## Strategic design and alternatives

Invest in design while implementing each change. Fix local sources of recurring complexity rather than adding another special case. Make necessary compromises explicit in the work report and track consequential follow-up work through the project's issue workflow.

For a consequential new interface or difficult refactor, sketch at least two meaningfully different designs before committing to one. Compare caller knowledge, hidden decisions, failure paths, and the locality of a likely future change. This can be a short design note; routine edits do not require a separate document or extra agents.

Decide which requirements matter most and organize the design around them. Use measurements to guide performance work. Improve the critical path while preserving a simple interface; avoid speculative caching, configuration, and optimization that complicate ordinary use. Correctness and required consistency remain part of the contract.

## Review and verification

Review affected modules against these questions. Report concrete failures and their consequences rather than assigning a numeric design score.

| Question | Evidence to inspect |
| --- | --- |
| Does the module hide a useful decision? | State what callers no longer need to know. |
| Is the common case simple? | Read a representative call site, including setup and error handling. |
| Is change local? | Trace a likely rule or implementation change; identify assumptions shared across modules. |
| Does each abstraction earn its cost? | Inspect forwarding chains, configuration, shallow helpers, and duplicated knowledge. |
| Are contracts understandable? | Read names, types, and comments without opening the implementation. |
| Are errors deliberate? | Check recovery, conflicts, retries, and uncertain outcomes against the contract. |
| Is behavior verified through the interface? | Test meaningful outcomes and invariants, including failures; use integration tests for adapter guarantees. |

Information leakage, temporal decomposition, unnecessary special cases, vague names, and hard-to-explain interfaces are signals to revisit a design. They are reasons for investigation, not automatic bans on a language feature.

## Supporting skills and sources

Use the installed [software-design-philosophy skill](../../.agents/skills/software-design-philosophy/SKILL.md) for detailed examples. The shared `codebase-design` skill provides complementary vocabulary for interface depth and locality. This project's rules above govern tradeoffs, verification, and review; third-party scoring systems and effort percentages are not acceptance criteria.

Primary references:

- [Author's book page](https://web.stanford.edu/~ouster/cgi-bin/book.php): second-edition scope, general-purpose design, deciding what matters, and differences from Clean Code.
- [CS 190 modular design notes](https://web.stanford.edu/~ouster/cgi-bin/cs190-spring16/lecture.php?topic=modularDesign): information hiding, module depth, decomposition, and comparing designs.
- [CS 190 wrap-up](https://web.stanford.edu/~ouster/cs190-winter23/slides/wrapup.pdf): the course's central design principles.
- [Designing abstractions](https://www.web.stanford.edu/~ouster/CS349W/lectures/abstraction.html): useful interfaces, defaults, and reducing error-handling complexity.

The book page documents a stronger emphasis on general-purpose interfaces in the second edition. Use that scope when interpreting earlier course examples. The supporting skill is a community adaptation, available from [wondelai/skills](https://github.com/wondelai/skills/tree/main/software-design-philosophy).
