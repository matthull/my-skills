---
name: slack-thread-triage
description: Scan a Slack channel, classify threads by action type (product, project, technical, no-action), and tag them with emoji reactions. Already-tagged threads are skipped on subsequent runs. This skill should be used when triaging Slack channels for actionable threads, or as part of a recurring triage workflow.
---

# Slack Thread Triage Router

Scan a Slack channel, read threads that need attention, classify each by action type, and tag with emoji reactions. On subsequent runs, already-tagged threads are skipped — making this idempotent and safe to run repeatedly.

## Invocation

```
/slack-thread-triage <channel> [hours_back]
```

- **channel** (required): Slack channel name, e.g. `#eng-team` or `eng-team`
- **hours_back** (optional, default: 24): How far back to scan

Example: `/slack-thread-triage #eng-team 48`

## Reaction Posting

Use `mcp__egregore-mcp__add_reaction(channel, message_ts, emoji)` to tag threads after classification.

- **channel**: channel name (e.g. `#eng-team`)
- **message_ts**: timestamp of the message to react to (from scan_channel output)
- **emoji**: emoji name without colons (e.g. `bookmark`, `wrench`, `file_folder`, `white_check_mark`)

## Triage Categories

| Category | Emoji | Slack Name | Signals | Tagged? |
|----------|-------|------------|---------|---------|
| Product | 📋 | `bookmark` | Needs product decision, prioritization call, feature scoping, user-facing tradeoff, or stakeholder input | Yes |
| Project | 🗂️ | `file_folder` | Needs project management action: timeline, dependency coordination, resource allocation, status tracking | Yes |
| Technical | 🔧 | `wrench` | Needs technical action: bug fix, architecture decision, code review, infrastructure change, investigation | Yes |
| No action | — | — | Informational, already resolved, or FYI-only. **No reaction added** — thread will be re-scanned next run but re-classifying is cheap and adding reactions to every thread is too disruptive. | No |

## Workflow

### Step 1: Scan for untagged threads

```
scan_channel(channel="<channel>", hours_back=<hours_back>, limit=200)
```

This returns recent messages with reply counts and `thread_ts` for threaded messages.

### Step 2: Identify already-tagged threads (skip logic)

Run four filtered scans to find threads already tagged with any triage emoji:

```
scan_channel(channel="<channel>", hours_back=<hours_back>, emoji="bookmark")
scan_channel(channel="<channel>", hours_back=<hours_back>, emoji="file_folder")
scan_channel(channel="<channel>", hours_back=<hours_back>, emoji="wrench")
```

Run these three scans in parallel. Collect all `thread_ts` values from the results — these threads are already triaged. Exclude them from the untagged set identified in Step 1.

**Important:** The `emoji=` filter on `scan_channel` does client-side filtering on the `reactions` field. It returns messages that have that specific reaction, regardless of who added it.

### Step 3: Read untagged threads

For each untagged message that has replies (indicated by `reply_count > 0` and a `thread_ts` in the scan output):

```
read_slack_thread(channel="<channel>", thread_ts="<thread_ts>")
```

Read threads in parallel where possible (batch 3-5 at a time to avoid rate limits).

For messages with no replies (standalone messages), classify based on the message text alone — no thread read needed.

### Step 4: Classify each thread

For each untagged thread, assign exactly one primary category. Use the classification guidance below.

If a thread genuinely spans two categories (e.g., a product decision that requires a technical spike first), assign the **upstream** category — the one that must be resolved first before the other can proceed. In the product-then-technical example, tag as Product because the product decision gates the technical work.

### Step 5: Tag automatically and output summary

**Tagging is automatic. Do not prompt the operator for confirmation before tagging.** The whole point of this skill is to take triage off the operator's plate. Tag immediately after classification — the operator reviews the summary after the fact, not before.

Only pause to ask if there is **genuine ambiguity that would change the category** (e.g., a thread that could reasonably be Product or Technical and the choice matters for routing). "Is this worth tagging?" is never a reason to pause — if it's actionable, tag it.

