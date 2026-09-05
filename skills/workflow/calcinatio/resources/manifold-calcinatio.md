# Manifold Calcinatio — Full Protocol

Multiple independent fires applied simultaneously, then synthesized. The most powerful pattern for breadth and coverage.

---

## Why This Works

A single perspective — no matter how expert — has blind spots inherent to its discipline. A security reviewer doesn't see performance implications. A performance specialist doesn't see UX friction. A domain expert doesn't see architectural debt. Manifold calcinatio applies multiple lenses simultaneously, and the synthesis reveals what no single lens could.

**Agreement strengthens confidence.** When three independent specialists flag the same issue from different angles, that finding is high-confidence. When only one specialist sees a problem, it may be a false positive or a genuine insight the others missed — both are worth investigating.

**Conflict reveals judgment calls.** When specialists contradict each other — "this is too complex" vs. "this needs more structure" — that's a signal that the artifex's judgment is needed, or that a deeper investigation would resolve the tension.

---

## The Protocol

```
1. DECOMPOSE
   - What independent perspectives would reveal different things about
     the work?
   - Derive from the witnesses: each witness's concerns suggest a
     professional discipline that would evaluate them
   - Don't just list "obvious" perspectives — think about what the
     work's specific nature demands

2. FAN OUT
   - Fire multiple specialist subagents in parallel
   - Each gets: the artifact + the intent + a focused lens
     ("evaluate this from a security perspective," "evaluate the
     performance implications," "assess readability for a junior
     developer joining the team")
   - Each works independently — they don't see each other's output
   - Use sonnet for specialists unless the review genuinely requires
     opus-level reasoning

3. SYNTHESIZE
   - Collect all findings
   - Deduplicate — same issue seen from different angles
   - Identify agreement (high confidence) vs. conflict (needs judgment)
   - Prioritize: which findings would most affect witness satisfaction?
   - Resolve what you can; escalate genuine conflicts
```

---

## Decomposition — The Art

The quality of manifold calcinatio depends on which perspectives you choose. This is where witness analysis pays off.

**Derive from witnesses, not from habit.** Don't always fire the same five review legs. Ask: for this specific work and these specific witnesses, which perspectives would reveal the most? A CLI tool might need correctness + ergonomics + documentation clarity. A data pipeline might need correctness + performance + failure-mode analysis. A user-facing email might need tone + accessibility + legal compliance.

**Independent dimensions produce the best results.** Two perspectives that would see the same things add redundancy, not breadth. Two perspectives that see fundamentally different things — that's manifold calcinatio working well. Security and performance are independent. Security and "code correctness" overlap heavily.

**The right number depends on the work.** Two perspectives might be enough for a focused change. Five might be right for a system-level review. Ten is what `/code-review` uses for comprehensive code quality. There's no magic number — match the breadth to the work's complexity and the witnesses' diversity of concerns.

---

## Illustrative Instances

*These are examples of the pattern in action, not an exhaustive list. The principle generates novel instances from the work.*

**Code review with specialist lenses.** Ten specialist legs examine the same diff in parallel — correctness, performance, security, elegance, resilience, style, smells, wiring, commit discipline, test quality. Each produces independent findings. Synthesis deduplicates, cross-references confidence, resolves conflicts. (Crystallized in `/code-review`.)

**Research fan-out.** A complex question has multiple facets. Spawn three subagents, each investigating a different dimension of the question. Synthesize their findings into a unified picture — facts extracted, connections identified, contradictions surfaced.

**Pre-publication review.** A document going to diverse witnesses. Fire accessibility, tone, domain-accuracy, and formatting specialists in parallel. Each evaluates the same document from their professional perspective. Synthesis reveals which issues affect which witnesses.

**System health assessment.** Multiple dimensions of a system need evaluation. Fire performance-analysis, security-audit, dependency-health, and test-coverage specialists in parallel. Synthesis produces a unified health picture no single perspective could provide.

**Design critique from multiple stakeholders.** A UI change serves multiple witnesses with different concerns. Fire specialists representing each witness's professional proxy — field ergonomics, visual design, accessibility, information architecture. Synthesis reveals where the design serves all witnesses and where trade-offs exist.
