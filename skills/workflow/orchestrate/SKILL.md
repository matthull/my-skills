---
name: orchestrate
description: >
  Plan and execute multi-step work through composable modes and sequences.
  Triages operator goals into concrete completion criteria and agent/operator
  boundaries, selects or composes orchestration patterns, and manages
  delegation across agents and teams. Teaches operators orchestration
  principles by modeling them in practice. Use when work needs structured
  coordination — not for simple single-agent tasks.
usage: "/orchestrate <task description or goal>"
---

# Orchestration

Coordinate work through subagents and teams. The orchestrator's job is to stay thin, delegate effectively, and steer when needed — never to do the work itself.

**Input:** `{{input}}`

---

## On Skill Load — Route to Planning or Execution

**The operator invoked `/orchestrate`. Before doing anything, determine whether a plan already exists.**

Immediately on skill load:

1. **Resolve `<task-dir>`** from operator input, inference, or defaults (see Task Dir Resolution below)
2. **Check if `<task-dir>/task-plan.md` exists**
   - **If YES → skip to Execution.** The plan was already approved. Do NOT enter Plan Mode. Go directly to the "Execution (Post-Plan Mode)" section below. The plan is the durable state — resumption reads it and picks up from the last completed phase.
   - **If NO → enter Plan Mode** and build the plan (continue with step 3 below)
3. **Enter Plan Mode** using the EnterPlanMode tool
4. **Check for existing triage output** (see Step 0 below) — this determines whether Pass 1 is needed
5. **Create tasks** using TaskCreate:
   - If no triage exists: Task A: "Triage — scope goal + completion criteria" (start `in_progress`), Task B: "Build and approve task plan" (leave `pending`)
   - If triage exists and is fresh: Task B only: "Build and approve task plan" (start `in_progress`)
6. Execute **Step 0: Triage** (below)
7. Once the operator approves the plan, **write a durable copy** to `<task-dir>/task-plan.md` using the Write tool. The Plan Mode plan in `~/.claude/plans/` is ephemeral and disappears on exit.
8. **Exit Plan Mode** using ExitPlanMode — this clears context
9. After context clears, read the durable plan from `<task-dir>/task-plan.md` and the mode/sequence resource files it references, then execute

The context separation is the point. Planning requires judgment, frameworks, and reasoning. Execution requires following a recipe. Mixing them causes drift.

### Task Dir Resolution

Resolve `<task-dir>` once during triage and reference it everywhere after:
1. Operator specifies explicitly (`/orchestrate --dir specs/article-suggestion-engine/tasks/abc-73/`)
2. Inferred from input (ticket number in the goal → `specs/<project>/tasks/<ticket-slug>/`)
3. If neither works, **assume no existing plan** — proceed to Plan Mode (step 3). Ask the operator during triage.

Create the directory if it doesn't exist. For backwards compatibility, if a `specs/<project>/orchestration-plan.md` exists from a prior run, read it — but new plans always write to `<task-dir>/task-plan.md`.

### Task Plan Format

The task plan written to `<task-dir>/task-plan.md` must contain:

