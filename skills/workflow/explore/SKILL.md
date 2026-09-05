---
name: explore
description: AI-guided interactive code exploration for holistic comprehension. Pre-analyzes a codebase area with parallel subagents, then guides an interactive session with focused diagrams, code links, and narrative. Use when you want to deeply understand how a chunk of a system works — not audit it, not review it, but comprehend it. Triggers on "explore", "walk me through", "explain this codebase", "how does this work", or when the goal is understanding existing code.
argument-hint: "<what to explore> <goal — why you're exploring this>"
capabilities:
  optional:
    - code-hosting   # PR history / design-rationale mining in Phase 1
---

# Code Exploration Skill

Guide the developer through deep comprehension of a codebase area. The goal is holistic understanding — how the pieces connect, why it's shaped this way, what the key abstractions are.

**This is exploration, not audit.** The primary output is comprehension. Not a quality report, not a list of problems, not a review. The developer wants to understand what exists right now.

## Input

The developer provides what they want to explore and why:
- `{{input}}`

## Environment Setup

If the `nvim-copilot` skill is installed, load it and use it to set up a side-by-side neovim session. It handles socket management, neovim launch, and provides the full protocol for navigation, annotations, floating windows, tour maps, and communication routing between panes.

Throughout the exploration, if a copiloted neovim session is active, follow `nvim-copilot`'s communication routing — rich commentary goes into neovim via annotations and floating windows; Claude Code messages stay concise.

If `nvim-copilot` is not installed, skip the side-by-side session and run the exploration entirely in the conversation: diagrams, code excerpts, and annotations all go directly into Claude Code messages, with file:line references so the developer can jump to the code in their own editor. This is the core-only mode — comprehension quality is unaffected; only the presentation surface changes.

## Interoperates With

- **`nvim-copilot`** — provides the optional side-by-side presentation surface described above. This is a skill dependency, not a capability binding: there's no environment-level tool to swap in, just a check for whether the skill is installed. No shared configuration is required between the two skills.

## Project and User Configuration

Load configuration in this order. **When multiple sources define the same binding,
the first one found wins** — stop checking lower sources for that binding:

1. Read `resources/personal-skill.md` if it exists — personal exploration preferences.
2. Read `resources/domain-skill.md` if it exists — project-specific exploration context.
3. Check the project's CLAUDE.md / CLAUDE.local.md for environment-level capability bindings (especially **code-hosting**).
4. For any capability still unbound, use the defaults specified in this skill (fall back to `git log` for design context when no code-hosting binding exists).

## Extension Points

### domain-skill.md
Provide project-specific exploration context:
- Where design docs, ADRs, or architecture notes typically live in this project
- Directory/module conventions that help subagents scope their search faster
- Areas of the codebase known to be confusing or under-documented, worth flagging proactively

### personal-skill.md
Provide personal exploration preferences:
- Whether to always attempt a side-by-side neovim session or default to conversation-only
- Preferred diagram density or narrative-vs-diagram balance
- Depth default (quick orientation vs. deep dive) when the developer doesn't specify

## Phase 0: Goal Clarification

**A goal is required.** The exploration needs both a *what* (the area to explore) and a *why* (what the developer is trying to accomplish by understanding it).

Good goals:
- "I need to understand the permissions model so I can make informed decisions about extending it"
- "I want to understand how auth works end-to-end so I can reason about security implications"
- "I'm about to modify the notification system and need to understand what exists before I change it"

If the input doesn't include a clear goal, ask:
> "What are you trying to accomplish by exploring this? Understanding the goal helps me focus on what matters most — e.g., are you preparing to modify this area, trying to understand it for architectural decisions, onboarding to a new part of the codebase, or something else?"

The goal shapes everything downstream — which files matter most, what level of detail to go to, which connections to highlight.

## Phase 1: Pre-Analysis (parallel subagents)

Fan out 4 subagents to build a map of the target area. Each subagent has a focused question. Run them in parallel for speed.

**Subagent 1 — File & Structure Mapping:**
> "For the area described as '{{input}}', identify: (a) the key files and directories involved, (b) the entry points — where does execution start or where would a developer start reading, (c) the major abstractions/classes/modules, (d) the directory structure and how files are organized. Report as a structured list with file:line references."

**Subagent 2 — Dependency & Flow Tracing:**
> "For the area described as '{{input}}', trace: (a) how data/control flows through the system — what calls what, (b) external dependencies — what libraries, services, or APIs does this area interact with, (c) the key interfaces/contracts between components. Report as a narrative with file:line references."

**Subagent 3 — Verification & Observability Mapping:**
> "For the area described as '{{input}}', map the verification landscape: (a) what testing strategies are used — unit tests, integration tests, system tests? What's the coverage approach and key test files? (b) are there other verification mechanisms — manual QA documented in PRs, verification rake tasks, seed scripts, conformance checks? (c) what observability exists — logging, metrics, error tracking, dashboards, health checks? (d) what's the overall verification posture — is this area well-covered, lightly tested, or untested? Report with file:line references for test files and observability code."

