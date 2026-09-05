# Migrations

## Safe Migration Discipline (CRITICAL)

IMMEDIATELY STOP if a migration:
- Adds a column AND uses it in the same deploy
- Removes a column without `ignored_columns` first
- Changes a column type on an active column
- Drops a table that's still referenced in code

## Two-PR Pattern

**Adding a column:**
1. PR 1: Migration that adds the column (deploy independently)
2. PR 2: Code that uses the column

**Removing a column:**
1. PR 1: Remove all code usage, add column to `ignored_columns` in model
2. PR 2: Migration that drops the column

## Index Safety

- Add indexes concurrently on large tables: `add_index :table, :column, algorithm: :concurrently`
- Use `disable_ddl_transaction!` when using concurrent indexes
- Never add a non-concurrent index on a table with >100k rows in production

## Data Migrations

- Never put data transformations in schema migrations
- Use rake tasks or one-off scripts for data backfills
- Data migrations should be idempotent (safe to run multiple times)

## Schema Drift

- **Always diff `db/schema.rb` against master** before committing
- Local `db:migrate` reflects your local DB state, which may have tables/indexes master doesn't
- If schema.rb has unexpected changes, investigate — don't just commit them

## Destructive Operations

- **Never** run `db:drop`, `db:reset`, or `db:schema:load` without explicit user permission
- For test DB issues, prefer `db:test:prepare` over dropping and recreating

## Checklist

- [ ] No column added and used in same PR
- [ ] No column removed without `ignored_columns` step
- [ ] Large-table indexes use `algorithm: :concurrently`
- [ ] Schema.rb diffed against master — no unexpected changes
- [ ] Data migrations are idempotent
