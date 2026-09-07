---
name: spec
description: >
  Create or update a feature specification from a natural language feature
  description. Enforces brownfield-first discovery, traceability tags,
  research coordination, and incremental document creation. Use when
  starting design work on a new feature or enhancement.
---

# Technical Specification Command

Create a well-researched technical specification that defines WHAT to build, not HOW to build it.

## Input

Feature description: `{{input}}`

---

## Core Principles

### 1. WHAT, Not HOW

Specs define outcomes, contracts, and responsibilities - never implementation details.

| SPECIFY | DON'T SPECIFY |
|---------|---------------|
| API endpoints & response shapes | Service class internals |
| Data model fields & relationships | Helper method implementations |
| Component responsibilities | File organization |
| UI structure (wireframe-level) | CSS/styling details |
| Test scenarios (behaviors to verify) | Test implementation |
| Method signatures | Method bodies |

### 2. Code Shows Structure, Not Logic

Code in specs shows signatures and flow - never implementation logic.

**The Coordination Test** determines what to specify:
- **Specify (contracts):** If changing it requires coordinating across modules → put it in the spec
- **Don't specify (implementation):** If it can change without external impact → leave to implementor

| Specify | Don't Specify |
|---------|---------------|
| Data structures used across modules | Internal helper methods |
| Method signatures (entry points, contracts) | Method body logic |
| API response shapes | Validation details |
| Cross-cutting data shapes | Logging specifics |

**Litmus Test:** Could you copy-paste the code and have it work? If yes, you over-specified.

**Good - structure and flow:**
```ruby
def self.call(input_id:)
  record = load_record(input_id)
  context = extract_context(record)
  recipients = find_recipients(record)

  # Process each recipient
  recipients.map { |r| process(r, context) }

  # Returns: { input_id:, results: [...] }
end
```

**Bad - implementation logic:**
```ruby
def quality_metrics
  {
    field_count: data.fields.size,
    has_name: data.name.present?,
    score: (filled.size / total.to_f).round(2)
  }
end
```

**Same thing, spec-appropriate:**
```ruby
def quality_metrics
  # Returns hash for logging - shape is internal to this class
  { ... }
end
```

**WHEN CODE IS APPROPRIATE:**

| Use Case | Example | Why It Helps |
|----------|---------|--------------|
| Data shapes / response formats | `{ id: number, name: string }` | Defines the contract |
| Method signatures | `def foo(bar:, baz:)` | Shows interface without implementation |
| Existing code references | `TestimonialRenderOptions::THEME_TYPES` | Points to source of truth |
| Migration schemas | `add_column :users, :role, :string` | Defines data model |
| API request/response examples | JSON snippets | Clarifies contract |

**WHEN CODE IS NOT APPROPRIATE:**

| Anti-Pattern | Problem | Better Approach |
|--------------|---------|-----------------|
| Full method bodies | Specifies HOW, not WHAT | Describe behavior in prose |
| Validation logic | Implementation detail | List validation rules as bullets |
| Conditional flows | Over-specifies | Describe fallback behaviors in prose |
| Helper methods | Premature abstraction | Let implementation decide structure |
| Class definitions | File organization | Describe responsibilities instead |

**Rule of thumb:** If the code block is >5 lines or contains logic (if/else, loops, error handling), it's probably too much. Describe the BEHAVIOR instead and let implementation figure out the code.

**Good example - reference without implementation:**
```markdown
- **Valid themes**: Use `TestimonialRenderOptions::THEME_TYPES` as source of truth
- **Invalid theme** → fall back to 'basic'
- **Custom theme deleted** → fall back to 'basic'
```

**Bad example - over-specified logic:**
```ruby
def get_theme
  if VALID_THEMES.include?(theme)
    if CUSTOM_THEMES.include?(theme)
      # ... 15 more lines of logic
    end
  end
end
```

### 3. Incremental Document Creation

**Create the spec file immediately — don't wait until discussion is complete.** The spec document is a living artifact that grows alongside research and discussion, not a final deliverable produced at the end.

