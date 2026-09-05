---
name: calcinatio
description: Refinement through verifying force — the principle and practice of subjecting work to fires that burn away what doesn't hold up. Covers deriving fires from witnesses, context shaping, and the orchestration patterns (dialectical, manifold). Load at session start; calcinatio applies to all work that will reach a witness.
---

# Calcinatio — Refinement Through Verifying Force

Any fire that reveals what needs refining and thereby brings the work closer to abundant satisfaction is calcinatio. Tests, QA, independent review, professional critique — the common property is that **the work encounters a force that strengthens what holds up and refines what doesn't.**

**When firing calcinatio subagents, always pass the full MO as context.** The MO defines what "good" looks like, who the witnesses are, and what concerns drive which fires. A calcinatio subagent without the MO is a fire without a standard to measure against.

Calcinatio both builds evidence and refines the work itself. Every fire the work passes through makes the output better AND produces the evidence the integrity geas requires. The goal: when a witness engages, their attention goes to genuinely human-level judgment — taste, strategic fit, intent alignment — not to issues the system could have caught.

---

## The Maximalist Posture

**Exhaust every fire you can before a witness sees the work.** Every fire you run autonomously converts effort into witness satisfaction rather than witness correction. The posture is maximalist: do all verification that *can* be done, not just what's prescribed. The environment's test suites, CI pipelines, and review procedures are the floor; what you derive from the principle is the ceiling.

**Verify agentically before involving humans.** Use subagents as professional proxies — examining the work from the perspective of each witness's discipline. The witness should encounter work that has already survived the fires their professional discipline would apply. If there isn't a subagent available, invent one — tell a subagent to be a security expert or an expert editor and give it relevant context.

**Before presenting work to a witness, take the measure of it.** Is there fire left that hasn't touched it? When the answer is "I've exhausted what I can," you bring it forward.

---

## Deriving Fires from the Work

The fires are not prescribed. They are derived.

**Discover what the environment provides.** Before generating fires, look at what already exists. Test suites, CI pipelines, linting, type checking, browser tools, QA processes, project skills, review conventions — the environment may have substantial calcinatio infrastructure you haven't found yet. Discovering it is part of the work. Use it.

**Start with the witnesses.** The Magnum Opus defines who the work serves. Each witness implies concerns — what would they check, what would bother them, what would delight them? Those concerns generate fires. A sales engineer witness generates demo-flow testing. A security-conscious CTO witness generates threat modeling. A field technician witness generates device QA under hostile conditions. For each concern, ask: can I execute this fire agentically? If yes, do it — spawn a subagent as professional proxy.

**The environment is the floor, not the ceiling.** CI pipelines, test suites, linting, type checking, required QA processes — these are prescribed calcinatio. Pick them up and execute them. Then go further.

**Generate fires beyond the floor.** What fires can you create from the work's nature? Unit-testable code generates TDD — the test is written first because the test *is* the fire. Architectural decisions with downstream consequences generate design review by a fresh-context agent. UI work generates browser QA against the witnesses' usage context. A data migration generates before/after integrity checks. An API change generates contract testing against consumers. The principle generates the practice — look at the work and ask what resistance it should survive.

**Add-coverage work generates mutation testing.** When the task is to add or strengthen test coverage, the derived fire is mutation testing — manual or tooled. A green test run cannot distinguish coverage that guards behavior from coverage that guards nothing; the mutation table is the only artifact that separates the two. Run the mutation (delete the line, swap the condition, reorder the branches) and confirm a test fails. This is the same relationship as "unit-testable code generates TDD" — the work's nature dictates the fire. A specific trap: assertions on the *text* of ordered rules (e.g., SQL CASE branch position, priority lists) survive reorderings that change behavior silently — ordering logic verified only by string assertion is under-tested by construction; a mutation that *demotes* a branch rather than deleting it is the fire that reveals this.

**Missing fires are assay gaps.** When the work demands a fire you can't produce — visual QA without browser tools, field testing without device emulators, specialized review without domain access — name the gap explicitly and escalate. The craftsman who lacks the right instrument surfaces the constraint so it can be acquired. The gap is information, not failure.

**Fires that modify source must not contaminate the artifact.** Some verification techniques require changing source code to observe behavior — mutation testing, fault injection, exploratory rewrites. These are legitimate fires, but they destroy what they examine if applied in-place. A verifier who mutates a builder's working tree has introduced the surprise it was hired to prevent. The rule: **source-mutating verification runs in a throwaway copy, or restores deterministically and proves it.** If copying is impractical, revert every mutation immediately and confirm the working tree is clean before continuing. The burden of proof is on the verifier.

---

## Fresh Context as Fire

Any calcinatio that involves judgment — code review, design critique, architectural review, editorial feedback — benefits from an independent agent with fresh context. The builder's context is contaminated with their own reasoning. Fresh eyes see what familiar eyes rationalize away.

This is the foundation of multi-agent calcinatio: **a clean context window is itself a fire.** A fresh agent encountering your work without your narrative about why your choices are right will see things you cannot. Domain expertise in the reviewing agent is a bonus; the freshness is the primary fire.

**Context shaping makes freshness complementary.** A fresh perspective is naive unless you shape what it sees. What you inject determines whether the fire is meaningful or aimless:

