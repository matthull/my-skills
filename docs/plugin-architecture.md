# Plugin Architecture for Composable AI Skills

**Version:** 0.1.0 (Draft)
**Author:** Matt Hull (Generated via Claude)
**Date:** 2026-09-03

## Overview

AI coding agent skills face a portability problem. A skill that references `mcp__telegram-mcp__notify` for notifications or `docker compose exec web bundle exec rspec` for testing is coupled to one person's environment. The workflow — monitor CI, triage failures, fix, notify — is universal. The tools are not.

This document defines a standard plugin architecture that separates **what a skill does** from **how the environment provides it**. The central idea is **dependency inversion for natural language**: skills declare abstract capabilities they need; project and user configuration supply concrete implementations. The LLM reads both and resolves the binding through contextual understanding — no template engine, no variable substitution, no runtime framework. Just well-structured prose that composes.

This is a fundamentally different kind of plugin system than what traditional software uses. There are no interfaces to implement, no type signatures to satisfy, no compilation step that validates bindings. The contract is human-readable markdown, and the "runtime" is a language model that resolves references contextually. The architecture works *because* of this flexibility, not despite it — and the constraints it requires are correspondingly different.

### Quick Start: What This Looks Like

Before diving into the architecture, here's the shape of the thing. A skill that monitors CI currently looks like this:

```markdown
# Before: Hardcoded to one environment
When CI fails, notify via Telegram: `mcp__telegram-mcp__notify(message: "CI failed")`
Check the visual-regression service for status.
```

After applying this architecture:

```markdown
# After: Portable across environments
When CI fails, use the **messaging** capability to send an informational notification.
Check the **ci-pipeline** capability for visual regression status.
If no messaging binding is configured, print status to the terminal.
```

The skill's *workflow* didn't change. What changed is that tool-specific references became semantic capability references. A separate file — owned by the project or user, not the skill — provides the concrete mapping:

```markdown
# In CLAUDE.md or resources/personal-skill.md:
### messaging
- **info:** `mcp__telegram-mcp__notify(message: <message>)`
- **blocking:** `mcp__telegram-mcp__ask(question: <message>)`
```

Swap Telegram for Slack, PushNotification, or terminal output — the skill doesn't change.

### Design Principles

**Dependency inversion for natural language.** Skills define *what* they need (the interface); binding files define *how* it's provided (the implementation). Graceful degradation is the default implementation — every capability works, just less richly, when no binding exists. This principle unifies the entire architecture: capability declarations are interface definitions, binding files are implementations, and the LLM is the runtime that resolves them.

**Graceful degradation is mandatory.** A skill must function without any plugin files. Core-only mode may be less capable (terminal output instead of push notifications, generic test detection instead of project-specific commands), but it must not break. Missing plugins are the common case, not an error.

**Convention over configuration.** Plugin files follow naming conventions and structural patterns. The contract is human-readable markdown, enforced by convention rather than schema validation. This matches the medium — and it's why a malformed plugin degrades behavior rather than crashing.

**Composition, not inheritance.** Layers augment rather than replace. A domain plugin adds project context to a skill's core workflow; it doesn't redefine the workflow. A personal plugin adds user preferences on top of both. Each layer narrows the behavior space.

Anti-pattern: a domain plugin that redefines the skill's workflow phases or gates has moved from augmentation to override. Domain plugins provide data and bindings; the core skill owns the workflow.

---

## The Three-Layer System

Every skill operates through a cascade of up to three layers:

| Layer | File | Scope | Provides |
|-------|------|-------|----------|
| **Core** | `SKILL.md` | Universal | Workflow logic, capability declarations, semantic verbs, gates |
| **Domain** | `resources/domain-skill.md` | Per-project | Project-specific bindings — test commands, conventions, tool configs |
| **Personal** | `resources/personal-skill.md` | Per-user | User preferences — notification channels, autonomy level, logging |

### Resolution Order

When a skill references a capability, bindings resolve through this precedence chain:

1. **Personal plugin** (`resources/personal-skill.md`) — user-specific tool bindings
2. **Domain plugin** (`resources/domain-skill.md`) — project-specific bindings
3. **Environment config** (`CLAUDE.md` / `CLAUDE.local.md`) — project-wide bindings available to all skills
4. **Core defaults** (defined in `SKILL.md`) — fallback behavior when no binding exists

Higher-precedence layers override lower ones. A personal notification preference overrides a domain default, which overrides the environment config.

