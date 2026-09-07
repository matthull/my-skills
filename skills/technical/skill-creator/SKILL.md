---
name: skill-creator
description: >
  Create, adapt, and audit Claude Code skills that conform to the plugin architecture.
  This skill should be used when authoring a new skill, migrating an existing skill to be
  portable across environments, or reviewing a skill for architectural conformance. Covers
  the frontmatter convention, capability declarations, semantic verbs, the resolution
  template, extension points, and graceful degradation.
capabilities:
  uses:
    - core-mandates
  optional:
    - skill-validation
---

# Skill Creator

Author Claude Code skills that work in someone else's environment. A skill encodes a
workflow; the tools that workflow runs on differ from machine to machine. This skill covers
the mechanics of separating the two.

The full architecture spec is `docs/plugin-architecture.md`, at the root of the skills
repository this skill ships in. Read it before authoring anything non-trivial. If you
installed this skill on its own and do not have that repository, carry on — what follows is
self-contained, and the spec supplies rationale, worked migrations, and the full capability
catalog rather than any step you are missing.

## When to Use

- Creating a new skill from scratch
- Adapting an existing skill so it stops depending on one person's tools and paths
- Auditing a skill for conformance before publishing or sharing it

## The Core Idea

Skills declare *what* they need from the environment. Separate configuration files declare
*how* it is provided. The model reads both and resolves the binding by understanding — there
is no template engine and no runtime.

A workflow step coupled to one vendor's tooling:

```markdown before
When CI fails, notify the user with the Telegram MCP notify tool.
```

becomes:

```markdown after
When CI fails, use the messaging capability to send an informational notification.
If no binding is configured, print the status to the terminal.
```

The workflow did not change. A tool-specific reference became a semantic one, and the
fallback made the skill work for someone who has no binding at all.

In a real body the capability name carries bold marking — see **Capabilities** below. It is
left plain here because that marking is machine-detected wherever it appears, illustrations
included, which is the first trap this skill will warn you about.

## Frontmatter

```yaml
---
name: skill-name          # must equal the directory name, kebab-case
description: What it does and when to use it. Third person. Specific triggers.
capabilities:             # omit entirely when self-contained
  uses:
    - test-runner
  optional:
    - issue-tracking
---
```

`uses` is for capabilities the workflow actively references. `optional` is for what the skill
leverages when present but never requires. Omitting the field is the unambiguous signal that
a skill is self-contained — do not include an empty one.

The description drives auto-discovery, which is unreliable in practice. Write it well, then
design workflows that invoke skills explicitly rather than trusting description matching. No
length ceiling is enforced, but it loads into every session — keep it to a couple of
sentences. Claude Code's other frontmatter fields, `allowed-tools` and `model` among them, are
permitted and go unchecked; conformance tooling validates only the keys inside `capabilities:`.

## Capabilities

Pick names from the standard catalog in `docs/plugin-architecture.md` whenever one fits —
`messaging`, `test-runner`, `lint-runner`, `ci-pipeline`, `code-hosting`, `issue-tracking`,
`browser-testing`, `session-logging`, `observability`, `team-messaging`. Project-specific
names are allowed; use kebab-case nouns.

Prefer a distinct name over a standard one that almost fits. This skill declares
`skill-validation` rather than reusing `lint-runner`, because an environment that binds
`lint-runner` binds it to a source-code linter — reusing the name would aim a Ruby or
JavaScript linter at a markdown file.

Reference a capability in the body with the bold form: `**<capability-name>** capability`.
This exact shape is what conformance tooling matches on, in both directions — a body
reference with no declaration fails, and a declaration the body never references also fails.

The word *capability* is load-bearing: a bold name followed by "binding", "tool", or a comma
does not register. Extension Points and configuration sections naturally say "binding", so
make sure at least one real workflow step carries the canonical form for every capability
declared. Conformance Traps below covers why this bites and how this file handles it.

Every reference needs a stated fallback. Graceful degradation is not a courtesy; a skill that
cannot run without its plugins has failed the architecture's central requirement.