- **Create the skeleton first:** After context gathering (step 1), write the spec file with header, traceability legend, section headings, and TBD placeholders
- **Fill incrementally:** Each research finding, decision, or discussion outcome gets written into the spec as it happens
- **Placeholders are expected:** `TBD`, `[needs research]`, empty sections are all fine — they make gaps visible and enable multi-session work
- **Avoid the "long conversation → giant draft" antipattern:** If you've been discussing for 10+ minutes without updating the spec file, something is wrong

**Why this matters:**
- Work can be split across sessions — the file captures progress even if the session ends early
- Gaps are visible — TBD sections show exactly what still needs work
- Reduces cognitive load — findings are recorded immediately, not held in conversation context
- Enables parallel exploration — user can read the evolving spec while discussion continues

### 4. Brownfield First (CRITICAL)

Before specifying ANYTHING new, exhaustively search for existing solutions.

See `resources/brownfield-development.md` for brownfield development principles.

**Discovery questions:**
- Does a similar pattern already exist?
- Can an existing model/service be EXTENDED instead of creating new?
- What conventions does the codebase follow for similar features?
- Are there tests covering related functionality to learn from?

**Pattern discovery:**
```bash
rg "SimilarPattern" --type ruby
rg "relatedEndpoint" --type ts
find app/ -name "*related*"
find spec/ -name "*similar*_spec.rb"
```

### 5. Let Abstractions Emerge

Don't pre-plan internal structure. Let complexity drive extraction.

| Anti-Pattern | Better Approach |
|--------------|-----------------|
| "Create UserEngagementService" | Describe the data contract; implementation structure emerges during coding |
| "Add helper module for X" | Describe what X does; extract helper only when complexity demands |
| "Organize into these files" | Describe responsibilities; file organization follows naturally |

### 6. Third-Party API Research

When specs involve external systems, research official documentation FIRST and create project-specific API reference docs.

See `resources/doc-extraction-mandatory.md` for API documentation extraction requirements.

**Protocol:**
1. Identify all third-party APIs the feature will integrate with
2. WebFetch official API documentation
3. Extract and quote relevant endpoints, request/response formats
4. Create `specs/<feature>/api-reference.md` with project-specific docs
5. Reference this doc in the main spec

**Why create project-specific docs?**
- Official docs are often sprawling; extract only what's needed
- Provides quick reference during implementation
- Documents assumptions and decisions about API usage
- Creates reusable knowledge for future features

**API reference should include:**
```markdown
## [Service Name] API Reference

**Base URL:** [from docs]
**Auth:** [from docs]

### Endpoint: [Name]
- **Method:** [QUOTE from docs]
- **Path:** [QUOTE from docs]
- **Request:** [QUOTE from docs]
- **Response:** [QUOTE from docs]
- **Our usage:** [How we'll use this endpoint]
```

---

## Phase 0: Research Coordination (CRITICAL FIRST STEP)

**The main conversation's primary role at spec start is RESEARCH COORDINATOR.**

Before writing any specification, you must gather solid evidence for the approach. The type of research depends on context:

### Research Assessment Matrix

| Context | Primary Research Focus | Method |
|---------|----------------------|--------|
| **Adding to existing codebase** | Conventions, patterns, existing code | Explore agents, Grep, Read existing files |
| **External services (new to project)** | Official docs, community patterns, examples | `/request-research` → `/research` or external |
| **External services (established in project)** | Existing integration patterns + any updates | Both internal exploration AND external research |
| **Industry-standard patterns** | Best practices, security considerations | Heavy external research before specifying |
| **Novel/custom features** | Similar solutions in other projects | Moderate external research |

### When to Create Research Requests

**Use `/request-research` liberally.** Create research requests when ANY of these apply:

1. **First-time integration** with a service/library (Supabase, PowerSync, Stripe, etc.)
2. **Security-sensitive features** (auth, RLS, encryption, secrets management)
3. **Industry-standard patterns** where best practices exist (multi-tenancy, caching, etc.)
4. **Uncertainty about approach** - if you're not confident, research first
5. **Multiple valid approaches** - research helps choose between them
6. **Framework/library updates** - patterns may have changed since last use

### Research Request Targets

Research requests are portable documents. They can be executed via:
- **Local `/research` command** - Parallel subagent approach
- **Claude.ai web research** - Alternative research path
- **Other research tools** - Any capable agent

