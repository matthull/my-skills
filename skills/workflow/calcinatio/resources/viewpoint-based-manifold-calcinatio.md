# Viewpoint-Based Manifold Calcinatio — Full Protocol

A manifold calcinatio pattern where each leg adopts a specific, narrow viewpoint for critique. The differentiator from generic manifold calcinatio is a structured **perspective derivation process** — instead of "figure out what perspectives to use," there's a concrete process for identifying them.

---

## Why This Works

Generic manifold calcinatio says "derive perspectives from the witnesses." This is correct but underspecified — it leaves the agent to improvise the derivation, which often produces obvious or habitual perspectives rather than the most revealing ones.

Viewpoint-based manifold calcinatio adds structure to the derivation. The result is perspectives that are:
- **Task-specific** — derived from the current work's nature, not from a generic checklist
- **Domain-informed** — research-derived perspectives bring expertise the system doesn't inherently have
- **Witness-grounded** — stakeholder concerns are extracted through the lens of the current task, not copied from general definitions

The dev-env-overhaul experience demonstrates the power: a Vite article and a Rails article each brought domain-specific concerns nobody had thought to define as stakeholders. The resulting spec was stronger than any single perspective could produce because it synthesized views that were genuinely independent and genuinely expert.

---

## Perspective Derivation Process

Three sources of perspectives, checked in order. Not all three apply to every situation — use judgment about which sources are relevant and how many perspectives to derive.

### 1. Witness-Derived Perspectives

Read MO witnesses and opus stakeholders (if applicable). For each, ask: *"What is this witness's specific stake in the current task?"*

The key move: **extract the task-relevant concern, not the general witness definition.** A CTO witness evaluating a spec might become a "scalability architect" leg. The same CTO evaluating a UI change might become a "technical debt" leg. The witness is stable; the perspective is task-dependent.

The professional proxy principle applies — find the discipline that serves this witness's concern in this context. The witness defines *what matters*; the proxy identifies *who would evaluate it best*.

### 2. Research-Derived Perspectives

Identify authoritative external viewpoints relevant to the work. These are perspectives the system doesn't inherently have — they come from outside.

Sources:
- Articles, blog posts, or documentation representing a specific technology's perspective (e.g., "the Vite perspective on dev server architecture")
- Reference architectures or patterns from authoritative sources
- Expert opinions or established frameworks for evaluating this class of work
- Community best practices from different ecosystems that intersect in this task

Each source becomes a subagent's lens. The subagent critiques the work from that source's perspective — not impersonating the author, but applying the concerns, priorities, and expertise that source represents.

**This is the most generative source.** Research-derived perspectives bring viewpoints nobody in the system thought to define. They're especially powerful when a task sits at the intersection of multiple domains (e.g., a Rails + Vite dev environment, where each ecosystem has its own priorities and conventions).

**Process:** If Phase 0 research was conducted (as in `/spec`), the research artifacts are already available — each distinct source can become a perspective leg. If no prior research exists, consider whether the task warrants research specifically for perspective derivation. Even a quick search for "how does [domain X] approach [this class of problem]" can surface a valuable lens.

### 3. Task-Intrinsic Perspectives

What concerns does this specific work demand that aren't captured by witnesses or research?

- **Cross-cutting concerns** — security, performance, accessibility, migration safety, backwards compatibility, observability
- **Domain-specific angles** — regulatory compliance, field ergonomics, data integrity, network resilience
- **Stakeholder needs not formally defined** — the on-call engineer, the new team member onboarding, the CI pipeline, the future maintainer

These emerge from the work's nature. A database migration demands a "data integrity" perspective. A user-facing API demands an "API consumer ergonomics" perspective. A deployment change demands an "rollback safety" perspective.

---

## The Protocol

```
1. DERIVE PERSPECTIVES
   - Check all three sources: witness-derived, research-derived, task-intrinsic
   - For each perspective, name it concretely — not "security" but
     "authentication flow security for a multi-tenant SaaS"
   - Aim for independence — perspectives that see fundamentally different
     things produce the best results
   - 3-7 perspectives is typical; scale with the work's complexity

2. FAN OUT
   - Fire one subagent per perspective (use sonnet unless opus-level
     reasoning is genuinely needed)
   - Each gets: the artifact + the intent + their narrow lens
   - Shape context per /calcinatio guidance — pass enough for meaningful
     resistance, not so much that freshness is lost
   - Each works independently — no leg sees sibling output

3. SYNTHESIZE
   - Collect all findings
   - Deduplicate — same issue seen from different viewpoints
   - Identify agreement (high confidence) vs. conflict (needs judgment)
   - Prioritize: which findings most affect the work's quality or
     stakeholder satisfaction?
   - Resolve what you can; escalate genuine conflicts
   - Document which perspectives produced the highest-value findings
     (this improves future derivation)
```

---

## Illustrative Instances

**Spec review with stakeholder + research perspectives.** A dev-env-overhaul spec reviewed by 7 parallel legs: Vite configuration lens, performance/resource lens, developer onboarding lens, worktree/parallel-dev lens, reference architecture alignment, Docker official guidance, and migration safety. Each critique file assessed the spec from one narrow viewpoint. The synthesis produced a spec that satisfied concerns from all seven domains.

**MO assessment with witness perspectives.** During assessment, each MO witness gets a dedicated leg: *"Thinking purely from this witness's vantage — given the landscape report, what would most bountifully serve them?"* The witness-perspective legs fire alongside materia-stimulus legs, producing both "what does the landscape offer?" and "what do the witnesses need?" See `AGENTS.md § Assessment Opera` for the full assessment protocol.

**Code review with domain-informed lenses.** Beyond the standard quality dimensions (correctness, security, performance), research-derived perspectives add domain-specific lenses. Reviewing a payment integration might add a "PCI compliance" leg and a "Stripe API best practices" leg alongside the standard review legs.

---

## Relationship to Other Patterns

**Viewpoint-based manifold calcinatio is a specialization of manifold calcinatio.** It inherits the full manifold protocol (fan out, independence, synthesis) and adds the perspective derivation process. Everything in `manifold-calcinatio.md` applies.

**It composes with dialectical calcinatio.** After manifold synthesis reveals conflicts or high-priority findings, dialectical calcinatio can resolve them through iterative exchange between the context-holder and a fresh perspective focused on the contested point.

**`/code-review` is a crystallized instance** with hardcoded professional-discipline perspectives. Viewpoint-based manifold calcinatio is the generative version — perspectives derived from context rather than predefined.
