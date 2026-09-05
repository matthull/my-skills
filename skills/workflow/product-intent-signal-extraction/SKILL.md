---
name: product-signal-extractor-base
description: Extract product intent signals from raw inputs (meeting transcripts, Slack threads, voice notes, brain dumps) into a structured signal map with per-source quality assessment. Designed to run as a subagent so extraction doesn't blow up the orchestrator's context. This skill should be used when pm-spec or any product management skill needs to process raw signals before shaping — never invoked directly by users.
---

# Product Signal Extractor — Base

Extract structured product intent signals from raw, messy inputs. This skill runs as a **subagent** — invoked by an orchestrating skill (e.g., `/pm-spec`), not directly by users. The orchestrator handles shaping into product requirements; this skill handles extraction with disciplined prompt rigor.

Why a dedicated skill rather than ad-hoc extraction: extraction quality directly determines the accuracy of every downstream artifact (PRD sections, breadboards, scope definitions). An undisciplined extraction prompt produces wrong signals — a breadboard built from misattributed quotes produces wrong product decisions. This skill exists to make extraction correct, repeatable, and quality-assessed.

---

## What Is a Product Intent Signal?

A product intent signal is any raw artifact that expresses what someone wants, thinks, or believes about a problem or solution. The key word is *expresses* — signals are not requirements. They are the unrefined material from which requirements are shaped.

**Signals are expected to be:**
- **Partial** — no single signal captures the full picture; that's normal, not a gap to apologize for
- **Contradictory** — different signals from different people, times, or contexts will conflict; this is data, not a problem
- **Incomplete** — signals often describe the what without the why; that's what the shaping conversation is for
- **Informal** — a voice note rambling for 3 minutes, a Slack thread that goes off-topic, a meeting that covered 5 things at once; all valid

**Signal provenance matters.** Who said it, when, in what context shapes how much weight to give it. A passing comment in a standup carries different authority than a direct statement in a product review. Capture provenance, don't strip it.

**Multiple signals expressing the same intent are corroboration, not redundancy.** When three people independently describe the same pain point in different ways, that convergence is meaningful. Preserve it.

**Signal types this skill extracts:**

| Signal Type | Description | Example |
|-------------|-------------|---------|
| **Problem statement** | A pain point, need, or gap described by a user or stakeholder | "Support agents never know which help article to send after a ticket" |
| **Goal / desired outcome** | What someone wants to achieve | "We want agents linking an article within 24h of a resolved ticket" |
| **Constraint** | A real limitation on the solution space | "Must send from the customer's own mail domain" |
| **Workflow signal** | How something works today or should work | "After a support call, the rep manually searches the library" |
| **No-go / exclusion** | Something explicitly ruled out | "We're not doing chat integration in v1" |
| **Rabbit hole** | A tempting path that would derail the core solution | "Don't auto-generate new articles — just recommend existing ones" |
| **NFR implication** | Non-functional requirement expressed as user expectation | "Agents need this before their next shift, so same-day delivery" |
| **Persona signal** | Who the user is, what they care about, their context | "Our agents are not technical — they won't configure anything" |
| **Priority signal** | What matters most, what can wait | "The email is the MVP — the admin panel is nice-to-have" |
| **Strategic alignment** | Reference to business outcomes or capabilities | "This supports the platform consolidation goal" / "This is about retention" |

---

## Source Authority: Principals vs. Stakeholders

Before extracting anything, identify every participant in the signals and classify their authority.

**Principals** — people with authority to define what gets built: product manager, designer, cofounder, engineering lead making scope calls. Their statements can be constraints and decisions.

**Stakeholders** — people who inform without deciding: customer success, customers, sales, other teams. Their statements are context — valuable for understanding the problem, not for resolving scope questions.

**The skill does not assume.** At triage (Pass 0), identify every participant. If any participant's authority is unclear, surface it explicitly in the output:

```
AUTHORITY UNKNOWN: "R. Delgado" appears in the transcript but their role is unclear.
Their statements have been extracted but flagged — confirm whether they are
a principal or stakeholder before acting on their signals.
```

