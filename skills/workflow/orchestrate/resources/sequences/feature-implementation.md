# Sequence: Feature Implementation

**Input:** Spec file path (e.g. `specs/h1a/spec.md`)
**Output:** Implemented, tested code on a feature branch with all handoffs complete
**When to use:** A spec exists and needs to go from paper to working code. Covers design, environment setup, and implementation.

---

## Starting a Sequence

**First: create the task-lead-implementer team** (`TeamCreate`) — the same team spans DESIGN through IMPLEMENT. Do this before anything else.

**Then: create TaskCreate entries** for phase tracking (tasks automatically associate with the active team context):
- `"DESIGN: [feature name] — task breakdown and handoffs"`
- `"FEATURE-INIT: [feature name] — branch and dev environment"`
- `"IMPLEMENT: [feature name] — task-lead-implementer execution"`
- `"VERIFY: [feature name] — spec compliance, QA execution by disposition, evidence"`
- `"SHIP: [feature name] — commit, PR, CI green"`

Update task status as phases complete. These are durable progress markers — if context is lost, they show exactly where to resume. The task lead retains codebase context through the whole sequence so implementers can query it later.

---

## Phase 1: DESIGN

**Goal:** Produce a complete set of handoff documents from the spec.
**Mode:** Task-lead-implementer team (TeamCreate). Task lead runs in full mode — research + taskout + handoffs. See `resources/task-lead-implementer-mode.md`.

Spawn the task lead with the spec path and instructions to:
1. Research the codebase
2. Produce a task breakdown (using a task-breakdown skill like `/taskout`, or directly if none available)
3. **Report back to orchestrator** with the task list before writing handoffs — the orchestrator will gate here

**Gate [requires: within-phase-gates]:** Orchestrator receives the task list from the task lead and sends NOTIFY_BLOCKING for user approval. On approval, message the task lead to proceed with handoff documents. Do not let the task lead write handoffs before approval. *If gate is inactive (trait off), proceed directly — architect writes handoffs without waiting for approval.*

After approval, architect produces handoff documents for each task (using a handoff skill like `/handoff`, or directly if none available). Output to `specs/{feature}/task-handoffs/T{n}-{slug}.md`.

**Gate [requires: phase-transition-gates]:** All handoff files must exist and be non-empty. Notify user and wait for approval before proceeding to FEATURE-INIT. *If gate is inactive, proceed as soon as handoffs exist — no approval needed.* Task lead stays alive — do not shut it down.

**Phase result:** Update `<task-dir>/task-plan.md` — append Produced, Confidence, and Gate outcome to this phase's section.

---

## Phase 2: FEATURE-INIT

**Goal:** Feature branch created, development environment running, ready to implement.
**Mode:** Inline — direct orchestrator action or single Agent call. Task lead team stays alive in background.

Run a feature setup skill for the project (e.g. `/init-feature`). This skill should:
- Create the feature branch from the default branch
- Start the development environment (services, emulators, hot reload)
- Verify the environment is healthy before returning

If no feature setup skill is available, perform equivalent steps directly: create branch, start necessary services, confirm healthy.

**Gate [requires: phase-transition-gates]:** Branch exists and environment is confirmed healthy. Notify user and wait for approval before proceeding to IMPLEMENT. *If gate is inactive, proceed as soon as environment is healthy.*

**Phase result:** Update `<task-dir>/task-plan.md` — append Produced, Confidence, and Gate outcome to this phase's section.

---

## Phase 3: IMPLEMENT

**Goal:** All handoffs implemented, tested, and verified on the feature branch.
**Mode:** Continue with the existing task-lead-implementer team. Task lead switches to implement-only role (context retention + implementer support — no more design artifacts). See `resources/task-lead-implementer-mode.md`.

Spawn a fresh implementer per handoff into the existing team (one handoff per implementer — see `task-lead-implementer-mode.md`). The mode handles:
- Implementer spawning and TDD execution
- Task lead fielding implementer questions via peer messaging (no relay through orchestrator)
- Verification loops per handoff
- Blocker escalation (fresh fixer agent + /rca, not the blocked implementer)
- Completion reporting

**Phase result:** Update `<task-dir>/task-plan.md` — append Produced, Confidence, and Gate outcome to this phase's section.

---

## Phase 4: VERIFY

