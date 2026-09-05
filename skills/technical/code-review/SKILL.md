---
name: code-review
description: "Structured code review with parallel specialist agents in separate subagent contexts. Uses /skill-discovery for domain-aware reviews. Each leg runs in its own fresh subagent for clean analysis."
tags:
  - code-review
  - quality-assurance
scope: user
capabilities:
  optional:
    - browser-testing   # Visual/browser QA is delegated to a companion skill, not run here
---

# /code-review — Structured Multi-Leg Code Review

Parallel specialist review agents, each in a fresh subagent context with a narrow focus and concrete checklist. Adapts to the codebase via `/skill-discovery` — loads domain skills (ruby-on-rails, vue, api-integration, etc.) based on changed files to inject project-specific review criteria.

## Usage

```
/code-review                                          # all legs, current branch diff to default branch
/code-review current branch diff to master             # explicit target description
/code-review --legs=security,wiring,test-quality       # specific legs only
/code-review --branch=feature-branch                   # explicit branch
/code-review src/components/                           # specific directory
```

**Default behavior:** Run ALL legs in parallel against current branch diff to default branch.
**To limit:** Use `--legs=` with comma-separated leg names.

## Process

### Step 1: Determine Review Target

Parse `$ARGUMENTS` for:
- **Legs filter** — value after `--legs=` (comma-separated list). If omitted, run ALL legs.
- **Branch** — value after `--branch=` (diff against default branch)
- **Target** — remaining args (file path, directory, or description like "current branch diff to master")

Get the diff:
- If `--branch` or "branch" mentioned: `git diff {default-branch}...{branch}`
- If target is a path: `git diff -- {path}` or read files directly
- If no specific target: `git diff {default-branch}...HEAD` (current branch vs default)
- Fallback: `git diff` (uncommitted changes)

Also gather: `git diff --stat` for file change summary, count of files/insertions/deletions.

If no changes found, report "No changes to review" and exit.

### Step 2: Skill Discovery

Invoke `/skill-discovery` via the Skill tool. This scans the installed skill catalog, evaluates relevance to the changed files, and outputs reasoning. It handles:
- Identifying which domain skills are relevant (ruby-on-rails, vue, unit-testing, etc.)
- Loading those skills so their guidance is available in context
- Outputting the reasoning for transparency

The loaded domain skill content becomes available for injection into leg prompts.

### Step 3: Launch ALL Leg Subagents in Parallel

**Every leg runs in its own separate subagent** (via the Agent tool, `run_in_background: true`). Fresh context per leg ensures focused, independent analysis. The overhead is worth it for review quality.

If your environment has a specialized code-review subagent type configured, use it for sharper, review-tuned analysis. Otherwise use the general-purpose agent type — the leg prompt's narrow focus and checklist do most of the work regardless of agent type.

For each leg (all legs unless `--legs=` filter was provided), spawn an Agent with:

1. **Base preamble** — from `resources/leg-prompts.md` (output format, file:line reference requirement)
2. **Leg-specific prompt** — the "Look for" checklist and "Questions to answer" for that leg
3. **The full diff** — each subagent gets the complete diff to analyze from its perspective
4. **Domain context** — relevant project conventions from loaded skills and CLAUDE.md

Launch ALL legs in a single message with multiple Agent tool calls.

### Step 4: Synthesize Findings

After all subagents return, synthesize into a unified report:

1. **Read all leg outputs**
2. **Deduplicate** — same issue found by multiple legs → merge into single entry, note all legs that found it
3. **Cross-reference confidence** — issues found by 3+ legs → auto-promote to next severity
4. **Resolve conflicts** — if legs disagree, flag as "Needs discussion" with both perspectives
5. **Prioritize** — P0 (must fix) → P1 (should fix) → P2 (nice to fix)

### Step 5: Output Report

@resources/synthesis-template.md

---

## Review Legs

Each leg has a narrow focus, concrete "Look for" checklist, and judgment-forcing "Questions to answer." Full leg definitions are in `resources/leg-prompts.md`.

By default ALL legs run. Use `--legs=` to run a subset.

### Analysis Legs
| Leg | Focus |
|-----|-------|
| **correctness** | Logic errors, edge cases, race conditions, off-by-one |
| **performance** | N+1 queries, O(n^2), missing indexes, blocking in async |
| **security** | OWASP, injection, auth bypass, data exposure, mass assignment |
| **elegance** | Abstraction quality, coupling, SOLID, reinventing utilities |
| **resilience** | Error handling, failure modes, partial failures, recovery |
| **style** | Convention compliance, naming, imports, comment quality |
| **smells** | Long methods (>50 lines), deep nesting (>3), DRY violations, god classes |

### Verification Legs
| Leg | Focus |
|-----|-------|
| **wiring** | Dependencies added but not used, SDK added but old impl remains |
| **commit-discipline** | Commit quality, atomicity, message clarity |
| **test-quality** | Weak assertions, missing negative cases, flaky indicators |

---

## NOT Responsible For

These are separate skills with their own scope:
- **Spec compliance** — `/spec-check` (per-requirement PASS/FAIL against spec)
- **QA classification** — `/qa-plan` (classifying verification items by execution channel)
- **Handoff compliance** — checking code against task handoff directives is a separate concern this skill does not cover
- **Browser verification** — a companion skill using the **browser-testing** capability (visual QA in real browser)

This skill reviews **code quality, correctness, and implementation patterns** — not whether the implementation matches a spec or handoff.

If no browser-testing binding is configured, note in the report that visual/browser QA was out of scope for this review and should be requested separately.

## Interoperates With

- **`/skill-discovery`** (Step 2) — loads domain skills relevant to the changed files. If `/skill-discovery` is not installed, skip domain skill loading and proceed with the generic "Look for" checklists only; note in the report that no domain skills were loaded.
- **`/spec-check`, `/qa-plan`** — complementary review skills with disjoint scope (see NOT Responsible For above). No shared configuration is required between them; each reads the same diff independently.
- **Browser-testing companion skill** — if the environment binds the **browser-testing** capability, a companion skill can pick up visual QA where this skill's scope ends. The binding lives in CLAUDE.md / CLAUDE.local.md so any skill that needs it (this one included) resolves to the same tool.

## Project and User Configuration

Load configuration in this order. **When multiple sources define the same binding,
the first one found wins** — stop checking lower sources for that binding:

1. Read `resources/personal-skill.md` if it exists — personal review preferences (e.g., preferred leg subset, notification routing).
2. Read `resources/domain-skill.md` if it exists — project-specific review configuration (e.g., extra legs, project conventions to weight heavily).
3. Check the project's CLAUDE.md / CLAUDE.local.md for environment-level capability bindings (especially **browser-testing**).
4. For any capability still unbound, use the defaults specified in this skill (browser QA reported as out of scope; general-purpose agent type for legs).

## Extension Points

### domain-skill.md
Provide project-specific review configuration:
- Additional or project-specific review legs beyond the standard set
- Project conventions the **elegance** and **style** legs should weight heavily (beyond what `/skill-discovery` already loads)
- Known false-positive patterns to deprioritize (e.g., a pattern that looks like a smell but is intentional in this codebase)
- Default `--legs=` subset for this project, if the full set is usually overkill

### personal-skill.md
Provide personal review preferences:
- Preferred severity threshold for what gets surfaced (e.g., suppress P2s by default)
- Notification routing for completed reviews, if any
- Whether to auto-run `/skill-discovery` or skip it for speed
