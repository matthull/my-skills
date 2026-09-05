---
name: rca
description: >
  Root cause analysis for technical investigations. This skill should be used when
  diagnosing production bugs, service degradation, unexpected behavior, or any issue
  requiring systematic evidence gathering. Triggers on "investigate", "root cause",
  "why is this failing", "diagnose", or when an issue requires gathering data from
  multiple sources before drawing conclusions. Emphasizes data-driven reasoning,
  context gathering, and not jumping to conclusions.
capabilities:
  optional:
    - observability      # Access logs, metrics, error tracking
    - session-logging    # Log investigation progress
---

# Root Cause Analysis

Systematic technical investigation methodology. The core principle: **build a case from evidence, don't chase a hypothesis.**

## Project and User Configuration

Load configuration in this order. **When multiple sources define the same binding,
the first one found wins** — stop checking lower sources for that binding:

1. Read `resources/personal-skill.md` if it exists — personal investigation preferences.
2. Read `resources/domain-skill.md` if it exists — project-specific investigation context.
3. Check the project's CLAUDE.md / CLAUDE.local.md for environment-level capability bindings (especially the **observability** capability and the **session-logging** capability).
4. For any capability still unbound, use the defaults specified in this skill (terminal output for logging, generic tool discovery for observability).

## Extension Points

### domain-skill.md
Provide project-specific investigation context:
- Log access commands (e.g., `docker compose logs -f web`, Heroku log drains)
- Infrastructure topology (services, databases, queues, third-party dependencies)
- Common failure modes and their diagnostic shortcuts
- Observability tool access (APM dashboards, error tracking URLs, metric queries)
- Known flaky areas to deprioritize in investigations

See `examples/domain-plugins/rails-heroku-rca.md` for a complete worked example (Rails + Heroku, shared-DB review apps, log filtering patterns, and an RCA output/documentation protocol) — copy and adapt it as a starting point for this project's `resources/domain-skill.md`.

### personal-skill.md
Provide personal investigation preferences:
- Session logging tool and format
- Preferred notification channel for investigation checkpoints
- Documentation destination for investigation notes

## Investigation Phases

### Phase 1: Orient

Establish the landscape before touching any data.

- Gather all existing context: tickets, PR history, prior investigations, customer reports, related incidents
- Identify the **claimed** symptoms vs what has actually been **observed and verified**
- Determine what changed recently: deploys, config changes, dependency updates, upstream services
- Map the system components involved: which services, workers, APIs, third-party dependencies
- Identify what observability is available: logs, metrics, error tracking, database access. Use the **observability** capability to enumerate and query these sources; if no binding is configured, fall back to generic tool discovery (ask what logging/monitoring tools the project uses, or search the codebase for logging configuration).
- **Preserve perishable evidence immediately.** Some evidence has a shelf life — logs rotate, ephemeral environments get destroyed, caches expire. Before diving into analysis, pull and save any evidence that might disappear. Examples: Heroku logs (shallow retention), review app logs (destroyed on merge), third-party API logs (time-limited). Save raw output to files for later reference.

Produce a brief written summary of the situation as understood so far, explicitly noting what is known vs assumed.

### Phase 2: Establish Baselines

Before concluding anything is "broken," establish what "normal" looks like.

- **Quantify the problem scope.** Raw error counts are misleading without context. Always compute rates: success vs failure, and compare against prior periods.
- **Control for volume effects.** A single account retrying 10 times inflates error counts. Break down by tenant, request, user, or whatever the relevant unit is.
- **Check multiple time windows.** Comparing one month to the next can be misleading. Look at 3+ periods to distinguish a spike from a trend from normal variance.
- **Don't assume a change is anomalous.** Ask: is this within historical variation? Is the sample size large enough to draw conclusions?

### Phase 3: Narrow the Failure Domain

Systematically eliminate possibilities by gathering evidence at each layer of the stack.

**Work from the outside in:**
1. What does the user see? (symptoms)
2. What does the application record? (job status, error messages, logs)
3. What did the application send? (serialized payloads, API requests)
4. What did the external service receive and return? (third-party logs, execution records)

**At each layer, ask:**
- Is the data flowing correctly into this layer?
- Is this layer transforming the data correctly?
- Is this layer's output what the next layer expects?

**Key technique: find minimal pairs.** Identify cases that are as similar as possible where one succeeded and one failed. Compare:
- Same account, different outcome
- Same data, different time
- Same time, different data
- Same everything — if identical inputs produce different outcomes, the non-determinism is downstream

### Phase 4: Test Specific Hypotheses

Only after Phases 1-3 have narrowed the domain, form specific hypotheses and test them.

- Each hypothesis must be **falsifiable** with available data
- State what evidence would **confirm** vs **refute** the hypothesis before looking
- Test one variable at a time when possible
- Record the result of each test regardless of outcome

