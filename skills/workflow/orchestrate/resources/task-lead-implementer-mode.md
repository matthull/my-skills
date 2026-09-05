# Task-Lead-Implementer Mode

Multi-role orchestration for features that require codebase research, specification, task breakdown, and TDD implementation. Uses `TeamCreate` for visibility and steering across interdependent phases.

---

## When to Use

Use for any coding task by default. See `/orchestrate` rubric — task-lead-implementer is the default for coding unless the operator explicitly says otherwise.

## When NOT to Use

- Operator explicitly directs a different approach
- Non-coding task (document production, research) — use Solo Agent or Parallel Research instead

## Invocation Context

**Full mode** (direct invocation, no pre-existing handoffs): task lead does research → spec → taskout → handoff, then implementer runs.

**Implement-only** (invoked from a sequence where DESIGN already produced handoffs): task lead does codebase research only — no spec/taskout/handoff. Task lead's role is context retention and implementer support. Skip task lead design steps in the Orchestration Flow below.

---

## Roles

### Task Lead

Researches the codebase, creates design artifacts, and writes handoff documents. The task lead has the deepest codebase understanding — its handoffs are context briefings to the implementer.

**Workflow:**
1. Research the codebase — read source code, find patterns, understand architecture
2. Run `/spec` to produce the feature specification (large/medium complexity)
3. Run `/taskout` to break the spec into TDD-sized tasks (large/medium)
4. Run `/handoff` to create implementation-ready handoff documents for each task

**Outputs:** Spec document, task list, handoff documents in `specs/<feature>/`

**Key constraints:**
- The task lead does not write application code — it produces plans and documents
- The task lead stays alive after design completes — it retains codebase context that the implementer can query via peer messaging
- Only shut down the task lead when implementation is complete and no design questions remain

**Spawn prompt template:**

```
You are the task lead for a development task. Your job is to research the codebase,
create specification/task documents if needed, and produce handoff documents.

## Task
{task description from ASSESS/triage}

## Complexity
{complexity classification}

## What to produce

Based on complexity:
- **Large**: Run `/spec` to create specification, then `/taskout` for task breakdown,
  then `/handoff` for each task
- **Medium**: Run `/spec` or `/taskout` if tasks.md doesn't exist, then `/handoff` for each task
- **Small**: Run `/handoff <task description>` directly

## Existing artifacts
{list any existing specs, tasks, handoffs found}

## Target directory
specs/{project-name}/

## Instructions

### Step 1: Discover relevant skills (MANDATORY)
Invoke `/skill-discovery` BEFORE doing any design work. You are the senior
engineer — bring the right knowledge. The skill handles catalog scanning,
per-skill reasoning output, domain skill checks, and the fallback chain.

### Step 2: Research and design
1. Research the codebase thoroughly — read source code, find patterns, understand architecture
2. Create the appropriate artifacts using the design skills below
3. Write ALL artifacts to disk in the specs/ directory
4. When complete, send a message to the orchestrator with:
   - What artifacts were created (with file paths)
   - Key design decisions made and rationale
   - Any open questions or trade-offs for user review
5. STAY ALIVE after completing — you retain valuable codebase context that may be
   needed during implementation

## Design skills
- `/spec` — Create implementation specification (includes brownfield discovery, design quality)
- `/taskout` — Generate task breakdown from spec
- `/handoff` — Create implementation handoff document
- `/research` — Deep research with citations
- `/request-research` — Commission parallel research subagents
```

### Implementer

Implements individual tasks from handoff documents using TDD.

**The handoff IS the prompt.** The handoff document (produced by `/handoff`) already contains behavioral requirements, file references, skill references, verification loops, and success criteria. The spawn prompt adds only environment constraints and team coordination instructions — do NOT duplicate handoff content.

**Spawn pattern:**
```
Task(
  name="implementer",
  team_name="...",
  prompt="Read and implement the task handoff at:
         specs/{project}/task-handoffs/{handoff-file}.md

         The 'task-lead' teammate has deep codebase context from the design
         phase. If you hit ambiguities or questions about patterns, message
         the task-lead directly via SendMessage. Do NOT relay through the
         orchestrator for technical questions.

         {include contents of resources/standard-agent-directives.md}

         Keep the orchestrator informed with brief summaries:
         - When you hit an issue (what happened, that you're consulting task-lead)
         - When the issue is resolved (what the resolution was)
         - When you're blocked and need user input (what you need)
         - When implementation is complete (summary of what was done, test results)

         When complete or stuck, send a final status message to the orchestrator."
)
```

**Key constraints:**
- Follows the handoff document — deviations are reported to orchestrator, not decided unilaterally
- Consults task lead directly for technical questions (peer-to-peer, no relay through orchestrator)
- Escalates blockers outside handoff scope (environment issues, infrastructure failures) to orchestrator

### Fixer (spawned on demand)

Fresh-context agent for diagnosing blockers. Never ask the blocked agent to debug its own issues.

**Spawn pattern:**
```
Task(
  name="fixer",
  team_name="...",
  prompt="Run /rca to diagnose and fix this issue:
         {blocker description from implementer}

         Context: The implementer hit this blocker during implementation.
         Your job is to diagnose the root cause and fix it.

         CRITICAL: Use /rca first. Do NOT guess at fixes.

         Report back to the orchestrator when fixed (or if you can't fix it)."
)
```

After the fixer resolves the issue, message the implementer to continue.

---

## Orchestration Flow

