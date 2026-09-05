# Parallel Research Mode

Fan-out multiple independent research questions to concurrent agents, then synthesize results in the orchestrator.

---

## When to Use

- Multiple independent questions need answering before a decision can be made
- Questions don't depend on each other's results
- Speed matters — sequential research would take too long
- Synthesis across findings is needed (the orchestrator combines results into a coherent picture)

## When NOT to Use

- Questions are sequential — answer to Q1 determines Q2
- Single research question (use Solo Agent mode)
- Research requires codebase modification (use Architect-Implementer mode)
- Results don't need synthesis — each answer stands alone and can be acted on independently

---

## How to Use

Spawn multiple `Agent` tool calls in a **single message** so they execute concurrently.

### Prompt Structure for Each Agent

1. **Question** — One specific, focused research question
2. **Scope** — Where to look (files, directories, docs, web)
3. **Output format** — What the summary should contain (findings, evidence, recommendations)
4. **Boundary** — Research only, do not modify code or create files

### Example

```
// Single message with three parallel Agent calls:

Agent(
  description: "Research auth patterns",
  prompt: "Research how authentication is currently implemented in this project.
    Look at src/lib/, supabase/ config, and any auth-related components.
    Summarize: auth flow, token handling, session management.
    Research only — do not modify any files."
)

Agent(
  description: "Research offline sync",
  prompt: "Research how offline sync is configured in this project.
    Look at PowerSync config, sync rules, and any conflict resolution patterns.
    Summarize: sync architecture, conflict strategy, known limitations.
    Research only — do not modify any files."
)

Agent(
  description: "Research test patterns",
  prompt: "Research the testing patterns used in this project.
    Look at test files, jest config, and any test utilities.
    Summarize: test framework, mocking patterns, coverage approach.
    Research only — do not modify any files."
)
```

---

## Synthesis

After all agents return, the orchestrator combines findings:

1. **Extract key facts** from each agent's summary — do not re-read the files they examined
2. **Identify connections** between findings that individual agents couldn't see
3. **Resolve contradictions** — if agents report conflicting information, note the conflict and investigate further if critical
4. **Produce a unified picture** — the synthesis is the orchestrator's primary value-add in this mode

The synthesized result informs the next decision: which mode to use for execution, what constraints to apply, or what to report to the user.

---

## Agent Type Selection

- **Codebase questions** → `subagent_type: "Explore"` — optimized for Glob/Grep/Read, no edit tools
- **Web research** → `subagent_type: "general-purpose"` — has WebFetch/WebSearch access
- **Documentation lookup** → tell the agent to use `/lookup-docs` for library/framework questions

## Scaling Rules

- **3-5 parallel agents** is the practical sweet spot — enough parallelism to save time, few enough to synthesize coherently
- Beyond 5, consider grouping related questions into single agents
- Each agent should answer ONE focused question — broad prompts produce shallow results
- Always specify `Research only — do not modify any files` in prompts to prevent side effects