### Semantic Verbs

When one capability has several interaction modes that change the workflow's logic, name the
modes. Messaging is the canonical case — "wait for a decision" and "post an update and move
on" are not interchangeable.

| Verb | Meaning | Default when unbound |
|------|---------|---------------------|
| NOTIFY_BLOCKING(message) | A decision is needed — wait for it | Ask the operator directly |
| NOTIFY_INFO(message) | Status update — do not wait | Terminal output |
| NOTIFY_ESCALATE(message) | Urgent — interrupt | The most intrusive channel available |

Verbs are UPPER_SNAKE_CASE. Reuse the names above rather than inventing synonyms: when
several skills share a vocabulary, one plugin file configures all of them. A capability
reference alone is enough when the skill just needs "some way to do this."

## Skill Anatomy

```
skill-name/
├── SKILL.md          # Required. Workflow + capability declarations.
└── resources/        # Optional.
    ├── domain-skill.md      # Per-project bindings (user-created, not shipped)
    ├── personal-skill.md    # Per-user preferences (user-created, not shipped)
    ├── references/          # Documentation loaded on demand
    ├── scripts/             # Deterministic executable helpers
    └── assets/              # Templates and fixtures
```

**`SKILL.md` must be uppercase.** Claude Code silently ignores a lowercase `skill.md` — the
skill simply never loads, with no error.

**Do not ship `domain-skill.md` or `personal-skill.md`.** They are written by whoever installs
the skill. Shipping one asserts a binding the installer never chose. Publish worked examples
under the repository's `examples/domain-plugins/` directory instead.

## Conformance Traps

Read these before drafting, not after. They govern how you write every paragraph, and
discovering them at validation time costs a rewrite. Each one has bitten a real skill.

**Illustrating the bold form costs you.** Conformance tooling matches a bold-marked
capability name followed by the word *capability*, across the whole body, code fences and
inline backticks included — neither is a shield, and the whitespace between the two may be a
line break, so wrapping the sentence does not help either. Writing that form in a teaching
example registers as a real reference and demands a matching declaration. So discuss
capability names in backticks and reserve the marked form for genuine references: that is why
the catalog above is in backticks, why the worked example earlier leaves its name unmarked,
and why the only two marked references in this file are its two real capability calls, in
steps 3 and 6. Writing this section is what tripped the check twice.

**Bold alone is not a reference.** The word *capability* must follow the marked name or
nothing registers — which is how a skill fails for declaring a capability whose body
reference the author believed was already there.

**Example fences must be labelled, and the scan is narrower than you would hope.** A fence
naming an MCP tool identifier is exempt only when marked: an info string of `example`,
`before`, or `after`, or a first line commenting the same. Unlabelled fences are read as live
instruction, which is right — hardcoded bindings hide in fences more often than in prose.

Know the reach before leaning on it. Automated scanning catches MCP identifiers, home paths,
email addresses, and whatever sits in the project's private denylist. It does not catch shell
commands, container invocations, vendor names, or most service URLs — the canonical hardcoded
binding, a `docker compose exec` test command, passes every check clean. Those are yours to
catch by eye, which is why step 6 keeps a manual pass and why diffing an adaptation against
its original is not optional.

One exception is worth knowing, because it is the leak that actually happens: chat and
issue-tracker URLs carrying an identifier-shaped token are caught, fence or no fence. Renaming
a workspace to something fictional while the real channel id rides along underneath is a
scrub that fools the reader and not the scan.

**The exemption does not extend to identifying information.** Employer names, personal
identity, and home paths are never acceptable, and being inside an example is not a defence.

**Declaring a capability the body never references fails too.** The check runs both
directions, so aspirational declarations do not survive. Declare what the workflow actually
uses.

**Omitting `capabilities:` while reading plugin files is not self-contained.** A skill that
reads `resources/domain-skill.md` is using the plugin layer and owes a precedence rule and a
contract regardless of what its frontmatter claims.

