---
name: handoff
description: Create handoff documents for tightly scoped implementation tasks sized to fit in a single Claude Code context window (target 50-60% max context). Handoffs embed core mandates, verification loops, and spec context so they can be passed to dedicated short-lived subagents that implement the task and exit. Designed for subagent dispatch (pass handoff as prompt to a Task tool subagent).
capabilities:
  uses:
    - project-conventions
---

# Handoff — Task Context Briefing Creator

Create self-contained handoff documents that brief a competent implementing agent on **what** to build and **where** to look — never **how** to build it. Each handoff is sized for a single Claude Code context window (target: 50-60% max context).

Handoffs embed core mandates directly (injection in depth). Practice skills are referenced as mandatory loads for the implementer.

**The architect loads this skill and writes handoffs directly.** There is no separate "handoff writer" agent — the agent with the deepest codebase understanding writes the briefing.

**Workflow:** `/spec` → `/taskout` → **`/handoff`** (architect writes) → subagent dispatch (via Task tool)

## Usage

```
/handoff <task-reference-or-description>
```

**Examples:**
- `/handoff @specs/project/TASKS.md task 1.1` — Single task from TASKS.md
- `/handoff @specs/project/TASKS.md task 1.1 1.2 1.3` — Multiple tasks in parallel
- `/handoff implement user authentication service` — Freeform description
- `/handoff @specs/project/tasks.md T001-T003` — Task range

## Input Modes

### Mode A: Task File Reference (Preferred)
- **Pattern:** `@<file-path> task <task-numbers>`
- Extract file path and task numbers, spawn parallel subagents

### Mode B: Freeform Description
- **Pattern:** Any text without `@` or `task` keyword
- Process directly in main conversation

### Mode C: Task Range
- **Pattern:** `@<file-path> T001-T003`
- Parse range, extract tasks, spawn parallel subagents

## Content Boundary: What Belongs in a Handoff

A handoff orients, constrains, and equips. It does NOT instruct.

**Include** if the implementer can't determine it from reading the code alone:
- Behavioral requirements from the spec
- File paths and codebase orientation
- Success criteria (observable, testable behaviors)
- Verification commands
- Mandatory skill references
- Out-of-scope boundaries

**Exclude** if the implementer can determine it by reading the code:
- Internal method structure, class/file organization
- Test implementation details, migration syntax
- Refactoring decisions, where to put scopes/concerns/helpers

**The Delete Test:** For every section, ask: "If I deleted this, would the implementer produce a worse result?" If no, delete it.

| Handoff says | Verdict |
|---|---|
| "Add `archived` boolean column" | GOOD — behavioral requirement from spec |
| "See `app/models/article.rb` lines 29-43 for existing scopes" | GOOD — codebase orientation |
| "Run `bundle exec rspec spec/models/`" | GOOD — verification command |
| "`scope :archived, -> { where(archived: true) }`" | BAD — implementation code |
| "`class AddArchived < ActiveRecord::Migration[7.2]`..." | BAD — implementer writes this |
| Full step-by-step instructions | BAD — over-specification |

**QA Expectations:** When a task has verification needs beyond automated tests (UI changes, API endpoints, background jobs, data model changes, console-verifiable logic), populate the `## QA Expectations` section. Tag scenarios with tool hints: `[browser]`, `[console]`, `[API]`, `[async]`, `[DB]`, `[logs]`. Not required for every handoff — only when automated tests alone won't fully verify the change. The verifier uses these to cross-check QA coverage and classify items as `[TEST]`, `[AUTOMATABLE]` (Claude can execute), or `[HUMAN]` (requires user action).

**UI tasks — visual verification is mandatory, never deferrable:** If the task touches any UI component or screen, the QA Expectations section MUST include a `[visual]` verification item. The phrase "visual review deferred to UAT" or any equivalent is a handoff defect — reject it. The implementer owns visual verification on device or emulator before handoff is complete. The project skill (e.g. `react-native-expo`) defines the specific tool and protocol.

## Process

### Step 1: Parse Arguments & Detect Mode

Parse `$ARGUMENTS` to determine which input mode applies.

### Step 2: Read Prerequisites (Mode A/C)

Before creating any handoff:

