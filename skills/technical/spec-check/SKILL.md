---
name: spec-check
description: Spec compliance checker. Given a spec and a branch, compares every requirement against the implementation diff with evidence. Reports per-requirement PASS/FAIL with file:line references and an overall verdict. Use standalone after any spec-driven implementation, or as the verification phase of an orchestrated pipeline.
---

# `/spec-check` — Spec Compliance Checker

**The question this answers:** "Given a spec and a branch, does the implementation satisfy the spec?"

One question, cleanly scoped. No code quality, no QA classification, no fix routing.

## Usage

```
/spec-check specs/feature/spec.md              # spec path (required)
/spec-check specs/feature/spec.md --branch foo  # explicit branch
```

| Parameter | Required | Default |
|-----------|----------|---------|
| Spec path | **Yes** | — |
| `--branch` | No | Current branch vs default branch |

The spec is the **only** accepted source of intent. Not handoffs, not tickets, not freeform descriptions. If it's not in the spec, it's not a requirement.

## Process

### Step 1: Parse Input

Parse `$ARGUMENTS` for:
1. **Spec path** (required) — first non-flag argument
2. **Branch** (optional) — value after `--branch` flag

If no spec path provided, STOP and report: "Usage: /spec-check <spec-path> [--branch <branch>]"

Determine the base branch:
- If `--branch` is provided, use it as the feature branch
- Otherwise, use the current branch (`git branch --show-current`)
- Detect the default branch: `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'` (typically `master` or `main`)

### Step 2: Read the Spec

Read the spec file at the provided path. Extract **every**:
- Explicit requirement (functional behavior, data contracts, API shapes)
- Acceptance criterion
- Behavioral expectation
- Input/output contract
- Scope boundary ("not responsible for", "out of scope")
- Constraint or invariant

**Extraction rules:**
- Number each requirement sequentially (R1, R2, R3...)
- Preserve the spec's own language — do not paraphrase
- If the spec uses sections, note which section each requirement comes from
- Include negative requirements ("must NOT do X") — these are testable too
- Scope boundaries become requirements of the form "implementation does NOT include X"

### Step 3: Get the Diff

Run: `git diff {default-branch}...{feature-branch}`

Also gather:
- `git diff {default-branch}...{feature-branch} --stat` for file change summary
- Count of files changed, insertions, deletions

If the diff is very large (>2000 lines), use `--stat` first to identify relevant files, then read specific files with the Read tool rather than consuming the entire diff.

### Step 4: Compare Requirements Against Implementation

For **each** extracted requirement, determine:

**PASS** — The implementation satisfies the requirement. Evidence must include at least one of:
- `file:line` reference showing the implementation
- Test name that verifies the behavior
- Observable structural evidence (e.g., "route defined at config/routes.rb:47")

**FAIL [CRITICAL]** — The requirement is missing or fundamentally wrong:
- Required behavior not implemented
- Data contract violated
- API shape doesn't match spec
- Required constraint not enforced

**FAIL [MINOR]** — The requirement is met in spirit but deviates:
- Naming differs from spec (e.g., `status` vs `state`)
- Minor behavioral difference that doesn't break intent
- Implementation order differs from spec's implied order

**N/A** — The requirement is explicitly deferred or out-of-scope per the spec itself (not per the implementation). Only use this for requirements the spec marks as future work.

**Judgment principles:**
- The spec is the source of truth. If the implementation deviates, the implementation is wrong — not the spec.
- Evidence must be specific. "Looks like it works" is not evidence. Cite file:line or test names.
- When uncertain, mark FAIL with a note explaining the uncertainty. False positives are better than false negatives.
- Scope boundaries are real requirements. If the spec says "not responsible for X" and the implementation includes X, that's a FAIL (scope creep).

### Step 5: Report

Output the compliance report in this exact format:

```markdown
## Spec Compliance Report

**Spec:** {spec path}
**Branch:** {feature branch} vs {base branch} ({N} files changed, +{insertions}/-{deletions})

### Requirements

| # | Requirement | Status | Evidence |
|---|------------|--------|----------|
| R1 | {extracted from spec} | PASS | {file:line, test reference, or observation} |
| R2 | {extracted from spec} | FAIL [CRITICAL] | {what's missing or wrong} |
| R3 | {extracted from spec} | PASS | {evidence} |
| R4 | {extracted from spec} | FAIL [MINOR] | {deviation description} |

### Verdict: {PASSED / FAILED [CRITICAL] / FAILED [MINOR]}

### Summary
{1-3 sentences on overall compliance state}
```

**Verdict rules:**
- **PASSED** — every requirement is PASS or N/A
- **FAILED [CRITICAL]** — one or more FAIL [CRITICAL]
- **FAILED [MINOR]** — no critical failures, but one or more FAIL [MINOR]

## NOT Responsible For

These concerns are explicitly out of scope. Do not comment on them, do not include them in the report:

- **Code quality, duplication, style** — that's `/code-review`
- **Running tests, linter, or type checker** — that's the implementer's gate check
- **QA classification or gap detection** — that's `/qa-plan`
- **Fix routing or orchestration** — that's the orchestrator's mode resource
- **Process compliance** — whether handoffs were followed, verification loops were run

If you notice issues in these areas, ignore them. Stay in lane.

## Edge Cases

- **Spec has no clear requirements** — Report this: "Spec does not contain extractable requirements. Cannot perform compliance check."
- **Branch has no diff** — Report: "No changes found on {branch} vs {base}. Nothing to check."
- **Spec references other documents** — Only check requirements in the provided spec file. Do not chase cross-references unless they are inlined.
- **Ambiguous requirements** — Extract them, attempt to evaluate, mark with a note about the ambiguity. Do not skip ambiguous requirements.
