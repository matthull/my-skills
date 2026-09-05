---
name: coding
description: >
  Structural protocol for code changes — mandatory TeamCreate, task-lead/implementer
  pattern, TDD cycle, verification floor. Loaded via /skill-discovery when the opus
  involves modifying code files. Makes verification structural rather than behavioral
  so builder context cannot rationalize past it.
---

# Coding — Structural Protocol for Code Changes

> **DEPRECATED:** This skill is superseded by the `coder` job (`shared/jobs/coder/JOB.md`). The job system replaces TeamCreate with inscription-as-spawning, and replaces process-heavy gates with perspective-driven identity. If you have `job: coder` in your opus, follow the job — not this skill. If you're a general-purpose azer doing code work, read the coder job for guidance or inscribe a coder azer.

**You loaded this skill because your opus involves code changes.** Writing excellent code and objectively verifying it are different disciplines that benefit from different perspectives — like how an author needs an editor, not because the writing is bad, but because fresh eyes see what immersed eyes can't. Everything below encodes that understanding into the workflow so you don't have to reconstruct it each time.

## TeamCreate Mandate

**Code changes = TeamCreate. Always. No threshold, no judgment call.**

Create a team immediately — before any code work begins. You are now the **task-lead**. Team members are **implementers**. This separation is the point: you hold the plan and verification responsibility with clean context; they do the building.

- Create the team now, before any code work begins — the value of the task-lead/implementer separation compounds from the first task, not just when things get complex.
- Keep the team live until verification is complete and you're ready to discharge — that's the full arc of the work.
- Your operational plan (TaskCreate in the default list) tracks what needs to happen. The team's task list tracks implementation work. These are separate namespaces — that's fine.

**On resistance.** Delegation may feel like overhead — the impulse to "just do it myself" is strong. Recognize that impulse as the craftsman's eagerness to build, which is good energy, but channel it: your creative contribution as task-lead is in the plan, the brief, the synthesis, and the judgment calls. The implementer gets to build with full creative latitude; you get to ensure the result is something you're proud to ship. Both roles are creative work.

## Task-Lead Discipline

While the team exists, you are the task-lead. Your job:

- **Plan** — decompose the work, decide what to delegate, track progress via TaskCreate
- **Brief** — write clear implementer briefs (see below)
- **Verify** — review results from clean context, run verification checks, approve or send back
- **Steer** — adjust the plan as you learn, re-prioritize, handle blockers

**Your leverage is in holding the plan and clean verification context.** The implementer reads the source, writes the code, debugs the details — that's where their full attention belongs. You stay upstream: the plan, the brief, the synthesis, the judgment calls on what matters.

Reading a test output summary or a short error message to decide next steps is fine. For implementation details, fresh-perspective review adds the most value — let the implementer and the review subagent carry that context.

### Task Decomposition — Small, Focused, Parallel

**Each implementer task should be one focused change.** A fresh context window is an asset, not a limitation — an implementer starting clean sees the code without accumulated assumptions. Don't stack 6 tasks on one implementer and burn through their context; send 6 brief tasks to separate implementers (or the same one sequentially, getting a fresh window each time).

**Group by shared context.** Tasks that touch the same files or need the same understanding belong together. Tasks that are independent get separate implementers — they can run in parallel, each with full context budget for their focused scope.

**Size for fresh context.** If a task would push an implementer past ~50% context, it's too big. Split it. The overhead of briefing a new implementer is trivial compared to the quality degradation of an exhausted context window. You get better code from three focused implementers than from one overloaded one.

## TDD Cycle: Red → Green → Refactor

Implementers follow this cycle. Include it in their briefs.

**Red — know what success looks like.** Define the empirical check before writing the implementation. A failing test is ideal (proves the test actually tests something). But the principle is broader: console output, curl against an API, browser observation — all valid. The medium doesn't matter. What matters: a concrete, observable expectation exists before the code is written.

**Green — make it pass.** Write the minimum implementation that satisfies the empirical check. Run it. Observe the result. This is the tightest feedback loop between intent and evidence.

**Refactor — dialectical calcinatio with a fresh perspective.** The implementer's deep immersion in the build is what enables excellent implementation — it's also why they benefit from an outside view for review. Spawn a code review subagent via dialectical calcinatio. Use the environment's code review skill or guidelines if available; define ad-hoc review criteria if not.

**Maintain an empirical loop throughout.** Observe the code working before committing it — the specific mechanism depends on the environment. Project CLAUDE.md and domain skills define what's available.

