---
name: direct-handoff
description: Hand off the current task to a fresh Claude session in a terminal-multiplexer sidecar pane. This skill should be used when context is getting heavy (>50%), when a task needs a fresh context window, or when the user explicitly asks to hand off work. Handles doc updates, ephemeral context capture, task list transition, and sidecar launch with confirmation.
capabilities:
  optional:
    - session-logging
---

# Direct Handoff

Hand off the current task to a fresh Claude session in a terminal-multiplexer sidecar pane. The receiving session gets full context through updated durable docs + task list + a minimal ephemeral handoff for anything that doesn't have a permanent home.

## Why Direct Handoff (Not /clear or /compact)

Direct handoff creates a **new session alongside the old one**. The old session stays open and accessible — scroll up, re-read context, copy information. This is better than `/clear` (destroys context) or `/compact` (lossy compression) because:

- **Old context is preserved intact** while the new session ramps up
- **Graceful transition** — verify the new session is running smoothly before abandoning the old one
- **Rollback** — if the handoff goes wrong, the old session is still there
- **Session sequence** — named sessions (e.g., `feature-x`, `feature-x-1`, `feature-x-2`) form a clear lineage

The old session can be closed once the new one is confirmed working.

## Core Principle: Update Existing Docs, Don't Create New Ones

The handoff doc is a **last resort**, not the primary mechanism. Before creating any handoff content:

1. **Update memory files** — decisions, patterns, team roles belong in `memory/`
2. **Update project docs** — research findings, specs, architecture docs belong in their permanent homes
3. **Update specs** — requirement changes discovered during the session belong in the spec files
4. **Task list is the coordination backbone** — the receiving session sees it via `TaskList`

The `/tmp` handoff doc captures only what's truly ephemeral: gathered signal references (Slack thread timestamps, file paths scanned), session-specific context that hasn't been persisted yet, and the receiving session's marching orders.

---

## Workflow

### Step 1: Persist Durable Context

Before any handoff mechanics, ensure all session learnings are in their permanent homes.

**Checklist:**
- [ ] Memory files updated? (decisions, patterns, team roles → `memory/`)
- [ ] Specs updated? (requirement changes → `specs/`)
- [ ] Project docs updated? (research, analysis → `project-docs/`)
- [ ] Session log entry written? (use the **session-logging** capability if configured)

If any in-progress documents were being worked on this session, update them now. The goal: if the handoff doc disappeared, the receiving session could still reconstruct most context from durable sources.

### Step 2: Review Task List

```
TaskList
```

Verify the task list reflects current state:
- In-progress tasks marked correctly
- Completed tasks resolved
- Remaining work captured as pending tasks with clear descriptions
- Task descriptions contain enough context for an independent reader

The task list is what the receiving session will use to know what to do. If tasks are vague or missing context, fix them now — not in the handoff doc.

### Step 3: Create Ephemeral Handoff (Only If Needed)

Write to `/tmp/handoff-<topic>.txt` only content that has no permanent home:

- **Signal references** — Slack thread timestamps, file paths that were scanned, URLs visited
- **Unpersisted session context** — e.g., "we discussed X with the user but haven't updated the spec yet"
- **Receiving session instructions** — what to do first, which task to start with, any special mode (e.g., "present each section for review")

**Keep it short.** If the handoff doc exceeds ~50 lines, something belongs in a durable location instead.

**Format:**
```
## Handoff: <topic>
<Date>

### What the receiving session should do first
<Clear instruction, e.g., "Read project-docs/X.md then start task #8">

### Signal references gathered this session
<File paths, Slack thread_ts values, URLs — things the receiving session needs to re-read>

### Unpersisted context
<Anything discussed but not yet written to durable docs>
```

If everything is already in durable docs and the task list, skip this step entirely. Just send the prompt directly.

### Step 4: Name the New Session and Create Sidecar Pane

**Session naming convention:** If the current session was named (via `/rename`), the new session inherits the name with a sequence suffix `-N`.

```
# Naming sequence:
#   feature-x      → feature-x-1
#   feature-x-1    → feature-x-2
#   feature-x-2    → feature-x-3
#   my-task        → my-task-1

# If current name already ends in -N, increment N
# If current name has no suffix, append -1
```

**Detect or create the pane.** Default (stock tmux):

```bash
# Get current location
LOCATION=$(tmux display-message -p '#S:#I')

# Check for existing panes
tmux list-panes -t $LOCATION -F '#P: #{pane_current_command}'
```

**If a Claude pane already exists** (pane running `claude`), use it.