**Goal:** Independent verification that implementation satisfies the spec, with all executable QA items run and results documented.
**Mode:** Inline — orchestrator composes standalone skills and executes QA items by disposition.

**Core principle:** VERIFY is not just classification — it is execution. Every QA item that CAN be run by an agent or walked through with the operator MUST be run before SHIP. Items that cannot be run (environment unavailable, credentials missing) are explicitly deferred with a stated reason and documented as critical unfinished work in the PR.

### Step 1: Parallel skill invocation

Spawn two agents in parallel:

**Agent A — Spec compliance:**
```
Task(
  name="spec-checker",
  team_name="...",
  prompt="FIRST: Run /skill-discovery to load relevant practice skills.
         THEN: Run /spec-check {spec-path}

         Practice skills provide domain-specific verification criteria
         (e.g., stub verification tags, migration discipline). Load them
         BEFORE running spec-check so your compliance report covers
         practice-level requirements, not just spec-level ones.

         {include contents of resources/standard-agent-directives.md}

         Send the full compliance report to the orchestrator when done."
)
```

**Agent B — QA classification:**
```
Task(
  name="qa-planner",
  team_name="...",
  prompt="FIRST: Run /skill-discovery to load relevant practice skills.
         THEN: Run /qa-plan in feature-scoped mode for the current branch.
         Spec path: {spec-path}

         Practice skills define testing requirements that inform QA
         classification (e.g., console validation steps, browser QA needs).
         Load them BEFORE running qa-plan.

         {include contents of resources/standard-agent-directives.md}

         Send the classified QA plan to the orchestrator when done."
)
```

### Step 2: Optional code quality review

**Gate [requires: within-phase-gates]:** If active, spawn a third agent:

```
Task(
  name="code-reviewer",
  team_name="...",
  prompt="FIRST: Run /skill-discovery to load relevant practice skills.
         THEN: Run /task-review against the handoffs at specs/{project}/task-handoffs/

         {include contents of resources/standard-agent-directives.md}

         Send the review report to the orchestrator when done."
)
```

*If gate is inactive, skip this step.*

### Step 3: Disposition mapping

After spec-check and QA plan agents report, the orchestrator maps each QA plan item to a **disposition** that determines who executes it and whether it gates SHIP.

| QA Channel | Default Disposition | Executor | Gates SHIP? |
|-----------|-------------------|----------|-------------|
| `[TEST]` | `AGENT` | Verification agent runs test suite | Yes |
| `[CONSOLE]` | `AGENT` | Verification agent runs console commands | Yes |
| `[EMAIL]` | `AGENT` | Verification agent checks mailer previews/logs | Yes |
| `[EVENTS]` | `AGENT` | Verification agent queries analytics | Yes |
| `[INTEGRATION]` | `AGENT` | Verification agent inspects job queues/APIs | Yes |
| `[BROWSER]`/`[RANGER]` | `RANGER` | Ranger feature review | Yes |
| `[HUMAN]` | `COPILOT` | QA copilot guides operator interactively | Yes |

**Override to `DEFER:ENV`:** The orchestrator may override any item's disposition to `DEFER:ENV` when the required environment is genuinely unavailable (e.g., production-only, third-party sandbox, credentials not configured). Each deferral requires an explicit reason. Deferred items still gate SHIP — they must be documented as critical unfinished work in the PR.

**Do NOT defer items that are executable in the current environment.** If an agent can run a console command or test suite right now, the disposition is `AGENT`, not `DEFER:ENV`.

Write the disposition map to `specs/{project}/verify-dispositions.md` for traceability.

### Step 4: AGENT execution

Spawn a verification agent that receives all `AGENT`-disposition items and executes them:

```
Task(
  name="qa-executor",
  team_name="...",
  prompt="Execute these QA verification items. For each item, run the
         specified verification method and report the result.

         Items to execute:
         {list of AGENT-disposition items with IDs, descriptions, and
          verification methods from QA plan}

         Execution rules:
         - [TEST] items: Run the specified test files/suites (rspec, vitest)
         - [CONSOLE] items: Run the specified console/DB commands
         - [EMAIL] items: Check mailer previews or delivery logs
         - [EVENTS] items: Query analytics tables or event logs
         - [INTEGRATION] items: Inspect job queues or external API responses

         For EACH item report:
         - Item ID and description
         - Command/method executed
         - Output (captured)
         - Result: PASS, FAIL, or BLOCKED (with reason)

         CRITICAL: Do NOT skip items. Do NOT substitute verification methods.
         If an item cannot be executed, report BLOCKED with the specific
         reason — do not improvise an alternative.

         {include contents of resources/standard-agent-directives.md}

         Send the complete results to the orchestrator when done."
)
```