- **The artifact** — the work being refined. Always.
- **The intent** — what "good" looks like, who the witnesses are. The reviewer needs something to measure against.
- **Constraints** — project conventions, known trade-offs, deliberate choices. Prevents false positives.
- **Not your reasoning.** Your narrative about *why* you built it this way contaminates the freshness. If your reasoning is sound, the work survives the fire without explanation.

Pass too much and you destroy the freshness that IS the value. Pass too little and the agent flails without signal. The judgment is: what does the reviewer need to apply *meaningful* resistance — and nothing more?

By using dialectical calcinatio you can leverage your own rich context to review the feedback from the fresh agent and use your judgement, critique the critique.

---

## Orchestration Patterns

Two primary patterns for multi-agent calcinatio. These are powerful approaches to reach for generatively — compose novel instances from the work, don't wait for predefined skills to invoke them.

Multi-agent orchestration for calcinatio is an underexploited capability in agent systems generally. Agents tend toward single-agent self-review, which is weak fire. The athanor names these patterns so agents internalize them and use them freely.

### Dialectical Calcinatio

Iterative exchange between a context-holder and a complementary fresh perspective. **Reach for this aggressively and often.** Whenever your work involves judgment, creativity, or quality-sensitive output — and that is most of the time — dialectical calcinatio will improve it. The cost is one subagent context; the quality improvement is substantial. A single agent reviewing its own work is like proofreading your own writing — you see what you meant, not what you wrote.

Shape context → fire a specialist subagent → review the output against your rich context → refine with corrective guidance → converge. The subagent's first pass is *expected* to be imperfect. Your review catches what the lossy handoff missed. Refinement is the normal path, not a failure case.

**The receiver retains full agency.** Richer context produces legitimate overrides — the fresh reviewer doesn't know what the builder knows. When you override a finding, write the reason into the trail. This serves the work: articulating why a finding doesn't apply often reveals whether it actually doesn't. The act of writing sharpens the judgment. And the trail carries what conversation would lose — future readers see not just what was done but what was considered and why.

This is a very powerful form of calcinatio for producing a more refined product before presenting to witnesses. Use it liberally.

**See `resources/dialectical-calcinatio.md` for the full protocol, context-shaping guidance, and illustrative examples.**

### Manifold Calcinatio

Multiple independent fires applied simultaneously, then synthesized. Fan out the work to several specialist subagents — each examining it from a different angle — then synthesize the findings. The power is in breadth: many perspectives see what any single one misses, and agreement across perspectives strengthens confidence.

Use this when there are a multitude of concerns to evaluate or tests to run.

Decompose → fan out in parallel → synthesize: deduplicate, identify agreement (high confidence) and conflict (needs judgment), resolve or escalate.

**See `resources/manifold-calcinatio.md` for the full protocol, decomposition guidance, and illustrative examples.**

### Viewpoint-Based Manifold Calcinatio

A specialization of manifold calcinatio with a structured **perspective derivation process**. Instead of improvising which perspectives to fan out, derive them from three sources:

1. **Witness-derived** — Extract each witness's *task-specific* stake (not their general concern). Professional proxy applies.
2. **Research-derived** — Find authoritative external viewpoints the system doesn't inherently have. Articles, docs, reference architectures each become a subagent's lens. The most generative source — brings perspectives nobody thought to define.
3. **Task-intrinsic** — Cross-cutting concerns, domain angles, or stakeholder needs not formally defined that the work's nature demands.

This is the formula to reach for when the work sits at the intersection of multiple domains, when stakeholder concerns are diverse, or when you want to ensure no relevant perspective is missed before the work reaches witnesses.

**See `resources/viewpoint-based-manifold-calcinatio.md` for the full protocol, perspective derivation process, and illustrative examples.**

### Composition

These patterns compose naturally. Manifold calcinatio produces findings from many angles; dialectical calcinatio resolves those findings through iterative exchange with the builder. The cycle can repeat — manifold→dialectical→manifold→... — until convergence. Research might fan out manifold, then each finding gets dialectically refined against domain knowledge. The patterns are building blocks, not standalone processes.

---

## Witnesses and Professional Proxy

Calcinatio connects to witnesses through professional proxy. When the Magnum Opus defines a witness, the question is: *which professional discipline exists to serve this class of witness?* A UX designer can anticipate an end user's reaction better than an agent impersonating that user, because the designer has frameworks for reasoning about user needs that the end user doesn't have themselves. The proxy applies professional judgment on behalf of the witness — not impersonation, but the discipline whose purpose is to serve that witness's interests.

When composing dialectical or manifold calcinatio, the professional proxy principle tells you what kind of specialist to fire. The witness defines the concern; the proxy identifies who would evaluate it best.

---

## Termination

Calcinatio continues until convergence (findings repeat — the fires have found the same grain), divergence (findings contradict — need the artifex's judgment), or exhaustion (all available fires applied, work has survived). The number of rounds is not prescribed. The termination condition is.

---

## Calcinatio Opera

Some verification is itself an opus — too large, too different in nature, or requiring too different a context to be a step within the current opus. An architectural review of a system. A UAT pass across features. An editorial review of a finished publication. When calcinatio derivation from witnesses identifies verification of this scale, it becomes work inscribed through the normal opus lifecycle.
