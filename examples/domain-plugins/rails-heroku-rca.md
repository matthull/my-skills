# RCA Domain Plugin — Rails + Heroku (Shared-DB Review Apps)

Example `resources/domain-skill.md` for the `rca` skill in a Rails project deployed to
Heroku, with per-PR review apps that share a single staging database.
Copy this file to `~/.claude/skills/rca/resources/domain-skill.md` and customize
for your project — app names, review-app naming pattern, and specs destination.

## Log Access

### Production
```bash
heroku logs -a myapp-production          # tail recent logs
heroku logs -a myapp-production -n 1500  # last 1500 lines
heroku logs -a myapp-production --ps web  # web dyno only
heroku logs -a myapp-production --ps worker  # worker dyno only
```

### Filtering by Service/Dyno Type
Use `--ps` (or `--dyno`) to filter logs to a specific service (e.g., `web`, `worker`, a
background-job dyno). If you don't know the dyno/service names for an app, discover them with:
```bash
heroku ps -a myapp-production              # list running dynos and their types
heroku ps --app myapp-pr-1234              # same for a review app
```
Then filter: `heroku logs -a myapp-production --ps web.1`

### Staging (Review Apps)
Review apps are per-PR deployments. The app name follows the pattern `myapp-pr-<PR_NUMBER>`
(adjust to match this project's naming convention).

```bash
heroku logs --app myapp-pr-1234          # tail recent logs for PR #1234
heroku logs --app myapp-pr-1234 -n 1500  # last 1500 lines
heroku logs --app myapp-pr-1234 --ps web # web dyno only
```

**To find the PR number:** Extract from the branch name or use `gh pr list --head $(git branch --show-current)`.

### Filtering Logs
Heroku log lines include the source and dyno. Useful grep patterns:
- `ActionController` — request routing and params
- `ActiveRecord` — SQL queries (if query logging enabled)
- `Error` / `Exception` — application errors
- `status=5` — 5xx responses from the router
- `H12` / `H13` / `H14` — Heroku timeout/connection errors
- `R14` — Memory quota exceeded
- `at=error` — Heroku router errors

## Application-Specific Log Patterns

### Rails Request Lifecycle
Key log markers for a Rails app:
- `Started GET/POST/PUT/DELETE` — request begins
- `Processing by ControllerName#action` — routing resolved
- `Completed 200/404/500` — request finished with status

### Background Jobs
- If using Sidekiq (or similar) for background processing, job failures appear in logs with class name and error
- Check the job-processing dashboard if available, or filter logs for the job class name

### Default-Scope Data Isolation
If models use a `default_scope` that hides a subset of rows by default (archived,
soft-deleted, draft), remember that investigating data issues may require the unscoped
or all-inclusive variant of the query — otherwise the records you're looking for may be
silently filtered out.

## RCA Output Protocol

### Documentation
- Save investigation documents to this project's standard documentation location (e.g. a specs directory or submodule — see the skill's core Documentation Template)
- If specs live in a separate repo/submodule, commit and push it independently
- Link to the doc via its repo URL, e.g.: `https://github.com/your-org/your-docs-repo/blob/main/investigations/rca-{name}.md`

### Team Chat Communication
- When posting RCA findings to a team channel, always:
  1. Clearly identify as bot/automated output
  2. State the level of human review the analysis received (e.g., "no human review", "reviewed by [name]")
  3. Include a disclaimer: findings are automated and should be verified before acting
- If the messaging binding can only post to whitelisted channels, fall back to copying the findings for the user to paste manually into non-whitelisted channels.

### Git Workflow for a Docs Submodule
```bash
# Stage and commit in submodule
git -C <docs-submodule> add investigations/rca-{name}.md
git -C <docs-submodule> commit -F /dev/stdin <<'EOF'
commit message here
EOF
git -C <docs-submodule> push origin main
```