**Subagent 4 — PR History & Design Context:**
> "For the area described as '{{input}}', use the **code-hosting** capability to check PR history (e.g., `gh pr list` / `gh pr view` on GitHub) to find: (a) the PRs that built or significantly changed this area — read their descriptions and review comments for design rationale, (b) whether this area is stable or actively evolving, (c) any discussion in PR reviews that reveals intent, tradeoffs, or known limitations. Focus on the most informative PRs, not an exhaustive list. Brief narrative with PR references."

If no code-hosting binding is configured, fall back to `git log --oneline` and commit messages on the relevant paths for design context, and note in the briefing that PR review discussion wasn't available.

### Pre-analysis guidelines

- Each subagent should use the Explore agent type for efficient codebase navigation
- Subagents should read actual code, not just file names — comprehension requires seeing the code
- Target completion in under 30 seconds — scope the search to the relevant area, don't scan the entire codebase
- If the area is ambiguous, the first subagent should cast a wider net to identify the right scope, and later subagents can narrow
- Pass the developer's goal to each subagent so they can focus on what's relevant

## Phase 2: Briefing

Synthesize subagent findings into a briefing for the developer. The briefing has four parts:

### 2a. Orientation Diagram(s)

Generate 1-3 small focused Mermaid diagrams (3-7 nodes each) rendered via `mermaid-ascii`. Each diagram answers one question:
- "What are the main components and how do they relate?" 
- "How does a request/event flow through this area?"
- "What depends on what?"

**CRITICAL CONSTRAINT:** If you feel inclined to generate a diagram with more than 7 nodes, STOP. Break it into multiple smaller diagrams, each embedded in textual narrative with file:line code links. The narrative carries the big picture; the diagrams illustrate specific relationships within it.

To render a diagram, write the Mermaid syntax to a temp file and run:
```bash
mermaid-ascii -f /tmp/explore-diagram-N.mmd
```

Use `graph LR` for most diagrams (horizontal layout renders best in mermaid-ascii). Avoid subgraphs — they render poorly. Keep node labels short.

### 2b. Narrative Overview

A concise narrative (3-5 paragraphs) that explains:
- What this area does and why it exists
- How the pieces connect (referencing the diagrams)
- The key abstractions and what they represent
- File:line references for every component mentioned

### 2c. Verification & Observability Landscape

A dedicated section on how this area proves it works:
- Testing strategy summary — what kinds of tests exist, what they cover, key test files
- Other verification — QA processes, rake tasks, scripts, manual checks
- Observability — what's instrumented, what you can see in production
- Gaps — areas with minimal testing or observability (stated factually, not as criticism)

This section serves comprehension: understanding *how something is verified* is part of understanding *how it works*.

### 2d. Suggested Starting Point

"Given your goal of [goal], I'd suggest we start with [file:line] because [reason]. From there we can follow [path]. What would you like to explore first?"

The developer may accept this or redirect. Follow their lead.

## Phase 3: Interactive Exploration

The developer is now in the driver's seat. They ask questions, you navigate the codebase.

### How to behave during exploration

- **Read code before explaining it.** Don't describe what you think a file contains — read it and explain what's actually there.
- **Use file:line references constantly.** Every component, function, class you mention should have a location the developer can jump to.
- **Show code in neovim when a copiloted session is active.** When discussing a file, open it in neovim via nvr. Annotate key lines with brief explanations. Use vsplit to show related files side-by-side. If no session is active, show the same excerpts and annotations directly in the conversation with file:line references.
- **Generate diagrams on the fly** when they'd clarify a relationship. Same constraints — small, focused, 3-7 nodes.
- **Connect to the big picture.** When exploring a detail, relate it back to the overall structure from the briefing.
- **Surface non-obvious things.** Interesting design decisions, surprising patterns, implicit contracts between components — the things a developer would miss skimming on their own.
- **Follow the developer's curiosity.** If they want to go deep on one function, go deep. If they want to skim across a module, skim. Match their energy and depth.
- **Don't audit.** Resist the urge to point out code quality issues, potential bugs, or improvement suggestions unless the developer specifically asks. The goal is comprehension, not critique.

### When you don't know

If you encounter something you can't explain from the code alone:
- Say so honestly: "I can see this calls ExternalService.process() but I can't determine from the code what that service does — it might be worth checking [location] or asking someone who set it up."
- Don't speculate and present it as fact.

## Phase 4: Wrap-Up (when the developer signals they're done)

Briefly summarize:
- What was explored in this session
- Key takeaways — the 3-5 most important things learned
- Open questions — things that weren't fully resolved
- Suggested next explorations — areas adjacent to what was explored that might be interesting

Keep the wrap-up concise. The exploration itself was the value; the summary is just a bookmark.