### Resolution Instruction Template

The LLM doesn't automatically know which binding wins — it reads all context holistically. Skills must embed an explicit precedence instruction. Use this standard template in the skill's plugin discovery section:

```markdown
## Project and User Configuration

Load configuration in this order. **When multiple sources define the same binding,
the first one found wins** — stop checking lower sources for that binding:

1. Read `resources/personal-skill.md` if it exists — personal tool bindings and preferences.
2. Read `resources/domain-skill.md` if it exists — project-specific configuration.
3. Check the project's CLAUDE.md / CLAUDE.local.md for environment-level capability bindings.
4. For any capability still unbound, use the defaults specified in this skill.
```

This turns the resolution order from a design aspiration into an executable instruction. The LLM encounters it as a procedure: check here first, then here, then here, stop when you find a binding.

### When Each Layer Is Appropriate

**Environment-level bindings** (CLAUDE.md / CLAUDE.local.md) are for capabilities shared across all skills in a project: the messaging tool, the CI system, the issue tracker. Define them once; every skill picks them up.

**Skill-level domain plugins** are for configuration specific to one skill's operation in one project: which pipeline phases to run, which reviewers to assign, what test commands to execute.

**Skill-level personal plugins** are for individual preferences within one skill: notification routing, autonomy calibration, session logging format.

This mirrors dependency injection in traditional systems: CLAUDE.md is the container's project-wide configuration; domain-skill.md is the module-specific override; personal-skill.md is the per-user profile. The difference is that the "container" is a language model reading structured prose, not a framework resolving typed dependencies.

---

## Capability Interfaces

A capability interface is the architecture's equivalent of an abstract dependency. It's a named, semantic description of something a skill needs from its environment. Skills reference capabilities by name; binding files map them to concrete tools.

### Declaring Capabilities

Skills declare their capabilities in YAML frontmatter:

```yaml
---
name: ci-monitor
description: Monitor CI for the current branch and fix failures.
capabilities:
  uses:
    - messaging        # Notify user of CI status changes
    - ci-pipeline      # Check CI run status
  optional:
    - issue-tracking   # Link failures to tickets
---
```

`uses` lists capabilities the skill actively references in its workflow. `optional` lists capabilities the skill can leverage if available but doesn't require. Skills with no external capability dependencies omit the field entirely — the absence is unambiguous.

**What reads these declarations.** Today, capability declarations are documentation — they tell a human installer what bindings a skill benefits from. They are also designed to be machine-readable for future tooling: `skill-discovery` could scan frontmatter to match skills to environments ("this project has Linear configured; these skills can use issue-tracking"), and a linter could warn when a skill body references a capability not declared in frontmatter. The format supports both uses without changes.

**Setup awareness.** When a skill is loaded and its declared capabilities have no binding in the current environment, it should note this transparently: "This skill uses the **messaging** capability but no binding was found. Notifications will print to the terminal. See the skill's Extension Points section to configure a binding." This turns silent degradation into informed degradation.

### Referencing Capabilities in Skill Body

In the skill's workflow instructions, reference capabilities semantically — this is the "interface call" in the dependency inversion:

```markdown
## Notification

When CI status changes, use the **messaging** capability to notify the user:
- Failures: blocking notification (wait for acknowledgment)
- Recovery: informational notification (no wait)

If no messaging binding is configured, print status updates to the terminal.
```

The skill defines *what* to communicate and *when*. The binding — the "implementation" — defines *how*.

### Standard Capability Catalog

These capability names are standardized across the skill collection. Use them for consistency; extend with project-specific capabilities as needed.

| Capability | Semantic Description | Typical Bindings |
|------------|---------------------|------------------|
| `messaging` | Asynchronous notification to the user | Telegram MCP, Slack MCP, PushNotification, terminal |
| `team-messaging` | Post to shared team channels | Slack MCP, Discord webhook |
| `issue-tracking` | Create/update/query work items | Linear MCP, GitHub Issues, Jira API |
| `test-runner` | Execute project test suites | Docker+RSpec, jest, pytest, cargo test |
| `lint-runner` | Execute code quality checks | RuboCop, ESLint, ruff, clippy |
| `ci-pipeline` | Interact with CI/CD status and artifacts | GitHub Actions (gh), CircleCI, GitLab CI |
| `browser-testing` | Browser-based QA and verification | Chrome DevTools MCP, Playwright |
| `code-hosting` | Interact with PRs, reviews, branches | GitHub (gh CLI), GitLab |
| `session-logging` | Log session activity for audit/history | A session-log MCP server, file-based logging |
| `observability` | Access logs, metrics, error tracking | NewRelic, Datadog, AppSignal, CloudWatch |

