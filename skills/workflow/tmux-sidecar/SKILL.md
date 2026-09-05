---
name: tmux-sidecar
description: Create and interact with secondary tmux panes or windows for bidirectional command execution. This skill should be used when "tmux sidecar" is mentioned, or when needing to run interactive sessions (REPLs, rails console, database clients, log tailing) in a separate pane or window while maintaining control from the main session.
---

# Tmux Sidecar

> **Note:** For Claude-to-Claude orchestration, prefer **agent-teams** (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`). Agent-teams provides built-in mailbox, shared task list, and tmux split-pane coordination that is more reliable than the polling-based patterns below. This skill remains the right tool for **non-Claude processes** (REPLs, databases, log tailing, build watchers). See `research/findings/agent-teams-egregore-impact.md`.

Create secondary tmux pane or window for bidirectional command execution.

## Pane vs Window Decision

**If the user does not specify pane or window, ALWAYS ask before creating the sidecar:**

> "Should I create this sidecar as a **new pane** (split in current window) or a **new window** (separate tab)?"

**When to suggest each:**
- **Pane** (split): Good for monitoring alongside current work, short-lived tasks, seeing output side-by-side
- **Window** (tab): Good for long-running processes, full-screen REPLs, when pane space is tight, Claude Code sidecars

**Creating a new window:**
```bash
LOCATION=$(tmux display-message -p '#S')
tmux new-window -t $LOCATION -n sidecar-name
# New window becomes SESSION:NEW_INDEX
# Reference as SESSION:WINDOW_NAME or SESSION:WINDOW_INDEX
```

**Creating a new pane:**
```bash
LOCATION=$(tmux display-message -p '#S:#I')
tmux split-window -v -t $LOCATION   # vertical (below)
tmux split-window -h -t $LOCATION   # horizontal (beside)
```

## Helper Scripts

Helper scripts are installed at `~/.local/bin/` to avoid pipe restrictions and handle Claude-specific behaviors:

```bash
# Capture pane output (avoids pipe to tail)
tmux-capture <pane> [lines] [output_file]
tmux-capture alfalfa:2.1           # Last 30 lines to stdout
tmux-capture alfalfa:2.1 50        # Last 50 lines to stdout
tmux-capture alfalfa:2.1 50 /tmp/out.txt  # To file

# Check sidecar status (returns: COMPLETE, BLOCKED, IDLE, or WORKING)
tmux-sidecar-status <pane>
tmux-sidecar-status alfalfa:2.1    # Returns status word

# Send prompt to Claude sidecar (handles two-enter requirement)
tmux-claude-send <pane> <prompt>
tmux-claude-send alfalfa:2.1 "Implement task T001"
tmux-claude-send alfalfa:2.1 -f /tmp/prompt.txt  # From file
```

**IMPORTANT:** Always use `tmux-claude-send` when sending prompts to a Claude sidecar. It handles the two-enter requirement automatically (first Enter ends input, second Enter submits).

## Workflow Pattern

```bash
# 1. Find current location
LOCATION=$(tmux display-message -p '#S:#I')

# 2. Create sidecar pane
tmux split-window -v -t $LOCATION   # vertical (below)
# OR
tmux split-window -h -t $LOCATION   # horizontal (beside)

# 3. Send command to sidecar
tmux send-keys -t ${LOCATION}.1 'your-command' C-m

# 4. Wait for completion
sleep N

# 5. Read output (use helper to avoid pipe restrictions)
tmux-capture ${LOCATION}.1 20
```

## Core Commands

### Identify Current Location
```bash
tmux display-message -p '#S:#I.#P'  # Returns session:window.pane
```

### Create Sidecar Pane
```bash
# Split vertically (pane below)
tmux split-window -v -t SESSION:WINDOW

# Split horizontally (pane beside)
tmux split-window -h -t SESSION:WINDOW
```

### Send Commands
```bash
# Send command to specific pane
tmux send-keys -t SESSION:WINDOW.PANE 'command here' C-m

# C-m = Enter key
# Without C-m, text appears but doesn't execute
```

### Read Output
```bash
# Using helper script (recommended - avoids pipe restrictions)
tmux-capture SESSION:WINDOW.PANE 30        # Last 30 lines
tmux-capture SESSION:WINDOW.PANE 50 /tmp/out.txt  # To file

# Raw tmux commands (may need pipes which trigger permission prompts)
tmux capture-pane -t SESSION:WINDOW.PANE -p              # Entire buffer
tmux capture-pane -t SESSION:WINDOW.PANE -p -S -N        # With history
```

### List Panes/Windows
```bash
# List all panes in window
tmux list-panes -t SESSION:WINDOW -F '#P: #{pane_current_command}'

# List all windows in session
tmux list-windows -t SESSION -F '#I: #W (#{window_panes} panes)'

# List all sessions
tmux list-sessions
```

### Close Sidecar
```bash
tmux kill-pane -t SESSION:WINDOW.PANE
```

## Pane Numbering

- Panes numbered 0, 1, 2...
- New split increments from highest existing
- Use `.0` for original pane, `.1` for first split

## Common Use Cases

- Interactive REPLs (rails console, python, node)
- Long-running commands with monitoring
- Database clients
- Build watchers
- Log tailing

## Rails Console Example

```bash
# Start Rails console in sidecar pane
LOCATION=$(tmux display-message -p '#S:#I')
tmux split-window -v -t $LOCATION
tmux send-keys -t ${LOCATION}.1 'bundle exec rails console' C-m
```

## Claude Code Sidecar Pattern

Use a Claude session in a sidecar for complex tasks requiring visibility and user intervention capability.

### Start Claude Sidecar
```bash
# Create pane with claude
LOCATION=$(tmux display-message -p '#S:#I')
tmux split-window -v -t $LOCATION -c /path/to/project
tmux send-keys -t ${LOCATION}.1 'claude' C-m
sleep 6  # Wait for Claude to initialize

# Enable "accept edits on" mode to auto-approve file edits
tmux send-keys -t ${LOCATION}.1 BTab
sleep 1
```

**Note:** Use `BTab` (not `S-Tab`) for Shift+Tab in tmux. This enables auto-approval of edits, preventing permission prompts from blocking the sidecar.

### Send Multi-line Prompts

**Recommended:** Use the `tmux-claude-send` helper which handles the two-enter requirement:

```bash
# Simple prompt
tmux-claude-send alfalfa:1.1 "Implement the changes in T001.md"

# Multi-line prompt (use file for complex prompts)
cat > /tmp/prompt.txt << 'EOF'
Your prompt here.

Multiple paragraphs work.

1. Numbered lists
2. Work fine
EOF
tmux-claude-send alfalfa:1.1 -f /tmp/prompt.txt
```

**Manual approach** (if needed):
Multi-line prompts to Claude require **TWO Enters**:
- First Enter ends the multi-line text
- Second Enter submits the prompt

```bash
tmux send-keys -t alfalfa:1.1 "Your prompt" Enter
sleep 0.5
tmux send-keys -t alfalfa:1.1 Enter  # Submit
```

### Monitor Progress
```bash
# Using helper scripts (recommended)
tmux-capture alfalfa:1.1 50           # Last 50 lines
tmux-sidecar-status alfalfa:1.1       # Returns COMPLETE/BLOCKED/IDLE/WORKING

# Watch continuously (user terminal, not Claude)
watch -n 5 'tmux-capture alfalfa:1.1 30'
```

### Benefits Over Subagents
- User can see Claude's thinking and tool use in real-time
- User can jump in and intervene if needed
- Persistent session for follow-up questions
- Permission prompts visible to user (can approve/deny interactively)
- Full Claude Code capabilities (can spawn its own subagents)
- Orchestrator session can monitor and intervene programmatically
- Bidirectional communication - sidecar can message back

## Communication Between Claude Sessions

**IMPORTANT LIMITATION**: `tmux send-keys` does NOT inject into another Claude session's conversation. It only types text into the terminal buffer, which the receiving Claude won't see unless it explicitly captures its own pane.

### The Only Reliable Pattern

Orchestrator must **poll the sidecar's output** to detect status:

```bash
# Using helper script (recommended)
STATUS=$(tmux-sidecar-status $SIDECAR)
# Returns: COMPLETE, BLOCKED, IDLE, or WORKING

# Or capture output manually
tmux-capture $SIDECAR 30 /tmp/sidecar-out.txt
# Then use Read/Grep tools on the file
```

### Signal Words for Sidecar

Instruct the sidecar to use clear signal words in its output:
- `TASK COMPLETE` - When finished successfully
- `BLOCKED:` - When stuck and needs help

The orchestrator will see these when polling the sidecar's output.

## Orchestration Patterns

When using a Claude sidecar as a delegated worker, the orchestrating session needs to monitor progress and detect completion.

### Completion Detection

Claude Code shows a visible prompt (`>`) when ready for input. Check for this:

```bash
# Check if Claude is waiting for input (task complete)
OUTPUT=$(tmux capture-pane -t ${LOCATION}.1 -p | tail -5)
if echo "$OUTPUT" | grep -q '^>'; then
  echo "Claude is ready for next prompt (previous task complete)"
fi
```

### Progress Monitoring Loop

```bash
# Poll for completion with timeout using helper script
SIDECAR="alfalfa:1.1"
TIMEOUT=300  # 5 minutes
INTERVAL=10  # Check every 10 seconds
ELAPSED=0

while [ $ELAPSED -lt $TIMEOUT ]; do
  STATUS=$(tmux-sidecar-status $SIDECAR)

  case "$STATUS" in
    COMPLETE|IDLE)
      echo "Task complete"
      break
      ;;
    BLOCKED)
      echo "Sidecar reports issue - intervention needed"
      break
      ;;
  esac

  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))
