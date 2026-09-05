# Pipeline Domain Plugin — Rails + Docker

Example `resources/domain-skill.md` for the `pipeline` skill in a Rails + Docker project.
Copy this file to `~/.claude/skills/pipeline/resources/domain-skill.md` and customize
for your project.

## Project

- **Name:** my-rails-app
- **Default branch:** main

## Assess

### Issue tracking
- A ticket MUST exist before work begins. If none exists, create one via the **issue-tracking** capability.
- The ticket ID drives branch naming and PR linking throughout the pipeline.
- Branch names MUST be prefixed with the lowercase ticket ID: `{ticket-id}-short-description`

## Setup

### Branch management
```bash
git checkout main
git pull
git checkout -b <branch-name>
```

### Docker
```bash
docker compose up -d
docker compose exec web echo "healthy"
```

Wait for healthy response before proceeding.

## Test Commands

**Ruby (RSpec):**
```bash
docker compose exec web bundle exec rspec {files}
```

**JavaScript (Vitest):**
```bash
docker compose exec web yarn test
```

Can target specific files with vitest path arguments.

## Lint Commands

**Ruby (RuboCop):**
```bash
docker compose exec web rubocop {files}
```

**JavaScript (ESLint):**
```bash
docker compose exec web yarn eslint {files}
```

## PR Conventions

- Use the **code-hosting** capability to create PRs
- Reviewer: assign via team convention or project settings
- Link PR to the issue tracking ticket (ticket was established in ASSESS phase)
- Merge strategy: squash merge only

## Post-Ship Steps

After PR is merged:

### Database migrations
If the branch included migrations:
```bash
# Verify migration ran in production
docker compose exec web bundle exec rails db:migrate:status
```

### Issue tracking update
If the **issue-tracking** capability is bound, update the ticket status to "Done."
Otherwise, note in terminal: "Update the ticket status manually."

## QA Config

### Available verification tools

Use the **browser-testing** capability if bound. Otherwise:

- **Console:** `docker compose exec web bundle exec rails console`
- **API:** `curl` against http://localhost:3000/api/...
- **DB:** `docker compose exec web bundle exec rails dbconsole`
- **Logs:** `docker compose logs -f web`

### Prerequisites
- Docker containers running: `docker compose exec web echo "healthy"`
- For browser QA: Chrome running with remote debugging enabled

### Pre-flight checks
- Seed data: `docker compose exec web rails runner "puts User.count > 0 ? 'OK' : 'EMPTY'"`
- Server health: navigate to http://localhost:3000

## REFLECT Mandatory Checks

During the REFLECT phase, the pipeline should verify:
- [ ] Documentation updated if public-facing behavior changed
- [ ] Learning propagation: any new conventions pushed to CLAUDE.md, domain plugin, or relevant skills
- [ ] Changelog entry added if user-visible change