**Extensibility.** This catalog is intentionally small — it covers the capabilities observed across 145 skills from 8 projects. Project-specific capabilities (e.g., `supabase`, `docker-compose`) are valid; use a descriptive kebab-case name, same convention as the standard catalog. When a project-specific capability recurs across multiple projects, it's a candidate for the standard catalog. No formal governance — the catalog grows by contribution and consensus.

---

## Semantic Verbs

Some capabilities benefit from a finer-grained interface: **semantic verbs**. Where a capability names a *kind* of tool, a semantic verb names a *specific interaction pattern* within that capability.

This pattern emerged from real usage. We had skills that needed "notifications" but meant three different things — "I need a decision from you and will wait," "here's an update, carry on," and "stop everything, urgent." One capability name couldn't distinguish these. Semantic verbs solved it: the skill names the interaction pattern; the personal plugin maps each pattern to the right tool behavior.

### The Pattern

The skill defines verbs with semantic meaning and default behavior:

```markdown
## Notification Verbs

| Verb | Meaning | Default (no binding) |
|------|---------|---------------------|
| NOTIFY_BLOCKING(message) | Need a decision — wait for response | AskUserQuestion |
| NOTIFY_INFO(message) | Status update — don't wait | Terminal output |
| NOTIFY_ESCALATE(message) | Urgent — interrupt the user | PushNotification |
```

The personal plugin maps verbs to concrete tools — the "implementation":

```markdown
## Notification Mapping

| Verb | Tool | Notes |
|------|------|-------|
| NOTIFY_BLOCKING | mcp__telegram-mcp__ask(question: message) | Waits for reply |
| NOTIFY_INFO | mcp__telegram-mcp__notify(message: message) | One-way |
| NOTIFY_ESCALATE | PushNotification(message: "URGENT: " + message) | Mobile push |
```

### When to Use Semantic Verbs vs. Capability References

**Capability references** are sufficient when the skill just needs "a way to do X" — run tests, check CI, track issues. The binding provides one concrete tool.

**Semantic verbs** are appropriate when a single capability has multiple interaction modes that the skill needs to distinguish. Messaging (blocking vs. informational vs. urgent) is the canonical example. Use them when the *how* matters to the workflow logic.

### Shared Verb Vocabularies

Multiple skills can share the same verb vocabulary. When `ci-monitor`, `pipeline`, and `fire-watch` all use `NOTIFY_BLOCKING` / `NOTIFY_INFO`, one personal plugin configures all of them. This is cross-skill consistency through shared semantics — no formal shared definition required, just convention. The convention holds because the verb names are descriptive enough that independent skill authors converge on the same names for the same concepts.

---

## Binding Mechanism

### Environment-Level Bindings (CLAUDE.md)

For capabilities shared across all skills in a project, add a `## Capability Bindings` section to the project's `CLAUDE.md`:

```markdown
## Capability Bindings

### messaging
- **blocking:** `mcp__telegram-mcp__ask(question: <message>)` — waits for reply
- **info:** `mcp__telegram-mcp__notify(message: <message>)` — one-way
- **fallback:** print to terminal

### test-runner
- **ruby:** `docker compose exec web bundle exec rspec {files}`
- **javascript:** `docker compose exec web yarn test`

### issue-tracking
- **tool:** Linear MCP (`mcp__linear__*`)
- **conventions:** Ticket ID prefixes branch names. Team: Engineering.
```

User-specific environment bindings go in `CLAUDE.local.md` (gitignored) — same format, overrides `CLAUDE.md` where both define the same capability.

### Skill-Level Bindings (resources/)

For configuration specific to one skill in one project, create plugin files in the skill's resources directory:

```
~/.claude/skills/ci-monitor/
├── SKILL.md
└── resources/
    ├── domain-skill.md      # "In this project, CI is GitHub Actions..."
    └── personal-skill.md    # "Send me Telegram notifications..."
```

When a user installs a skill from this repo, they copy the `SKILL.md` and optionally create `resources/domain-skill.md` and `resources/personal-skill.md` for their environment.

### Cross-Skill Configuration

