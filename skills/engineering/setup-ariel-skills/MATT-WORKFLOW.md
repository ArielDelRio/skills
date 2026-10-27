# Matt Pocock's workflow

This repo's development loop runs on [Matt Pocock's skills](https://github.com/mattpocock/skills):

```text
grill-with-docs -> (to-spec -> to-tickets) -> implement (tdd) -> code-review -> pr -> retro
```

The parenthesized steps apply only to multi-session builds. Section E of `SKILL.md` and step 5 use this file.

## Availability

The skills each step needs, and where they must be available:

| Step | Skills | Kind |
| --- | --- | --- |
| Grill | `grill-with-docs`, `grilling`, `domain-modeling` | user, model, model |
| Plan | `to-spec`, `to-tickets` | user, user |
| Build | `implement`, `tdd`, `codebase-design` | user, model, model |
| Review | `code-review` | model |
| Ship | `pr` | model |
| Improve | `retro` | user |
| Precondition | `setup-matt-pocock-skills` | user |

Matt's skills are general-purpose, so they belong at user level rather than in each repo. When any are missing from your available skills, recommend installing the whole set once at user level:

```bash
npx skills@latest add mattpocock/skills -g -a claude-code codex
```

Running this changes the user's global setup, outside this repo: ask first. When the user prefers per-repo installs, drop `-g`. Installing with both `npx skills` and Matt's Claude Code plugin duplicates every skill: if the plugin is already installed, install nothing.

## Running Matt's setup

`setup-matt-pocock-skills` is user-invoked, so no skill can call it through the Skill tool. Instead, with the user's agreement, read its `SKILL.md` and carry out its process here, as part of this run. Locate it, in this order:

```bash
for d in .agents/skills .claude/skills "$HOME/.agents/skills" "$HOME/.claude/skills"; do
  test -f "$d/setup-matt-pocock-skills/SKILL.md" && echo "$d/setup-matt-pocock-skills/SKILL.md" && break
done
find "$HOME/.claude/plugins" "$HOME/.codex" -path '*setup-matt-pocock-skills/SKILL.md' 2>/dev/null | head -1
```

Follow that file's steps and its own confirmations (issue tracker, triage labels, domain docs), with one override: its **pick the file to edit** rule is replaced by "write the `## Agent skills` block into the root `AGENTS.md`". After `curate-agents-md`, `CLAUDE.md` only imports `AGENTS.md`, and the block must stay there. Its seed templates sit beside its `SKILL.md`.

Skip this when `docs/agents/issue-tracker.md` already exists and the user does not want to change the tracker.

## Readiness checks

After the setup, check each step's prerequisites and report one line per step: ready, or what is missing and how to fix it.

- **Grill**: `docs/agents/domain.md` exists and the `## Agent skills` block points to it. `GLOSSARY.md` and `docs/adr/` are created lazily; their absence is fine.
- **Plan**: `docs/agents/issue-tracker.md` exists. For GitHub, `gh auth status` succeeds and `gh repo view` resolves this repo; for GitLab, the same with `glab`. When `triage` is available, every label in `docs/agents/triage-labels.md` exists in the tracker.
- **Build**: the repo has a test command `tdd` can drive (from the testing recommendations or the repo's scripts). No test runner is a gap to report, not to fix here.
- **Review**: `CODING_STANDARDS.md` exists at the root and links every standard in `docs/standards/`. `code-review` treats that file as a mandatory standards source.
- **Ship**: a Git remote exists and the PR tool (`gh pr` or `glab mr`) is authenticated.
- **Improve**: `retro` turns mechanical mistakes into deterministic checks and judgement calls into rules in `CODING_STANDARDS.md`. Report which guardrails exist to receive checks: linter config, pre-commit hooks, CI workflows.
