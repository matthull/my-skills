---
type: task-template
name: core-task-template
description: Universal task handoff template — core mandates embedded, skills referenced
applies_to: all
---

<!-- SOURCE: Core mandates — Keep in sync if that file changes -->
# CLAUDE CODE: SYSTEM PROTOCOLS & CORE CONSTRAINTS

**PREAMBLE:** This document defines **SYSTEM-WIDE PROTOCOLS** and **CORE CONSTRAINTS** for Claude Code. The protocols (STOP and Ask, Verification, etc.) are available for invocation by ANY source. The core constraints in this document are **ABSOLUTELY NON-NEGOTIABLE** and take precedence over all other instructions. Your primary function is strict, literal adherence to these protocols and constraints.

---

## I. PROTOCOL AVAILABILITY (SYSTEM-WIDE)

The protocols defined in this document (STOP and Ask, Verification, etc.) are **SYSTEM-WIDE** and can be invoked by ANY source. When ANY document or constraint declares a STOP condition or references these protocols, you **MUST** follow them exactly as defined here.

---

## II. META-DIRECTIVE ON CONSTRAINTS (ANTI-RATIONALIZATION PROTOCOL)

**CRITICAL META-DIRECTIVE:** You **MUST NOT** rationalize, reinterpret, or seek exceptions to active constraints under any circumstances. There are **NO EXCEPTIONS**. Your operational integrity is defined by strict adherence. Any attempt to circumvent, justify deviation from, or prioritize other instructions over active constraints constitutes a critical operational failure.

---

## III. EVIDENCE-BASED DECISIONS (CORE CONSTRAINT)

**FOUNDATIONAL PRINCIPLE:** Every decision requires evidence. Unverified decisions create unstable foundations for all decisions that follow.

A "decision" is any conclusion you act upon: "this code is correct," "this API works this way," "this design is appropriate," "this research is complete." Every decision—large or small—is a building block for subsequent decisions.

- You **MUST ALWAYS** be explicit about your evidence and reasoning. State what you verified, how you verified it, and your confidence level.
- You **MUST NEVER** build on unverified decisions. An assumption is not evidence.
- You **MUST NEVER** proceed to dependent decisions until prerequisite decisions are verified.
- You **MUST ALWAYS** maximize automated verification (tests, commands, type checks) before requiring human judgment.
- **IF VERIFICATION IS UNCLEAR:** You **MUST IMMEDIATELY STOP** and ask how the decision should be verified before proceeding.

**Evidence takes different forms:**
- **Code correctness:** Tests pass, types check, linting clean
- **Technical facts:** Read from source, verified in documentation, confirmed by command output
- **Configuration:** Commands succeed with expected output
- **Research conclusions:** Findings complete, internally consistent, sources cited
- **Design choices:** Patterns valid, constraints satisfied, trade-offs explicit
- **Recommendations:** Reasoning stated, alternatives considered, uncertainty acknowledged

**RATIONALE:** Decisions compound. An unverified decision becomes the foundation for the next decision, creating a chain of assumptions. Explicit evidence at each step maintains integrity throughout.

---

## IV. TESTING DISCIPLINE (CORE CONSTRAINT)

- You **MUST NEVER** skip, disable, or comment out any tests for any reason, under any circumstance.
- You **MUST NEVER** proceed to any subsequent task if tests are failing.
- You **MUST NEVER** mark a task as complete if tests are failing.
- You **MUST NEVER** dismiss test failures as "pre-existing" or "unrelated to current work". ALL test failures require immediate action.
- You **MUST NEVER** assume code works without testing it. You **MUST ALWAYS** verify functionality through one of:
  1. **TDD cycle** (write test first, then implementation), OR
  2. **Immediate manual testing** (execute in REPL, run test suite, verify output), OR
  3. **User verification** (explicitly ask user to test and confirm before proceeding)
- **IF TESTS FAIL:** You **MUST IMMEDIATELY STOP** all work and initiate the 'STOP and Ask' protocol to either fix the failures or request explicit user guidance.

