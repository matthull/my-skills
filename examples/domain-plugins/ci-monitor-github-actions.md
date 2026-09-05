# CI Monitor Domain Plugin — GitHub Actions + Docker + Visual Regression

Example `resources/domain-skill.md` for the `ci-monitor` skill in a Rails/JS project using
GitHub Actions for CI, Docker for local execution, and a visual-regression service for UI diffs.
Copy this file to `~/.claude/skills/ci-monitor/resources/domain-skill.md` and customize
for your project.

## CI Pipeline

- **System:** GitHub Actions
- **Check status:** `gh run list --branch $(git branch --show-current) --limit 5`
- **View logs:** `gh run view {run_id} --log-failed`
- **Re-run:** `gh run rerun {run_id} --failed`

## Checks That Require Human Review (not an auto-fix target)

**Visual regression (your visual-regression service):** Fails whenever new or changed components
produce visual diffs that need human review. This is expected for UI PRs and is not a code
problem — do not attempt to fix it. Extract the review URL from the failed run's logs:
```bash
gh run view <RUN_ID> --log-failed 2>&1 | grep "<REVIEW_URL_MARKER>"  # e.g. the line your visual-regression tool prints before the review link
```
Relay the URL via the messaging capability's NOTIFY_INFO verb (not NOTIFY_BLOCKING — the loop
should keep monitoring other checks while visual review is pending).

## Test Commands

- **Ruby (RSpec):** `docker compose exec web bundle exec rspec {files}`
- **JavaScript:** `docker compose exec web yarn test`
- **Lint (RuboCop):** `docker compose exec web rubocop {files}`
- **Lint (ESLint):** `docker compose exec web yarn eslint {files}`

## Failure Log Patterns

- **RSpec:** `gh run view <RUN_ID> --log-failed 2>&1 | grep -E "(Failure|Error|expected|.*_spec\.rb)" | head -50`
- **ESLint:** `gh run view <RUN_ID> --log-failed 2>&1 | grep -E "(error|eslint.*warning)" | head -30`
- **RuboCop:** `gh run view <RUN_ID> --log-failed 2>&1 | grep -iE "(offense|cop:)" | head -30`

## Known Flaky Tests

- `spec/system/pdf_export_spec.rb` — intermittent Puppeteer timeout, retry once before treating as a real failure
- `spec/jobs/sync_job_spec.rb` — race condition on CI, not a real failure

## Post-Fix Verification

After pushing a fix, wait 2 minutes then re-check CI status.
Branch protection requires all checks to pass before merge.

## PR Conventions

- Auto-fix commits: prefix with `fix(ci):`
- If a fix touches production code (not just tests), request review before pushing rather than pushing directly.
