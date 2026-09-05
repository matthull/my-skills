---
name: qa-plan
description: QA strategy and classification. Works in two modes — PR-scoped (analyze a diff) or feature-scoped (analyze a feature from docs, specs, and code exploration). Classifies verification items by execution channel, detects gaps, and produces a structured QA plan or test matrix. Use standalone or as the verification phase of a development pipeline.
capabilities:
  optional:
    - browser-testing   # Executes [BROWSER]-tagged items; degrades to a manual browser-flow description
---

# `/qa-plan` — QA Strategy and Classification

Analyze changes or a feature and produce a classified QA plan. Works standalone or as the verification phase of an autonomous development pipeline.

## Usage

```
/qa-plan                          # Analyze uncommitted changes (PR mode)
/qa-plan <branch>                 # Analyze branch diff against default branch (PR mode)
/qa-plan @<handoff-path>          # Analyze with handoff QA Expectations cross-check (PR mode)
/qa-plan <freeform description>   # Feature-scoped QA from docs, specs, code exploration
```

## Process

### Step 1: Gather Context

Determine the **scope mode** from the arguments:

#### Mode A: PR / Diff Scope (default when no freeform description)

1. **Get the diff** — `git diff` (uncommitted) or `git diff <default-branch>...<branch>` (branch)
2. **Identify changed files** — group by type (models, controllers, views, services, config, tests)
3. **Read handoff QA Expectations** — if handoff path provided or discoverable, extract expected verification scenarios

#### Mode B: Feature / Freeform Scope

When the user provides a freeform description, references docs/specs, or the scope clearly exceeds a single PR:

1. **Read provided documents** — PDFs, specs, handoffs, UAT plans, or any referenced files
2. **Explore the codebase** — use an Explore agent to map the feature surface area:
   - UI components, pages, and routes involved
   - Controllers and API endpoints
   - Models, state machines, and callbacks
   - Background workers and scheduled jobs
   - Mailers and notification paths
   - Tracking/analytics events
   - External integration triggers (webhooks, sync workers)
3. **Identify all verification channels** — don't limit to browser. Ask: what happens when this feature runs? Consider:
   - Browser UI (pages, modals, forms, navigation)
   - Email notifications (who gets notified, when, with what content)
   - Analytics events (what gets tracked, with what properties)
   - Database side effects (state transitions, cascading updates, callbacks)
   - Background jobs (what gets enqueued, retry behavior)
   - External integrations (third-party API syncs, webhooks)
   - File storage (uploads, attachments lifecycle)
   - Cron/scheduled processing
4. **Cross-reference with provided docs** — extract expected behaviors, known bugs, UAT feedback

**Key principle:** The context gathering phase should be thorough enough that the resulting test matrix covers the full feature, not just the obvious UI flows. Ask "what else happens?" after mapping the browser paths.

### Step 2: Test Data Assessment

If QA will involve local environment verification, assess whether adequate test data exists before planning execution.

**Quick check — does baseline data exist?**

1. Verify the database has been seeded with test/development data
2. If empty → flag immediately with the project's seed command as remedy

**Feature-specific data needs:**

For each verification scenario, ask: *does the required data exist?*

| Need | Example |
|------|---------|
| Specific records | Users, assets, orders in the right states |
| Records in specific states | Published, pending, rejected, etc. |
| Relationships | Parent with children, user with permissions |
| Feature flags / config | Required flags enabled for test account |

**Seed vs. ad-hoc decision:**

- **Add to seeds** when: common scenario, multiple features need it, baseline record type
- **Create ad-hoc** when: highly specific to this feature, temporary edge case, would add noise to seeds

**Output (include in QA plan):**

```markdown
### Test Data Readiness
- **Baseline seeds:** Present / NEEDS SEEDING
- **Feature-specific data:** Adequate / GAPS FOUND

| Missing Data | Remedy | Type |
|-------------|--------|------|
| {description} | {command or seed addition} | Seed / Ad-hoc |
```

### Step 3: Coverage Analysis

The depth of coverage analysis depends on the scope mode.

#### PR Mode: Analysis by Test Layer

Work through each testing layer systematically:

