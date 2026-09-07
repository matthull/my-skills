# Skill Creator Domain Plugin — Team With a Skills Repository

Example `resources/domain-skill.md` for the `skill-creator` skill, for a team that keeps a
shared skills repository, checks conformance in CI, and maintains its own capability names.
Copy this file to `~/.claude/skills/skill-creator/resources/domain-skill.md` and edit for
your project.

This file binds the two capabilities `skill-creator` declares, and supplies the conventions
its workflow asks for. Everything here is what the skill *cannot* know on its own.

## core-mandates

The standing principles every skill authored in this project must weave into its workflow.
The skill's injection step draws on these instead of its built-in defaults.

Canonical source: `docs/engineering-principles.md`. When authoring a skill, read that file and
pick the principles the workflow actually touches. The recurring ones:

- **Tests before implementation.** Any skill that produces code instructs the agent to write
  a failing test first. A skill that generates code with no test step is incomplete.
- **Evidence before action.** Any skill that makes a judgement instructs the agent to verify
  from the source — read the file, run the command — rather than inferring from context.
- **State confidence honestly.** Verified, believed-but-unverified, and guessed are three
  different claims, and a skill that reports results must keep them distinct.
- **Stay in the stated scope.** A skill that discovers unrelated problems records them
  separately rather than widening its own change.

Weave these in as ordinary workflow steps. A "Principles" section appended at the end of a
skill is the failure mode — nobody reads it at the moment it would matter.

## skill-validation

- **Command:** `python3 scripts/check_skills.py skills/<category>/<skill-name>`
- **Whole repository:** `python3 scripts/check_skills.py`
- **Prove the checker still bites:** `python3 scripts/mutation_check.py`

Reading the output: `error` blocks the merge. `warning` does not — a capability name outside
the standard catalog warns by design, and is correct whenever no standard name fits the
meaning. Do not rename a capability just to silence the warning; a name that misdescribes
what the skill needs is the worse outcome.

The checker requires an untracked denylist of identifying terms at
`scripts/private-terms.local` and refuses to report a result without one, because a pass with
no denylist would say nothing about the thing it exists to catch. Create it before the first
run.

Run the check before opening a pull request. CI runs the same two commands.

## Where Skills Live

| Scope | Location | When |
|-------|----------|------|
| Team | this repository, under `skills/<category>/` | The workflow applies to more than one project |
| Project | `<project>/.claude/skills/<name>/` | The workflow only makes sense in that repository |

Categories are `development`, `architecture`, `product`, `orchestration`, `collaboration`,
`tooling`. A skill needing project-specific detail still belongs at team scope — the detail
goes in a domain plugin, not in the skill.

Default to team scope. A skill that started project-local and had to be generalized later is
the more expensive mistake.

## Capability Names Added Beyond the Standard Catalog

Reuse these rather than coining synonyms:

- `design-system` — component library tokens, variants, and usage rules
- `feature-flags` — flag state and rollout control
- `data-warehouse` — analytical query access, separate from the application database

Adding a name: define it in this file with a one-line semantic description before any skill
references it, so the next author finds it instead of inventing a near-duplicate.

## When a Skill Is Added

1. Add it to the inventory table in `README.md` and bump the category count.
2. If it pairs with an existing skill, add both to each other's **Interoperates With** section.
3. If it declares a capability new to this project, document that name in the section above.