```markdown
# Task Plan: [description]

## ⚠️ EXECUTION PREREQUISITES — NO EXCEPTIONS
1. **Load `/orchestrate`** using the Skill tool before executing ANY phase.
   Do NOT skip this. Do NOT implement anything directly. Do NOT rationalize that the task is "simple enough"
   to do inline. The orchestrator DELEGATES — it never writes code, edits files, or implements.
2. **If the plan uses TeamCreate**, create the team FIRST — tasks must land in the team's task list,
   not the default list. Then create TaskCreate entries for every phase and gate. If no team is used,
   create TaskCreate entries immediately after reading the plan.
   These are durable progress markers — if context is lost, they show exactly where to resume.
   Update task status as phases complete.

## Goal
[From triage, or confirmed in Pass 1]

## Completion Criteria
[From triage, or confirmed in Pass 1. 1-3 concrete signals — NOT a restatement of the spec.]

## Agent/Operator Boundary
[From triage, or confirmed in Pass 1]
**Agent owns:** [list]
**Operator owns:** [list]
**Gates at:** [list with rationale]

## Triage Source
[Path to triage.md if exists, or "inline — triaged during this planning session"]

## Phases
1. [PHASE NAME] — [description]
   - Mode: [mode name or "inline"]
   - Mode resource: [path to resource file, if named mode]
   - Completion: [how to know this phase is done]
   - Gate: [what operator decision is needed before next phase, if any]

2. [PHASE NAME] — ...

Phase sections contain **definition** (written during planning) and **results** (appended during execution).
Results are appended after each phase completes — never during planning. Format:
- **Produced:** [what was produced — artifacts, files, branches]
- **Confidence:** [free-form summary of verification done]
- **Gate outcome:** [what happened at the gate, or "skipped (autonomous)"]

Phases with all three result fields are treated as complete on resumption (see Execution § Phase Result Protocol).

## Autonomy Profile
[Profile name + any overrides]

## Starting Artifacts
[Specs, handoffs, task docs, etc. that already exist — with file paths]

## Verification Strategy
[For each completion criterion: what empirical verification confirms it's met? Map criteria →
verification methods. Criteria without mapped automated verification require explicit operator
acknowledgment — they are attention budget withdrawals. Unknown verification methods are
escalation points — surface them here, don't skip them. References domain skills, testing
infrastructure, and gaps from triage artifact audit.]
```

### Iterative Planning

You don't need the complete roadmap on the first pass. Plan what you can see clearly, mark the rest TBD:

- Goal and completion criteria should be stable even if phases evolve
- Mark unclear phases as "TBD — return to planning after Phase N"
- The rule: always have an approved plan before executing, even if it's partial

---

## Step 0: Triage (Plan Mode)

This section runs in Plan Mode. Its ONLY output is the task plan.

### Triage Input Check

Before doing anything else, check whether a triage output already exists:

1. **Look for `<task-dir>/triage.md`** — if `<task-dir>` is known from the input or can be inferred
2. **Look for a well-scoped Linear ticket** — if input references a ticket, fetch it and check whether it has goal, completion criteria, scope, and agent/operator boundary populated

**Three paths:**

**Path A — Triage exists and is fresh:** Read the task shape from `<task-dir>/triage.md` (or the well-scoped ticket). Present the goal, completion criteria, and agent/operator boundary to the operator with: "This was triaged on [date]. Does this still reflect the current intent, or should we re-triage?" If operator confirms, skip to Pass 2.

**Path B — Triage exists but may be stale:** Same as Path A, but flag staleness signals:
- Spec has been modified since triage date
- Branch has diverged significantly from when triage was done
- Operator's input suggests scope has shifted

Ask operator: "The triage from [date] may be stale because [reason]. Re-triage, or proceed with existing?" Operator decides — they may have internalized context that makes the existing triage still valid.

