---
name: go-cli
description: Go CLI development patterns — testing strategy, argument parsing, error handling, concurrency, and quality gates. Load this skill when implementing or modifying Go CLI tools.
---

# Go CLI Development

Patterns for building reliable Go CLI tools that interact with external processes (tmux, git, docker, etc.). Distilled from production experience.

---

## Quality Gate: `make check`

Every Go CLI project MUST have a `make check` target. This is the single command that must pass before shipping.

```makefile
check: fmt vet lint test
```

Where:
- `fmt` — `gofmt -w . && goimports -w .`
- `vet` — `go vet ./...`
- `lint` — `golangci-lint run ./...`
- `test` — `go test ./... -v` (all tests including integration)

Also provide `test-short` for fast feedback: `go test ./... -v -short` (skips integration tests).

**Rule:** If `make check` doesn't pass, don't commit. This means lint must pass — `golangci-lint` errors (including `errcheck` on unchecked error returns) are not warnings, they are build failures. Fix them before moving on. Lint passing is part of the TDD loop: write test → make it pass → make lint pass → refactor.

---

## Testing Strategy: Two-Layer Model

Unit tests alone are insufficient for Go CLI tools that interact with external processes. The bugs that escape unit tests live at the seam between argument parsing and execution — where environmental behavior (tmux prefix matching, flag parsing order) determines correctness.

### Layer 1: Unit Tests (pure logic, `-short` mode)

Test all logic that doesn't require external processes:
- **Argument parsing**: Export `parseFooArgs()` functions and test them directly
- **Config serialization**: `WriteConfig` → `ReadConfig` round-trip
- **String processing**: Sanitization, template generation, status parsing
- **Error classification**: Sentinel error matching from stderr patterns

**Run:** `go test ./... -short` — seconds, every save

**What unit tests catch:** Logic bugs, regressions, edge cases in pure functions.

**What unit tests miss:** Environmental behavior, argument flow through command structure, external tool quirks.

### Layer 2: Acceptance Tests (installed binary + real environment)

Test the compiled binary against real infrastructure. These are sequential scenario tests that exercise the full lifecycle:

```go
func TestFullLifecycle(t *testing.T) {
    if testing.Short() { t.Skip("skipping acceptance test") }

    // Use temp dirs / env overrides — don't touch real state
    tmpHome := t.TempDir()
    t.Setenv("MY_HOME", tmpHome)

    // Helper runs the installed binary
    runCLI := func(args ...string) (string, error) {
        cmd := exec.Command("mybinary", args...)
        cmd.Env = append(os.Environ(), "MY_HOME="+tmpHome)
        out, err := cmd.CombinedOutput()
        return string(out), err
    }

    // Sequential phases — each builds on the previous
    t.Run("create resource", func(t *testing.T) { ... })
    t.Run("verify resource exists", func(t *testing.T) { ... })
    t.Run("modify resource", func(t *testing.T) { ... })
    t.Run("cleanup resource", func(t *testing.T) { ... })
    t.Run("error cases", func(t *testing.T) { ... })
}
```

**Run:** `go test ./... -run TestFullLifecycle -timeout 120s` — 20-30s, before commits

**What acceptance tests catch:** Flag parsing order bugs, external tool behavior (tmux fuzzy matching, process timing), command flow, real error messages, state management across commands.

**Key patterns:**
- **Track resources for cleanup:** `defer` killing tmux windows, temp files created during test
- **Use env vars for isolation:** `$MY_HOME`, `$MY_CONFIG` — never touch real user state
- **Verify through the same interface users see:** Check stdout/stderr, process lists, filesystem state
- **Non-fatal timing checks:** Process output capture is timing-sensitive — log warnings, don't hard-fail

### When to write which