**A skill outside the category directories is not checked at all.** A conformance run given
no path walks only the categories it recognizes; anything staged elsewhere is skipped in
silence while the run still reports that everything conforms. Compare the count it prints
against the number of skills you expected it to open, and pass the path explicitly for
anything kept outside them.

## Creating a Skill

### 1. Establish what it does

Pin down concrete usage examples, the trigger conditions, and which existing skills overlap
or should be delegated to. A skill that duplicates an existing one is worse than no skill.

Settle placement here too. A workflow that only makes sense in one repository belongs in that
repository's `.claude/skills/`. Anything reusable belongs at user scope, or in a shared skills
repository under whichever category directory fits that collection — every collection names
its own set, so take them from the domain plugin or from the directories already present
rather than assuming. A skill that needs project-specific detail
still belongs at the wider scope, with the detail in a domain plugin. Generalizing a skill
that was written project-local is the more expensive direction to travel.

### 2. Identify the environment coupling

List every tool, path, command, and service the workflow touches. Each one is either
universal (stays in the skill) or environmental (becomes a capability plus a fallback). Be
suspicious of anything naming a vendor, an absolute path, a container command, or a specific
MCP tool.

### 3. Gather the principles to inject

Use the **core-mandates** capability to obtain the standing principles this project expects
woven into every skill, then embed the relevant ones as ordinary steps in the workflow — not
as an appended disclaimer. A skill that produces code carries testing discipline; a skill
that makes decisions carries evidence-before-action; a skill that builds agent components
carries this injection practice itself.

When no binding supplies them, use these defaults: verify before claiming completion, state
claims at the confidence the evidence supports, keep changes within the stated scope, and
leave the workspace no worse than you found it.

This step is the reason this skill declares a capability at all. An earlier version of it
named one project's architecture document by absolute path — which made the skill useless to
everyone else. The path was the dependency; inverting it is the whole lesson.

### 4. Write the body

Verb-first, instructional, objective. Not conversational, not second person.

Answer four questions in order: what is this for, when does it trigger, what is the
procedure, and what resources exist. Point at real files rather than pasting code; keep
inline snippets to a few lines.

Keep `SKILL.md` under about 5k words. Anything longer — schemas, extended references, large
examples — belongs in `resources/references/` and gets loaded on demand.

Draft with the Conformance Traps in hand. The fence-labelling rule, the bold-form rule, and
the ban on vendor names in workflow prose all constrain sentences as they are written;
applying them afterwards means rewriting the body rather than correcting it.

### 5. Wire the plugin layer

Any skill that declares capabilities owes the reader two sections.

First, `## Project and User Configuration`. Model it on this skill's own section below. Four
things must survive into your version, because tooling matches on them: that exact heading,
the three sources named in load order (`resources/personal-skill.md`, then
`resources/domain-skill.md`, then CLAUDE.md), and the phrase **first one found wins**. That
last one is matched as a literal string, not read for meaning — "the first binding found
wins" says the same thing and fails the check. Copy the wording exactly.

Everything else must be rewritten rather than copied — the clauses describing what each layer
supplies and what the final fallback is are specific to one skill's defaults, and carrying
them into another skill produces instructions that resolve to nothing.

Second, `## Extension Points`, naming the sections a plugin author should provide and what
belongs in each. That section is the contract — without it, plugin authors reverse-engineer
the skill's expectations from its workflow and get them wrong.

Add `## Interoperates With` when the skill has companions — a skill that consumes another's
output, or that expects shared configuration to exist. Name them and say what is shared.
Configuration two skills both read belongs in the environment's CLAUDE.md, not in either
skill's plugin files, where it falls out of sync.

### 6. Validate