Some configuration is shared between skills that interoperate: a pipeline skill defines PR conventions that a PR-creation skill also needs; a spec skill defines traceability tags that a spec-check skill validates.

This is a real architectural tension. The options:

1. **Duplicate the configuration** in each skill's domain plugin. Simple but violates DRY.
2. **One skill reads another skill's resources.** This works (and is how pr-create currently reads orchestrate's domain-skill.md), but creates implicit coupling that's invisible from either skill's documentation.
3. **Lift shared configuration to environment-level bindings.** CLAUDE.md becomes the single source of truth for configuration that multiple skills consume.

This architecture recommends **option 3 as the default**: configuration consumed by multiple skills belongs in CLAUDE.md, not in any single skill's resources directory. Skill-level domain plugins are for configuration that genuinely belongs to one skill only.

When skills need to document their interoperation, add an **Interoperates With** section in the SKILL.md listing companion skills and what shared configuration they expect from the environment.

### Documenting Extension Points

Every skill with capabilities must include a section documenting what its plugin files should contain. This is the contract — it tells the plugin author what the skill expects, without requiring them to reverse-engineer it from the workflow:

```markdown
## Extension Points

### domain-skill.md
Provide project-specific CI configuration:
- CI system and how to check run status (e.g., `gh run list --branch {branch}`)
- Branch/PR conventions for CI triggers
- Known flaky tests to deprioritize
- Post-fix verification commands

### personal-skill.md
Provide notification preferences:
- Map NOTIFY_CI_PASS, NOTIFY_CI_FAIL, NOTIFY_CI_FIXED to concrete tools
  (see Notification Verbs table for semantics)
- Session logging preferences
- Autonomy level for auto-fix decisions (conservative / moderate / aggressive)
```

---

## Examples

### Example 1: Self-Contained Skill (Minimal Adaptation)

**rca** (Root Cause Analysis) — a phased investigation methodology. Already generic, already has an ad-hoc domain resource pattern.

**Before:** The skill checks for `resources/{project-name}.md` at runtime — a working but non-standard lookup. References `specs/tasks/` as a hardcoded investigation doc destination. No formal capability declarations.

**After:**

```yaml
---
name: rca
description: Root cause analysis for technical investigations.
capabilities:
  optional:
    - observability    # Access logs, metrics, error tracking
    - session-logging  # Log investigation progress
---
```

Body changes:
- `specs/tasks/` reference becomes: "Write investigation notes to the project's standard documentation location (see domain plugin or project conventions)."
- The `resources/{project-name}.md` pattern is renamed to `resources/domain-skill.md` for consistency.
- An **Extension Points** section documents what the domain plugin should contain.
- Resolution instruction template added to the plugin discovery section.

**What didn't change:** The phased investigation methodology, anti-patterns, evidence hierarchy. The core workflow is untouched — the adaptation was purely structural.

### Example 2: Hardcoded Bindings Extracted (Medium Adaptation)

**ci-monitor** — monitors CI and auto-fixes failures. Currently references a specific messaging tool, a specific visual-regression vendor, and project-specific details.

**Before:** Hardcoded messaging-tool calls, private project references, vendor-specific visual-regression CI steps.

**After:**

```yaml
---
name: ci-monitor
description: Monitor CI for the current branch and fix failures.
capabilities:
  uses:
    - messaging
    - ci-pipeline
    - code-hosting
  optional:
    - browser-testing
---
```

Semantic verbs defined in skill body. All Telegram references removed from core. All employer-specific CI steps moved to an example domain plugin.

**Complete domain-skill.md for a GitHub Actions + Docker project:**

```markdown
# CI Monitor — Domain Configuration

## CI Pipeline

- **System:** GitHub Actions
- **Check status:** `gh run list --branch $(git branch --show-current) --limit 5`
- **View logs:** `gh run view {run_id} --log-failed`
- **Re-run:** `gh run rerun {run_id} --failed`
- **Visual regression:** your visual-regression service (check status in the Actions log output)

## Test Commands

- **Ruby:** `docker compose exec web bundle exec rspec {files}`
- **JavaScript:** `docker compose exec web yarn test`
- **Lint:** `docker compose exec web rubocop {files} && docker compose exec web yarn eslint {files}`

## Known Flaky Tests

- `spec/system/pdf_export_spec.rb` — intermittent Puppeteer timeout, retry once
- `spec/jobs/sync_job_spec.rb` — race condition on CI, not a real failure

## Post-Fix Verification

After pushing a fix, wait 2 minutes then re-check CI status.
Branch protection requires all checks to pass before merge.

## PR Conventions

- Auto-fix commits: prefix with `fix(ci):` 
- If fix touches production code (not just tests), request review before pushing
```