**If no sidecar exists**, create one:
```bash
tmux split-window -v -t $LOCATION
tmux send-keys -t ${LOCATION}.1 'claude' C-m
sleep 6
# Verify Claude started
tmux capture-pane -p -t ${LOCATION}.1
```

If you have a richer sidecar skill installed (e.g. one that adds pane-status polling or private launch helpers), use it in place of the raw commands above — but the plain tmux sequence is the default and works with nothing else installed.

**Do NOT send `/rename` or other slash commands programmatically into the new pane.** Slash commands sent that way are unreliable and can break the receiving session. Instead, tell the user what to name the session, or include a note in the prompt asking the receiving session to suggest a name.

### Step 5: Compose and Send Handoff Prompt

1. Use the **Write tool** to create the ephemeral handoff file (if Step 3 produced one) and a prompt file with the prompt content.
2. Deliver the prompt into the pane reliably. Sending raw keystrokes through `send-keys` can misfire on slash commands or special characters, so load the prompt into the tmux paste buffer and paste it as a single unit. Default (stock tmux):
```bash
tmux load-buffer /tmp/handoff-prompt.txt
tmux paste-buffer -t ${LOCATION}.1
tmux send-keys -t ${LOCATION}.1 C-m
```
If a richer sidecar skill is installed, its delivery mechanism may be more robust — use it if available, but the buffer load/paste sequence above is the default that works standalone.

**Prompt structure:**
1. One-line summary of what the receiving session is doing
2. Point to the task list: "Check TaskList for tasks #N-#M"
3. Point to durable docs: "Read <file> for full context"
4. Point to ephemeral handoff (if created): "Read <path> for signal references"
5. Any special instructions (e.g., "present each section for user review", "say TASK COMPLETE when done")
6. Suggest a session name for the user to apply manually (e.g., "Suggested session name: `feature-x-1`")

### Step 6: Confirm and Transition

Give the pane a few seconds to start working, then check its status. Default (stock tmux):
```bash
sleep 8
tmux capture-pane -p -t ${LOCATION}.1
```
Read the captured output to verify the session is actively working, not idle or blocked. If idle or blocked, check the output and retry or troubleshoot. If a richer sidecar skill provides a dedicated status check, prefer it — but capturing and reading the pane is the default.

**Report to user:**
- Handoff complete, new session `<name>` is working
- The old session (this one) stays open — user can scroll up, re-read, copy context
- Once the new session is confirmed running smoothly, user can close this session
- If anything goes wrong, this session is still here as fallback

---

## When to Use This Skill

- Context usage exceeds ~50% and significant work remains
- User explicitly asks to hand off or "use a fresh session"
- Task is well-defined enough that a new session can pick it up from docs + task list
- Current session has gathered signals/context that would be lost to compaction

## When NOT to Use This Skill

- Task is nearly complete — just finish it
- The work requires deep conversational context that can't be captured in docs (e.g., nuanced design discussion still in progress)
- No tmux session available

## Anti-Patterns

- **Dumping everything into the handoff doc** — If it's durable knowledge, put it in a durable location
- **Vague task descriptions** — "Continue the work" is not a handoff. Task list entries must be specific.
- **Skipping Step 1** — Updating durable docs IS the handoff. The sidecar mechanics are just the delivery.
- **Creating handoff docs for things that belong in memory/** — Decisions and patterns persist across sessions via memory files, not handoff docs

## Interoperates With

- **tmux-sidecar** — if you have a richer sidecar skill covering pane detection, creation, prompt delivery, and status-check mechanics, it can replace the stock tmux commands this skill uses by default in Steps 4-6. Not required — the stock commands work standalone.

## Project and User Configuration

Load configuration in this order. **When multiple sources define the same binding,
the first one found wins** — stop checking lower sources for that binding:

1. Read `resources/personal-skill.md` if it exists — personal tool bindings and preferences.
2. Read `resources/domain-skill.md` if it exists — project-specific configuration.
3. Check the project's CLAUDE.md / CLAUDE.local.md for environment-level capability bindings.
4. For any capability still unbound, use the defaults specified in this skill.

## Extension Points

### domain-skill.md
Provide project-specific handoff configuration:
- Where durable docs, memory, and specs live in this project (paths Step 1 should check)
- Project-specific session-naming conventions, if different from the default sequence
- Any team convention for what belongs in the ephemeral handoff vs. durable docs

### personal-skill.md
Provide session-logging preferences:
- Map the **session-logging** capability to a concrete tool (see Standard Capability Catalog in the plugin architecture spec — e.g. a session-logging MCP tool, or file-based logging)
- Default when unbound: skip the session log checklist item; rely on durable docs and the task list as the record of what happened