**Path C — No triage exists:** The task shape must exist before planning can proceed — but it can live in either a `triage.md` file OR a well-scoped Linear ticket. A ticket qualifies if it has: goal, completion criteria (with verification methods), scope (in/out), and agent/operator boundary. If neither source exists, run `/task-triage` inline (invoke via Skill tool with the operator's input). `/task-triage` may produce a `triage.md` file, update the ticket directly, or both — any of these satisfies the dependency. When triage completes and the operator has confirmed, proceed to Pass 2.

### Pass 2: Full Plan (after triage is confirmed)

With the confirmed task shape — goal, completion criteria, and agent/operator boundary (from triage) — now determine:

1. **Mode/Sequence** — which orchestration pattern fits
2. **Starting artifacts** — what already exists (with file paths)
3. **Autonomy profile** — which profile to run under
4. **Phases** — ordered work blocks with modes, completion criteria, and gates
5. **Verification strategy** — how we gain confidence across this execution (informed by triage artifact audit and domain skills)

Present the full plan and ask for approval.

### Autonomy Resolution

Resolve in order:
1. Explicitly specified in `{{input}}`
2. Already active in session (`/tmp/claude-sessions/{session_id}/autonomy-profile.txt`)
3. Default from the sequence or mode
4. Ask the operator

### Convergence

**Triage converges** when the operator confirms goal + completion criteria + boundary (via any of the three paths above).
**Pass 2 converges** when BOTH: (1) the plan has workable phases and modes, and (2) the operator approves.

Once approved: write the task plan to `<task-dir>/task-plan.md`, exit Plan Mode, begin execution.

---

## Execution (Post-Plan Mode)

After Plan Mode clears context, the executor starts fresh. It reads — in this order:

1. **This skill file** (`~/.claude/skills/orchestrate/SKILL.md`) — the behavioral constraints (delegation, context preservation, how to delegate) do not survive context clear. Re-read them.
2. The task plan (`<task-dir>/task-plan.md`). For backwards compatibility, also check `specs/<project-name>/orchestration-plan.md` if the task-dir plan doesn't exist.
3. **Check for phase results (resumability).** Scan each phase section in the task plan for result lines (`Produced:`, `Confidence:`, `Gate outcome:`). Phases that have all three result fields are already complete — mark their tasks `completed` and skip them during execution. This is the resumability mechanism: the operator starts a new session, loads `/orchestrate`, and the executor picks up where the previous session left off by reading the plan's embedded results. No separate manifest file is needed — the plan doc IS the durable state.
4. The mode/sequence resource files referenced in the plan
5. **If the plan uses TeamCreate, create the team FIRST** (`TeamCreate`) — this establishes the team's task list. Tasks created before the team land in the default list and won't be visible to team agents. **Then create TaskCreate entries** for every phase and gate in the plan. For each phase: create a task with subject `"Phase N: {PHASE NAME}"`, description containing the phase's completion criteria from the plan, and status `pending` (or `completed` if the phase already has results from step 3). For each gate between phases: create a task with subject `"Gate: {description}"` and the gate's trigger condition. These tasks are durable progress markers — if context is lost, they show exactly where to resume. Update task status as phases complete (`in_progress` when starting, `completed` when done).
6. **Install session injection for orchestration discipline.** Ensure the session directory exists:
   ```bash
   ~/.claude/hooks/ensure-session-dir.sh
   ```
   Then Read `resources/orchestrate-injection.txt` and Write its contents to `/tmp/claude-sessions/$CLAUDE_SESSION_ID/orchestrate.txt`. This injects delegation constraints into every turn for the rest of the session, combating attentional drift over long executions.

7. **Execute work-start steps.** If the task references a Linear ticket and `resources/domain-skill.md` defines work-start steps, execute them now (set ticket status, assign to operator, etc.). These are idempotent — safe on resumption.

Then it follows the plan as a recipe. The sections below are the executor's reference material.

### Phase Result Protocol

After each phase completes (all completion criteria met, gate resolved), the executor appends results to that phase's section in `<task-dir>/task-plan.md`:

```
- **Produced:** [what was produced — artifacts, files, branches]
- **Confidence:** [free-form summary of verification done]
- **Gate outcome:** [what happened at the gate, or "skipped (autonomous)"]
```

**Rules:**
- Write results on completion only — not on phase start
- Confidence is a free-form narrative, not a structured checklist
- No completion dates
- No automatic session spawning — reading the plan on startup enables resumption but the operator starts new sessions manually

These embedded results serve dual purpose:
1. **Resumability** — a new session reads the plan, sees completed phases, and skips them
2. **Traceability** — the plan doc becomes a complete record of what happened

---

## Core Vocabulary

**Mode** — a reusable pattern for one block of work. Defines agent roles, communication patterns, and how work flows within that block.

**Sequence** — an ordered chain of phases with gates between them. Each phase uses a mode.

**Phase** — a distinct stage within a sequence, with its own completion criteria.

**Gate** — a decision point where execution pauses. The autonomy profile controls which gates are active.

**Composing** — chaining modes and sequences together across a session.

---

## Empirical Verification Mandate

No work is complete without empirical evidence that it achieves the goal. This is a first-order principle, not a phase-specific procedure.

**Why this matters architecturally:** Agent outputs have high variance — from brilliant to unusable — and the orchestrator cannot reliably distinguish which is which by reading summaries. Automated empirical verification is the mechanism that prunes low-quality, off-goal outputs before they reach the operator. The orchestrator's job is to ensure this pruning happens — for every phase, for every task type. Carefully defined goals (from triage) aligned with automated verification create a loop: off-goal outputs are discarded automatically, preserving operator attention for judgment only humans can provide. This applies to all work — code, skills, workflows, documentation, infrastructure — not just tasks with established test suites.

**What this means in practice:**

- **Every phase completion** must cite empirical evidence (test output, console results, command output, before/after comparison), not narrative belief ("I implemented the feature as specified"). The orchestrator rejects completion claims that lack evidence and sends the agent back to produce it.
- **Every task plan** must map each completion criterion to a concrete verification method before the plan is approvable. Criteria without mapped verification require explicit operator acknowledgment of the gap.
- **Unknown verification = escalation.** When the agent doesn't know how to empirically verify a type of work, that is an escalation point, not a silent pass. The agent stops and surfaces: "I don't know how to verify this type of work. What verification would give you confidence?" The operator may know, or may accept the risk explicitly. This is the safety net — just as a developer would stop and ask "how do I test this?" rather than shipping untested code, agents must stop and figure out verification rather than skipping it.
- **The VERIFY phase** (in feature-implementation) is one expression of this principle for code, not its entirety. Task types without a formal VERIFY phase still require empirical verification before the orchestrator declares task complete.

---

## Autonomy Profiles

Profiles control **gate behavior and communication style only.** They do NOT change what the orchestrator does — the orchestrator always delegates, never implements. A profile never grants permission to read source code, write implementation, or skip delegation.

```
                    supervised  review-gated  design-collab  notify-only  semi-autonomous
question-threshold  low         high          design-only    high         high
interrupt-channel   in-session  in-session    push-notif     push-notif   push-notif-non-blocking
agent-verbosity     full-report summary       summary        summary      silent
within-phase-gates  on          off           off            off          off
phase-transition    on          on            on             off          off
```

**design-collab** — Operator is a thought partner on design/architecture decisions, fully autonomous on logistics (research, docs, file creation). Design substance goes to `PushNotification`; mechanical questions (file paths, tool choices, doc formatting) are handled autonomously or tabled for later. The operator wants to collaborate on WHAT and WHY, not manage HOW.
- `question-threshold: design-only` — only surface design/architecture decisions, tradeoffs, and novel ideas. Never ask about mechanics or logistics.
- `interrupt-channel: push-notification` — design discourse happens asynchronously via push notifications.
- `phase-transition: on` — operator approves phase boundaries (these are design decisions).

Full profile definitions: `resources/autonomy-profiles/{name}.md`

Include the active profile's behavioral directives in every agent spawn prompt.

### Gate Evaluation

When encountering a gate annotated `[requires: trait-name]`:
1. Read the active profile's structural traits
2. If the required trait is `off`, skip the gate
3. If `on`, execute the gate (notify/wait per `interrupt-channel`)

---

## Core Decision: How to Delegate

**When the plan specifies a mode, use that mode.** The table below is for unplanned delegation only — it never overrides an explicit plan. If the plan says Task-Lead-Implementer, use TeamCreate. Period. Do not downgrade to Agent because the task "looks simple."

**Coding tasks → Task-Lead-Implementer (TeamCreate). No exceptions.**

**Non-coding tasks (only when no mode is specified in the plan):**

| Signal | Use `Agent` tool | Use `TeamCreate` | Use terminal sidecar |
|--------|-----------------|------------------|----------------------|
| Scope | Single bounded output | Multi-step, multi-artifact | Work that itself needs a team |
| Duration | Quick (minutes) | Long-running (30min+) | Indefinite / session-length |
| Uncertainty | Low — clear path | High — needs steering | Requires its own orchestrator |

Also default to TeamCreate when tasks require domain skills, have quality gates, or where "missed a requirement" is a real failure mode.

---

## Context Preservation

The orchestrator must protect its own context window.

**NEVER:** Read/Grep/Glob source code, pull implementation details into orchestrator context, debug directly, participate in implementation.

**DO:** Receive structured summaries from agents, pass navigation context (file paths, constraints) not content context, read only orchestration artifacts.

---

## Interacting with Agents and Teams

**Spawning agents:** Complete self-contained prompts. Include file paths, constraints, expected output. **Always include the contents of `resources/standard-agent-directives.md` in every agent spawn prompt** — read it once at execution start and inject into all prompts.

### Equipping Agents with Skills

When the plan specifies skills, starting artifacts, or review lenses for a phase, the orchestrator MUST translate those into concrete agent prompt instructions. The orchestrator passes **file paths and invocation instructions**, never content summaries — agents load their own context.

**Skills — two mechanisms depending on agent type:**

1. **Agents with Skill tool access** (general-purpose, or any `subagent_type` that has `*` tools) — tell the agent to invoke the skill: *"Invoke `/vue` using the Skill tool before starting your review."* The agent gets the full skill content including progressive disclosure and resource routing.

2. **Specialized agents without Skill tool** (code-review-expert, Explore, etc.) — include the SKILL.md path and any relevant resource file paths with explicit read instructions: *"Read and apply the skill at `~/.claude/skills/vue/SKILL.md` and its `resources/` directory."*

**Starting artifacts** — every plan-specified starting artifact relevant to a phase MUST appear in that phase's agent prompts with its file path and usage instruction. If the plan lists it and the phase needs it, the agent prompt must reference it. No exceptions — this is how the plan's intent reaches the agents.

**Pre-spawn checklist** — before sending any agent prompt, verify:
- [ ] All plan-specified skills for this phase are referenced (with invocation or read instructions)
- [ ] All relevant starting artifacts are referenced (with file paths and usage instructions)
- [ ] Standard agent directives are included

**Managing teams:** Name agents by role. Steer with questions, not prescriptions. Let agents propose approaches.

**Handling blockers:** Spawn a fresh fixer agent (not the blocked agent). Always use `/rca` for diagnosis.

---

## Modes and Sequences

### Sequences

| Sequence | Resource | When to use |
|----------|----------|-------------|
| **Feature Implementation** | `resources/sequences/feature-implementation.md` | Spec exists, needs task breakdown → handoffs → implementation → PR with green CI |

When starting a sequence: create TaskCreate per phase, load the resource file, follow it.

**Phase-aware skill discovery:** At each phase start, review the skill catalog for phase-relevant skills. Include matching skills in the agent prompt.

### Modes

| Mode | Resource | When to use |
|------|----------|-------------|
| **Task-Lead-Implementer** | `resources/task-lead-implementer-mode.md` | Coding tasks needing TDD implementation with verification |
| **Solo Agent** | `resources/solo-agent-mode.md` | Single bounded artifact, no steering needed |
| **Parallel Research** | `resources/parallel-research-mode.md` | Multiple independent research questions concurrently |

Before executing any phase that references a named mode: use the Read tool on the mode resource file. The resource file contains the actual spawn instructions, agent roles, and communication patterns. Knowing the mode name is not the same as knowing what to do — the resource file is the instruction set. Do not proceed with a phase until you have read its mode resource.

---

## Project Context

Read `resources/domain-skill.md` if it exists for project-specific guidance.
Read `resources/personal-skill.md` if it exists for personal customizations.