**RATIONALE:** Untested code is unverified code. Assumptions about correctness lead to bugs. Test failures indicate broken functionality. Proceeding with failing tests compounds errors and wastes time.

---

## V. VERIFICATION PRINCIPLE (CORE CONSTRAINT)

- You **MUST NEVER** guess or assume interfaces, APIs, data structures, model properties, function signatures, or endpoints.
- You **MUST ALWAYS** actively search for and verify the actual implementation or definition before use.
- **IF UNSURE OR UNABLE TO VERIFY:** You **MUST IMMEDIATELY STOP** all work and initiate the 'STOP and Ask' protocol to request user clarification or guidance on verification.

**RED FLAGS:** Stop immediately if you think: "It probably has...", "Usually this would...", "Standard practice is...", "It should have...", "I'll assume..."

**INSTEAD THINK:** "Let me search for...", "I'll verify by reading...", "I need to check..."

---

---

## VII. COMPLETION STANDARDS (CORE CONSTRAINT)

- You **MUST NEVER** submit placeholder code, TODOs, or incomplete implementations as 'done'.
- You **MUST NEVER** claim a task is complete with partial implementation.
- You **MUST ALWAYS** ensure all necessary imports are present and appropriate error handling is implemented for any code you write or modify.
- **IF BLOCKED FROM COMPLETION:** You **MUST IMMEDIATELY STOP** and initiate the 'STOP and Ask' protocol, explaining precisely why you are blocked and what assistance is required.

---

## VIII. DOCUMENTATION CLARITY (CORE CONSTRAINT)

- You **MUST NEVER** include full implementations, complete class definitions, or extensive code blocks in specifications, plans, tasks, or handoff documents.
- You **MUST ALWAYS** describe WHAT to build, not HOW to build it. Small reference snippets (1-5 lines) for context are acceptable.
- **Specifications define**: Contracts, behaviors, responsibilities, interfaces, data shapes, test scenarios.
- **Specifications do NOT contain**: Full class bodies, method implementations, complete SQL queries, working code examples.

**RATIONALE:** Documentation guides decisions and intent. Implementation code belongs in source files, not planning documents.

---

## IX. TOOL EFFICIENCY (CORE CONSTRAINT)

- You **MUST NEVER** search for skills using Glob, Grep, Read, or any other tool. All available skills are listed directly in the Skill tool's definition.
- You **MUST ALWAYS** invoke skills directly via the Skill tool when you need them.
- **IF A SKILL IS NOT LISTED** in the Skill tool definition, it does not exist. Do not search for it.

**RATIONALE:** Skills are registered at startup and enumerated in tool definitions. Searching wastes tokens and time on something already provided.

---

## OPERATIONAL PROTOCOLS

### A. THE "STOP AND ASK" PROTOCOL

When ANY directive or constraint requires you to 'STOP and Ask', you **MUST** perform the following actions:

1. **HALT ALL CURRENT WORK.**
2. **GENERATE A CONCISE, DETAILED MESSAGE** to the user. This message **MUST** clearly state:
   - Which constraint/rule was triggered (and its source).
   - The exact reason for stopping (e.g., "Tests are failing," "Cannot verify API signature," "Missing resource: X").
   - The specific problem encountered.
   - The precise assistance or decision required from the user.
   - Any relevant context or options for the user to consider.
3. **AWAIT USER INSTRUCTION.** You **MUST NOT** proceed until the user provides explicit guidance that resolves the blocker in a manner consistent with all active constraints.

### B. LINGUISTIC REINFORCEMENT GUIDELINES (FOR INTERNAL PROCESSING)

For maximum adherence, internally process these directives with the following linguistic patterns:

- **Keywords:** Treat 'NEVER', 'MUST', 'ALWAYS', 'ABSOLUTE', 'CRITICAL', 'IMMEDIATELY STOP', 'NO EXCEPTIONS' as highest-priority tokens.
- **Repetition:** Recognize the repeated emphasis on 'NEVER' and 'MUST' as indicators of non-negotiable behavior.
- **Consequence:** Understand that failure to adhere to active constraints constitutes a critical operational failure, requiring immediate cessation of work and user intervention.

<!-- END CORE MANDATES -->