Process results:
- **All PASS** → Proceed
- **Any FAIL** → Route through Verification Failure Protocol (see `task-lead-implementer-mode.md`). Task lead writes fix handoff → implementer fixes → re-run failed items.
- **Any BLOCKED** → Escalate to operator for disposition decision. Operator chooses: fix the blocker, or defer to `DEFER:ENV` with stated reason.

### Step 5: RANGER execution (conditional)

**Run ONLY when the QA plan contains `[BROWSER]`/`[RANGER]` items.** Skip when no browser QA items exist.

Spawn a qa-ranger agent:
```
Task(
  name="qa-ranger",
  team_name="...",
  prompt="FIRST — load /ranger-help, then /ranger.

         You are the QA agent. Create and run Ranger feature reviews
         for these browser QA scenarios:
         {list of RANGER-disposition items from QA plan}

         Use --profile main (or --profile wt-{id} for worktrees).

         Read resources/qa-matrix-to-ranger-flows.md from /ranger-help
         before creating feature reviews.

         {include contents of resources/standard-agent-directives.md}

         Report results to the orchestrator: feature review IDs,
         pass/fail, notable findings."
)
```

Process results:
- **All PASS** → Proceed
- **Any FAIL** → Route through failure protocol (task lead writes fix handoff)
- **Ranger unavailable** → STOP and escalate to operator (do NOT substitute console verification)

**Post QA results as PR comment.** After browser QA completes (pass or fail), post a summary comment on the PR with Ranger feature review IDs, dashboard links, and pass/fail results.

### Step 6: COPILOT execution (conditional)

**Run ONLY when the QA plan contains `[HUMAN]` items.** Skip when no human verification items exist.

Open a tmux sidecar **window** (not pane) named `qa-copilot` using `/tmux-sidecar`. The new Claude session receives the QA copilot prompt template from `resources/prompts/qa-copilot.md` with these parameters:
- The `COPILOT`-disposition items from the QA plan
- The path to write results: `specs/{project}/verify-results.md`
- The feature name and spec path for context

**The copilot session talks directly to the operator** — not through the orchestrator or team-lead. This is an interactive session where the operator performs physical actions (opens Slack, clicks UI elements, observes behavior) and reports results to the copilot.

The orchestrator waits for completion by monitoring for `specs/{project}/verify-results.md` to contain COPILOT results, or for the operator to signal back in the orchestrator window.

Process results:
- **All PASS** → Proceed
- **Any FAIL** → Route through failure protocol
- **Any DEFERRED** → Operator must have stated a reason. Deferred items become critical unfinished work in the PR.

### Step 7: Aggregate verdicts and persist evidence

Wait for all execution steps (4-6) to complete. Write consolidated results to `specs/{project}/verify-results.md`:

```markdown
# Verification Results — {feature name}
**Date:** {date}
**Spec:** {spec-path}

## Spec Compliance
- **Result:** PASS / FAIL
- **Details:** {summary from spec-check — requirement count, any deviations}

## QA Execution Results

### AGENT Items
| ID | Description | Method | Output | Result |
|----|-------------|--------|--------|--------|
| {id} | {desc} | {command} | {output summary} | PASS/FAIL/BLOCKED |

### RANGER Items
| ID | Description | Feature Review ID | Result |
|----|-------------|-------------------|--------|
| {id} | {desc} | {ranger ID} | PASS/FAIL |

### COPILOT Items
| ID | Description | Operator Result | Notes |
|----|-------------|----------------|-------|
| {id} | {desc} | PASS/FAIL/DEFERRED | {operator notes or deferral reason} |

## Deferred Items (Critical Unfinished Work)
| ID | Description | Reason for Deferral | Follow-up Required |
|----|-------------|--------------------|--------------------|
| {id} | {desc} | {reason} | {what needs to happen} |

## Gate Summary
- AGENT: {pass count}/{total} PASS
- RANGER: {pass count}/{total} PASS (or N/A)
- COPILOT: {pass count}/{total} PASS, {defer count} DEFERRED (or N/A)
- **VERIFY gate:** PASS / BLOCKED
```