Use the **skill-validation** capability to check the result mechanically. A skills repository
that ships a conformance checker binds it here; for a worked domain plugin binding both
`skill-validation` and `core-mandates`, see
`examples/domain-plugins/skill-creator-team-conventions.md` in the repository this skill ships
in. Read its output with two things in mind: a capability name outside the standard catalog is
reported as a *warning*, not an error, and earning one deliberately is the right call whenever
no standard name fits the meaning; and such a check normally scans every file a skill ships,
not only SKILL.md, so anything under `resources/` is in scope too. With nothing bound, walk
this list by hand:

- `SKILL.md` is uppercase and `name` matches the directory
- Declared capabilities and bold body references agree in both directions
- The resolution template and `## Extension Points` are present when capabilities are declared
- Every capability reference and every semantic verb has a stated fallback
- No absolute home paths, email addresses, or employer and private-project names *anywhere*
  — a labelled example fence is not a defence for these
- No MCP tool identifiers outside a labelled example fence
- No shell commands, container invocations, or vendor names in the workflow prose — nothing
  scans for these, so they are the ones to hunt by eye
- Naming holds: kebab-case for directories and capabilities, UPPER_SNAKE_CASE for verbs

Then read the skill as someone with none of the plugin files. If it still works, it conforms.

Register it wherever the collection tracks its inventory — a README table, a manifest, an
index — and update the counts there. A skill nobody can find has been stored, not installed.

Then use it on real work. When something struggles, decide deliberately whether the fix
belongs in the core workflow, a plugin layer, or a reference file — misplacing it is how core
skills silently reacquire the environment coupling you just removed.

## Adapting an Existing Skill

Classify it first; the class determines the work.

| Class | Signal | Action |
|-------|--------|--------|
| Self-contained | No external services, no project paths | Normalize frontmatter, omit `capabilities:`, move to a category directory |
| Implicit bindings | Refers to tools generically already | Formalize as declarations, document extension points |
| Hardcoded bindings | Names concrete tools, absolute paths, vendors | Extract to capabilities, replace with semantic references, add fallbacks |
| Existing plugins | Already has plugin files | Add declarations, resolution template, verify the contract is documented |

Preserve the workflow. In a correct adaptation the methodology is untouched and only the
bindings move — if the phases or gates changed, something went wrong.

Diff the adapted skill against its original before publishing. Pattern-matching catches home
paths and tool names; it does not catch in-house vocabulary that reads as ordinary English,
and the diff is the only control that does.

## Project and User Configuration

Throughout, *the project* means the repository the skill is being authored for — not the
skills repository this skill itself lives in, when those differ. Plugin file paths are
relative to this skill's own installed directory.

Load configuration in this order. **When multiple sources define the same binding,
the first one found wins** — stop checking lower sources for that binding:

1. Read `resources/personal-skill.md` if it exists — personal authoring preferences.
2. Read `resources/domain-skill.md` if it exists — this project's skill conventions and its
   `core-mandates` and `skill-validation` bindings.
3. Check the project's CLAUDE.md / CLAUDE.local.md for environment-level capability bindings.
4. For any capability still unbound, use the defaults specified in this skill: the general
   principles listed in step 3, and the manual checklist in step 6.

## Extension Points

### domain-skill.md

Provide this project's skill-authoring conventions:

- The `core-mandates` binding — where the project's standing principles live, or the
  principles themselves inline, so injection has something concrete to draw on
- The `skill-validation` binding — the command that checks a skill mechanically, and how to
  read its output
- Where skills are installed in this project, and how project scope is chosen over user scope
- Capability names this project has added beyond the standard catalog
- Any registry, index, or manifest that must be updated when a skill is added

### personal-skill.md

Provide individual authoring preferences:

- Default placement for new skills when scope is ambiguous
- Preferred verbosity and house style for skill prose
- Personal capability bindings that should apply across projects

## Interoperates With

- `skill-discovery` — finds and loads skills at task start. A skill's description is what
  discovery matches on, which is the practical reason to write it precisely.
- `agentic-architecture` — owns the question of *what* agent component to build and *why*.
  This skill owns the mechanics of well-formed skills specifically. When the work is an MCP
  server, a hook, or a guidance module rather than a skill, that is the right destination.