**Escalation rule:** If three hypotheses in a row are falsified, stop generating hypothesis #4. Step back and question the mental model of the system itself. The repeated falsification likely means the framing is wrong, not just the details. Revisit Phase 1 assumptions, re-examine what "normal" means, or ask the user to help reframe the problem.

### Phase 5: Systemic Analysis (Cause Under the Cause)

**Prerequisite:** Only perform this phase after the proximate cause is identified and supported by evidence from Phase 4. This phase asks: **"Why wasn't this caught before it reached users?"**

The proximate cause explains what broke. This phase identifies the systemic failures that allowed it to ship. These findings are often the most actionable output of an RCA — they drive prevention, not just fixes.

**Work through these layers in order, stopping when you find the most relevant gap:**

#### Layer 1: Automated Test Coverage

Could this bug have been caught by automated tests within the project's existing test infrastructure?

- **Unit tests:** Was the failing code path exercised by existing unit tests? If not, could it reasonably have been? Identify the specific test case(s) that would have caught this — e.g., "a test for `processOrder()` with a null shipping address would have caught the NPE."
- **Integration tests:** Did the failure involve an interaction between components? Could an integration test covering that boundary have caught it?
- **Component/visual tests (Storybook, etc.):** For UI issues — was the affected component covered? Could a visual regression or interaction test have caught the state?

If automated tests could have caught it, note the **specific missing test case(s)** — these become part of the fix, not just the bug ticket.

#### Layer 2: Manual QA

If automated testing couldn't reasonably have caught this (e.g., complex multi-step user flows, visual/UX judgment, environment-specific issues):

- Could a manual QA pass on the originating PR have caught it?
- Was there a QA step in the process that was skipped or insufficient?
- Is this a case where a manual test script or checklist would help?

#### Layer 3: Process and Tooling

Look beyond testing at the broader development process:

- **Code review:** Was the relevant change reviewed? Did the review miss the issue, or was it not flagged as needing careful review?
- **Agentic tooling:** Did a skill, pipeline step, or handoff template contribute to the gap? E.g., did the implementation step produce code that lacked edge case handling because the handoff didn't specify it? Did the pipeline skip a verification step?
- **Specification gaps:** Was the failing behavior underspecified? Would a more precise spec have prevented the implementation error?
- **Deployment/rollout:** Could canary deploys, feature flags, or staged rollout have limited blast radius?

**Output of this phase:** A concise "prevention analysis" section listing:
1. The most relevant gap layer (automated test / manual QA / process)
2. Specific preventive measures (test cases to add, process changes to make)
3. Whether this represents a pattern (has this class of gap produced bugs before?)

### Phase 6: Document and Assess

Continuously document findings, using the **session-logging** capability to record investigation progress as it happens rather than reconstructing it afterward. If no session-logging binding is configured, keep the investigation document itself as the running record (see Documentation Template below). At any checkpoint, the investigation document should clearly distinguish:

1. **Verified facts** — things confirmed by direct observation of data
2. **Supported inferences** — conclusions that follow from multiple verified facts, but could have alternative explanations
3. **Open questions** — things we still don't know
4. **Ruled out** — hypotheses tested and falsified

**Evidence types have different weights.** Be explicit about which type supports each finding:

- **Code analysis** proves a mechanism *exists* (e.g., "this line serializes the entire AR object"). It does not prove the mechanism *fired* in the incident.
- **Runtime evidence** (logs, metrics, error traces) proves what *actually happened*. This is the strongest evidence for confirming a failure mode.
- **Firsthand engineering reports** (PR descriptions written while debugging, incident notes, commit messages explaining a fix) are strong evidence — the author observed the behavior directly. Weight these higher than casual Slack messages or secondhand accounts.
- **Git history** proves what changed and when. Strong for establishing timelines and identifying suspects, but does not prove causation alone.
- **Secondhand reports** (Slack messages, ticket descriptions from non-investigators) establish what was *claimed* but require corroboration.

**Self-check before presenting findings:** For each major conclusion, ask: "What type of evidence supports this? Did I confirm the mechanism fired, or only that it could fire?" If the answer is only code analysis, explicitly flag the gap and propose how to close it (check logs, reproduce locally, etc.) rather than presenting the finding as fully confirmed.

## Anti-Patterns

These are the most common failure modes in technical investigations:

### Premature conclusion
Drawing broad conclusions from a single data point. One example of X does not prove X is the only thing happening. Phrases like "this confirms that..." after examining one case are almost always premature.

### Narrative bias
Constructing a plausible story and then seeking confirming evidence. Instead, seek **disconfirming** evidence for the current leading explanation.

