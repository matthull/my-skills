# Orchestrate Domain Skill — Example App

Project-specific configuration for the orchestrate skill when running in the Example App project.

## Project
- Name: Example App
- Default branch: master

## Work-Start Steps

When the task references a Linear ticket, execute these immediately on entering Execution (before starting any phase):
- **Set ticket status to "In Progress"** using `mcp__linear__save_issue`
- **Assign the ticket to Matt** — look up Matt's user ID via `mcp__linear__list_users` if not already known, then set `assigneeId` via `mcp__linear__save_issue`

These are idempotent — safe to re-run on session resumption.

## PR Conventions

- **Reviewers:** `reviewer-one` and `reviewer-two` (use `gh pr edit --add-reviewer reviewer-one --add-reviewer reviewer-two`)
- **Ticket linking:** Branch names are prefixed with the lowercase ticket ID: `{ticket-id}-short-description` (e.g., `abc-13-slack-dm-delivery`). The PR title should be prefixed with the uppercase ticket ID: `ABC-13: Slack DM delivery`.
- **Merge policy:** Squash merge only (`gh pr merge --squash`). Merge commits and rebase are disabled.
- **Labels:** None required by default.

## Post-Ship Steps (after merge — operator-initiated)

These steps apply after the operator merges the PR, not during the SHIP phase:

### Linear ticket update
If Linear MCP tools are available, update the ticket status. If not, note: "Update the Linear ticket status manually."

## CI Monitor Config

- CI runs parallel RSpec jobs: `test(4, 0)` through `test(4, 3)`
- Other workflows: `Rspec`, `Eslint Code`, `Vitest`, `Lint Code`, `Chromatic`
- Test commands for local verification:
  - Ruby: `docker compose exec web bundle exec rspec {files}`
  - JS: `docker compose exec web yarn test`
- Lint commands:
  - Ruby: `docker compose exec web rubocop {files}`
  - JS: `docker compose exec web yarn eslint {files}`