For each actionable thread, call `add_reaction` immediately:

```
add_reaction(channel="<channel>", message_ts="<thread_ts>", emoji="<emoji_name>")
```

Then present results as a markdown table:

```markdown
## Triage Summary — #eng-team (last 24h)

| # | Thread | Category | Emoji | Rationale |
|---|--------|----------|-------|-----------|
| 1 | "API rate limits hitting 429s in prod" | 🔧 Technical | `:wrench:` | Active bug requiring investigation and fix |
| 2 | "Should we support SSO for enterprise?" | 📋 Product | `:bookmark:` | Feature scoping decision needed from product |
| 3 | "Sprint retro notes" | ✅ No action | `:white_check_mark:` | Informational, no follow-up needed |

**Already tagged (skipped):** 4 threads
**Newly tagged:** 3 threads
```

## Classification Guidance

### Product (📋 `bookmark`)

Assign when the thread involves:
- **Feature decisions:** "Should we build X?" or "How should feature Y work for users?"
- **Prioritization:** "Is this P0 or P1?" or debate about what to build next
- **User-facing tradeoffs:** "Do we show an error or silently retry?"
- **Stakeholder alignment:** "Product and engineering disagree on scope"
- **Metrics/goals:** "Are we measuring the right thing?"

**Not product:** A discussion about how to technically implement an already-decided feature is Technical, not Product.

### Project (🗂️ `file_folder`)

Assign when the thread involves:
- **Timeline/scheduling:** "When will this ship?" or "Can we move the deadline?"
- **Dependency coordination:** "We're blocked on Team X's API"
- **Resource allocation:** "Who's picking up this work?"
- **Status updates that need action:** "This is at risk" (as opposed to "This is on track" which is no-action)
- **Process/ceremony:** "Let's restructure our sprint planning"

**Not project:** A thread where someone asks "what should we build?" is Product. A thread where someone asks "when will we finish building it?" is Project.

### Technical (🔧 `wrench`)

Assign when the thread involves:
- **Bugs:** Active issues, error reports, debugging discussions
- **Architecture decisions:** "Should we use Redis or Memcached?"
- **Code review requests:** "Can someone review this PR?"
- **Infrastructure:** "The deploy pipeline is broken"
- **Technical investigation:** "Why is latency spiking?"
- **Implementation approach:** "What's the best way to implement X?" (where X is already decided)

**Not technical:** "Should we even have a caching layer?" is Product (it's a feature/scope question). "Should we use Redis or Memcached for caching?" is Technical (the decision to cache is made, now it's implementation).

### No Action (✅ `white_check_mark`)

Assign when the thread is:
- **Informational/FYI:** Announcements, links shared, "just letting everyone know"
- **Already resolved:** The thread contains its own resolution — question asked and answered, problem reported and fixed
- **Social/team:** Celebrations, kudos, off-topic chat
- **Stale:** Discussion that clearly concluded days ago with no open items

**When in doubt:** If a thread *might* need action but you're not sure, do NOT tag it as no-action. Tag it with the most likely action category and note the uncertainty in the rationale. False positives (tagging something as needing action when it doesn't) are cheaper than false negatives (missing something that needed attention).

## Ambiguity Rules

1. **When a thread spans categories:** Tag the upstream/gating category. Product gates Project gates Technical.
2. **When classification is uncertain:** Tag with the most likely category and note uncertainty in the rationale column.
3. **When a thread has no replies but is clearly a question:** Classify based on the question content alone.
4. **When a thread is very long (>20 messages):** Focus classification on the latest 5-10 messages — the current state of the discussion matters more than how it started.

## Idempotency

This skill is designed to be run repeatedly on the same channel. The skip logic (Step 2) ensures that already-tagged threads are not re-classified. This means:

- Running twice in a row produces no new output (all threads already tagged)
- Running with a larger `hours_back` window picks up older untagged threads
- If someone removes a reaction, the thread becomes eligible for re-triage on the next run