done
```

### Result Extraction

After task completion, extract the relevant output:

```bash
# Capture session output to file, then use Read/Grep tools
tmux-capture $SIDECAR 200 /tmp/sidecar-output.txt
# Then: Read(/tmp/sidecar-output.txt)
```

### Sending Follow-up Tasks

Use the `tmux-claude-send` helper:

```bash
# Send next task to existing sidecar
tmux-claude-send $SIDECAR "Now implement the next task: [description]"
```

### Structured Handoff Pattern

For implementation tasks, use file-based prompts for complex instructions:

```bash
cat > /tmp/task-prompt.txt << 'EOF'
Read and implement the task in specs/feature/task-handoffs/T001.md

Report when complete with:
- What was implemented
- Any blockers encountered
- Test results
EOF
tmux-claude-send $SIDECAR -f /tmp/task-prompt.txt
```

### Cleanup

```bash
# Kill the sidecar pane (simplest approach)
tmux kill-pane -t $SIDECAR

# Note: Graceful exit with '/exit' is unreliable due to Claude's
# command palette intercepting the input. Just kill the pane.
```

### Restarting Claude Between Tasks

**Kill and recreate the pane** (most reliable approach):

```bash
LOCATION=$(tmux display-message -p '#S:#I')

# 1. Kill the old pane
tmux kill-pane -t $SIDECAR