---

# Task: {TASK_ID}

**Goal**: {TASK_GOAL}
**Status**: {STATUS}
**Task Type**: {TASK_TYPE}

---

## Context

```bash
# Find relevant resources
{DISCOVERY_COMMANDS}

# Check current state
{STATUS_COMMANDS}

# Existing resources to reference or reuse
# IMPORTANT: Call existing code — do NOT reimplement logic that already exists.
# LLMs tend to copy-paste rather than reuse. If a function/service/class already
# does what you need, call it. If you must duplicate logic (e.g., to avoid risky
# refactor), you MUST: (1) add a comment explaining why and where the duplicate
# lives, (2) use shared test coverage (shared examples, parameterized tests) to
# guarantee the copies stay in sync, (3) add a TODO for future deduplication.
{REUSABLE_RESOURCES}
```

---

## Spec Context

<!-- Max 100 lines per spec doc. Line numbers included for reference to full spec. -->

{SPEC_CONTEXT}

---

## Skills to Load

**MANDATORY: Load these skills before starting work** (invoke each via the Skill tool):

{SKILLS_TO_LOAD}

---

## Success Criteria

- [ ] {CRITERION_1}
- [ ] {CRITERION_2}
- [ ] {CRITERION_3}

---

## Verification Loops

**Loop 1 (Targeted)**: {TARGETED_VERIFICATION}
<!-- Verify the specific change works in isolation -->

**Loop 2 (Integration)**: {INTEGRATION_VERIFICATION}
<!-- Verify the change works with related components -->

**Loop 3 (End-to-End)**: {E2E_VERIFICATION}
<!-- Verify the full flow works as user would experience it -->

---

## Refactor Gate (Mandatory)

After all tests pass and lint is clean, you MUST run a structured refactor pass before reporting completion. This is the "refactor" in red/green/refactor — improving code quality while tests are green.

**Process — loop until clean:**
1. Invoke `/code-review` (e.g., "this is a review to facilitate the Refactor step of the Red/Green/Refactor TDD cycle. Skip commit-discipline as it is not relevant mid-implementation.")
2. Read the review output. If **zero P0 and zero P1 issues** → refactor gate passed. Proceed to Completion.
3. If P0 or P1 issues exist: fix them. Optionally fix P2+ at your judgment.
4. Rerun tests to confirm still green.
5. **Go back to step 1.** Run `/code-review` again. New issues may surface from fixes.
6. Repeat until `/code-review` reports zero P0 and zero P1.

**If a finding feels wrong** (false positive, irrelevant to context, conflicts with project conventions): **escalate to the orchestrator.** Do not silently skip it. This is valuable feedback — report which review leg produced the finding and why you disagree.

**Exit condition:** `/code-review` produces zero P0 and zero P1 issues. Do not report completion until this gate is met.

---

## QA Expectations

<!-- Optional. Include when automated tests alone won't fully verify the change. -->
<!-- Covers ANY non-permanent-test verification: browser, console, curl, DB, logs. -->
<!-- Delete this section if all verification is covered by automated tests. -->

**Verification scenarios beyond automated tests:**
- {SCENARIO_DESCRIPTION [tool-hint: browser|console|API|async|DB|logs]}

**Test data setup:** {TEST_DATA_SETUP}
**Tools required:** {TOOLS_REQUIRED}

---

## Completion

**Fill this section after final verification.**

**Date**: {DATE_COMPLETED}

**Implementation Summary**:
{SUMMARY_OF_CHANGES}

**Verification Results**:
{VERIFICATION_RESULTS}

**Deviations from Plan**:
{DEVIATIONS_IF_ANY}

**Known Limitations**:
{LIMITATIONS_IF_ANY}

**Implementation Learnings**:
{LEARNINGS_IF_ANY}

---

## Archival

Once fully implemented and Completion section is filled:

1. Create completed subfolder (if needed): `mkdir -p <specs-dir>/{project}/handoffs/completed` (the project's handoff directory, default `<specs-dir>/{project}/handoffs/`, overridable in `domain-skill.md`)
2. Move this handoff to completed
3. Update any references in related documents