### Step 8: PR description assembly

The verifier writes the PR description — they have the best context on what was tested, what risks exist, and where reviewers should focus.

**Pass the PR description template** to the spec-checker or a dedicated agent. The template lives at `.claude/skills/pr-create/resources/pr-description-template.md`. The agent reads the template and fills it using verification findings:

- **Summary**: What changed and why (from spec + handoffs)
- **Test plan**: Checklist with pass/fail status for each test layer (from execution results, not just classification)
- **Blast radius**: 5 yes/no questions about scope of impact (from diff analysis). Each YES on shared infrastructure or external changes gets flagged as REVIEWER FOCUS.
- **Ranger feature reviews**: Table with IDs and results (conditional — only if Ranger QA ran)
- **Critical unfinished work**: Table of all DEFERRED items with deferral reasons and required follow-up. **This section is mandatory if any items were deferred.** Reviewers must see what was NOT verified before approving.
- **Other risks**: Test gaps, rollback safety, feature flags, reviewer focus areas

Save the filled template to `specs/{project}/pr-description.md`. This file is consumed by `/pr-create` in the SHIP phase.

### VERIFY → SHIP Gate

**All of the following must be true to proceed to SHIP:**

1. **Spec compliance:** PASS (or MINOR with operator acknowledgment)
2. **All AGENT-disposition items:** PASS
3. **All RANGER-disposition items:** PASS (or N/A if none)
4. **All COPILOT-disposition items:** PASS or explicitly DEFERRED by operator with stated reason
5. **No FAIL results** from any execution step
6. **Deferred items** (if any) documented in PR description under "Critical Unfinished Work"
7. **`verify-results.md`** exists with complete results for all items

**Gate [requires: phase-transition-gates]:** Notify operator with VERIFY summary (including any deferred items) and wait for approval before proceeding. *If gate is inactive, proceed only if all items PASS — any DEFERRED items force a gate stop regardless of gate setting, because the operator must acknowledge unfinished work.*

**Phase result:** Update `<task-dir>/task-plan.md` — append Produced, Confidence, and Gate outcome to this phase's section.

---

## Phase 5: SHIP — PR Creation and CI

**Goal:** PR created, pushed, CI green, ready for operator code review.
**Mode:** Inline — orchestrator delegates CI monitoring to a teammate. No complex agent protocol needed.

**This phase is autonomous.** Flow through all steps without stopping for operator confirmation unless a real decision is needed (e.g., CI failure requiring operator input). Do not ask "ready to proceed?" between steps.

### Step 1: Commit

Commit all changes. Do not stop for operator review of the diff — the operator reviews via the PR.

### Step 2: Push and Create PR

Invoke `/pr-create` with the pre-filled PR description from VERIFY:

```
/pr-create specs/{project}/pr-description.md
```

`/pr-create` handles: push, PR creation, title formatting (ticket ID from branch), reviewer assignment, and project conventions (from orchestrate domain-skill). It reads the pre-filled description and uses it as the PR body.

If `/pr-create` is not available, fall back to manual PR creation:
```bash
git push -u origin <branch-name>
gh pr create --title "<title>" --body "$(cat specs/{project}/pr-description.md)"
```

### Step 3: Monitor CI (DELEGATED TO TEAMMATE)

**Immediately after creating PR**, spawn a `general-purpose` **teammate** named `ci-monitor` to watch CI and fix failures. Do NOT run `/ci-monitor` inline — it consumes orchestrator context with sleep cycles and debug loops.

**IMPORTANT: Use a regular teammate, NOT a background agent.** Background agents (`run_in_background: true`) are unreliable for long-running monitoring — they die silently without notification. Regular teammates have proper lifecycle management and send idle/completion messages.

```
Task(
  subagent_type="general-purpose",
  name="ci-monitor",
  team_name="{team-name}",
  description="Monitor CI for PR #{number}",
  prompt="Run /ci-monitor for PR #{number} on branch {branch-name}.
         Fix any failures autonomously. When CI is green (or you're stuck),
         send a final status message to the team lead.

         ## BASH RULES
         - NEVER chain commands with && or ; or |
         - Use SEPARATE Bash tool calls for each command

         {include contents of resources/standard-agent-directives.md}"
)
```

**Do NOT set `run_in_background: true`** — spawn as a normal teammate so it participates in the team lifecycle.

