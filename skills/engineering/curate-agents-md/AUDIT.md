# Audit rules for AGENTS.md

`AGENTS.md` is loaded on every turn. Each line must change the agent's behavior in this repo, and anything only some tasks need lives behind a pointer.

Managed blocks (see `SKILL.md`) are audited only for broken paths and contradictions. Report any other finding inside them as a note for the owning skill rather than proposing an edit.

## Correctness

- **Broken reference**: a path, link, script, or command that does not exist. Fix it or remove the line.
- **Contradiction**: two instructions that cannot both be followed, within the file, against a nested `AGENTS.md`, or against what the code and config actually do. Ask the user which is correct.
- **Stale fact**: describes behavior, structure, or status the repo no longer has. Remove or update it.

## Duplication

- **Duplicated meaning**: the same instruction in two places (within the file, or copied from `README.md`, `CONTRIBUTING.md`, or `docs/`). Keep the authoritative copy and point at it.
- **Cache of the environment**: restates what one lookup reveals: a directory tree, the full script list from `package.json`, dependency versions, linter or formatter rules. Remove it. Keep what no file confesses: unwritten conventions, the reason behind a choice, gotchas.
- **Installed skill list**: names installed skills or plugins only to list them. Remove it; the harness already shows them.

## Pointers

- **Pointer without a condition**: links a doc without saying when to read it ("see docs/architecture.md"). Rewrite as condition plus target ("Before changing module boundaries, read `docs/architecture.md`").
- **Inlined reference**: a long section only some tasks need (deploy procedure, schema details, a full testing guide). Move it into a doc and leave a pointer with its condition.
- **Vague target**: "see the docs", "check the wiki". Name the exact repo-relative path or URL.

## Signal

- **No-op**: an instruction the agent follows by default ("write clean code", "be careful", "follow best practices"). Delete the sentence.
- **Negation-only rule**: a prohibition with no positive target. Rewrite it as the behavior wanted, keeping the prohibition only as a hard guardrail.
- **Task status**: temporary failures, current work, dated notes. Remove it; it belongs in issues or the work report.

## Shape

- **Length**: above about 100 lines, find what to move behind pointers. Treat the number as a prompt to look, not a quota. Prefer fewer, sharper lines over a target count.
- **Structure**: headings and bullets, one rule per bullet, a table when there is more than one command.
- **Scope**: repo-wide rules in the root file; a nested `AGENTS.md` only for a subtree with different commands or rules, and shorter than the root.
