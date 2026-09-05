---
name: nvim-copilot
description: Neovim copiloting protocol — drive a side-by-side neovim instance as a presentation surface for code. Manages setup, navigation, annotations, floating windows, code snippet popups, tour maps, and communication routing between Claude Code and neovim panes. Use as a dependency from any skill that shows code alongside conversation (exploration, code review, debugging, teaching). Also invocable directly to start a copiloted neovim session.
argument-hint: "[socket path if neovim already running]"
---

# Neovim Copilot

Protocol for driving a side-by-side neovim instance from Claude Code. Claude controls the editor — opening files, annotating code, showing floating explanations, maintaining a tour map — while the developer reads code in neovim and converses in the Claude Code pane.

This skill is both directly invocable and a dependency for other skills (e.g., `/explore`, `/code-review`). When loaded as a dependency, the calling skill controls *what* to show; this skill controls *how* to show it.

## Input

Optional: a socket path if neovim is already running.
- `{{input}}`

## Environment Setup

Open neovim to the right of the current Claude Code session:
```bash
tmux split-window -h -l 65% "nvim --listen /tmp/nvim-explore.sock $(pwd)"
```

This creates a side-by-side layout: Claude Code on the left (~35% width) and neovim on the right (~65% width). Both get full terminal height. The developer reads code on the right while the conversation happens on the left.

**Verify the socket is ready:**
```bash
ls /tmp/nvim-explore.sock
```

If the socket already exists from a previous session, remove it first (`rm -f /tmp/nvim-explore.sock`) before starting neovim.

**If the developer already has neovim running** with a listen socket, skip setup and ask them for the socket path (or use the one they passed as input).

## Core nvr Operations

All commands use `nvr --servername /tmp/nvim-explore.sock` (adjust path if the developer provided a different socket).

**Open a file:**
```bash
nvr --servername /tmp/nvim-explore.sock --remote +LINE /path/to/file
```

**Navigate to a line in the current file:**
```bash
nvr --servername /tmp/nvim-explore.sock -c 'LINE'
```

**Open a related file in a horizontal split (top/bottom):**
```bash
nvr --servername /tmp/nvim-explore.sock -c 'split +LINE /path/to/file'
```
Use horizontal splits sparingly — only when it's critical to show two files simultaneously (e.g., a caller and the function it calls). Vertical splits (`vsplit`) are unusable in this layout — the neovim pane is already narrow from the Claude Code side panel.

**Switch to a different file (same window, no split):**
```bash
nvr --servername /tmp/nvim-explore.sock -c 'edit +LINE /path/to/file'
```
This is the default for navigation. Most of the time, just switch files — the developer can use neovim's buffer list or `:bp` to go back.

**Close all splits, return to single window:**
```bash
nvr --servername /tmp/nvim-explore.sock -c 'only'
```

**Query what's currently open:**
```bash
nvr --servername /tmp/nvim-explore.sock --remote-expr 'bufname("%") .. " | line: " .. line(".")'
```

## Annotations

Use neovim's extmark API to add inline annotations at specific lines. Three types, each for a different purpose.

### Brief inline annotations

Virtual text at end of line — best for short contextual notes. Low visual footprint, appears right next to the code it describes:
```bash
nvr --servername /tmp/nvim-explore.sock -c "lua local ns = vim.api.nvim_create_namespace('explore'); vim.api.nvim_buf_set_extmark(0, ns, LINE_0_INDEXED, 0, {virt_text={{'  <- annotation text', 'DiagnosticInfo'}}, virt_text_pos='eol'})"
```

Highlight groups for different emphasis:
- `DiagnosticInfo` (blue) — general explanatory notes
- `DiagnosticWarn` (yellow) — important design decisions or key points
- `DiagnosticHint` (teal) — supplementary context

### Floating windows

For longer multi-line explanations positioned near relevant code:
```bash
nvr --servername /tmp/nvim-explore.sock -c "lua local buf = vim.api.nvim_create_buf(false, true); vim.api.nvim_buf_set_lines(buf, 0, -1, false, {'Line 1', 'Line 2', 'Line 3'}); vim.api.nvim_open_win(buf, false, {relative='win', row=ROW, col=COL, width=WIDTH, height=HEIGHT, style='minimal', border='rounded'})"
```

### Code snippet popups

Show lines from another file without leaving the current one — anchored to the right so the main code stays readable:
```bash
nvr --servername /tmp/nvim-explore.sock -c "lua local buf = vim.api.nvim_create_buf(false, true); local lines = vim.fn.readfile('FILE_PATH', '', END_LINE); for i = 1, START_LINE - 1 do table.remove(lines, 1) end; vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines); vim.api.nvim_set_option_value('filetype', 'FILETYPE', {buf=buf}); local win_width = vim.api.nvim_win_get_width(0); vim.api.nvim_open_win(buf, false, {relative='win', row=2, col=win_width - 95, width=90, height=#lines + 1, style='minimal', border='rounded', title=' TITLE ', title_pos='center'})"
```
Replace `FILE_PATH`, `START_LINE`, `END_LINE`, `FILETYPE` (e.g., `ruby`, `typescript`), and `TITLE` (e.g., `parser.rb:15-30`). This is the preferred way to show related code — better than splits because the developer stays oriented in the main file.