1. Read the tasks file to extract task details
2. Check for "Prerequisites" or "Input" section in the file header
3. Read ALL listed prerequisite documents (plan.md, research.md, data-model.md, contracts/, etc.)
4. Extract spec context using the hybrid approach (Step 3)

**If prerequisites are missing:** STOP and report which files are missing.

### Step 3: Extract Spec Context

Extract task-relevant excerpts from spec docs. **Limit: 100 lines max per spec document.**

**Priority order:**
1. **Line references** from tasks.md (e.g., `**Ref:** spec:195-226`) — extract those lines directly
2. **Section header matching** — match task keywords to spec section headers
3. **Keyword context** (fallback) — grep for key terms with surrounding context

### Step 4: Code Discovery & Reuse Mapping (Optional but HIGH VALUE)

For coding tasks, invoke an Explore agent to find existing implementations:
- Services/classes doing similar things
- Utilities/helpers providing needed functionality
- Similar features and test patterns

**DRY-critical discovery (LLM duplication bias mitigation):**
LLMs have a strong tendency to copy-paste existing logic rather than calling it. The
handoff MUST explicitly surface reusable code so the implementer calls it instead of
reimplementing it. For each discovered existing implementation, note it in
`{REUSABLE_RESOURCES}` with the specific file:line and a directive like
"Call this, do not reimplement" or "Extend this class, do not create a parallel one."

If the task involves preview/dry-run modes, **flag this explicitly**: the
implementation MUST call the production code path, not duplicate it.

If agent fails or times out, continue without.

### Step 5: Discover Relevant Skills (MANDATORY)

Invoke `/skill-discovery` via the Skill tool. It scans the installed skill catalog, evaluates relevance to the task's technology and domain, and outputs reasoning.

Add the discovered skills to the handoff's "Skills to Load" section.

**Mandatory skill for UI tasks:** If the task touches any UI component or screen, check `resources/domain-skill.md` for a project-designated visual-verification skill (e.g., `react-native-expo` for a React Native project) and include it regardless of other skill selections — this is not optional. If no domain plugin is configured, flag the gap in the handoff's "Skills to Load" section and instruct the implementer to identify and load the stack-appropriate visual verification skill before treating the UI portion as complete.

**Template language:** The Skills to Load section tells the implementer to invoke each skill via the Skill tool (not `/skillname` which is user shorthand).

**Also check `resources/domain-skill.md`** if it exists for project-specific always-on skills.

### Step 6: Compose Handoff (Two-Write Strategy)

**CRITICAL: The template must be copied verbatim, then placeholders replaced mechanically.**

LLMs do not reliably reproduce text verbatim. To prevent core mandates drift:

**Write 1 — Copy template to handoff path:**
1. Read the handoff skill's `templates/core.md`
2. Write its ENTIRE contents to the handoff save path using the Write tool
3. Do NOT modify anything — pure copy

**Write 2 — Replace placeholders with Edit tool:**
Use the Edit tool to replace each `{PLACEHOLDER}` with its actual value:
- `{TASK_ID}`, `{TASK_GOAL}`, `{STATUS}`, `{TASK_TYPE}`
- `{DISCOVERY_COMMANDS}`, `{STATUS_COMMANDS}`, `{REUSABLE_RESOURCES}`
- `{SPEC_CONTEXT}` — extracted spec excerpts from Step 3
- `{SKILLS_TO_LOAD}` — from Step 5, formatted as mandatory loads
- `{CRITERION_N}` — behavioral success criteria (no method/class names)
- `{TARGETED_VERIFICATION}`, `{INTEGRATION_VERIFICATION}`, `{E2E_VERIFICATION}`

Leave Completion section placeholders for the implementer to fill.

**Content quality gate:** Before writing, verify every section passes the Delete Test. If a section contains implementation code or step-by-step instructions, rewrite it as behavioral requirements or codebase orientation.

3. Validate against `templates/validation.md`

### Step 7: Save Handoff

**Save location detection:**
1. If project has `specs/` structure: the project's handoff directory (default `<specs-dir>/{project}/handoffs/`), overridable in `domain-skill.md`: `<specs-dir>/{project}/handoffs/{TASK_ID}-{slug}.md`
2. If in project root without specs: `specs/tasks/{TASK_ID}-{slug}.md`
3. Fallback: `./{TASK_ID}-{slug}.md`

