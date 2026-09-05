---
name: pr-create
description: >
  Create or update a pull request with a rich, structured description.
  Supports two modes: (1) orchestrated — receives a pre-filled PR description
  from a verifier or other source, (2) standalone — gathers context from git
  and fills the template itself. Handles PR mechanics: create, update, push,
  reviewer assignment, ticket linking.
usage: "/pr-create [path-to-pr-description.md]"
capabilities:
  uses:
    - code-hosting
  optional:
    - browser-testing
---

# PR Create

Create or update a pull request with a structured description that helps reviewers understand what changed, what was tested, and where to focus.

**Input:** `{{input}}`

---

## Mode Detection

Determine which mode to run in:

1. **Orchestrated mode** — a file path to a pre-filled PR description was provided (e.g., `specs/{project}/pr-description.md`). Read that file and use it as the PR body. The verifier or other upstream agent already filled the template with verification context.

2. **Standalone mode** — no pre-filled description provided. Gather context and fill the template yourself (see "Standalone Context Gathering" below).

If `{{input}}` contains a `.md` file path → orchestrated mode.
Otherwise → standalone mode.

---

## Step 1: Gather State

Use the **code-hosting** capability. Default (gh CLI), run these in parallel:

```
git branch --show-current          # current branch name
git status                         # uncommitted changes
git log master..HEAD --oneline     # commits on this branch
gh pr list --head $(git branch --show-current) --json number,url,state --limit 1
```