**Wait for CI to be green before completing.** Unlike the old pipeline (which proceeded to REFLECT while CI ran), the feature-implementation sequence blocks here because the completion goal is "PR ready for operator code review" — which requires green CI.

If ci-monitor reports persistent failures after 3 fix cycles, escalate to operator via NOTIFY_BLOCKING with diagnosis.

### Step 4: Hand back remaining work to the ticket

After CI is green, compile all remaining work needed to *close the ticket* (not just merge the PR). The PR is a milestone — the ticket stays open until the feature is delivered.

**Sources of remaining work:**
1. **Operator-owned actions from task shape** (field 3, agent/operator boundary) — production configuration, third-party service setup, team/stakeholder communication, rollout steps. These were identified during triage and tracked through the plan.
2. **DEFERRED items from VERIFY** — items with `DEFER:ENV` disposition from `verify-results.md`. These represent verified-but-not-yet-run QA items with stated reasons.
3. **Post-deploy verification** — if the change needs verification in a deployed environment.
4. **Domain-skill post-ship steps** — if the domain-skill defines post-ship steps requiring human action.

**Write remaining items to the ticket.** These must be durable — they survive session end. If a Linear ticket exists, update it with a checklist of remaining items. If not, write them to `<task-dir>/remaining-work.md` as the durable record.

**Rules:**
- Be specific: "Configure production Slack bot: add users:read and users:read.email OAuth scopes in api.slack.com dashboard" not "Update Slack bot"
- Include context an operator needs to act without re-reading the PR: what to do, where to do it, why it's needed
- Reference source (triage mise en place, verify-results.md item ID) for traceability
- If no remaining items exist, skip this step — but verify against the task shape first. Missing items here that were identified in triage is a bug.

### Step 5: Notify operator

```
NOTIFY_INFO: "PR ready for review: {PR title}
{PR URL}
CI: green
VERIFY: {summary verdict}
Remaining work to close ticket: {count and summary, or 'none — ticket can be closed on merge'}"
```

The notification must surface remaining operator-owned work prominently. The operator should know at a glance whether merging the PR closes the ticket or whether there's more to do.

**Phase result:** Update `<task-dir>/task-plan.md` — append Produced, Confidence, and Gate outcome to this phase's section.

**The sequence stops here.** Merge is operator-initiated after their code review. The operator may:
- Review and merge manually
- Ask the orchestrator to merge (operator-delegated, per-PR authorization)
- Request changes (triggers a feedback loop — see below)

---

## PR Review Feedback — Re-entry Loop

**Trigger:** PR receives reviewer feedback that requires code changes.

This is not a new sequence run — it loops back into earlier phases. The PR and branch already exist.

### When this applies
- Reviewer requests changes
- Reviewer approves with actionable suggestions
- Reviewer comments with technical feedback requiring code changes

### When this does NOT apply
- Reviewer asks a question (reply on the PR)
- Feedback is out of scope (create a follow-up ticket)
- Cosmetic-only feedback (fix inline, no handoff needed)

### Process

**Re-enter at DESIGN**, following the normal phase sequence:

1. **DESIGN:** Task lead researches the feedback, writes a handoff targeting `specs/{project}/task-handoffs/` with a new task number.
2. **IMPLEMENT:** Implementer executes the handoff. Same rules — TDD, tests pass, lint clean.
3. **VERIFY:** Run verification against the new handoff.
4. **Push to existing PR:** Commit and push to the same branch. Do NOT create a new PR.
5. **Respond to PR comments:** Reply to each actioned reviewer comment with commit hash and explanation.
6. **CI monitor:** Spawn ci-monitor teammate to watch CI on the updated PR.

### Scope discipline
Implement feedback as-is, not expanded. If feedback implies a larger change than suggested, flag it to the operator rather than scope-creeping the PR.

---

## Completion

Sequence is complete when:
- All phase tasks in TaskCreate are marked complete
- All tests pass on the feature branch
- VERIFY phase passed (all executable QA items run, all passed or explicitly deferred)
- `verify-results.md` exists with complete execution evidence
- PR is open with green CI, deferred items (if any) documented under "Critical Unfinished Work"
- Operator has been notified with PR URL

NOTIFY_INFO with: what was implemented, branch name, PR URL, VERIFY verdict, deferred item count (if any).