This file contains everything the skill needs to operate in this specific project. The skill's core workflow is unchanged — it just reads these specifics instead of having them hardcoded.

### Example 3: Existing Plugin Pattern Standardized

**pipeline** — a full development pipeline orchestrator. Already has domain-skill.md and personal-skill.md with rich content.

**Before:** Working three-layer system with no formal capability declarations. Notification verbs defined in SKILL.md but not declared in frontmatter. Cross-skill resource sharing via other skills reading its resources.

**After:**

```yaml
---
name: pipeline
description: Full development pipeline from assess through reflect.
capabilities:
  uses:
    - test-runner
    - lint-runner
    - code-hosting
    - messaging
  optional:
    - issue-tracking
    - browser-testing
    - session-logging
    - observability
---
```

Changes:
- Capability declarations added to frontmatter
- Notification verb table standardized to the shared vocabulary
- Extension Points section added, documenting domain-skill.md's expected sections
- Resolution instruction template embedded
- Cross-skill resource sharing replaced: PR conventions that other skills (pr-create) need are documented as belonging in environment-level CLAUDE.md bindings rather than in pipeline's domain-skill.md
- **Interoperates With** section added, listing pr-create and ci-monitor as companion skills

**What didn't change:** The pipeline phases, the orchestration logic, the existing domain-skill.md and personal-skill.md content. Existing plugin files continue to work — the adaptation is additive.

---

## Directory Structure

### Skill Repository Layout

```
claude-skills/
├── README.md
├── MANIFEST.md
├── docs/
│   └── plugin-architecture.md          # This document
├── examples/
│   ├── CLAUDE.md.example               # Project binding template
│   ├── CLAUDE.local.md.example         # Personal binding template
│   └── domain-plugins/                 # Example domain plugins for popular stacks
│       └── rails-docker.md             # Additional stacks added as needed
├── skills/
│   ├── development/                    # Coding, testing, CI, debugging
│   ├── architecture/                   # Design, specs, system thinking
│   ├── product/                        # PM, research, signals, triage
│   ├── orchestration/                  # Multi-agent coordination, pipelines
│   ├── collaboration/                  # Communication, handoff, threads
│   └── tooling/                        # Skill creation, discovery, config
└── README.md
```

### Skill Directory Layout

```
skill-name/
├── SKILL.md                            # Required. Core workflow + capability declarations.
└── resources/                          # Optional. Extension material.
    ├── domain-skill.md                 # Per-project configuration (user-created)
    ├── personal-skill.md               # Per-user preferences (user-created)
    ├── references/                     # Documentation loaded on demand
    ├── scripts/                        # Executable code for deterministic tasks
    └── assets/                         # Templates, fixtures, examples
```

### Naming Conventions

- **Skill directories:** kebab-case (`ci-monitor`, `code-review`, `spec-check`)
- **Skill file:** `SKILL.md` (uppercase — Claude Code silently ignores lowercase)
- **Plugin files:** `domain-skill.md`, `personal-skill.md` (lowercase, fixed names)
- **Resource subdirectories:** lowercase (`references/`, `scripts/`, `assets/`)
- **Category directories:** lowercase, plural nouns (`development/`, `orchestration/`)
- **Capability names:** kebab-case nouns (`messaging`, `test-runner`, `issue-tracking`)
- **Semantic verbs:** UPPER_SNAKE_CASE (`NOTIFY_BLOCKING`, `NOTIFY_INFO`)

---

## Migration Guide

### Step 1: Assess the Skill

Read the skill and classify it:

| Classification | Characteristics | Action |
|---------------|----------------|--------|
| **Self-contained** | No external service references, no project-specific paths | Add frontmatter (no `capabilities:`), move to category directory |
| **Implicit bindings** | References tools/services generically ("use the messaging system") | Formalize as capability declarations, document extension points |
| **Hardcoded bindings** | References specific tools/paths (`mcp__telegram-mcp__notify`, `/home/username/`) | Extract to capability interfaces, replace with semantic references |
| **Existing plugins** | Already has domain-skill.md / personal-skill.md | Standardize frontmatter, add resolution template, verify contract documentation |

