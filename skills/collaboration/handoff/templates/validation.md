---
type: validation-checklist
name: handoff-validation
description: Self-check before finalizing any task handoff
---

# Handoff Validation Checklist

## Before Writing Handoff to Disk

**Perform this self-check BEFORE using Write tool:**

### Code Block Line Count Check

1. **Scan entire handoff for code blocks** (between ``` markers)
2. **Count lines in each code block**
3. **FAIL if any code block > 5 lines** (unless it's bash commands for verification)

**Exceptions:**
- Bash commands for verification (grep, cat, find, test commands)
- Brief 1-5 line reference snippets with comments
- NOT full method implementations
- NOT complete class definitions
- NOT complete test implementations

### Content Pattern Check

**FAIL if handoff contains:**
- `class SomeClass` followed by full class body
- `def method_name` followed by complete implementation
- `it 'test description' do` followed by complete test
- Multiple methods shown in sequence with implementations
- Full file contents reproduced

**PASS if handoff contains:**
- Method names with brief purpose descriptions
- Test scenario descriptions without code
- References to existing code by line numbers
- Small 1-5 line snippets showing specific patterns
- API contracts (input/output specifications)

### Over-Specification Check

**FAIL if handoff contains:**
- An "Implementation Steps" section (any heading with those words)
- An "Inline Testing Discipline" or "Code Quality Checklist" section — skills handle these
- Success criteria with method names, class names, or internal structure (e.g., "Add `summary_text` method")
- Content that duplicates what a referenced skill provides (inline TDD workflow, Rails conventions, testing patterns)
- An empty "Skills to Load" section — this MUST be populated

**PASS if:**
- Success criteria are behavioral: "Email includes a summary of the change" not "Add method X"
- Skills to Load has at least one skill with rationale
- No section duplicates skill content

### The Delete Test

For each non-mandatory section, ask: **"If I deleted this, would the implementer produce a worse result?"**

- If YES → keep it (codebase orientation, verification commands, skill references)
- If NO → remove it (implementation details the implementer would figure out from code)

**Common Delete Test failures:**
- Scope patterns like `` `scope :name, -> { where(...) }` `` — implementer reads existing scopes
- Migration class names — implementer generates these
- "Use `change` method not `up/down`" — Rails skill covers this
- Test structure instructions — testing skill covers this

### Self-Correction Protocol

**IF validation fails:**

1. **STOP immediately before Write**
2. **Rewrite problematic sections** to:
   - Replace implementations with descriptions
   - Replace test code with scenario descriptions
   - Add line number references instead of code reproduction
3. **Re-run validation**
4. **Only Write when validation passes**

---

## Example: Violation vs Correction

### VIOLATION: Full Implementation
```ruby
# TOO MUCH DETAIL
class BaseImportJobFinder
  Result = Struct.new(:count, :record_ids, keyword_init: true)
  def initialize(account:, settings:)
    @account = account
    # ... 10 more lines
  end
end
```

### CORRECTION: Description with References
```
**Base class required**: `BaseImportJobFinder`

**Extract from existing finder:**
- Result struct (lines 17-18)
- Initialization pattern (lines 25-28)

**Methods required:**
- `call` — Main entry point, returns Result with count and record_ids
- `importable_types` — Abstract method, raises NotImplementedError

**Reference existing pattern:** `app/services/imports/csv/record_finder.rb`
```

---

## Quick Visual Check

**Red flags:**
- Code blocks longer than ~10 visible lines
- Multiple method definitions shown in sequence
- `class ClassName` followed by full class body
- Test blocks with full Arrange/Act/Assert
- More code than prose in any section

**Green flags:**
- Line number references like "Extract from lines 17-18"
- Prose descriptions: "Method should return X when Y"
- Test scenarios: "Verify behavior when condition occurs"
- Pointers: "Similar to existing_file.rb:45-50"
- Contracts: "Accepts account, returns Result struct"
