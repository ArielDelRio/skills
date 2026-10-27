---
name: curate-agents-md
description: "Consolidate and audit a repo's agent instruction files so AGENTS.md is the single source and CLAUDE.md only imports it. Use when the user wants to review, clean up, consolidate, or shorten AGENTS.md or CLAUDE.md, when the two disagree, or before another skill writes into them."
---

# Curate AGENTS.md

Make `AGENTS.md` the one **source of truth** for agent instructions in this repo, then audit it so it stays short and made of **pointers**: lines that name where material lives and the condition for reading it.

Before drafting any change, call the Skill tool with `writing-for-agents`. It defines pointers, the two loads, caches, no-ops, and sediment; the audit below applies those terms. If that skill is unavailable, say so and continue with the rules in [AUDIT.md](./AUDIT.md).

Present a report and a diff, then write only what the user approves.

## Process

### 1. Inventory

Find every instruction file in the repo, excluding `node_modules/`, `.git/`, and installed skill folders (`.agents/skills/`, `.claude/skills/`):

```bash
find . \( -name AGENTS.md -o -name CLAUDE.md -o -name CLAUDE.local.md \) -not -path '*/node_modules/*' -not -path './.git/*' -not -path '*/.agents/skills/*' -not -path '*/.claude/skills/*'
```

For each `CLAUDE.md`, classify it as: **import-only** (just `@AGENTS.md`, optionally with a heading), **symlink** to the sibling `AGENTS.md`, or **standalone** content. `CLAUDE.local.md` is personal and out of scope: leave it alone and mention it only if it contradicts `AGENTS.md`.

Note the **managed blocks** written by other skills. Each one stays exactly as written and is moved as a single unit:

- `## Agent skills` with `### Issue tracker` / `### Triage labels` / `### Domain docs` subsections: owned by `setup-matt-pocock-skills`.
- Content between `<!-- setup-ariel-skills:start ... -->` and `<!-- setup-ariel-skills:end -->`: owned by `setup-ariel-skills`.

The completion criterion: every instruction file is listed with its classification and its managed blocks.

### 2. Consolidate

For each directory that has a standalone `CLAUDE.md`:

- Move every instruction that is only in `CLAUDE.md` into the sibling `AGENTS.md` (create it if missing), including managed blocks.
- Where the two files say different things about the same topic (commands, language, conventions, workflow), list each contradiction with both versions quoted and ask the user which one wins. Do not choose for them.
- Instructions that only apply to Claude Code (for example, a tool name that only Claude Code has) stay in `AGENTS.md` under a short note naming the harness, so Codex reads them as not applying.

The target for every such directory: `CLAUDE.md` contains exactly

```markdown
@AGENTS.md
```

Use the import, not a symlink: an import works on every OS and in every Git client. An existing symlink is also valid, so keep it.

The completion criterion: every instruction from every `CLAUDE.md` is either placed in `AGENTS.md` or resolved by the user as dropped.

### 3. Audit

Audit each `AGENTS.md` with the rules in [AUDIT.md](./AUDIT.md). The completion criterion: every rule has been checked against every line, and every finding names the line, the rule, and the proposed change.

Verify against the repo rather than from memory: run `ls`/`test -e` on every path, look up every command in `package.json` scripts or the equivalent, and compare each section against `README.md`, `CONTRIBUTING.md`, and `docs/` for duplicated material.

### 4. Report and confirm

Show the user:

1. **Consolidation**: files merged, contradictions with the user's decisions, and the final `CLAUDE.md` contents.
2. **Findings**: grouped by rule, most consequential first (broken paths and contradictions before style).
3. **Diff**: the proposed `AGENTS.md`, plus any material moved into a linked doc (new file path and contents).
4. **Size**: line count before and after.

Let the user accept, reject, or edit each change. Nothing is written until they confirm.

### 5. Write and verify

Apply the approved changes. Then check:

- Every `CLAUDE.md` in scope is import-only or a symlink.
- Every relative link and path in each `AGENTS.md` resolves.
- Managed blocks are intact, character for character, apart from their new location.
- `git status` shows only the files the user approved.

Report the result in a few lines.