Create requests that work for ANY research executor (no internal file references).

### Research Coordination Workflow

1. **Assess research needs** using the matrix above
2. **Create research requests** via `/request-research` for each external topic
3. **Execute research** through appropriate channels (local and/or external)
4. **Analyze reference projects** if available (clone repos, read their patterns)
5. **Synthesize findings** into evidence base
6. **THEN proceed to spec writing** - only after research is complete

### Research Quality Checklist

Before proceeding to spec writing:
```
□ All external services/libraries researched via official docs?
□ Community patterns and best practices identified?
□ Reference repos/starter packs analyzed (if available)?
□ Security considerations researched (if applicable)?
□ Research findings documented (in research/findings/ or spec folder)?
□ Confidence level high enough to specify approach?
```

**If confidence is low, do more research. Specs built on assumptions fail during implementation.**

---

## Traceability (MANDATORY)

**Every requirement in the spec MUST be tagged with its evidence source.** When citing primary sources (meetings, Slack threads, documents), use the citation format from the `/citations` skill — markdown footnotes with chain of evidence propagation.

### Traceability Tags

| Tag | Meaning | When to Use |
|-----|---------|-------------|
| `[R:filename]` | **Research-backed** | Requirement comes from research docs |
| `[B:context]` | **Business requirement** | From roadmap, user stories, stakeholder input |
| `[D:reason]` | **Decision** | Implementation choice not from research (explain why) |
| `[E:existing]` | **Extends existing** | Builds on existing code/pattern in codebase |
| `[U:topic]` | **Unbacked** | No research found - flagged for validation |

### Why Traceability Matters

1. **Accountability** - Know WHY each requirement exists
2. **Validation** - Unbacked items get flagged for review
3. **Change management** - When research updates, know what specs to revisit
4. **Debugging** - When implementation differs from spec, trace back to source
5. **Knowledge transfer** - New team members understand rationale

### Traceability Examples

**Good - Tagged with source:**
```markdown
### Session Storage
- Use MMKV with encryption `[R:auth-flow-session.md]`
- Encryption key in SecureStore `[R:auth-flow-session.md]`
- Separate instance for auth vs preferences `[D:separation-of-concerns]`
```

**Bad - No traceability:**
```markdown
### Session Storage
- Use MMKV with encryption
- Encryption key in SecureStore
- Separate instance for auth vs preferences
```

### Extraction Step (Recommended for Complex Features)

For features with significant research, create an extraction doc BEFORE the spec:

1. Create `specs/<feature>/<phase>-extraction.md`
2. Map each requirement area to research coverage
3. Identify gaps (items with no research backing)
4. Resolve gaps via decisions or additional research
5. Flag remaining unbacked items with `[U:topic]`

**Extraction doc structure:**
```markdown
## 1. [Requirement Area]

### Research Coverage: COMPLETE | PARTIAL | NONE

**What's documented:**
- [List items from research with source]

**Gaps identified:**
- [ ] [Missing item] - needs research or decision

### Resolution
- [How gaps were resolved or flagged]
```

### Traceability Audit

Before finalizing spec, verify:
```
□ Every schema field tagged?
□ Every configuration value tagged?
□ Every behavior/contract tagged?
□ All [U:*] items explicitly acknowledged?
□ Research file references are accurate?
```

---

## Workflow

### 1. Context Gathering

Parse the feature description and clarify with user:
- Output location (suggest `specs/<feature-name>/` or project convention)
- Scope boundaries if description is ambiguous
- Any existing specs to update vs. new spec needed
- **Research needs assessment** (see Phase 0 matrix)

### 2. Create Spec Skeleton (IMMEDIATELY)

After agreeing on output location, **create the spec file now** — before any research. Use the header template from the Output section, add section headings based on the feature description, and mark everything TBD:

