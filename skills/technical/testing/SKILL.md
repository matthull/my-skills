---
name: testing
description: Test scenarios, coverage analysis, test quality standards, and the mandatory test failure stop protocol. Load this skill for any task requiring test coverage.
---

# Testing Practice

## MANDATORY: Test Failure Stop Protocol

**This is an ABSOLUTE constraint with NO exceptions:**

When running tests:
- IF output contains ANY failure indicators: IMMEDIATELY output "STOP: Test failures detected"
- DO NOT analyze, explain, or categorize failures
- DO NOT dismiss as "pre-existing" or "unrelated"
- EXECUTE: STOP and Ask protocol
- AWAIT: User decision
- ONLY if ZERO failures: Proceed to next step

---

## Test Quality Standards

### Organization
- **ONE spec file per class** (no method-specific spec files)
- Use `describe` and `context` blocks to organize within the file
- Tests written BEFORE implementation (TDD red-green-refactor)

### Reliability
- No execution order dependencies (tests pass in random order)
- No `.only` or `.skip` in committed code
- All tests pass consistently (run 3x to verify if flaky suspected)
- No test pollution (tests pass in isolation and in suite)
- No flaky tests

### Quality
- Clear test descriptions (readable as documentation)
- No over-mocking (test real behavior when possible)
- Fast tests (< 30 seconds for full suite if possible)
- Tests verify behavior, not implementation details

---

## Test Scenario Planning

When planning test coverage, identify:
- **Happy path**: Primary success scenario
- **Edge cases**: Boundary conditions, empty inputs, large inputs
- **Error handling**: Invalid input, missing data, service failures

Reference existing test patterns in the codebase for structure.

---

## Anti-patterns

**You MUST NEVER:**
- Create multiple spec files for individual methods (ONE per class)
- Add boilerplate comments (`# Arrange`, `# Act`, `# Assert`, `# Setup`, `# Given/When/Then`)
- Skip tests to "make it work first"
- Use `sleep` to fix timing issues (find root cause)
- Stub methods on the object under test
- Test private methods directly (test through public interface)
- Leave failing tests commented out
- Write one spec per response attribute (use comprehensive specs)

**Prefer:**
- Test behavior, not implementation
- Comprehensive response specs (one spec per scenario, checking all attributes)
- Descriptive test names that explain "why" not "what"
- Test-first development (red-green-refactor)
- Integration tests for critical user flows
- Fast, focused unit tests for edge cases
- Comments ONLY for non-obvious business logic (rare)
