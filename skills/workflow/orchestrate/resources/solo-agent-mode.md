# Solo Agent Mode

Single subagent for producing a bounded artifact. Uses the `Agent` tool directly — no team overhead.

---

## When to Use

- Task produces a single, well-defined output (a document, a config file, a migration, a test suite)
- Path to completion is clear — no research phase or design ambiguity
- Low failure chance — the agent is unlikely to get stuck or need redirection
- No steering anticipated — the output is either correct or it's not
- Quick turnaround — expected to complete in one pass (under ~15 minutes)

## When NOT to Use

- Scope is uncertain or may expand during execution
- Multiple interdependent artifacts need to be produced
- Human review is needed mid-process (not just at the end)
- Task requires back-and-forth between research and implementation
- Agent is likely to need unblocking or course correction

---

## How to Use

Spawn a single `Agent` tool call with a self-contained prompt.

### Prompt Structure

A good solo agent prompt includes:

1. **Goal** — What to produce, in concrete terms
2. **Context** — File paths, constraints, conventions, relevant background
3. **Skill reference** — Which skill to invoke if applicable (e.g., "Run `/spec` on...")
4. **Output expectations** — What the result should look like, where files go
5. **Boundary** — What the agent should NOT do (prevent scope creep)

### Example

```
Agent(
  description: "Generate pgTAP tests for RLS",
  prompt: "Write pgTAP tests for the RLS policies in supabase/migrations/20240101_create_todos.sql.
    Follow the patterns in supabase/tests/existing_test.sql.
    Output to supabase/tests/todos_rls_test.sql.
    Only test RLS policies — do not modify migrations or schema."
)
```

---

## Foreground vs Background

**Foreground (default):** Use when the agent's output is needed before proceeding. The orchestrator waits for the result.

**Background (`run_in_background: true`):** Use when the orchestrator has other independent work to do. The system notifies when the agent completes. Good for:
- Kicking off a research task while working on something else
- Running tests or validation while continuing to code
- Parallel independent tasks (use multiple Agent calls in one message)

---

## Handling Results

The agent returns a single result message. The orchestrator should:

1. **Verify the output meets expectations** — not by reading source code, but by checking the agent's summary
2. **Act on the result** — integrate it into the broader workflow, report to the user, or spawn follow-up work
3. **If the result is insufficient:** Spawn a new agent with refined instructions, or escalate to a different mode if the task turned out to be more complex than expected

**Do not resume a solo agent to fix its output.** The overhead of resuming with corrections often exceeds spawning fresh with better instructions.
