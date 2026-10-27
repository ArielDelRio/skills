# Ariel's skills

Agent skills installed with [skills.sh](https://skills.sh) (`npx skills add ArielDelRio/skills`) into Claude Code and Codex.

## Layout

Skills live in bucket folders under `skills/`:

- `engineering/`: daily code work
- `in-progress/`: experimental, not promoted in the README
- `deprecated/`: no longer used

Each skill folder holds a `SKILL.md` and an `agents/openai.yaml` (Codex UI metadata). Every skill in `engineering/` is listed in the top-level `README.md` and in its bucket `README.md`, with the name linked to its `SKILL.md`, grouped into **User-invoked** and **Model-invoked**.

## Invocation

A skill is either user-invoked or model-invoked, in both harnesses at once:

- **User-invoked**: `disable-model-invocation: true` in `SKILL.md` frontmatter and `policy.allow_implicit_invocation: false` in `agents/openai.yaml`. The description is a one-line human-facing summary.
- **Model-invoked**: omit both. The description is model-facing and carries the trigger phrasing.

When a skill depends on another model-invoked skill, instruct the agent to call the Skill tool with its name. A user-invoked skill cannot be reached that way: tell the user to run it.

## Versioning

Skills that write files into other repositories carry `metadata.version` in their frontmatter and stamp that version into what they write. Bump it (semver) whenever their templates or written output change, and record the change in the skill's `CHANGELOG.md`.

## Standards and their skills

Each standard template in `setup-ariel-skills/templates/standards/` carries an `aligned-with` stamp (upstream repo, skill path, commit) and a precedence table listing where it overrides its supporting skill. Run `skills/engineering/setup-ariel-skills/scripts/check-drift.sh` before releasing a new setup version; for each drifted standard, review the upstream diff, update the standard and its table, then move the stamp to the reviewed commit.

## Writing

Write all prose, comments, and commit messages in English. Call the Skill tool with `writing-for-agents` before creating or editing a `SKILL.md` or this file.

## Local development

`scripts/link-skills.sh` symlinks every skill outside `deprecated/` into `~/.claude/skills` and `~/.agents/skills`, so edits in this checkout apply immediately. Re-run it after adding, removing, or renaming a skill.