```markdown
# [Feature] Specification

**Status:** Draft
**Created:** [date]

---

## Traceability Legend
[standard legend]

---

## Overview
TBD

## Domain Dictionary
[Define the core terms and concepts used in this feature. Each entry
should name the concept, explain what it is in plain language, note
key relationships to other concepts, and flag whether it's new or
extends something existing. This section anchors all other sections —
if a term appears in the spec, it should be defined here.]

TBD

## Workflow / Dataflow
[Show how data and control flow through the system for this feature.
Choose the representation that fits: a text flowchart for a linear
pipeline, prose for a simple feature, a sequence of steps for a
multi-actor interaction. The goal is to give the reader a mental
model of the happy path before they dive into details.]

TBD

## [Section based on feature]
TBD

## Test Scenarios
TBD

## Out of Scope
TBD

## Retrospective
TBD
```

This file is now the living artifact. All subsequent steps UPDATE this file rather than producing a separate document at the end.

### 3. Brownfield Discovery

Before filling in the spec, conduct thorough codebase research:

**Discovery checklist:**
- [ ] Searched for existing patterns solving similar problems
- [ ] Identified models/services that could be extended (not duplicated)
- [ ] Found similar implementations to learn conventions from
- [ ] Checked for existing tests covering related functionality
- [ ] Documented all findings

### 3b. Third-Party API Research (if applicable)

If the feature integrates with external systems:

- [ ] Identified all third-party APIs involved
- [ ] Fetched and read official documentation
- [ ] Extracted relevant endpoints and contracts
- [ ] Created `specs/<feature>/api-reference.md`

**Update the spec file** with findings from brownfield discovery and API research before proceeding.

### 4. Specification Completion

By this point, much of the spec should already be filled in from steps 2-3b. Review the spec file for remaining TBDs and fill them in. Ensure these are addressed:

**Completeness checklist:**
```
□ Brownfield discovery documented
□ Third-party API reference created (if applicable)
□ Extraction doc created (if complex feature with research)
□ Interfaces defined (API contracts, method signatures, data shapes)
□ Responsibilities clear (what each component does)
□ Dependencies identified (existing code to use/extend)
□ Data flow described (how information moves between components)
□ Test scenarios listed (behaviors Claude will verify as QA Engineer)
□ Out of scope defined (explicit exclusions)
□ Every requirement tagged with traceability [R/B/D/E/U]
```

### 4b. Generate verify-specs.sh (Backend Work)

**If the spec involves backend work (Ruby/Rails, services, controllers, models):**

Generate a `verify-specs.sh` script that provides a focused test loop during implementation. This is critical because full test suites often take 10+ minutes.

**IMPORTANT:** The spec document MUST reference the verify script in its header metadata. Example:
```markdown
**Verify Script:** `specs/<feature>/verify-specs.sh`
```

**See example:** `specs/usage-dashboard/verify-specs.sh`

**Script structure:**
```bash
#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "Feature: [FEATURE_NAME] Verification"
echo "========================================"

# Track results
TESTS_PASSED=true
RUBY_LINT_PASSED=true

# Pattern-based spec discovery - CUSTOMIZE THESE PATTERNS
SPECS=$(find spec -type f -name '*_spec.rb' \( -path '*PATTERN1*' -o -path '*PATTERN2*' \) 2>/dev/null | sort)

if [ -n "$SPECS" ]; then
  echo "Running RSpec tests..."
  docker compose exec -T web bundle exec rspec $SPECS --format documentation || TESTS_PASSED=false
else
  echo -e "${YELLOW}No specs found yet (pre-implementation)${NC}"
fi

# Ruby linting - CUSTOMIZE THESE PATTERNS
RUBY_FILES=$(find app lib -type f -name '*.rb' \( -path '*PATTERN*' \) 2>/dev/null | head -20)
if [ -n "$RUBY_FILES" ]; then
  echo "Running Rubocop..."
  rubocop $RUBY_FILES --force-exclusion || RUBY_LINT_PASSED=false
fi

# Summary
echo "========================================"
echo "Verification Summary"
echo "========================================"
$TESTS_PASSED && echo -e "${GREEN}✓ Tests: PASSED${NC}" || echo -e "${RED}✗ Tests: FAILED${NC}"
$RUBY_LINT_PASSED && echo -e "${GREEN}✓ Ruby Lint: PASSED${NC}" || echo -e "${RED}✗ Ruby Lint: FAILED${NC}"
```

