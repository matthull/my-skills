# PR Description Template

When filling this template:
- **Summary**: What changed and why — not implementation details
- **Test plan**: What was tested, pass/fail status. Use checkboxes.
- **Blast radius**: Answer each question honestly. Every YES on shared infrastructure or external changes → flag as **REVIEWER FOCUS**
- **Other risks**: What ISN'T covered, what could go wrong, where reviewers should focus

---

## Summary
- [2-4 bullets: what changed and why, not how]

## Test plan
**CHECK/UNCHECK** based on what work was already done.
- [x] [Unit tests — Just give a brief summary of what's covered and not covered by the unit tests, actually pass status is handled by CI]
- [x] [Integration/E2E tests — which workflows exercised, notable workflows NOT exercised and why]
- [x] [Component tests — component workbench stories or previews; if applicable, describe what is and isn't covered on the frontend side]
- [x] [QA verification (automated) — {scenarios executed: browser, console, API, etc.}]
- [ ] [QA verification (human) — {scenarios remaining, or "none required"}]

## Blast radius
- [ ] **Feature-gated code only** (behind a feature flag — name the flag)? YES/NO
- [ ] **Shared infrastructure modified** (base classes, clients, utilities)? YES/NO — LIST FILES
- [ ] **Database schema changes**? YES/NO (migration type)
- [ ] **External API changes** (endpoints added/modified)? YES/NO
- [ ] **Files touched that other teams/features depend on**? LIST FILES

## Automated QA evidence
<!-- Include ONLY if the project's browser-testing / QA-review tool was run against this PR. Delete this section otherwise. -->
- {tool}: {what was run} — {result/link}

## Other risks
- **Test gaps**: [What ISN'T covered by automated tests and why?]
- **Rollback**: [Can this be reverted cleanly?]
- **Feature flag**: [Behind a flag? Which flag?]
- **Reviewer focus**: [Where should reviewers look hardest?]

---

### Bug Fix Addendum

For bug fix PRs, add these sections immediately after Summary:

## Root cause
{Why the bug was happening — the underlying issue, not just the symptom}

## Fix
{The approach taken to fix it — keep concise}