**Unit tests:**
- Are all new/modified code units covered by unit tests?
- Are edge cases tested (nil inputs, empty collections, boundary values, error paths)?
- Is anything that CAN be easily unit tested left untested? Flag it specifically.
- Are tests asserting meaningful behavior, not just exercising code paths?

**Integration / E2E tests:**
- Are key user-facing workflows covered end-to-end?
- If the change affects a UI workflow, is there a feature spec or system test?
- Are API endpoints tested with request specs if applicable?

**Component / visual tests:**
- For UI changes: are affected components covered in a component workbench (Storybook or equivalent)?
- Are interactive states tested (loading, error, empty, populated)?

**Console / REPL verification:**
- For data model changes or complex business logic: can behavior be verified in console?
- Note what should be verified and how.

**Non-test verification:**
- What scenarios need verification beyond permanent automated tests?
- Be specific: "Navigate to /orders, verify filter controls render" not "test the feature."
- If everything is covered by automated tests, explicitly state no additional QA needed.

#### Feature Mode: Analysis by Functional Area

Organize scenarios into functional areas (logical groupings of related behavior). For each area:

1. **Enumerate every verifiable behavior** — what should a user see, what should the system do?
2. **Include happy paths AND edge cases** — empty states, error states, boundary values, concurrent actions
3. **Include non-obvious side effects** — emails sent, events tracked, integrations triggered, state machine callbacks
4. **Assign IDs with area prefixes** — e.g., `S01` for Search, `CH01` for Checkout
5. **Write concrete steps and expected results** — specific enough that a QA agent or human could execute without ambiguity

### Step 4: QA Classification

Tag every verification item by **execution channel**:

#### Taxonomy

| Tag | Executor | Meaning |
|-----|----------|---------|
| `[TEST]` | CI / test suite | Covered by a permanent automated test in the codebase |
| `[BROWSER]` | Browser agent (**browser-testing** capability) | Browser E2E verification via automated feature reviews |
| `[CONSOLE]` | Console / DB | Verifiable via application console, DB queries, or job queue inspection |
| `[EMAIL]` | Email verification | Check mailer delivery, recipients, content |
| `[EVENTS]` | Analytics / tracking | Verify tracking events fired with correct properties |
| `[INTEGRATION]` | External sync | Verify third-party API interactions triggered correctly |
| `[EXTERNAL]` | Real external service | Cross-system integration requiring real external service interaction (not stubs). Examples: CRM write-back, OAuth flow against real IdP, webhook delivery to real endpoint |
| `[HUMAN]` | Manual tester | Requires subjective judgment or access automation doesn't have |

For PR-scoped plans, `[BROWSER]` and `[CONSOLE]` may be sufficient. For feature-scoped plans, use the full taxonomy — the broader tags help ensure nothing falls through the cracks.

#### Classification Heuristics

| Verification Need | Tag |
|---|---|
| Navigate page, verify content renders | `[BROWSER]` |
| Fill form, submit, verify result | `[BROWSER]` |
| Multi-step UI workflow (login → action → verify) | `[BROWSER]` |
| Screenshot for visual verification | `[BROWSER]` |
| Verify data model state, record counts, field values | `[CONSOLE]` |
| Verify state machine transitions and callbacks | `[CONSOLE]` |
| Verify background job enqueued/completed | `[CONSOLE]` |
| Verify feature flag behavior | `[CONSOLE]` |
| Verify log output | `[CONSOLE]` |
| Verify API endpoint response | `[CONSOLE]` (curl) or `[BROWSER]` (browser) |
| Verify email sent, recipients, content | `[EMAIL]` |
| Verify analytics event fired with properties | `[EVENTS]` |
| Verify external sync triggered | `[INTEGRATION]` |
| Verify write-back to external service (e.g., a CRM, HubSpot) | `[EXTERNAL]` |
| Verify OAuth flow against real identity provider | `[EXTERNAL]` |
| Verify webhook delivery to real external endpoint | `[EXTERNAL]` |
| Verify end-to-end data flow through external API (not stubbed) | `[EXTERNAL]` |
| Subjective UX judgment ("does it feel right?") | `[HUMAN]` |
| Cross-browser / mobile device testing | `[HUMAN]` |
| Production environment access required | `[HUMAN]` |
| Credentials or systems automation can't reach | `[HUMAN]` |

