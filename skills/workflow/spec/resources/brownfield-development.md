# Brownfield Development

## Core Rules
- Assume existing code works
- Search for patterns before creating — **LLMs are biased toward reimplementing rather than reusing**
- Extend existing models, don't create new
- **Call existing code, don't copy-paste it.** If logic exists, call it. If you must duplicate (e.g., risky refactor), require: comment explaining why, shared tests for consistency, TODO for deduplication.

## Pattern Discovery
```bash
rg "ClassName" --type ruby
find app/ -name "*service*"
ls app/models/concerns/
find spec/ -name "*similar*_spec.rb"
```

## Investigation Protocol
1. Test specific usage
2. Find working examples
3. Create minimal reproduction

## Planning Anti-Patterns

### Over-Specification
❌ Planning service objects before complexity exists
❌ Defining helper classes upfront
❌ Specifying internal file organization
✅ Let these emerge during implementation

### Premature Abstraction
❌ Service class in plan
✅ Inline code first, extract when complex

### Creating Parallel Structures
❌ New model when existing serves purpose
✅ Extend existing model with fields

### Copy-Pasting Logic (LLM Anti-Pattern)
❌ Reimplementing existing service/function in a new file
❌ Preview/backtest/dry-run mode that duplicates the production code path
❌ Duplicated test setup across spec files
✅ Call existing code paths — preview modes invoke production logic
✅ Shared examples / test helpers for repeated assertion patterns
✅ If duplication is intentional: comment + shared tests + TODO

### Assuming Global Breakage
❌ "Infrastructure is broken globally"
✅ Test your specific case first

### Planning Creep
❌ HOW details (class structure, file organization)
✅ WHAT goals (data model, API surface)

## Checklist
□ Focused on WHAT not HOW?
□ Searched for existing solutions?
□ Can extend existing models?
□ Avoided pre-planning services?
□ Verified issue isn't just your code?
