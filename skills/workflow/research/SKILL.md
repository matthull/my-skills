---
name: research
description: Deep research with parallel subagents, automatic citations, and chain-of-evidence footnotes. This skill should be used when conducting research that requires verifiable sources, when creating documents that need footnote citations, or when working with downstream documents that must maintain traceability to primary sources. Triggers on "research", "investigate", "find sources for", or when creating documents that require citations.
argument-hint: "<question to investigate>"
---

# Research Skill

Conduct rigorous research with parallel subagents, producing documents with proper footnote citations that maintain a chain of evidence across all derivative documents.

## Core Principle: Chain of Evidence

**Every claim traces back to a primary source.**

Research findings are only as valuable as their verifiability. When creating research documents or any downstream documents derived from research:

1. **Primary research documents** must cite original sources with footnotes
2. **Downstream documents** (summaries, decisions, plans) must preserve footnote references to the *original sources*, not to the research document itself
3. **The chain is unbroken** - a reader can trace any claim in any document back to a verifiable primary source

### Why This Matters

Without chain of evidence:
- Claims become "telephone game" assertions
- Verification becomes impossible over time
- Decisions rest on unverifiable foundations

With chain of evidence:
- Any claim can be independently verified
- Documents remain useful even as context is lost
- Decisions have clear supporting evidence

---

## Phase 1: Query Classification

Before researching, classify the query to determine the appropriate strategy.

### Query Types

**1. LIBRARY/API DOCUMENTATION** (Context7 preferred)
- Questions about library APIs, framework usage, package documentation
- Examples: "How do I use React hooks?", "PowerSync API for offline sync"
- Strategy: Use Context7 first, fall back to web search if insufficient

**2. BREADTH-FIRST** (Wide exploration)
- Multiple independent aspects, survey questions, comparisons
- Examples: "Compare managed Postgres providers", "Evaluate cloud providers"
- Strategy: 5-10 parallel subagents, each exploring different aspects

**3. DEPTH-FIRST** (Deep investigation)
- Single topic requiring thorough understanding
- Examples: "How does transformer architecture work?", "Postgres logical replication limits"
- Strategy: 2-4 subagents with overlapping but complementary angles

**4. SIMPLE FACTUAL** (Quick lookup)
- Single fact, recent event, specific data point
- Examples: "When was GPT-4 released?", "Current CEO of Microsoft"
- Strategy: 1-2 subagents for verification

---

## Phase 2: Parallel Research Execution

Spawn appropriate research subagents **in a single message** for true parallelization.

### Task Prompts Must Include Mode Indicator

Start each task prompt with a trigger phrase:

| Mode | Trigger Phrases | Effort |
|------|----------------|--------|
| Quick Verification | "Quick check:", "Verify:", "Confirm:" | 3-5 searches |
| Focused Investigation | "Investigate:", "Explore:", "Find details about:" | 5-10 searches |
| Deep Research | "Deep dive:", "Comprehensive:", "Thorough research:" | 10-15 searches |

### Example Parallel Launch

```
Task(description="Amazon RDS research",
     prompt="Investigate: Amazon RDS for PostgreSQL - backup retention, SLA terms, maintenance windows, and major-version upgrade path",
     subagent_type="research-expert")

Task(description="Google Cloud SQL research",
     prompt="Investigate: Google Cloud SQL for PostgreSQL - backup retention, SLA terms, maintenance windows, and major-version upgrade path",
     subagent_type="research-expert")

Task(description="TN state requirements",
     prompt="Deep dive: PostgreSQL version support online school requirements and state recognition",
     subagent_type="research-expert")
```

### Subagent Output Pattern

Each subagent writes full report to `/tmp/research_[timestamp]_[topic].md` and returns:
- File path to the full report
- Brief 2-3 sentence summary
- Key topics covered
- Number of sources found

---

## Phase 3: Synthesis with Footnotes

### Footnote Format (Required)

Follow the citation format defined in the `/citations` skill. Key points summarized below for quick reference.

Every significant claim must have a footnote. Use this format:

**Inline reference:**
```markdown
Amazon RDS publishes a 99.95% Multi-AZ availability SLA[^rds-sla] and retains automated backups for up to 35 days[^rds-backup].
```

**Footnote definition (at document end):**
```markdown
[^rds-sla]: Amazon RDS Service Level Agreement. 99.95% monthly uptime commitment for Multi-AZ deployments. [View Source](https://aws.amazon.com/rds/sla/) (accessed 2025-12-26)

[^rds-backup]: Amazon RDS User Guide, "Working with backups". Automated backup retention configurable from 0 to 35 days. [View PDF](https://www.example.com/docs/pricing.pdf) (accessed 2025-12-26)
```

### Footnote Naming Convention