Items can have multiple tags (e.g., `[BROWSER]` + `[CONSOLE]`) when verification spans channels.

#### `[EXTERNAL]` Detection Heuristic

When the feature involves outbound API calls to external services — especially write-backs, webhooks, or OAuth flows — flag at least one `[EXTERNAL]` item even if all API calls are stubbed/mocked in tests. The heuristic: **if the feature's value proposition depends on a real external service response, stubbed tests are necessary but not sufficient.**

Signals that `[EXTERNAL]` items are needed:
- The feature writes data to a third-party system (a CRM, HubSpot, Stripe, etc.)
- The feature depends on an OAuth handshake with an external IdP
- The feature sends webhooks or callbacks to external URLs
- The feature reads from an external API where response fidelity matters (not just "returns 200")

`[INTEGRATION]` (stubbed) and `[EXTERNAL]` (real) are complementary — `[INTEGRATION]` verifies the code triggers the right calls with the right payloads; `[EXTERNAL]` verifies the real service accepts them and produces the expected outcome.

#### `[EXTERNAL]` Disposition

| Condition | Disposition |
|-----------|-------------|
| No credentials or sandbox available | `DEFER:ENV` — create a follow-up E2E validation ticket |
| Sandbox credentials available | `BROWSER` (navigate external UI via the **browser-testing** capability) or `AGENT` (make real API calls) |

Items deferred with `DEFER:ENV` must include an explicit recommendation in the QA plan output:

> **DEFER:ENV — External Service Verification Required**
> These items require real external service access. If credentials/sandbox are not available, create a follow-up E2E validation ticket. Stubbed tests confirm code correctness but cannot verify the external system accepts the integration.

### Step 5: Gap Detection

Flag as **CRITICAL GAP** any scenario that has:
- No automated test (`[TEST]`) AND
- No QA plan (no tag from any execution channel)

A scenario covered by any execution channel tag is acceptable. A scenario covered by nothing is not.

### Step 6: Cross-Check Against Source Documents

**PR mode:** If handoff(s) contain `## QA Expectations`, verify every handoff scenario is covered. Missing handoff scenarios should be flagged.

**Feature mode:** Cross-reference against all provided source documents (UAT plans, specs, requirement docs). Flag any documented behavior, known bug, or expected scenario that isn't covered by at least one test matrix row. Also flag UAT bugs as explicit regression test rows.

### Step 7: Output

The output format depends on the scope mode.

#### PR Mode Output

```markdown
## QA Plan

### Test Data Readiness
- **Baseline seeds:** Present / NEEDS SEEDING
- **Feature-specific data:** Adequate / GAPS FOUND

| Missing Data | Remedy | Type |
|-------------|--------|------|
| {description} | {command or seed addition} | Seed / Ad-hoc |

### Coverage Assessment
- **Unit tests:** ADEQUATE / GAPS FOUND
- **Integration tests:** ADEQUATE / GAPS FOUND / N/A
- **Component tests:** ADEQUATE / GAPS FOUND / N/A
- **Overall:** ADEQUATE / GAPS FOUND

### Gaps (if any)
| Gap | Layer | Blocking? | Recommendation |
|-----|-------|-----------|----------------|
| {description} | {unit/integration/etc} | Yes/No | {what to add} |

### Classified QA Items

| # | Scenario | Tag | Tool/Method |
|---|----------|-----|-------------|
| 1 | {description} | [TEST] | {test file/name} |
| 2 | {description} | [BROWSER] | {browser flow description} |
| 3 | {description} | [CONSOLE] | {console command/query} |
| 4 | {description} | [HUMAN] | {what human checks} |

### Source Document Cross-Check
- [x] {handoff scenario} — covered by item #N
- [ ] {handoff scenario} — **NOT COVERED** (add to plan)

### Summary
- **[TEST]:** {count} items (covered by CI)
- **[BROWSER]:** {count} items (browser verification)
- **[CONSOLE]:** {count} items (backend verification)
- **[EXTERNAL]:** {count} items (real external service verification)
- **[HUMAN]:** {count} items (user action needed)
- **Critical gaps:** {count or "none"}
```