### Cleanup

**Close floating windows:**
```bash
nvr --servername /tmp/nvim-explore.sock -c "lua for _, win in ipairs(vim.api.nvim_list_wins()) do if vim.api.nvim_win_get_config(win).relative ~= '' then vim.api.nvim_win_close(win, true) end end"
```

**Clear all annotations from current buffer:**
```bash
nvr --servername /tmp/nvim-explore.sock -c "lua vim.api.nvim_buf_clear_namespace(0, vim.api.nvim_create_namespace('explore'), 0, -1)"
```

## When to Use Which

| Situation | Tool |
|-----------|------|
| "This line does X" | Inline annotation (DiagnosticInfo) |
| "This is a key design decision" | Inline annotation (DiagnosticWarn) |
| "Here's how this connects to the broader system" | Floating window (3-5 lines) |
| "Look at this file next" | Open file via nvr --remote |
| "Look at this related code" | Code snippet popup (right-anchored, stays in context) |
| "Compare these two files extensively" | Horizontal split (only when critical) — otherwise switch between files |
| "Follow the data flow from A to B" | Open file A, annotate key lines, snippet popup for B, then switch to B with `edit` |

## Tour Map — Persistent Orientation

Maintain a small **tour map** popup in the bottom-right of the neovim window throughout the session. This is the developer's "you are here" — a sliding context window showing the current file's neighborhood.

**What the tour map shows:**
- Where we came from (`checkmark` prefix — visited, still relevant)
- Where we are now (`>` prefix)
- Key relationships of the current file — associations, key methods, what calls it, what it calls
- What's next (if there's a natural next step)

**What the tour map does NOT show:**
- Every file ever visited — old entries roll off as they become irrelevant
- Full method listings — only the methods/associations relevant to understanding this file's role
- Implementation details — keep it at the "what connects to what" level

**Tour map behavior:**
- Max ~6-8 lines — compact enough to stay in the bottom-right without obscuring code
- Updates when switching files — close old popup, open new one with current neighborhood
- The content is curated, not generated from code structure — include whatever is most useful for comprehension
- It's a **sliding window**, not an accumulating history — add relevant context, drop entries that are no longer part of the current neighborhood

**Rendering the tour map** (bottom-right anchored):
```bash
nvr --servername /tmp/nvim-explore.sock -c "lua for _, win in ipairs(vim.api.nvim_list_wins()) do if vim.api.nvim_win_get_config(win).relative ~= '' then vim.api.nvim_win_close(win, true) end end; local buf = vim.api.nvim_create_buf(false, true); vim.api.nvim_buf_set_lines(buf, 0, -1, false, {LINES}); local win_w = vim.api.nvim_win_get_width(0); local win_h = vim.api.nvim_win_get_height(0); vim.api.nvim_open_win(buf, false, {relative='win', row=win_h - HEIGHT - 2, col=win_w - WIDTH - 3, width=WIDTH, height=HEIGHT, style='minimal', border='rounded', title=' Tour ', title_pos='center'})"
```

## Navigation Flow

When moving between files:

1. **Clear annotations** from the current file
2. **Switch file** via `edit +LINE`
3. **Update tour map** — close old, open new with current file's neighborhood
4. **Annotate** key lines in the new file
5. Repeat

The tour map provides the "zoom out" context; annotations provide the "zoom in" detail. Together they keep the developer oriented as you navigate.

## Communication Routing — Neovim-Primary

**The developer's eyes are on neovim, not the Claude Code pane.** The Claude Code pane is a thin command/status strip (~20 lines visible). If you put significant output there, the developer has to go full-screen on the Claude pane to read it, which breaks flow.

**Rule: rich commentary goes into neovim via annotations and floating windows. Claude Code messages should be concise — a short paragraph is fine, a wall of text is not.**

| Communication type | Where it goes |
|---|---|
| Explaining what a line/block does | Neovim: inline virtual text annotation |
| Longer explanation of a concept or design decision | Neovim: floating window near relevant code |
| "I'm opening file X because Y" | Claude Code: 1-2 line status message |
| "Next I'd suggest looking at X" | Claude Code: 1-2 line suggestion |
| Answering a developer question | Neovim: floating window if code-specific, Claude Code if general (keep brief) |
| Diagrams | Claude Code pane (developer will glance down, this is an acceptable full-screen moment) |
| Session briefing / longer one-time output | Claude Code pane (developer expects to read this before diving into code) |

**When in doubt:** put it in neovim. The developer can always ask you to elaborate in the Claude pane if they need more.

## Guidelines

- **Annotate sparingly.** 3-5 annotations per file maximum. Too many annotations are as noisy as no annotations.
- **Clear annotations before moving to a new file** — stale annotations from a previous file are confusing.
- **Close floating windows after the developer has read them** — they obscure code. Exception: the tour map stays open.
- **Don't fight the developer's navigation.** If they manually jump to a file, query what they're looking at via `--remote-expr` and adapt. Don't force them back to your planned path.
- **Extmark lines are 0-indexed.** Line 1 in the file is index 0 in the API.