### Step 2: Update Frontmatter

Add capability declarations if the skill references external services:

```yaml
# Before
---
name: ci-monitor
description: Monitor CI for the current branch and fix failures.
---

# After
---
name: ci-monitor
description: Monitor CI for the current branch and fix failures.
capabilities:
  uses:
    - messaging
    - ci-pipeline
  optional:
    - issue-tracking
---
```

Self-contained skills need no `capabilities:` field — omission signals self-contained.

### Step 3: Replace Hardcoded References

Convert specific tool references to semantic capability references:

```markdown
# Before
Send a Telegram notification: `mcp__telegram-mcp__notify(message: "CI failed")`

# After
Use the **messaging** capability to send an informational notification:
"CI failed on branch {branch} — {failure_count} failures detected."

If no messaging binding is configured, print the status to the terminal.
```

The skill defines *what* to communicate and *when* — the interface. The binding defines *how* — the implementation. This is where dependency inversion for natural language becomes concrete.

### Step 4: Document Extension Points

Add an **Extension Points** section listing what domain-skill.md and personal-skill.md should contain. Be specific about what the skill expects — this is the contract for plugin authors. Include the expected section headings and what kind of information belongs in each.

### Step 5: Add Plugin Discovery with Resolution Template

Add the resolution instruction template from "The Three-Layer System" section. This is not optional — without it, the LLM has no instruction to prefer personal bindings over domain bindings over environment bindings. The template is the mechanism that makes precedence work.

### Step 6: Verify Graceful Degradation

Confirm the skill works in core-only mode. Every capability reference should have a defined fallback. Every semantic verb should have a default behavior. A skill that can't function without its plugins has failed the architecture's core requirement: dependency inversion requires a default implementation.

---

## Design Decisions and Tradeoffs

**Why not formal schemas?** We tried structured YAML configuration for pipeline's domain plugin early on and abandoned it. The problem: skills are prose instructions consumed by a language model. When the configuration was structured YAML, the skill had to include parsing instructions and error handling for malformed config. When the configuration was just markdown with expected sections, the skill naturally understood it — or gracefully handled missing sections by falling back to defaults. The medium dictates the mechanism.

**Why shared verb vocabularies instead of formal interfaces?** Three skills independently arrived at the same notification patterns (blocking, informational, urgent) with slightly different names. We standardized the names — but the "interface" is convention, not compilation. In traditional systems, this would be fragile. In LLM systems, it works because the verb names are semantically descriptive: even if a skill uses `NOTIFY_URGENT` instead of `NOTIFY_ESCALATE`, the personal plugin's mapping table and the verb's documented meaning make the intent clear. The binding is resolved by understanding, not by signature matching.

**Why environment-level bindings in CLAUDE.md?** We discovered that the same messaging configuration was being duplicated across four skills' personal-skill.md files and falling out of sync. "In this project, notifications go to Telegram" is a project fact, not a per-skill preference. CLAUDE.md is the natural home for project-wide facts that all skills inherit. The skill-level plugins remain for configuration that genuinely belongs to one skill — pipeline phase configuration doesn't belong in CLAUDE.md any more than a function's local variables belong in environment variables.

**Why two customization axes (domain/personal)?** Domain configuration is project-specific and typically committed to the repo — it's shared with the team. Personal configuration is user-specific and typically gitignored — it's private to the user. The separation maps to real organizational boundaries: a team shares the test commands; each team member chooses their notification channel. Collapsing them into one file conflates shared project conventions with individual preferences.

**Why no versioning scheme?** This architecture is for a curated skill collection, not a package registry. Skills don't have independent version numbers — they evolve with the collection. The spec version (in this document's header) tracks the architecture itself. If the plugin contract changes (new frontmatter fields, renamed conventions), the change is documented in CHANGELOG.md and skills are updated in the same commit. This is appropriate for the current scale; a package-registry model would be premature.

---

## Scope and Future Work

This spec covers the plugin architecture for the current skill collection (~105 unique skills, 21 publishable as-is). It intentionally does not address:

- **A skill package manager or registry.** Skills are installed by copying files. This is appropriate for a curated collection.
- **Runtime capability validation.** Whether a skill's declared capabilities match its actual references is not validated. A future linter could check this.
- **Automated binding resolution.** The LLM resolves bindings by reading structured prose. A future tool could generate binding files from environment inspection.

Each of these would be a natural extension if the collection grows beyond a single maintainer.