Domain-skill may override save location conventions.

### Step 8: Report

Report to user:
- File path created
- Skills referenced (from Step 5)
- Spec context extracted (line counts)
- Next steps for implementer

## Multi-Task Mode (Mode A/C)

When multiple tasks are requested, spawn **parallel Task tool subagents** — one per task. Each subagent does the **mechanical template assembly** only (Write 1 + Write 2).

**The architect (main agent) makes all content decisions:**
1. Read the tasks file and spec docs, extract context
2. Run skill discovery once (applies to all tasks)
3. Determine behavioral requirements and orientation for each task
4. Pass complete content to each subagent for mechanical assembly

**Subagent prompt must include:**
- Full text of the two-write strategy (Step 6)
- Pre-determined content for all placeholders
- The validation checklist

**Use parallel tool calls** — invoke ALL Task tools in a single message.

## Project and User Configuration

Domain and personal plugin files supply the **project-conventions** capability —
project-specific and individual context for handoff composition: skills that
always apply to this project (including the project-designated visual-verification
skill Step 5 requires for UI tasks), project test commands and conventions, save
location conventions, and technology stack details, layered with personal
customizations. If no binding exists, this workflow's own defaults carry the
gap: `/skill-discovery` (Step 5) selects skills fresh each time, the Step 7
save-location cascade applies, and codebase inspection during Step 4 substitutes
for pre-declared tech stack details.

Load configuration in this order. **When multiple sources define the same binding,
the first one found wins** — stop checking lower sources for that binding:

1. Read `resources/personal-skill.md` if it exists — personal tool bindings and preferences.
2. Read `resources/domain-skill.md` if it exists — project-specific configuration.
3. Check the project's CLAUDE.md / CLAUDE.local.md for environment-level capability bindings.
4. For any capability still unbound, use the defaults specified in this skill.

## Extension Points

### domain-skill.md
Provide project-specific handoff configuration:
- Skills that always apply to this project's handoffs — in particular, the
  project-designated visual-verification skill for UI tasks (e.g.
  `react-native-expo` for a React Native project), which Step 5 requires
  regardless of `/skill-discovery` output
- Project test commands and conventions, for populating
  `{TARGETED_VERIFICATION}`, `{INTEGRATION_VERIFICATION}`, `{E2E_VERIFICATION}`
- Save location conventions, where they differ from the Step 7 default cascade
  (the project's handoff directory — default `<specs-dir>/{project}/handoffs/`,
  overridable in `domain-skill.md` — `specs/tasks/`, or `./`)
- Technology stack details that orient the implementer without requiring a
  fresh Explore pass every time (frameworks, key directories, build tooling)

### personal-skill.md
Provide individual handoff-authoring preferences:
- Preferred level of detail in codebase orientation and `{SPEC_CONTEXT}` excerpts
- Personal conventions for structuring `{REUSABLE_RESOURCES}` notes
- Any personal skill-loading habits to fold into "Skills to Load" alongside
  `/skill-discovery` output

## Interoperates With

- **skill-discovery** — invoked in Step 5 to select practice skills for the "Skills to Load" section.
- **code-review** — the template's Refactor Gate runs it after tests pass.
- **spec**, **taskout** — typically upstream in the pipeline (`/spec` → `/taskout` → `/handoff`); handoff reads their output documents but doesn't invoke them directly.

## Design: What's Embedded vs. Referenced

**Embedded in the handoff (injection in depth):**
- Core mandates — all 9 constraint sections + operational protocols
- Task-specific content — spec context, codebase orientation, success criteria
- Verification loops with specific commands

**Referenced as skills (loaded by implementing agent):**
- Practice guidance — TDD workflow, API patterns, testing strategy, etc.
- The handoff says *which* skills to load; the skills say *how* to work

## File Reference

```
templates/
├── core.md               # Complete handoff template with core mandates embedded
└── validation.md         # Pre-save validation checklist
resources/
├── domain-skill-template.md    # Template for project-specific plugin
└── personal-skill-template.md  # Template for personal plugin
```
