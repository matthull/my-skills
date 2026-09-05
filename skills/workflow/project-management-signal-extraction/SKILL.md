---
name: project-management-signal-extraction
description: Extract project management signals from raw inputs (meeting transcripts, Slack threads, stand-up notes, async updates) into a structured signal map. Designed to run as a subagent so extraction doesn't blow up the orchestrator's context. This skill should be used when a project management skill or orchestrator needs to process raw signals before synthesis — never invoked directly by users.
---

# Project Management Signal Extraction

Extract structured project management signals from raw, messy inputs. This skill runs as a **subagent** — invoked by an orchestrating skill (e.g., `/project-management`), not directly by users. The orchestrator handles synthesis; this skill handles extraction with disciplined prompt rigor.

Why a dedicated skill rather than an ad-hoc subagent prompt: extraction quality directly determines the accuracy of every downstream artifact (status updates, blocker reports, milestone tracking). An undisciplined extraction prompt produces wrong signals. This skill exists to make extraction correct and repeatable.

---

## What Is a Project Management Signal?

A project management signal is any raw artifact that expresses the current state of work: where things stand, what's blocked, what was decided, what was committed to. Like product intent signals, they are expected to be partial, informal, and occasionally contradictory — that's normal. The extraction job is to surface the signal, not judge the source for being messy.

**Signal types this skill extracts:**

| Signal Type | Description | Example |
|-------------|-------------|---------|
| **Action item** | A commitment to do something, with owner and optionally a due date | "Tom will have the API spec done by Friday" |
| **Status update** | Progress against a milestone or body of work | "We're about 70% through the indexing work" |
| **Blocker** | Something actively preventing progress | "Can't proceed until legal signs off on the data agreement" |
| **Decision** | A choice made with rationale | "We decided to drop the batch processing requirement for v1" |
| **Risk** | Something that could become a blocker or miss a milestone | "If the third-party API doesn't support pagination, we'll need to rethink the sync approach" |
| **Milestone update** | A milestone hit, missed, or flagged at-risk | "Shipped the scoring model to staging yesterday" |
| **Commitment / next step** | What the team is moving toward next | "Next sprint is focused entirely on the evaluation harness" |
| **Scope change** | Something added to or removed from the project | "Grant said to drop the export feature for now" |

---

## Source Authority: Principals vs. Stakeholders

Before extracting anything, identify every participant in the signals and classify their authority.

**Principals** — people with authority over project decisions: project lead, PM, engineering lead, cofounder. Their statements about scope, priorities, and decisions carry decisional weight.

**Stakeholders** — people who inform without deciding: other teams, customers, support, external partners. Their signals provide context but don't override principal decisions.

**The skill does not assume.** At triage, identify every participant. If any participant's authority is unclear, surface it explicitly in the output:

```
AUTHORITY UNKNOWN: "R. Delgado" appears in the transcript but their role is unclear.
Their statements have been extracted but flagged — confirm whether they are
a principal or stakeholder before acting on their commitments.
```

Authority shapes extraction:
- Principal statements about scope, timeline, or priorities → extracted as decisions or constraints
- Stakeholder statements about problems or needs → extracted as context, flagged with source role
- Unknown authority → extracted but explicitly flagged

---

## Extraction Passes

Run passes sequentially. Each pass has a single focus to avoid context bleed.

### Pass 0: Triage

Before extracting signals:
- Identify source types (transcript, Slack, async doc, stand-up notes)
- Identify all participants and classify authority (principals / stakeholders / unknown)
- Note date range of signals
- Flag any obvious conflicts visible at surface level
- Note signal density — is this a rich source or sparse?

Output: participant list with authority classification, source inventory, conflict flags.

### Pass 1: Commitments and Action Items

Extract every stated or implied commitment:
- Who owns it
- What they committed to
- When (if stated — never infer a date that wasn't given)
- Context (what prompted the commitment)

Flag ambiguous ownership: "we should get that done" is not the same as "Tom will do X by Friday."

### Pass 2: Status and Progress

Extract current state signals:
- Progress statements (percentage, milestone markers, "done", "in progress", "not started")
- Velocity signals (moving fast, slowing down, stalled)
- Confidence signals ("pretty sure", "I think", "definitely")

Note confidence level alongside each status signal — a tentative status is different from a confirmed one.

### Pass 3: Blockers and Risks

Extract:
- Active blockers (stated explicitly or clearly implied)
- How long the blocker has existed (if inferable)
- Who owns unblocking
- Risks (things that could become blockers)
- Dependencies not yet resolved

Distinguish blockers (active, stopping work now) from risks (potential, not yet blocking).

### Pass 4: Decisions and Scope Changes

Extract:
- Decisions made with rationale where stated
- Scope additions or removals
- Priority changes
- "We're not doing X" statements — these are scope signals, not just editorial comments

### Pass 5: Synthesis

Assemble the signal map. Do not introduce new claims — only organize, flag conflicts, and surface missing information.

For each conflict found (two signals that contradict): surface both with citations. Do not resolve silently.

---

## Output Format

Return a structured signal map — not prose, not a summary. The orchestrating skill will synthesize from this.

```markdown
# Signal Map

**Extracted from:** [source types, date range]
**Participants:** [name — role/authority for each]
**Extraction confidence:** [HIGH / MEDIUM / LOW — overall quality of signals]

---

## Authority Flags
[Any participants with unknown authority, requiring clarification before acting]

---

## Action Items
- **[Owner]:** [Commitment] — due [date if stated, otherwise omit] — *Source: [who said it, when]*
- ...

## Status / Progress
- **[Work area]:** [Status signal] — confidence: [HIGH/MED/LOW] — *Source: [citation]*
- ...

## Blockers
- **[Blocker]:** [Description] — owner: [who unblocks] — duration: [how long if inferable] — *Source: [citation]*
- ...

## Risks
- **[Risk]:** [Description] — *Source: [citation]*
- ...

## Decisions
- **[Decision]:** [What was decided] — rationale: [if stated] — *Source: [who decided, when]*
- ...

## Scope Changes
- **[Change]:** [What was added or removed] — *Source: [citation]*
- ...

## Conflicts Detected
- **[Conflict]:** [Source A] says [X]. [Source B] says [Y]. Requires adjudication.
- ...

## Gaps / Missing Information
- [Things that appear to be missing or were referenced but not resolved]
```

---

## Primary Source Preservation

Every extracted signal must be citable. Preserve verbatim quotes for high-stakes signals (decisions, scope changes, blockers). For lower-stakes signals (status updates), a precise paraphrase with attribution is sufficient.

Never fabricate specificity. If a date wasn't stated, don't infer one. If ownership wasn't clear, flag it. A gap in the signal map is better than a wrong signal.

---

## Invocation Context

### Standard Invocation Pattern

The correct way to invoke this skill is via a subagent that reads the skill itself. This keeps the orchestrator's context lean and ensures extraction follows the full skill discipline rather than an ad-hoc summary.

Orchestrator prompt to subagent:
```
Read skills/workflow/project-management-signal-extraction/SKILL.md
and follow it to extract signals from: [file path or pasted content].
Return the full signal map.
```

Do NOT summarize this skill's instructions into the subagent prompt — have the subagent consume the skill directly. The skill is the prompt.

### What to Provide

When invoking, the orchestrator should give the subagent:
1. The path to this SKILL.md (so the subagent reads it fully)
2. The raw signal inputs (full text — do not pre-filter or summarize)
3. Any known participant roles (if already established by the orchestrator)
4. The signal types most relevant to the current task (optional — defaults to all types)

The skill returns the signal map. The orchestrator handles what to do with it.