**Review before commit** — this is where calcinatio closes the loop. Code that passes tests is promising; code that's also been through independent eyes is finished. The review elevates the result from working to ship-worthy.

## Implementer Briefing

When delegating to a team member, the brief covers four things:

1. **WHAT to build** — behavioral requirements, not implementation steps. "The token refresh endpoint returns a new access token when given a valid refresh token" not "create a method called refreshToken that calls..."
2. **WHERE to look** — file paths, codebase orientation, existing patterns to follow. "See `internal/auth/token.go` for the existing token generation pattern."
3. **HOW to verify** — specific test commands, lint commands, empirical checks. "Run `make check`. Verify with `curl -X POST /auth/refresh`."
4. **WHICH skills to load** — by Skill tool invocation, not advisory. "Invoke `/go-cli` using the Skill tool before starting." "Invoke `/unit-testing` using the Skill tool."

**The delete test:** For every section of the brief, ask: "Would the implementer produce worse results without this?" If no, delete it. Don't over-specify HOW — that's the implementer's judgment. A brief that reads like step-by-step instructions is over-specified.

## Verification Floor

Verification is calcinatio — the fires that reveal what's strong and refine what isn't. Running these checks is how the craftsman's pride expresses itself: the work that passes them cleanly is work worth shipping. These are the minimum fires before code work is considered verified. Domain skills loaded by the implementer may add more (e.g., /ui adds browser observation, /go-cli adds `make check`).

- **Tests pass** — the project's test command runs clean
- **Lint clean** — the project's lint/format command runs clean
- **Code review** — dialectical calcinatio with a fresh review agent (not the implementer, not you). The reviewer gets the diff, the intent, and any relevant constraints — but NOT the implementer's reasoning about why they built it this way. Fresh perspective is the point.
- **CLAUDE.md mandatory gates** — check the project's CLAUDE.md for unconditional verification requirements triggered by the files you changed. These are non-negotiable and cannot be waived by blast-radius assessment — only the operator can override them. Example: CLAUDE.md may require browser QA (Ranger) for any change touching `app/javascript/`, regardless of whether the change has visual impact. If a CLAUDE.md gate applies, run it. If you cannot run it, escalate — do not self-authorize a skip.

If any check fails: fix and re-verify. These are the fires that strengthen the work — passing them cleanly is part of the craft.

## Post-Implementation Verification Expansion

The verification floor above covers the fires you planned before implementation. But implementation reveals blast radius that planning couldn't predict — an implementer may restructure an API endpoint, touch a shared serializer, modify a configuration surface, or change files in domains you didn't anticipate. **What was actually changed may require fires beyond what you planned.**

After the verification floor passes and before declaring the work verified, run a verification expansion:

1. **Review the actual diff** — not your plan, the concrete changes. What files were touched? What domains do they belong to? What downstream systems consume them?
2. **Re-check skill discovery against what changed.** The files that were modified may trigger domain skills that weren't relevant to the original opus scope. A task scoped as "add analytics properties" may have touched an API serializer — that's a different blast radius than "analytics" suggests. Run `/skill-discovery` if the changed files span domains you didn't load skills for.
3. **Derive fires from the blast radius AND check CLAUDE.md for rule-based gates.** Two sources of mandatory fires exist here and both must be checked:
   - *Derived fires:* For each area of change, ask: "What could break if this change is wrong, and how would I detect it?" If domain skills prescribe verification for these areas, those fires are mandatory.
   - *Rule-based gates:* Check the project's CLAUDE.md for unconditional verification requirements triggered by file paths (e.g., "any change to `app/javascript/` requires Ranger QA"). These gates are **not subject to blast-radius reasoning** — they fire on file path match, not on assessed risk. An azer that concludes "blast radius is low, so browser QA is unnecessary" has answered the wrong question when a CLAUDE.md rule says the gate is unconditional. If a rule-based gate applies but you judge it genuinely inapplicable, escalate for an operator waiver — do not self-authorize a skip.

**This step exists because planning-time verification and implementation-time verification answer different questions.** Planning asks "given my intent, what fires do I need?" Expansion asks "given what actually changed, what fires does the blast radius require?" The gap between these two is where outages live.

A fresh-context subagent is ideal for this step — it sees the diff without the builder's accumulated assumptions about what's "safe." Shape context: pass the diff, the loaded skills' verification requirements, and the project's CLAUDE.md verification rules. The subagent's question: *"Given what was actually changed, what additional verification is needed beyond tests, lint, and code review?"*
