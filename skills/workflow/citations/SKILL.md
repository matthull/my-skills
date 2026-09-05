---
name: citations
description: Standard citation format for human- and LLM-friendly source traceability across all document types. Covers web sources, internal sources (Slack, meetings, voice notes), and chain-of-evidence propagation. This skill defines the format convention — not invoked directly, but referenced by other skills that produce cited documents.
---

# Citations

Standard citation format for maintaining source traceability across all document types. Designed to be readable by both humans and LLM agents processing documents downstream.

This skill defines the convention. It is referenced by other skills (pm-spec, research, project-management, etc.) that produce documents with source citations.

---

## Footnote Format

Use markdown footnotes. Every significant claim gets a footnote.

**Inline reference:**
```markdown
Sales reps currently search the asset library manually after calls[^gong-workflow].
```

**Footnote definition (at document end):**
```markdown
[^gong-workflow]: Product planning meeting, 2026-01-15. J. Rivera (PM), A. Okonkwo (Eng). "After a support call ends, the agent has to go dig through the knowledge base themselves." [View Thread](https://example.slack.com/archives/C00000000/p0000000000000000)
```

### Footnote Naming Convention

Short, descriptive slugs: `[^org-topic]` or `[^topic-subtopic]`

- `[^gong-workflow]` — the call platform workflow description
- `[^rds-sla]` — RDS SLA terms
- `[^ray-scope-v1]` — Ray's v1 scope decision
- `[^eng-team-dns]` — DNS discussion in #eng-team

### Required Components

Each footnote must include what's available from the source:

1. **Source context** — what kind of source (meeting, Slack thread, web page, voice note, document)
2. **Date** — when it happened or was published
3. **Participants/author** — who said it (when attributable)
4. **Key claim** — what the source says (brief quote or precise paraphrase)
5. **Link** — clickable link when available: URL, Slack thread link, document path

Not all components exist for every source. Include what you have.

---

## Source Types

### Web Sources
```markdown
[^rds-sla]: Amazon RDS Service Level Agreement. 99.95% monthly uptime commitment for Multi-AZ deployments. [View Source](https://aws.amazon.com/rds/sla/) (accessed 2026-02-20)
```
Include access date for web sources — content changes.

### Slack Threads
```markdown
[^eng-team-dns]: #eng-team thread, 2026-02-10. A. Okonkwo: "Should we make custom DNS a requirement so we don't need to worry about falling back?" [View Thread](https://example.slack.com/archives/C00000000/p1234567890)
```

### Meetings
```markdown
[^planning-scope]: Product planning meeting, 2026-01-15. Ray, Matt, Okonkwo. Ray: "Let's keep v1 to email only — Slack integration is v2."
```
No link unless a recording/transcript exists.

### Voice Notes
```markdown
[^matt-voice-0218]: Voice note, 2026-02-18. J. Rivera. "The key insight is that agents don't want to search — they want articles surfaced for them."
```

### Documents
```markdown
[^prd-v1]: Article Suggestion Engine PRD v1, 2026-01-12. Section: "No-Gos". [View](path/to/prd.md)
```

### Linear Items
```markdown
[^lin-update-feb13]: Linear project update, 2026-02-13. A. Okonkwo. "PR for using customer's DNS when available is up and approved." [View](https://linear.app/example/project/article-suggestion-engine/updates#project-update-0000)
```

---

## Chain of Evidence

**Footnotes travel with claims.** When a claim moves from one document to another, its footnote moves too.

### Anti-pattern (Broken Chain)
```markdown
## Decision Document
Sales reps search manually after calls (see research-findings.md).
```
Reader can't verify without finding the research document.

### Correct Pattern (Preserved Chain)
```markdown
## Decision Document
Sales reps search manually after calls[^gong-workflow].

[^gong-workflow]: Product planning meeting, 2026-01-15. J. Rivera. "After a support call ends, the agent has to go dig through the knowledge base themselves."
```
The footnote is self-contained. Any document, anywhere, can be verified.

### Propagation Rules

1. **Copy footnotes with claims** — when moving a claim to a new document, move its footnote too
2. **Consolidate duplicates** — if multiple claims cite the same source, use one footnote
3. **Never cite intermediate documents as sources** — cite the primary source the intermediate document cited
4. **Verbatim for high-stakes claims** — use exact quotes for decisions, constraints, scope changes. Precise paraphrase is fine for context and background.

---

## For Skills That Reference This Convention

Any skill producing cited documents should include in its prompt or instructions:

```
Citation format: Use markdown footnotes per the citations skill convention.
- Inline: claim text[^slug]
- Definition: [^slug]: Source context, date. Author. "Key quote or paraphrase." [Link](url)
- Footnotes travel with claims across documents (chain of evidence)
```

Or reference this skill directly:
```
@skills/workflow/citations/SKILL.md
```
