---
name: request-research
description: >
  Create research request documents for topics requiring investigation.
  Produces portable documents usable by any research agent. Use when a
  feature or decision needs external research before proceeding.
---

# Request Research

Create a research request document for: {{input}}

## Footnote Format Reference

Read the `/research` skill for the required footnote format. When generating the request document, bake the footnote format specification inline so external researchers can follow it.

## Output

Save to `research/requests/[topic-slug].md` in the project root.

The document should be usable by any research agent (Claude Code, Claude.ai, or other tools). Assume the agent knows HOW to research — focus on WHAT and WHY.

**Important:** The researcher has NO access to this repo. Bake in all relevant context — do not link to internal docs. Read relevant project docs first, then include the necessary context directly in the request.

## Evidence Standards (CRITICAL)

**Research findings are only as valuable as their verifiability.** Every significant conclusion needs an evidence chain that can be independently verified.

### Required for All Claims
- **Direct quotes** for key findings (not paraphrases)
- **Source links** for every significant claim
- **Access date** for web sources
- **Section/page reference** for docs (when applicable)

### Evidence Quality Hierarchy

| Tier | Source Type | Weight |
|------|-------------|--------|
| 1 | Official docs, primary sources, peer-reviewed | Authoritative |
| 2 | Official examples, starter repos, official blogs | High |
| 3 | Verified community patterns (multiple sources agree) | Moderate |
| 4 | Single blog post, forum answer, outdated content | Low (flag uncertainty) |

### Flag Gaps Explicitly
- No authoritative source found → Flag as `[UNCERTAIN - no authoritative source]`
- Conflicting sources → Present both positions with links
- Outdated sources only → Note recency concern explicitly
- Single-source claims → Note `[single source]` for transparency

---

## Document Structure

```markdown
# Research Request: [Topic]

**Created:** [date]
**Status:** Open

## Goal
What we're trying to learn or decide. Be specific about the outcome needed.

## Context
Why this matters. Include all relevant background directly — the researcher cannot access our repo. Explain:
- What project/situation this is for
- What decisions depend on this research
- Any constraints or requirements

## Key Questions
Numbered list of specific questions to answer. These should be:
1. Concrete and answerable
2. Prioritized (most important first)
3. Scoped appropriately (not too broad, not too narrow)

## What Would Change Our Approach
What findings would actually shift our strategy or decisions? This helps the researcher focus on actionable insights rather than general background.

## Known Assumptions to Challenge
Any beliefs we currently hold that should be tested. Be explicit about what we think we know — and why we might be wrong.

## Output Format
What format is most useful? Options:
- Summary with sources
- Comparison table
- Pro/con analysis
- Step-by-step guide
- Annotated source list

## Recency Requirements
[Specify how important recency is for this topic:]
- Critical (2024-2025 only) — fast-moving landscape, older content likely outdated
- Prefer recent — recent sources preferred but older foundational content acceptable
- Not critical — topic is stable, older sources fine

## Instructions for Researcher

### Footnote Format (Non-negotiable)
[Include the footnote format from the skill here - inline reference syntax, footnote definition format with all required components, and naming convention. This must be self-contained for external researchers.]

### Evidence Requirements
- **Quote, don't paraphrase** — Include exact quotes for key findings
- **Link everything** — Every significant claim needs a footnote with source URL
- **Date your sources** — Note publication date AND access date in footnotes
- **Show evidence tiers** — Flag whether sources are Tier 1-4 (see Evidence Standards above)

### Research Process
- Ask clarifying questions before diving in if scope is unclear or assumptions seem off
- Push back if the questions seem misguided or if there's a better framing
- Distinguish between well-established findings and emerging/contested ideas
- Be direct about limitations or gaps in available evidence

### Transparency Requirements
- Flag `[UNCERTAIN]` when no authoritative source exists
- Flag `[CONFLICTING]` when sources disagree (present both sides)
- Flag `[SINGLE SOURCE]` when a claim relies on only one reference
- Flag `[OUTDATED]` when newest source is >2 years old on fast-moving topics
```

## After Creating

1. Create `research/requests/` directory if it doesn't exist
2. Inform user where the request was saved
3. Note that findings should go in `research/findings/[topic-slug].md` when fulfilled

## Principles
- Bake in all context — researcher cannot access our files
- Be specific about what decisions this research informs
- Encourage the researcher to push back and ask questions
- Don't over-specify methodology — trust the researcher