### Anchoring on the first anomaly
The first unusual thing discovered gets treated as the root cause. Often it's a symptom, a coincidence, or one of several contributing factors.

### Skipping baselines
Declaring a 72% failure rate is "catastrophic" without knowing the historical rate. Maybe it was always 30%. Maybe the denominator changed.

### Conflating correlation with causation
"Failures started after deploy X" does not mean deploy X caused the failures. Check whether the deploy changed the relevant code path. Check whether something else changed at the same time.

### Tunnel vision on one layer
Spending hours debugging application code when the issue is in the third-party service, or vice versa. The outside-in approach prevents this.

### Code-analysis confidence bias
Finding a plausible mechanism in code and presenting it as the confirmed root cause without verifying it fired at runtime. Code analysis proves a bug *can* happen; logs/metrics prove it *did* happen. When the code path is unambiguous it's tempting to skip runtime verification — but "could" and "did" are different evidence levels. Always check logs before declaring a root cause confirmed, and if logs aren't available, explicitly state that the finding is mechanism-confirmed but not runtime-confirmed.

## Documentation Template

Create an investigation document in the project's standard documentation location (see domain plugin for project conventions, or default to the working directory) with this structure:

```markdown
# [TICKET]: [Brief Description] Investigation

**Date:** YYYY-MM-DD
**Status:** In Progress / Blocked / Resolved
**Assignee:** [name]

## Problem Statement
[What was reported, by whom, when. Stick to observable facts.]

## Prior Work
[Any previous investigation, fixes, or PRs related to this issue.]

## What We've Verified
[Each finding as a subsection. Include the evidence, the query/command used, and what it proves.]

## Evidence Gaps
[What evidence would strengthen the findings but is unavailable? Why is it unavailable?
For each major conclusion, note the evidence type: code analysis, runtime logs, firsthand report, git history, secondhand report.]

## What We Don't Know
[Numbered list of open questions.]

## Hypotheses Tested
[What was tested, what the result was, what it means.]

## Prevention Analysis
[Which layer failed: automated test / manual QA / process?]
[Specific missing test cases or process gaps.]
[Is this a recurring pattern?]

## Next Steps
[Concrete actions with clear owners. Include preventive measures from above.]

## Console Queries / Commands Used
[Reproducible queries for anyone picking up this investigation.]
```

## When to Involve Human Judgment

The goal is to minimize the user's **total attentional cost over the life of the investigation**, not to minimize interruptions per se. The cost function is asymmetric: proceeding autonomously down a wrong path wastes far more attention (explaining, backtracking, re-investigating) than a brief check-in costs.

**Always involve the user for:**
- **Interpreting whether data is anomalous.** The agent sees numbers; the user knows the business context. A 72% failure rate means nothing without knowing whether 27% was the prior norm.
- **Choosing which thread to pull next.** When multiple avenues are open, the user may know which external system has better observability, which team can provide access, or which hypothesis maps to a known pattern.
- **Assessing severity and urgency.** The agent can quantify the problem; the user determines whether it's a drop-everything-now or a next-sprint issue.
- **Deciding when "good enough" is reached.** Some investigations need root cause. Others need "enough to unblock the customer." The user decides the stopping point.
- **Anything involving external communication.** Reaching out to third-party vendors, updating stakeholders, or escalating — always the user's call.

**Act autonomously for:**
- **Gathering data.** Running queries, reading code, checking git history, computing baselines — do this without asking. The user's attention is better spent interpreting results than approving queries.
- **Documenting findings.** Keep the investigation doc current. Don't ask whether to document.
- **Suggesting the next query.** Always have a recommendation for what to check next. Present it as a suggestion, not a question.

**The check-in cadence:** After each meaningful finding (not each query), briefly present what was found and what it suggests, then propose the next step. This gives the user natural decision points without requiring them to manage the investigation step-by-step.

## Working with the User

- **Present data before interpretation.** Show the numbers, then discuss what they might mean.
- **Flag uncertainty explicitly.** "This suggests X but we'd need to check Y to confirm" is better than "This means X."
- **Offer the next most informative query.** At each step, identify what single piece of evidence would most reduce uncertainty.
- **Keep a running document.** Update the investigation doc as findings come in so context isn't lost if the investigation spans sessions.
- **Respect the user's domain knowledge.** They may know that certain patterns are normal, certain systems are flaky, or certain data is unreliable. Incorporate this rather than overriding it with statistical arguments.
- **Recognize course-correction signals.** When the user says things like "let's not jump to conclusions," "could there be other explanations," "we don't know that yet," or "that's one data point" — these are not pushback, they are the investigation working correctly. Immediately recalibrate: soften the claim, identify what additional evidence is needed, and widen the aperture. The user often has contextual knowledge about what's normal vs abnormal that isn't visible in the data.