**Customize patterns for:**
- Spec files that will test the feature
- Ruby files that will be created/modified
- JavaScript files if applicable (add ESLint section)

### 5. Iterative Fill-In

As research and discussion progress, **update the spec file incrementally**. Don't accumulate findings in conversation and write them all at once — write them into the spec as you go:

- After brownfield discovery → fill in the dependencies and existing patterns sections
- After API research → fill in contracts and data shapes
- After each decision → replace the relevant TBD with the decision and its traceability tag
- After test scenario discussion → fill in the test scenarios section

**Each update is a small edit**, not a rewrite. The spec grows organically alongside the conversation.

### 5b. Viewpoint-Based Review

After the spec draft is substantially filled in, fan out parallel review subagents, each critiquing the spec from a specific narrow viewpoint. The diversity of perspectives catches what any single reviewer misses.

**Deriving viewpoints (check all three sources):**

1. **Stakeholder perspectives** — Who cares about this feature? End users, ops team, the dev who maintains it, QA, product. For each relevant stakeholder, ask: *"What's their specific stake in THIS feature?"* That becomes a review lens. Not "what does QA generally care about" but "what would QA specifically worry about in this feature?"

2. **Research-derived perspectives** — Research gathered in Phase 0 often represents distinct domain viewpoints. An article on Vite's dev server and an article on Rails asset pipeline conventions are two different lenses. Each can critique the spec from its own domain expertise. If Phase 0 produced multiple research sources, each is a candidate perspective.

3. **Concern-driven perspectives** — What cross-cutting concerns does this feature touch? Performance, security, migration safety, backwards compatibility, developer ergonomics, accessibility. Each becomes a lens.

**Process:**
- Derive 3-7 viewpoints from the sources above (scale with spec complexity)
- Fire one subagent per viewpoint (use sonnet)
- Each gets: the spec draft + the feature intent + their narrow lens
- Each independently critiques from that single viewpoint
- Synthesize: deduplicate, identify agreement (high confidence) vs. conflict (needs judgment)
- Update the spec with findings before presenting to user

**Why this works:** A single reviewer — no matter how thorough — has blind spots inherent to their perspective. A security reviewer doesn't see performance implications. A performance specialist doesn't see UX friction. Viewpoint-based review applies multiple lenses simultaneously, and the synthesis reveals what no single lens could. This is especially powerful when the feature sits at the intersection of multiple domains.

**For the full formula** (including witness-derived perspectives and detailed protocol), see `/calcinatio` skill → `resources/viewpoint-based-manifold-calcinatio.md`.

### 6. Review with User

Present the spec and ask:
- Does this capture the intended scope?
- Any missing requirements?
- Any concerns about the proposed approach?

### 7. Include Retrospective Section

**Every spec MUST include a "Retrospective" section** that defines what to review when the feature is complete.

**Why:** Implementation produces valuable learnings captured in task handoffs. Without explicit review, these insights are lost instead of improving documentation, plans, skills, and workflows.

**Template:**
```markdown
## Retrospective

When this feature is complete, review all task handoffs and extract:

### Documentation Updates
- [ ] Architecture decisions that should be documented
- [ ] Patterns discovered that others should know about
- [ ] Environment/tooling gotchas worth capturing

### Project Plan Updates
- [ ] Scope changes that affect the roadmap
- [ ] New dependencies or constraints discovered
- [ ] Estimates vs actuals for future planning

### Workflow Improvements
- [ ] Skills or commands that could be created/updated
- [ ] Template sections that were missing or unclear
- [ ] Process friction points to address

### Knowledge Capture
- [ ] Reusable code patterns to document
- [ ] External API quirks worth noting
- [ ] Testing strategies that worked well
```

**Adapt the checklist** based on feature type - not all items apply to every feature.

### 8. Product Team FYI Section

**Every spec should include a "Product FYI" section** with pre-written Slack messages for decisions that need product awareness.

**Philosophy: "Inform and move on"**
- Default: Make reasonable decisions, FYI product in Slack ("Going this route, lmk if not ok")
- Exception: Flag for discussion when there's significant risk, large investment, or user-facing impact

**Categorize decisions:**

