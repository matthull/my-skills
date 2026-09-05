---
name: threads
description: Conversational scaffolding for multi-threaded exploratory discussions. This skill should be used during shaping sessions, brainstorming, spec conversations, or any exploration where multiple threads emerge. Tracks questions, ideas, decisions, agreements, and topics so nothing is lost. Dependency for PM and spec skills.
---

# Threads — Externalized Executive Function for Conversations

Serve as externalized executive function during exploratory conversations. Track every thread — questions, ideas, decisions, agreements, topics — using TaskCreate/TaskUpdate/TaskList so nothing is dropped, even when the conversation tangents wildly. Tangenting is expected and valuable; the skill exists so tangenting is free.

## Thread Taxonomy

| Type | Prefix | Captures | Resolves when |
|------|--------|----------|---------------|
| Question | `Q:` | Open question needing answer | Answered explicitly |
| Idea | `I:` | Proposed approach or possibility | Accepted, rejected, or parked |
| Decision | `D:` | Choice point between alternatives | Decision made with rationale |
| Agreement | `A:` | Something both parties agreed on | Created already-resolved (record) |
| Thread | `T:` | General topic / line of discussion | Explored to satisfaction or parked |

## Task Convention

Each thread = one task via TaskCreate.

- **subject:** `"<PREFIX> <concise description>"` (e.g., `"Q: How should auth tokens refresh?"`)
- **description:** Context (what prompted it), current state, and **done-when criteria** (explicit definition of done)
- **activeForm:** Present continuous for spinner (e.g., `"Exploring auth token refresh"`)
- **metadata.thread_type:** `question | idea | decision | agreement | thread`
- **metadata.state:** `open | parked | resolved`
- **metadata.resolution:** One-line outcome (populated when resolved)

For `A:` (agreement) tasks, create with `metadata.state: resolved` and `metadata.resolution` populated immediately, then **immediately mark completed** via TaskUpdate — agreements are records of what was decided, not open items.

### Completion Discipline

Every task has done-when criteria. Do not mark a task completed unless those criteria are met.

- "Discussed" is a valid done-when — but only if actually discussed, not just mentioned
- "Decision made with rationale" means the rationale is recorded, not just that a choice was voiced
- "Mostly done" is not done. If done-when criteria aren't met, the task stays open
- After completing any task, check TaskList for the next item or newly unblocked work

## Behavioral Protocol

### Thread Creation Triggers

Apply these continuously throughout the conversation:

1. **New topic emerges** — A substantively new line of discussion appears. Create a `T:` task before engaging with the topic.
2. **Question raised** — A question that isn't immediately answered. Create a `Q:` task. If the question IS answered immediately in the same exchange, create an `A:` agreement task instead (capturing the Q&A as a durable record).
3. **Decision point surfaces** — Alternatives or tradeoffs appear. Create a `D:` task capturing the options in the description.
4. **Explicit agreement reached** — Both sides agree on something. Create an `A:` task immediately with resolution populated. Agreements are the most durable output of exploration and the easiest to lose.
5. **Multi-item intake** — A message contains 2+ distinct items (questions, topics, ideas). TaskCreate all of them before responding to any.

### Thread Update Triggers

- **Question answered** — Mark the `Q:` task **completed** via TaskUpdate (status: `completed`). Set `metadata.state: resolved`, `metadata.resolution` to the answer. Completed tasks disappear from the active list — this is the desired behavior.
- **Decision made** — Mark the `D:` task **completed**. Include the chosen option and rationale in `metadata.resolution`.
- **Idea accepted/rejected** — Mark the `I:` task **completed** with disposition in `metadata.resolution`.
- **Thread explored to satisfaction** — Mark the `T:` task **completed**.
- **Topic shift with unresolved thread** — Set `metadata.state: parked` on the thread being left behind (task stays open).
- **Return to parked thread** — Set `metadata.state: open`, task status `in_progress`.

### Thread Map

Surface a compact grouped summary every 5-7 turns, or immediately on request. Format:

```
## Thread Map

**Open (3)**
- Q: How should auth tokens refresh? (turn 4)
- D: REST vs GraphQL for new endpoints (turn 6)
- T: Performance budget discussion (turn 8)

**Parked (1)**
- I: Consider event sourcing for audit trail (turn 3)

**Resolved (2)**
- A: Use PostgreSQL for primary store (turn 2)
- Q: Which CI provider? — GitHub Actions (turn 5)
```

### Completion Gate

Before concluding the conversation or producing a final artifact (spec, summary, decision log), surface all unresolved threads:

**Blocking** — open `Q:` and `D:` items. These represent unanswered questions and unmade decisions. Flag them explicitly.

**Deferrable** — parked `T:` and `I:` items. These are exploratory threads that can be consciously deferred.

Present both categories. The user decides what to resolve now vs. defer. Do not conclude with unresolved blocking threads unless the user explicitly acknowledges them.

## Injection in Depth

### Specification Leverage

The conversation IS the spec work. Thread quality directly determines spec quality. A dropped question is a gap in the spec. A lost agreement is an unrecorded decision that will be relitigated later. Tracking threads with discipline is the mechanism that converts exploratory conversation into durable specification.

### Intent Encoding

Agreements and decisions captured via `A:` and `D:` tasks are encoded intent. Each one is a primary source that downstream work (specs, implementations, handoffs) can trace back to. Losing them means losing the intent chain — the spec becomes disconnected from the reasoning that produced it.

### Feedback Targets Context

If threads keep getting dropped in a particular pattern — e.g., agreements that emerge mid-discussion are consistently missed — update this skill's triggers rather than just catching the current miss. The skill should get better at the patterns that matter to the user's actual conversation style.
