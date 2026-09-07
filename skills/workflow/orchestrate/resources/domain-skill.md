# Orchestrate Domain Skill — Example

Project-specific configuration for the orchestrate skill. This file is an **example**:
copy it into your own project and replace every value below with your project's real
conventions. The orchestrate skill reads whatever your copy declares.

## Project
- Name: Example App
- Default branch: `main`

## Work-Start Steps

When the task references a tracker ticket, execute these immediately on entering Execution (before starting any phase):
- **Set ticket status to "In Progress"** using your tracker's MCP tool
- **Assign the ticket to the operator** — look up the operator's user ID via the tracker's user-list tool if not already known, then set the assignee

These are idempotent — safe to re-run on session resumption.

## PR Conventions

- **Reviewers:** list your team's default reviewer handles here (e.g. `gh pr edit --add-reviewer <handle>`)
- **Ticket linking:** Branch names are prefixed with the lowercase ticket ID: `{ticket-id}-short-description` (e.g., `abc-13-chat-dm-delivery`). The PR title should be prefixed with the uppercase ticket ID: `ABC-13: Chat DM delivery`.
- **Merge policy:** Squash merge only (`gh pr merge --squash`). Merge commits and rebase are disabled.
- **Labels:** None required by default.

## Post-Ship Steps (after merge — operator-initiated)

These steps apply after the operator merges the PR, not during the SHIP phase:

### Tracker ticket update
If tracker MCP tools are available, update the ticket status. If not, note: "Update the tracker ticket status manually."

## CI Monitor Config

- CI runs parallel test jobs: `test(4, 0)` through `test(4, 3)`
- Other workflows: name the lint, unit-test, and visual-regression workflows your CI defines
- Test commands for local verification:
  - Backend: `docker compose exec web <test-runner> {files}`
  - Frontend: `docker compose exec web <js-test-runner> {files}`
- Lint commands:
  - Backend: `docker compose exec web <linter> {files}`
  - Frontend: `docker compose exec web <js-linter> {files}`