```
1. Create team (TeamCreate)
2. Spawn task lead → research + spec + taskout + handoff
3. Verify artifacts exist (Glob for specs/{project}/task-handoffs/*.md)
4. Design review steering point (see Autonomy Heuristic below)
5. For each handoff: spawn fresh implementer → TDD (red/green/refactor) → gate check
6. Monitor progress (steering point after each handoff; shut down implementer before spawning next)
7. On blockers → spawn fixer with /rca, resume implementer after
8. VERIFY phase — handled by the sequence (see feature-implementation.md Phase 4)
9. Process verdict → fix or proceed (see Verification Failure Protocol)
10. Ship and cleanup
```

**Note:** Step 8 (VERIFY) is defined in the feature-implementation sequence, not in this mode. The sequence composes standalone skills (`/spec-check`, `/qa-plan`, optionally `/task-review`) and routes failures back through this mode's Verification Failure Protocol (step 9).

### Autonomy Heuristic: Gate on Design Review or Proceed?

**This gate is annotated `[requires: within-phase-gates]`.** If the active autonomy profile has `within-phase-gates: off`, skip this heuristic entirely and proceed. If `on`, apply the rules below:

After the task lead completes, decide whether to pause for human review:

**Proceed without waiting** when ALL true:
- All design decisions follow established codebase patterns
- No novel architectural choices or new abstractions introduced
- Scope is clear and bounded (small/medium complexity)
- No trade-offs between meaningfully different approaches

**Pause and wait for review** when ANY true:
- A decision introduces a new pattern or abstraction
- There are genuine trade-offs between different valid approaches
- The task lead flagged open questions needing user input
- Scope expanded beyond what was assessed
- Large complexity tasks (always gate on design review)

### Steering Points

**After task lead completes:** Highest-leverage steering point — changes here are cheap, changes after implementation are expensive. Verify: scope matches goal, task breakdown is appropriately sized, no critical concerns missed.

**After each implementation handoff:** Check that tests pass and implementation aligns with handoff. Redirect if drifting. Do NOT read source code — rely on implementer's summary.

**On blockers:** Classify: context issue (provide more info) → design issue (loop back to task lead) → environment issue (spawn fixer with `/rca`). Never let the orchestrator debug directly.

### Verification Failure Protocol (Step 9)

When the verifier reports failures, fixes **always** route through the task lead. The orchestrator never ad-hoc prompts implementers with fix instructions.

```
Verifier reports failure
  → Orchestrator sends failure details to task lead
  → Task lead writes fix handoff(s) to specs/{project}/task-handoffs/
  → Orchestrator spawns implementer with the fix handoff
  → Re-verify
```

**The handoff is the unit of work.** If there's no handoff, there's no implementation. The orchestrator coordinates — the task lead designs fixes, the implementer executes from handoffs. No shortcuts.

---

## Team Lifecycle

**Creation:** `TeamCreate(team_name="{slug}")` — use a short identifier.

**Spawning order:** Task lead first. Implementer after design review. Verifier after implementation. Fixer only on demand.

**Peer communication:** Implementer and task lead communicate directly for technical questions. Orchestrator receives summary notifications only: issue occurred, issue resolved, stuck, complete.

**Keeping agents alive:** Keep the task lead alive during implementation — it has codebase context the implementer may need. Shut down after implementation completes and no design questions remain.

**Shutdown:** Use `shutdown_request` for graceful termination. Shut down agents as their role completes.

**Cleanup:** `TeamDelete` when all work is complete.

---

## Handoff Iteration

Design may produce multiple handoffs (one per task). List them with `Glob: specs/{project}/task-handoffs/*.md`.

**One handoff per implementer (mandatory).** Spawn a fresh implementer for each handoff. Multiple handoffs in a single implementer context exhaust it silently — TeamCreate has no context-exhaustion signal. After an implementer completes its handoff and passes the gate check, shut it down and spawn a new one for the next handoff.

**Sequential (default):** Implement handoffs in order — one fresh implementer per handoff. Run verification once after all are complete.

**Parallel (when independent):** If handoffs explicitly state they are independent, spawn multiple implementers concurrently (`implementer-1`, `implementer-2`). Each still gets exactly one handoff.

### Gate Check Before Advancing (per handoff)

- [ ] Implementer signals completion
- [ ] All tests pass (confirmed by implementer)
- [ ] Linting clean (confirmed by implementer)
- [ ] All verification loops from handoff satisfied
- [ ] Refactor step complete (see below)

### Refactor Step (red/green/REFACTOR)

After green (tests pass, lint clean), the implementer runs a structured refactor pass before the handoff is considered complete. This is the "refactor" in red/green/refactor — improving code quality while tests are green.

**Process — loop until clean:**
1. Invoke `/code-review` with a prompt like:
   `this is a review to facilitate the Refactor step of the Red/Green/Refactor TDD cycle. Skip commit-discipline as it is not relevant mid-implementation.`
2. Read the review output. If **zero P0 and zero P1 issues** → refactor step is complete. Proceed to commit.
3. If P0 or P1 issues exist: fix them. Optionally fix P2+ at implementer judgment.
4. Rerun tests to confirm still green.
5. **Go back to step 1.** Run `/code-review` again on the updated code. New issues may have been introduced by fixes, or previously-masked issues may surface.
6. Repeat until `/code-review` reports zero P0 and zero P1.
7. If a fix is not viable or appropriate, **escalate** to the orchestrator — do not defer, do not skip.
8. If a P0/P1 finding feels **inappropriate or wrong** (false positive, irrelevant to context, conflicts with project conventions), **escalate that too**. This is valuable feedback — it means either `/code-review` leg prompts need tuning or the implementation guidance needs to align. Report which leg produced the finding and why you disagree.

**Exit condition:** `/code-review` run produces zero P0 and zero P1 issues. This is the gate — do not commit until this condition is met.