| Writing... | Layer |
|------------|-------|
| New arg parsing logic | Unit test for parse function + acceptance test for the command |
| Pure data transformation | Unit test only |
| New CLI command | Both — unit for logic, acceptance for the full flow |
| Bug fix | Acceptance test that reproduces the bug first, then fix |
| External tool interaction | Acceptance test only (can't unit-test external behavior) |

### Bugs caught by each layer (from experience)

| Bug | Unit? | Acceptance? |
|-----|-------|-------------|
| Flags after positional args silently dropped | No | Yes |
| External tool does prefix matching instead of exact | No | Yes |
| Config round-trip loses fields | Yes | Also yes |
| Incorrect error message text | Possibly | Yes |

---

## Go Patterns

### Struct over global functions

Wrap configuration in an explicit struct. All operations are methods on the struct.

**Why:**
- No hidden global state — constructor makes dependencies visible
- Test isolation is trivial: `NewRunnerWithSocket("test-socket")` vs mutating a global
- Multiple instances can coexist
- No init-order bugs from globals

```go
type Runner struct {
    socket string
}
func NewRunner() *Runner { return &Runner{} }
func NewRunnerWithSocket(s string) *Runner { return &Runner{socket: s} }
func (r *Runner) DoThing(target string) error { /* uses r.socket */ }
```

### Channel semaphore for per-target locking

Use buffered channels of size 1 instead of mutexes when you need lock timeout. `select` with `time.After` gives a deadline; `sync.Mutex.Lock()` blocks forever.

```go
func AcquireLock(target string, timeout time.Duration) bool {
    sem := getTargetSem(target) // chan struct{} with buffer 1
    select {
    case sem <- struct{}{}: return true   // acquired
    case <-time.After(timeout): return false // gave up
    }
}
```

**When to use:** Locks guarding external process interaction where hangs are possible.

### Sentinel errors + stderr classification

Classify external tool errors by parsing stderr into sentinel errors. Callers use `errors.Is()` for control flow.

```go
var (
    ErrNoServer        = errors.New("no server running")
    ErrSessionNotFound = errors.New("session not found")
)
func (r *Runner) wrapError(err error, stderr string, args []string) error {
    if strings.Contains(stderr, "no server running") { return ErrNoServer }
    return fmt.Errorf("cmd %s: %s", args[0], stderr)
}
```

### One file per concern

Split by primary operation: `send.go`, `lock.go`, `idle.go`, `capture.go`. Target 30-170 lines per file.

---

## CLI Argument Parsing

### Flags-after-positional gotcha

**CRITICAL BUG PATTERN:** Go's `flag.Parse` stops at the first non-flag argument. If your usage is `cmd <positional> [--flag value]`, flags after the positional arg are silently ignored.

```
mycli create myname --project /tmp    # --project silently dropped!
mycli create --project /tmp myname    # works, but unnatural
```

**Fix: `splitArgs` helper.** Separate positional and flag arguments before parsing:

```go
func splitArgs(args []string) (positional, flags []string) {
    for i := 0; i < len(args); i++ {
        if strings.HasPrefix(args[i], "-") {
            flags = append(flags, args[i])
            if !strings.Contains(args[i], "=") && i+1 < len(args) && !strings.HasPrefix(args[i+1], "-") {
                flags = append(flags, args[i+1])
                i++
            }
        } else {
            positional = append(positional, args[i])
        }
    }
    return
}

func runCreate(args []string) int {
    positional, flagArgs := splitArgs(args)
    if len(positional) < 1 { /* error */ }
    name := positional[0]

    fs := flag.NewFlagSet("create", flag.ContinueOnError)
    fs.StringVar(&project, "project", "", "working directory")
    fs.Parse(flagArgs)
    // ...
}
```

**Use `splitArgs` for every command that takes `<positional> [--flags]`.** Unit-test `splitArgs` itself.

For commands where all args are flags (no positional), `flag.Parse(args)` directly is fine.

**Exit code convention:** 1 = runtime error, 2 = usage/argument error.

---

## Test Infrastructure Patterns

### TestMain for process isolation

`TestMain` creates an isolated environment for the entire test package. Non-negotiable for tests that interact with external processes.

```go
var testSocket string

func TestMain(m *testing.M) {
    testSocket = fmt.Sprintf("myapp-test-%d", os.Getpid())
    code := m.Run()
    _ = exec.Command("tmux", "-L", testSocket, "kill-server").Run()
    os.Exit(code)
}
```

- Use `os.Getpid()` in resource names to avoid collisions
- Cleanup in TestMain — ensures cleanup even if tests panic
- Individual tests also use `t.Cleanup` for their own resources

### Server exit race

**Gotcha:** When a test kills the last session on an isolated server, the server shuts down. Next test gets "server exited unexpectedly".

**Fix:** Retry once after a short sleep on this specific error.

### Shell readiness wait

**Gotcha:** Session creation returns before the shell is ready to receive input.

**Fix:** Poll for visible output before proceeding:

```go
func waitForShellReady(t *testing.T, r *Runner, session string) {
    deadline := time.Now().Add(5 * time.Second)
    for time.Now().Before(deadline) {
        lines, _ := r.CapturePaneLines(session, 3)
        for _, line := range lines {
            if strings.TrimSpace(line) != "" { return }
        }
        time.Sleep(100 * time.Millisecond)
    }
}
```

### Integration test tagging

Every integration/acceptance test starts with:
```go
if testing.Short() {
    t.Skip("skipping integration test")
}
```

Two speeds: `go test ./... -short` (seconds) vs `go test ./...` (full suite, ~30s).

---

## Environment Gotchas

### Claude Code Bash tool does NOT source `.zshenv`

Go tools installed via `go install` to `~/go/bin` won't be found. Add `env.PATH` to `.claude/settings.local.json`:

```json
{
  "env": {
    "PATH": "$HOME/go/bin:$HOME/.local/bin:$PATH"
  }
}
```

### External tools may not error on bad input

Some CLI tools succeed silently with invalid input (e.g., tmux `display-message -t nonexistent` returns "0" with exit 0). Always write explicit tests for "not found" cases. Don't assume tools will error when given bad input.
