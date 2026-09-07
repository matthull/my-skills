# My Claude Skills

This repo holds various Claude skills I've developed over the past year.

There are a number of software development skills, but also some for other domains like project management and personal assistant.

## Plugin Architecture

These skills use a natural language dependency inversion system. I came up with this to facilitate using the same skills across projects or teams.

| Layer | File | What it provides |
|-------|------|-----------------|
| **Core** | `SKILL.md` | Universal logic |
| **Domain** | `resources/domain-skill.md` | Project-specific bindings (test commands, CI system, conventions) |
| **Personal** | `resources/personal-skill.md` | User preferences (notification channel, autonomy level) |

See [docs/plugin-architecture.md](docs/plugin-architecture.md) for the full spec.

## Skill Catalog

42 skills, under `skills/<category>/<skill-name>/SKILL.md`.

### Technical — 20

Software development: languages, frameworks, databases, review, and tooling.

| Skill | What it does |
|---|---|
| [`bash-scripts`](skills/technical/bash-scripts/) | Shell scripting safety patterns, bats-core TDD, Docker execution, idempotency |
| [`code-review`](skills/technical/code-review/) | Structured review with parallel specialist agents, each in a fresh subagent context |
| [`davinci-resolve`](skills/technical/davinci-resolve/) | Edit OBS recordings into screencasts in DaVinci Resolve 20 — speed ramping, voiceover, captions, export |
| [`disk-cleanup`](skills/technical/disk-cleanup/) | Analyze disk usage and clear package/container caches on an Arch Linux workstation |
| [`fastmcp-python`](skills/technical/fastmcp-python/) | Build FastMCP/Python MCP servers — tool design, naming conventions, pytest, sidecar E2E testing |
| [`go-cli`](skills/technical/go-cli/) | Go CLI patterns — testing strategy, argument parsing, error handling, concurrency, quality gates |
| [`markdown-to-pdf`](skills/technical/markdown-to-pdf/) | Convert markdown to formatted PDFs with dark mode and ASCII diagram support |
| [`pr-create`](skills/technical/pr-create/) | Create or update a PR with a structured description — blast radius, test plan, risks |
| [`qa-plan`](skills/technical/qa-plan/) | QA strategy and test matrices, PR-scoped or feature-scoped, with gap detection |
| [`rca`](skills/technical/rca/) | Root cause analysis — systematic evidence gathering before diagnosis, no jumping to conclusions |
| [`react-native-best-practices`](skills/technical/react-native-best-practices/) | React Native performance — FPS, TTI, bundle size, memory leaks, re-renders, animations. *Vendored from Callstack, MIT* |
| [`ruby-rails`](skills/technical/ruby-rails/) | Rails patterns — fixture builder, RSpec organization, migrations, console verification |
| [`skill-creator`](skills/technical/skill-creator/) | Create, adapt, and audit skills that conform to the plugin architecture |
| [`spec-check`](skills/technical/spec-check/) | Compare every spec requirement against the implementation diff, with file:line evidence |
| [`supabase-migrations`](skills/technical/supabase-migrations/) | Idempotent Supabase migration patterns — tables, functions, RLS policies, triggers, indexes |
| [`supabase-postgres-best-practices`](skills/technical/supabase-postgres-best-practices/) | Postgres rules across 8 categories — query plans, connection management, indexing, schema design. *Vendored from Supabase, MIT* |
| [`supabase-sql`](skills/technical/supabase-sql/) | Supabase application logic — RLS policies, auth hooks, triggers, pgTAP testing |
| [`testing`](skills/technical/testing/) | Test scenarios, coverage analysis, quality standards, and the test-failure stop protocol |
| [`ui-state-management`](skills/technical/ui-state-management/) | Zustand + MMKV for ephemeral, local-only UI state that doesn't sync between devices |
| [`waydroid-adb`](skills/technical/waydroid-adb/) | Drive the Waydroid Android emulator over ADB for Expo/React Native verification |

### Workflow — 16

How work gets planned, verified, researched, and driven — mostly language- and domain-agnostic.

| Skill | What it does |
|---|---|
| [`calcinatio`](skills/workflow/calcinatio/) | Subject work to verifying fires derived from its witnesses — the refinement framework other skills build on |
| [`citations`](skills/workflow/citations/) | Standard citation format for source traceability — referenced by other skills, not invoked directly |
| [`explore`](skills/workflow/explore/) | Guided interactive walkthrough of a codebase area, for comprehension rather than audit |
| [`manual-qa`](skills/workflow/manual-qa/) | Verify features end-to-end via tools before deferring to human UAT |
| [`nvim-copilot`](skills/workflow/nvim-copilot/) | Drive a side-by-side neovim instance as a presentation surface for code |
| [`orchestrate`](skills/workflow/orchestrate/) | Plan and run multi-step work through composable modes, completion criteria, and delegation |
| [`orthogonal-emanation`](skills/workflow/orthogonal-emanation/) | Generate maximally independent candidates to escape mode collapse before converging |
| [`product-intent-signal-extraction`](skills/workflow/product-intent-signal-extraction/) | Turn transcripts and brain dumps into a structured product signal map — runs as a subagent |
| [`project-management-signal-extraction`](skills/workflow/project-management-signal-extraction/) | Turn stand-ups and async updates into a structured PM signal map — runs as a subagent |
| [`request-research`](skills/workflow/request-research/) | Write portable research request documents any research agent can pick up |
| [`research`](skills/workflow/research/) | Deep research with parallel subagents, automatic citations, and chain-of-evidence footnotes |
| [`skill-discovery`](skills/workflow/skill-discovery/) | Scan the installed skill catalog, match against the current task, load what's relevant |
| [`slack-thread-triage`](skills/workflow/slack-thread-triage/) | Classify Slack threads by action type and tag them with emoji reactions, skipping ones already tagged |
| [`spec`](skills/workflow/spec/) | Create or update feature specs with brownfield-first discovery and traceability tags |
| [`tmux-sidecar`](skills/workflow/tmux-sidecar/) | Run REPLs, consoles, and log tails in a secondary tmux pane while driving from the main session |
| [`youtube-transcribe`](skills/workflow/youtube-transcribe/) | Transcribe a YouTube video and act on the transcript — summarize, analyze, extract quotes |

### Collaboration — 4

Working with other agents and with other people.

| Skill | What it does |
|---|---|
| [`direct-handoff`](skills/collaboration/direct-handoff/) | Hand the current task to a fresh Claude session in a sidecar pane when context gets heavy |
| [`handoff`](skills/collaboration/handoff/) | Write self-contained handoff docs sized to fit one context window, for subagent dispatch |
| [`nt-comms`](skills/collaboration/nt-comms/) | Review sensitive work messages against common workplace norms before sending |
| [`threads`](skills/collaboration/threads/) | Track questions, ideas, decisions, and agreements across multi-threaded exploratory conversations |

### Personal Assistant — 2

Life admin.

| Skill | What it does |
|---|---|
| [`meal-planning`](skills/personal-assistant/meal-planning/) | Meal plans, recipe extraction, and ADHD-friendly shopping lists |
| [`resume-workflow`](skills/personal-assistant/resume-workflow/) | Generate and manage resumes in JSON Resume format, with theming and PDF output |

### Adding a Skill

Use [`skill-creator`](skills/technical/skill-creator/). Add the new skill to the table above, bump its category count, and bump the total on the first line of this section.