# 2. Create fresh pane
tmux split-window -v -t $LOCATION -c /path/to/project

# 3. Start Claude
tmux send-keys -t ${LOCATION}.1 'claude' C-m
sleep 6

# 4. VERIFY: Check for Claude banner
tmux-capture ${LOCATION}.1 15 /tmp/start-check.txt
# Read file - should see "Claude Code" banner

# 5. Update SIDECAR variable
SIDECAR="${LOCATION}.1"
```

**Why kill instead of /exit:** The `/exit` command is intercepted by Claude's command palette, making graceful exit unreliable. Killing the pane is instant and deterministic.

### Orchestrator Integration Example

```bash
# Full orchestration cycle
LOCATION=$(tmux display-message -p '#S:#I')
SIDECAR="${LOCATION}.1"

# 1. Create sidecar with Claude
tmux split-window -v -t $LOCATION -c /path/to/project
tmux send-keys -t $SIDECAR 'claude' C-m
sleep 6

# 2. Send task using helper
tmux-claude-send $SIDECAR "Implement task T001 from specs/feature/task-handoffs/T001.md. Say TASK COMPLETE when done."

# 3. Monitor until complete using helper
while true; do
  sleep 30
  STATUS=$(tmux-sidecar-status $SIDECAR)
  [ "$STATUS" = "COMPLETE" ] || [ "$STATUS" = "IDLE" ] && break
  [ "$STATUS" = "BLOCKED" ] && break
done

# 4. Extract result
tmux-capture $SIDECAR 100 /tmp/sidecar-result.txt

# 5. Send next task or cleanup
```