Use short, descriptive slugs:
- `[^rds-backup]` - RDS backup retention
- `[^cloudsql-pricing]` - Cloud SQL pricing tiers
- `[^pg-eol]` - PostgreSQL end-of-life policy

Pattern: `[^org-topic]` or `[^topic-subtopic]`

### Footnote Components

Each footnote must include:

1. **Source name/organization** - Who published this
2. **Document/page title** - What the source is (in quotes if a title)
3. **Key claim** - What the source says (brief paraphrase)
4. **Link** - Clickable link with descriptive text `[View Source](URL)`
5. **Access date** - When accessed `(accessed YYYY-MM-DD)`

### Evidence Quality Tiers

Flag source quality when relevant:

| Tier | Source Type | Reliability |
|------|-------------|-------------|
| 1 | Official docs, primary sources, peer-reviewed | Authoritative |
| 2 | Official examples, starter repos, official blogs | High |
| 3 | Verified community patterns (multiple sources agree) | Moderate |
| 4 | Single blog post, forum answer, outdated content | Low (flag uncertainty) |

---

## Phase 4: Chain of Evidence in Downstream Documents

**Critical Rule:** When creating documents derived from research, preserve footnote references to *original sources*.

### Anti-pattern (Broken Chain)

```markdown
## Decision Document

Amazon RDS retains automated backups for up to 35 days (see research-findings.md).
```

This breaks the chain - a reader cannot verify the claim without finding the research document.

### Correct Pattern (Preserved Chain)

```markdown
## Decision Document

Amazon RDS retains automated backups for up to 35 days[^rds-backup].

---

## Footnotes

[^rds-backup]: Amazon RDS User Guide, "Working with backups". Automated backup retention configurable from 0 to 35 days. [View PDF](https://www.example.com/docs/pricing.pdf) (accessed 2025-12-26)
```

The footnote travels with the claim. Any document, anywhere, can be verified.

### Propagation Rules

1. **Copy footnotes with claims** - When moving a claim to a new document, move its footnote too
2. **Consolidate duplicate footnotes** - If multiple claims use the same source, use one footnote
3. **Never cite research docs as sources** - Cite the primary source the research doc cited
4. **Update access dates** - If re-verifying a source, update the access date

---

## Research Report Structure

The synthesized report (written to file) should include:

```markdown
# Research Report: [Topic]

**Date:** [YYYY-MM-DD]
**Status:** [Draft/Final]

## Executive Summary

[3-5 paragraph overview synthesizing all findings]

## Key Findings

1. **[Finding 1]** - Description with source attribution[^source1]
2. **[Finding 2]** - Description with source attribution[^source2]
3. **[Finding 3]** - Description with source attribution[^source3]

## Detailed Analysis

### [Theme 1]

[Comprehensive analysis with inline footnote citations]

### [Theme 2]

[Comprehensive analysis with inline footnote citations]

## Unknowns / Follow-Up Required

- [ ] [Question that couldn't be answered]
- [ ] [Verification needed for uncertain claim]

## Footnotes

[^source1]: [Full footnote definition]
[^source2]: [Full footnote definition]
...

## Document History

- **[Date]:** Initial research
- **[Date]:** Added [specific updates]
```

---

## Handling Uncertainty

### Flag Gaps Explicitly

When evidence is incomplete:

```markdown
**Note:** No authoritative source found for exact per-region pricing. Tiered pricing is documented[^rds-pricing] but the specific rates vary by region.
```

### Uncertainty Markers

- `[UNCERTAIN - no authoritative source]` - Claim based on inference
- `[CONFLICTING]` - Sources disagree (present both positions)
- `[SINGLE SOURCE]` - Claim relies on only one reference
- `[OUTDATED - verify current status]` - Source is >2 years old on fast-moving topic

---

## Execution Checklist

Before finalizing any research document:

- [ ] Every significant claim has a footnote
- [ ] Footnotes include source, title, brief description, link, and access date
- [ ] Uncertainty is flagged explicitly
- [ ] Sources are appropriate tier for the claim's importance
- [ ] Downstream documents preserve footnotes (don't cite research docs)

---

## Example: Good Footnote Practices

From `documents/research/online-school-comparison.md`:

**Inline:**
> Both RDS and Cloud SQL track **supported PostgreSQL major versions**.[^pg-eol]

**Definition:**
```markdown
[^pg-eol]: PostgreSQL Global Development Group, "Versioning Policy" (updated 8/1/2025). Each major version is supported for five years after release. [View PDF](https://www.postgresql.org/support/versioning/)
```

This footnote includes:
- Source organization (PostgreSQL Global Development Group)
- Document title ("Versioning Policy")
- Date (updated 8/1/2025)
- What it says (Both schools are listed)
- Clickable link with descriptive text