#### Feature Mode Output — Test Matrix

For feature-scoped QA, produce a comprehensive test matrix organized by functional area. Each area gets its own table. Include prioritization tiers and source document cross-references.

```markdown
# {Feature Name} — QA Test Matrix

**Feature:** {description}
**Source:** {list of source documents used}
**Purpose:** Comprehensive QA test scenarios — {list relevant channels}
**Date:** {date}

## Test Classification
{taxonomy table — only include tags actually used}

## Prerequisites
{what must be true before testing}

## Area N: {Functional Area Name}

| ID | Scenario | Steps | Expected Result | Tag |
|----|----------|-------|-----------------|-----|
| {prefix}{nn} | {description} | {steps} | {expected} | {tag(s)} |

## Summary
| Tag | Count | Description |
|-----|-------|-------------|
{counts per tag}

## Prioritization
### P0 — Core Happy Path
### P1 — Critical Workflows
### P2 — Regression Tests (from source doc bugs/issues)
### P3 — Data Integrity & Side Effects
### P4 — Robustness & Edge Cases

## Source Document Cross-Reference
{checklist of scenarios from source docs mapped to matrix IDs}
```

## Execution Guidance

Once the QA plan or test matrix is produced, items are executed by channel:

- `[TEST]` — CI handles these; informational only
- `[BROWSER]` — Execute via the **browser-testing** capability; track links and results in the matrix. If no browser-testing binding is configured, write the item as a concrete manual browser-flow description (steps + expected result) instead of an automated run.
- `[CONSOLE]` — Execute via application console or DB queries
- `[EMAIL]` — Verify via mailer previews or delivery logs
- `[EVENTS]` — Query the analytics events table
- `[INTEGRATION]` — Inspect job queues or external system dashboards
- `[EXTERNAL]` — If sandbox/credentials available: execute via the **browser-testing** capability or real API calls. If not: defer with `DEFER:ENV` and recommend a follow-up E2E validation ticket
- `[HUMAN]` — Surface as follow-up items for manual verification

For feature-scoped matrices, treat the output as a living document — update it as tests are executed, track results inline, and flag bugs found during execution for follow-up.

## Interoperates With

- **`/spec-check`** — if a spec-check run flags a requirement as unverified, treat it as a candidate QA item; no shared configuration required.
- **Handoff-producing skills (e.g., a pipeline or spec skill)** — PR mode reads `## QA Expectations` from a handoff if one is provided. The handoff format itself is owned by whichever skill produces it, not by qa-plan.
- **Browser-testing companion skill** — `[BROWSER]` and `[EXTERNAL]` items execute through the **browser-testing** capability. The binding (which tool actually drives the browser) belongs in CLAUDE.md / CLAUDE.local.md so any skill that needs browser automation resolves to the same tool.

## Project and User Configuration

Load configuration in this order. **When multiple sources define the same binding,
the first one found wins** — stop checking lower sources for that binding:

1. Read `resources/personal-skill.md` if it exists — personal QA preferences.
2. Read `resources/domain-skill.md` if it exists — project-specific QA configuration.
3. Check the project's CLAUDE.md / CLAUDE.local.md for environment-level capability bindings (especially **browser-testing**).
4. For any capability still unbound, use the defaults specified in this skill (write `[BROWSER]`/`[EXTERNAL]` items as manual browser-flow descriptions instead of automated runs).

## Extension Points

### domain-skill.md
Provide project-specific QA configuration:
- Seed command and how to check whether baseline test data exists
- Project-specific test data conventions (factories, fixtures, common record states)
- Non-standard verification channels beyond the standard taxonomy, if this project has them
- Sandbox/credential availability for `[EXTERNAL]` items, and where to find them

### personal-skill.md
Provide personal QA preferences:
- Preferred level of detail in test matrix steps
- Notification routing when a QA plan finds a CRITICAL GAP
- Default scope mode when ambiguous (PR vs feature)