**How authority shapes extraction:**
- Principal statements that define scope or make decisions → extracted as constraints or decisions, cited with full authority
- Stakeholder statements describing problems or needs → extracted as informational context, flagged with source role
- Conflicting signals across authority levels → surface both; note which came from a principal
- Unknown authority → extracted but explicitly flagged

---

## Signal Quality Assessment

Not all signal inputs are equally useful. This skill assesses the quality of each signal source **during extraction** and reports it alongside the extracted signals. Quality is reported, not gated — low-quality signals are still extracted, but the assessment travels with them so the shaping conversation can account for it.

### Per-Source Quality Assessment

For each signal source (each transcript, Slack thread, voice note, etc.), assess:

**Can we extract actionable intent from this input?** Report a confidence level and, for anything below HIGH, diagnose why.

| Quality Issue | Description | Example |
|---------------|-------------|---------|
| **Too vague** | Expresses general sentiment without actionable specificity | "We should probably improve the search experience" |
| **No principal present** | Lacks decision-maker input; everything is stakeholder context | Customer interview with no product/eng voice |
| **Off-topic** | Discusses adjacent concerns, not the target feature | Meeting that spent 90% on unrelated items |
| **Unresolved contradictions** | Source contradicts itself without resolution | Same speaker says opposite things 10 minutes apart |
| **Missing business context** | Describes solution desires without connecting to business outcomes | Feature requests with no "why" |
| **Stale** | Predates decisions that changed the landscape | Pre-pivot meeting transcript |
| **Low density** | Long source with very few extractable signals | 45-minute meeting yielding 2 signals |

### Aggregate Quality

After per-source assessment, compute an overall extraction quality summary:
- How many high-confidence signals were extracted total?
- How many sources were assessed as LOW quality?
- Are there systematic patterns? (e.g., "all three voice notes were too vague to extract goals from — the voice note process may need adjustment")

**Quality patterns feed back to the source process.** If voice notes are consistently too vague, if meetings consistently lack principal input, if Slack threads consistently go off-topic — these are signals about the input pipeline, not just about individual sources. Surface patterns when they emerge.

---

## Extraction Passes

Run passes sequentially. Each pass has a single focus to avoid context bleed.

### Pass 0: Triage + Quality Assessment

Before extracting signals:
- Identify source types (transcript, Slack, brain dump, existing PRD, ticket, strategy doc)
- Identify all participants and classify authority (principals / stakeholders / unknown)
- Note date range of signals
- Flag any obvious conflicts visible at surface level
- **Assess each source's quality** — can we extract actionable intent? If not, diagnose why (use quality issue categories above)
- Note signal density per source — rich or sparse?
- **Identify any strategic alignment references** — do sources mention business outcomes, company-level objectives, or strategic priorities?

Output: participant list with authority classification, source inventory with per-source quality assessment, conflict flags, strategic alignment notes.

### Pass 1: Problems and Goals

Extract:
- Pain points and problems described (who has the problem, what it looks like)
- Desired outcomes and goals (what success looks like)
- Business context (why this matters to the business)
- Persona signals (who the users are, what they care about)

Every claim cited to source. Distinguish between directly stated problems and inferred problems.

### Pass 2: Solution Shape and Workflows

Extract:
- How things work today (current state workflows)
- How things should work (desired state)
- Decision points and branching logic mentioned
- Interaction patterns described or implied

Do not design — extract what was said about how things should work. Shape comes later in the orchestrating skill.

### Pass 3: Constraints, No-Gos, and Rabbit Holes

Extract:
- Explicit constraints on the solution space
- Things ruled out ("we're not doing X")
- Known traps — things a reasonable person might pursue that would derail the core solution
- Technical constraints expressed as product constraints ("must use customer DNS")

Distinguish principal-stated constraints from stakeholder preferences.

### Pass 4: NFR, Priority, and Strategic Alignment

Extract:
- Non-functional expectations expressed as user needs (speed, reliability, scale)
- Priority signals — what matters most, what's nice-to-have, what can wait
- Sequencing signals — what should come first, dependencies between features
- **Strategic alignment signals** — any references to company-level objectives, product capabilities, or how this work connects to company strategy. These may be explicit ("this supports the platform consolidation goal") or implicit ("if we don't fix this, customers churn"). Extract both, flagging implicit ones as inferred.