| Category | Action | Example |
|----------|--------|---------|
| **Routine technical** | No FYI needed | "Using the existing ArticleList model" |
| **Product-visible but low risk** | FYI, move on | "Emails will be plain text for MVP" |
| **Risk or user impact** | FYI, await response | "Unpublished drafts could leak to end users" |
| **Major scope/investment** | Discuss before proceeding | "Need to build new auth system" |

**Template for spec:**
```markdown
## Product FYI

Decisions that product team should be aware of. Copy-paste to Slack as needed.

### FYI - Moving Forward (no response needed unless concerns)

**[Topic]:** [What we decided and why, casual tone]

### Flagged for Input (please confirm or redirect)

**[Topic]:** [The tradeoff or risk, what we're leaning toward, why we're flagging]
```

**Example messages:**
```markdown
### FYI - Moving Forward

**Email format:** Going with plain text emails for MVP. Simpler to build,
can add HTML templates in phase 2 if adoption warrants. Lmk if you want
HTML from the start.

### Flagged for Input

**Public article lists:** Recipients can't log in, so the recommendation
links need to be publicly accessible. This means we can only include
*published* articles (otherwise unpublished drafts could leak to end users).
This seems right but flagging since it's a data exposure consideration.
Want to confirm this approach before we build it.
```

---

## Spec Quality Checklist

Before finalizing, verify:

```
RESEARCH GROUNDING
□ Research requests created for external services/libraries?
□ Official documentation consulted and cited?
□ Community patterns/best practices identified?
□ Reference projects analyzed (if available)?
□ Research findings documented and referenced in spec?

TRACEABILITY
□ Traceability legend included in spec header?
□ Every requirement tagged with [R/B/D/E/U]?
□ Extraction doc created (if complex feature)?
□ All gaps identified and resolved or flagged [U:*]?
□ Research file references accurate and verifiable?
□ No unbacked items without explicit acknowledgment?

VIEWPOINT-BASED REVIEW
□ Viewpoint-based review completed?
□ Stakeholder perspectives derived and critiqued?
□ Research-derived perspectives used (if Phase 0 produced multiple sources)?
□ Concern-driven perspectives identified for cross-cutting issues?
□ Synthesis findings incorporated into spec?

SPEC CONTENT
□ Domain dictionary defines core terms and concepts?
□ Workflow/dataflow shows how the feature works end-to-end?
□ Focused on WHAT not HOW?
□ Code shows structure/flow, not implementation logic?
□ Litmus test passed? (Could copy-paste and it works = over-specified)
□ Only cross-cutting data structures specified? (Coordination Test)
□ Brownfield discovery completed and documented?
□ Existing patterns/models identified for extension?
□ Third-party APIs researched and documented (if applicable)?
□ verify-specs.sh created (if backend work)?
□ verify-specs.sh referenced in spec header (if created)?
□ Avoided pre-planning services/helpers?
□ Clear contracts between components?
□ Test scenarios describe behaviors, not implementations?
□ Retrospective section included with review checklist?
□ Product FYI section with pre-written Slack messages?
```

---

## Output

The spec file is created early (step 2) and filled incrementally. By the time the workflow completes, it should be a full specification. Common structures:
- Single file: `specs/<feature>/spec.md`
- With supporting docs: `specs/<feature>/requirements.md`, `specs/<feature>/api-contracts.md`
- With third-party integration: `specs/<feature>/api-reference.md` (external API docs)
- With research extraction: `specs/<feature>/<phase>-extraction.md` (research-to-requirement mapping)
- With backend work: `specs/<feature>/verify-specs.sh` (make executable with `chmod +x`)

**Spec header should include:**
```markdown
# [Feature] Specification

**Phase:** [if applicable]
**Status:** Draft
**Created:** [date]
**Extraction Doc:** `specs/<feature>/<phase>-extraction.md` (if created)

---

## Traceability Legend

| Tag | Meaning |
|-----|---------|
| `[R:filename]` | Research-backed |
| `[B:context]` | Business requirement |
| `[D:reason]` | Decision |
| `[E:existing]` | Extends existing |
| `[U:topic]` | Unbacked |

---
```

Remind user to review before implementation begins.
