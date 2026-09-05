---
name: skill-discovery
description: >
  Discover and load relevant skills for the current task. Scans the installed skill catalog,
  evaluates relevance, and outputs reasoning. Use at the start of any orchestrated agent work
  to ensure the right practice skills are loaded.
---

# Skill Discovery

Find which installed skills are relevant to your current task, load them, and document your reasoning. Run this before doing substantive work.

## When to Use

At the start of any task that might benefit from practice skills — implementation, design, research, QA, or orchestration. If you are unsure whether skills exist for your task, run discovery anyway.

## Discovery Process

### 1. Locate the Skill Catalog

Your system context includes a catalog of all installed skills. Look for the block listing available skills in the Skill tool definition or the `<available-skills>` section. This is your source of truth — do not search the filesystem.

### 2. Evaluate Each Skill

For every skill in the catalog, read its name and one-line description. Decide: is it relevant to this task's technology, domain, or workflow?

### 3. Output Reasoning (MANDATORY)

You MUST output your selection reasoning for transparency and debugging. Format:

```
Skill discovery:
- supabase-sql: NO — no database policy work in this task
- react-native-expo: NO — this is a Rails backend task
- pg-perf-power-user: YES — task involves query optimization
- lookup-docs: YES — task references unfamiliar library API
- ruby-rails: YES — Rails service object implementation
```

Every skill gets a YES/NO with a brief justification. Do not skip skills silently.

### 4. Check Domain Skill

Read `resources/domain-skill.md` if it exists in the project's `.claude/skills/` directory. Domain skills define project-specific always-on skills that apply regardless of task type.

### 5. Load Selected Skills

Invoke each YES skill via the Skill tool immediately. These are now part of your working context.

### 6. Apply Fallback Chain

If no skill matches what you need:

1. **Improvise** — use your general knowledge to handle the task directly
2. **Escalate** — if you cannot improvise effectively, consult the operator before proceeding

Do not stall because a skill is missing. The chain is: **find skill -> improvise -> escalate**.

## Output

Produce a **Skills to Load** list that your caller can reference:

```
Skills to Load:
- ruby-rails (Rails patterns and conventions)
- pg-perf-power-user (query optimization guidance)

No matching skill found for: Kafka consumer patterns (improvising from general knowledge)
```

Include both loaded skills and any gaps where the fallback chain was applied.
