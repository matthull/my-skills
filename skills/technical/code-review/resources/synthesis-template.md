# Synthesis Output Template

After all review leg agents return, synthesize findings into this format:

```markdown
# Code Review: {target description}

**Scope:** {N files changed, +insertions/-deletions}
**Preset:** {preset used} | **Legs:** {list of legs that ran}
**Domain skills loaded:** {list of skills loaded via discovery, or "none"}

## Executive Summary

{2-3 sentences: overall code quality assessment, biggest risks, merge recommendation}

**Recommendation:** APPROVE / REQUEST CHANGES / NEEDS DISCUSSION

## Critical Issues (P0 — Must fix before merge)

### {Issue title}
- **File:** `{path:line}`
- **Found by:** {leg names — note if multiple legs found same issue}
- **Impact:** {what breaks or is at risk}
- **Fix:** {specific, actionable recommendation with code example if helpful}

## Major Issues (P1 — Should fix before merge)

### {Issue title}
- **File:** `{path:line}`
- **Found by:** {leg name}
- **Impact:** {description}
- **Fix:** {recommendation}

## Minor Issues (P2 — Nice to fix)

- **{Issue title}** — `{path:line}` — {brief recommendation}

## Wiring Check

{Summary from wiring leg — dependencies added but not used, configs defined but not referenced. "Clean" if nothing found.}

## Test Quality

{Summary from test-quality leg — assertion strength, negative case coverage, edge cases. "Solid" if nothing found.}

## Strengths

{Things done well — important for balanced feedback. List 2-4 specific positives with file references.}

## Observations

{Non-blocking notes, patterns noticed, suggestions for future work. Not actionable now but worth noting.}
```

## Synthesis Rules

1. **Deduplication:** Same issue found by multiple legs → merge into single entry. Note all legs that found it in "Found by" field.

2. **Cross-reference confidence:** Issues found by 3+ legs → auto-promote to next severity level (P2 → P1, P1 → P0).

3. **Conflict resolution:** If legs disagree (e.g., elegance says "extract helper" but smells says "don't abstract yet"), flag as "Needs discussion" with both perspectives.

4. **Prioritization:** Within each severity level, order by: security > correctness > performance > everything else.

5. **Evidence required:** Every issue MUST have a file:line reference. If a leg reported an issue without a reference, either find it or downgrade to Observations.

6. **Balanced feedback:** MUST include Strengths section. A review that only criticizes is incomplete. Acknowledge good patterns, clean implementations, thorough tests.

7. **Actionable over advisory:** "This could be better" is not useful. "Extract lines 42-67 into a private method `calculate_score` to reduce nesting from 4 levels to 2" is useful.
