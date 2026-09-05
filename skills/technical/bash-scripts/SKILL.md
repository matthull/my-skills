---
name: bash-scripts
description: Bash scripting safety patterns, bats-core TDD testing, Docker execution, idempotency. Load this skill when writing or modifying shell scripts.
---

# Bash Scripts Practice

## CRITICAL: Bash Script Safety (ABSOLUTE)

**You MUST ALWAYS start scripts with:**
```bash
#!/usr/bin/env bash
set -euo pipefail
```

- `set -e` - Exit immediately if any command fails
- `set -u` - Exit if undefined variable is used
- `set -o pipefail` - Catch failures in pipes

**EXCEPTION:** Only use `set +e` temporarily for commands you EXPECT to fail, then re-enable.

---

## CRITICAL: Test Every Bash Function (ABSOLUTE)

**You MUST NEVER add bash functions without bats tests.**

Every public function needs a `@test` annotation in bats:

```bash
# test/validator.bats
@test "validate_config accepts valid JSON" {
  run validate_config valid.json
  [ "$status" -eq 0 ]
}

@test "validate_config rejects invalid JSON" {
  run validate_config invalid.json
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Invalid JSON" ]]
}
```

---

## CRITICAL: Parameter Validation (ABSOLUTE)

Validate in every script:
- Required parameters exist
- Parameter count is correct
- File paths exist (if expected)
- Enums match expected values

```bash
if [ $# -lt 1 ]; then
  echo "Error: Missing required parameter" >&2
  echo "Usage: $0 <config_file>" >&2
  exit 1
fi
```

---

## CRITICAL: Idempotency (ABSOLUTE)

**Scripts MUST be safe to run multiple times.**

```bash
# WRONG:
mkdir output/      # Fails on second run
rm config.old      # Fails if file doesn't exist

# CORRECT:
mkdir -p output/
rm -f config.old
```

---

## Script Structure Pattern

```bash
#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

show_help() { ... }
log_info() { echo -e "\033[0;32m✓\033[0m $*"; }
log_error() { echo -e "\033[0;31m✗\033[0m $*" >&2; }

main() {
  # Parse arguments, validate, execute
}

main "$@"
```

---

## Bats Testing Patterns

**Basic assertions:**
```bash
[ "$status" -eq 0 ]                    # Exit code
[[ "$output" =~ "expected pattern" ]]  # Regex match
[[ "$lines[0]" == "first line" ]]      # Specific line
[ -f "$file" ]                         # File exists
```

**Setup/teardown:**
```bash
setup() {
  export TEST_TEMP_DIR="$(mktemp -d)"
}
teardown() {
  rm -rf "$TEST_TEMP_DIR"
}
```

---

## Verification Loops

**Loop 1 (TDD)**: `bats test/{script_name}.bats`
**Loop 2 (Full Suite)**: `bats test/**/*.bats`
**Loop 3 (Manual)**: Run script with test data, verify output/side effects

---

## Code Quality Checklist

- [ ] Script starts with `set -euo pipefail`
- [ ] Every function has bats test
- [ ] Required parameters validated
- [ ] Script is idempotent
- [ ] ShellCheck passes: `shellcheck {script_name}.sh`
- [ ] All bats tests pass
- [ ] No debug statements (`set -x`)
- [ ] Functions small and focused (< 20 lines)
- [ ] Error messages descriptive and go to stderr
- [ ] Help text clear with examples

---

## Anti-patterns

**You MUST NEVER:**
- Omit `set -euo pipefail`
- Skip parameter validation
- Write bash functions without tests
- Use `set +e` globally
- Ignore exit codes
- Write non-idempotent scripts
- Parse ls output (`for file in $(ls)`)
- Use `eval`
- Put secrets in scripts
- Forget to quote variables (`$var` -> `"$var"`)

**Prefer:**
- Small, focused functions
- Bats tests for every function
- Descriptive error messages to stderr
- Help text with examples
- ShellCheck linting
- Docker-aware scripts (check `/.dockerenv`)