From this determine:
- **Branch name** and **ticket ID** (extract from branch prefix, e.g., `abc-214` from `abc-214-add-csv-export` — see `resources/domain-skill.md` for this project's ticket prefix pattern; skip ticket linking if none is configured)
- **PR exists?** — if yes, this is an update; if no, this is a create
- **Uncommitted changes?** — if yes, commit first (ask user unless autonomy profile says otherwise)

---

## Step 2: PR Title

Format: `{TICKET}: {Short description}`

- Ticket ID is UPPERCASE in the title: `abc-214` branch → `ABC-214: ...`
- Use imperative mood: "Add", "Fix", "Update" — not "Added", "Fixed"
- Keep under 70 characters

If updating an existing PR, preserve the existing title unless the scope has changed.

---

## Step 3: PR Description

### Orchestrated Mode

Read the file path from `{{input}}`. This is the PR body — use it directly. The template was already filled by the verifier who has the best context on testing and risk.

### Standalone Mode

Fill the template yourself. Read `resources/pr-description-template.md` for the full template structure.

**Context gathering for standalone:**

```
git diff master...HEAD              # all changes on this branch
```

Then fill each section:
- **Summary**: Derive from commit messages and diff — what changed and why
- **Test plan**: Check what test files were added/modified. Run tests if not already green. Note coverage gaps honestly.
- **Blast radius**: Analyze the diff for each question in the template. Be specific about files.
- **Other risks**: Assess rollback safety, flag untested paths, note where reviewers should focus.

For **bug fix PRs** (detected from branch name containing "fix", or from commit messages), include the Root Cause and Fix addendum sections.

---

## Step 4: Project Conventions

Load PR conventions using the standard resolution order (see "Project and User Configuration" below). Reviewer assignment, ticket-linking requirements, merge policy, and labels are typically project-wide facts shared with other skills — prefer defining them once in the project's CLAUDE.md Capability Bindings rather than duplicating them in this skill's own `resources/domain-skill.md` (see Interoperates With below).

If conventions are found, apply:
- **Reviewer assignment** — via the **code-hosting** capability, default (gh CLI): `gh pr edit --add-reviewer {reviewers}`
- **Ticket linking** — ensure ticket ID is in branch name and PR title
- **Merge policy** — note in PR if relevant (e.g., squash-only)
- **Labels** — apply if conventions specify them

If no conventions are found in any configuration source, create the PR without reviewer assignment or special conventions.

---

## Step 4.5: Frontend QA Gate

Before executing (Step 5), check whether the diff touches this project's frontend code. Default pattern set, which works with no plugin at all — `resources/domain-skill.md` may narrow or replace it with a project-specific pattern, but the gate fires by default either way:

```bash
git diff master...HEAD --name-only -- '**/*.tsx' '**/*.jsx' '**/*.vue' '**/*.svelte' 'src/components/' 'assets/' 'app/javascript/'
```

If any files match:
1. **Check for browser QA evidence**, using the **browser-testing** capability where applicable — any of: UI system/integration tests covering the affected flows (new in the diff, or pre-existing — named in the test plan), a documented browser smoke check in the PR's test plan (pages/flows exercised, screenshot when feasible), or evidence from any other project-specific QA review process (`resources/domain-skill.md` documents what counts).
2. **If no evidence exists**, warn: "This PR modifies frontend files but has no browser QA evidence." Include the project's specific browser-verification requirement from `resources/domain-skill.md` if one is configured, otherwise state the generic expectation: owned tests or a documented smoke check for changes to user-facing code.
3. **In autonomous mode** (no user available to confirm override): treat missing evidence as a **hard block** — use the **browser-testing** capability to perform the missing verification (at minimum a browser smoke check documented in the PR's test plan: pages/flows exercised, screenshot when feasible; an owned test if the PR adds or changes a critical user journey) before proceeding to Step 5. Do not self-authorize a skip. If no browser-testing binding is configured, say so explicitly and ask the user how to proceed rather than skipping silently.
4. **In interactive mode**: present the warning and let the user decide whether to proceed without browser QA (acceptable for genuinely trivial changes like comment-only edits)

---

## Step 5: Execute

Use the **code-hosting** capability for all operations in this step. Default (gh CLI):

### Creating a New PR

```bash
git push -u origin {branch-name}
```

Then create the PR. Use a HEREDOC for the body to preserve formatting:

```bash
gh pr create --title "{TICKET}: {title}" --body "$(cat <<'EOF'
{pr description content}
EOF
)"
```

After creation, apply reviewer assignment and labels per project conventions.

### Updating an Existing PR

```bash
gh pr edit {number} --body "$(cat <<'EOF'
{pr description content}
EOF
)"
```

Update the title only if scope has changed.

---

## Step 6: Report

Output:
- PR URL
- Whether this was a create or update
- Reviewers assigned (if any)
- Any warnings (uncommitted changes found, no ticket ID detected, frontend QA gate triggered, etc.)

---

## Project and User Configuration

Load configuration in this order. **When multiple sources define the same binding,
the first one found wins** — stop checking lower sources for that binding:

1. Read `resources/personal-skill.md` if it exists — personal tool bindings and preferences.
2. Read `resources/domain-skill.md` if it exists — project-specific configuration.
3. Check the project's CLAUDE.md / CLAUDE.local.md for environment-level capability bindings (especially **code-hosting**, and any shared PR conventions per Interoperates With below).
4. For any capability still unbound, use the defaults specified in this skill.

## Extension Points

### domain-skill.md
Provide project-specific PR configuration:
- Ticket ID prefix/pattern used in branch names and titles (default: none — skip ticket linking if not configured)
- Frontend QA gate: the path pattern that identifies frontend code, and what counts as browser QA evidence for this project (test frameworks used, any additional review process, and the **browser-testing** binding that produces or verifies it)
- Any PR conventions that genuinely belong to this skill alone (conventions shared with other skills belong in CLAUDE.md instead — see Interoperates With)

### personal-skill.md
Provide personal preferences:
- Autonomy profile for handling uncommitted changes at Step 1 (ask vs. auto-commit)
- Preferred verbosity for Step 6 reporting

Example domain-skill.md excerpt for a Rails project:

```markdown
# example domain-skill.md excerpt
## Ticket Prefix
`abc-` (e.g. `abc-482-fix-export`) → title prefix `ABC-482`

## Frontend QA Gate
- **Path pattern:** `src/components/`
- **browser-testing binding:** Playwright specs under `src/` for owned coverage.
```

## Interoperates With

- **orchestrate** (or any pipeline/orchestration skill) — when PR conventions (reviewer assignment, ticket-linking, merge policy, labels) are needed by both pr-create and a pipeline skill, define them once in the project's CLAUDE.md Capability Bindings rather than having one skill read the other's `resources/` directly.