### Pass 5: Synthesis + Quality Summary

Assemble the signal map. Do not introduce new claims — only organize, flag conflicts, and surface missing information.

For each conflict found (two signals that contradict): surface both with citations. Do not resolve silently.

**Produce the quality summary:**
- Per-source quality ratings with diagnoses
- Aggregate signal count by confidence level
- Any systematic quality patterns observed across sources
- Overall extraction confidence

---

## Output Format

Return a structured signal map — not prose, not a summary. The orchestrating skill will shape from this.

```markdown
# Product Intent Signal Map

**Extracted from:** [source types, date range]
**Participants:** [name — role/authority for each]
**Overall extraction confidence:** [HIGH / MEDIUM / LOW]

---

## Source Quality Assessment

| Source | Type | Quality | Signals Extracted | Issues |
|--------|------|---------|-------------------|--------|
| [source 1] | transcript | HIGH | 12 | — |
| [source 2] | voice note | LOW | 2 | Too vague, missing business context |
| [source 3] | Slack thread | MEDIUM | 6 | Off-topic for 60% of thread |

**Quality patterns:** [Any systematic observations about the input pipeline]

---

## Authority Flags
[Any participants with unknown authority, requiring clarification before acting]

---

## Strategic Alignment Signals
- **[Signal]:** [How this connects to business outcomes] — explicit/inferred — *Source: [citation]*
- ...

## Problems / Pain Points
- **[Problem]:** [Description] — who experiences it: [persona/role] — *Source: [citation]*
- ...

## Goals / Desired Outcomes
- **[Goal]:** [Description] — *Source: [citation]*
- ...

## Workflows
- **Current state:** [How it works today] — *Source: [citation]*
- **Desired state:** [How it should work] — *Source: [citation]*
- ...

## Constraints
- **[Constraint]:** [Description] — authority: [principal/stakeholder] — *Source: [citation]*
- ...

## No-Gos / Exclusions
- **[Exclusion]:** [What's ruled out] — *Source: [citation]*
- ...

## Rabbit Holes
- **[Trap]:** [What it is and why it's a trap] — *Source: [citation]*
- ...

## NFR Implications
- **[Requirement]:** [User expectation] — *Source: [citation]*
- ...

## Priority Signals
- **[Signal]:** [What matters most/least] — *Source: [citation]*
- ...

## Persona Signals
- **[Persona]:** [Who they are, what they care about] — *Source: [citation]*
- ...

## Conflicts Detected
- **[Conflict]:** [Source A] says [X]. [Source B] says [Y]. Requires adjudication.
- ...

## Gaps / Missing Information
- [Things that appear to be missing or were referenced but not resolved]
```

---

## Primary Source Preservation

Every extracted signal must be citable. Preserve verbatim quotes for high-stakes signals (constraints, no-gos, scope decisions, rabbit holes). For lower-stakes signals (persona context, workflow descriptions), a precise paraphrase with attribution is sufficient.

Never fabricate specificity. If something was implied but not stated, flag it as inference. A gap in the signal map is better than a wrong signal.

---

## Invocation Context

### Standard Invocation Pattern

The correct way to invoke this skill is via a subagent that reads the skill itself. This keeps the orchestrator's context lean and ensures extraction follows the full skill discipline rather than an ad-hoc summary.

Orchestrator prompt to subagent:
```
Read .claude/skills/product-signal-extractor-base/SKILL.md
and follow it to extract signals from: [file path or pasted content].
Return the full signal map.
```

Do NOT summarize this skill's instructions into the subagent prompt — have the subagent consume the skill directly. The skill is the prompt.

### What to Provide

When invoking, the orchestrator should give the subagent:
1. The path to this SKILL.md (so the subagent reads it fully)
2. The raw signal inputs (full text — do not pre-filter or summarize)
3. Any known participant roles (if already established by the orchestrator)
4. Whether this is a new extraction or a delta extraction (new signals against existing requirements)
5. Any known strategic context (so the extractor can identify alignment signals)

The skill returns the signal map with quality assessment. The orchestrator handles shaping it into product requirements.
