---
name: supabase-migrations
description: Guidance for writing Supabase database migrations with idempotent patterns. This skill should be used when creating or modifying database objects (tables, functions, RLS policies, triggers, indexes) or any SQL committed as a migration file.
---

# Supabase Migrations

Supabase uses timestamped SQL migrations in `supabase/migrations/`. Migrations run once, in order, and cannot be rolled back. This requires idempotent patterns.

## Key Constraints

1. **No rollback** - Migrations only go forward
2. **No repeatable migrations** - Cannot re-run modified files (unlike Flyway's `R__` prefix)
3. **No checksum validation** - System won't detect edits to already-run migrations

**Critical rule:** Never edit a migration that has already run in any environment. Create a new migration instead.

## Pattern Selection

| Object Type | Pattern | Rationale |
|-------------|---------|-----------|
| Tables | `CREATE TABLE` | One-time DDL, never modified after creation |
| Functions | `CREATE OR REPLACE FUNCTION` | Idempotent, can be updated in new migrations |
| RLS Policies | `DROP POLICY IF EXISTS` + `CREATE POLICY` | Policies cannot be replaced, must drop first |
| Triggers | `DROP TRIGGER IF EXISTS` + `CREATE TRIGGER` | Same as policies |
| Indexes | `CREATE INDEX CONCURRENTLY IF NOT EXISTS` | Non-blocking, **separate file per index** |

## Workflow

```bash
# Create new migration
npx supabase migration new <name>

# Apply locally (drops everything, runs all migrations + seed)
npx supabase db reset

# Apply pending only (preserves data)
npx supabase db push

# Check status
npx supabase migration list
```

## Command Timeouts

**CRITICAL:** Supabase commands can be slow. Using insufficient timeouts causes SIGKILL (exit code 137) which looks like a failure but is just a timeout.

| Command | Minimum Timeout | Notes |
|---------|-----------------|-------|
| `supabase db reset` | **120s (2 min)** | Drops DB, runs all migrations, restarts containers |
| `supabase db push` | 60s | Only applies pending migrations |
| `supabase migration list` | 30s | Quick status check |
| `supabase status` | 30s | Quick status check |

**When using Bash tool, always set appropriate timeout:**
```
timeout: 120000  # for db reset (milliseconds)
```

## Interpreting Output

**Success indicators** (look for these, not just exit code):
- "Applying migration XXXXXX_name.sql..." for each migration
- "Finished supabase db reset on branch main."

**Warnings (not errors):**
- `WARN: no files matched pattern: supabase/seed.sql` - Fine if no seed data yet

**Actual errors:**
- SQL syntax errors will show the failing statement
- "ERROR: relation X already exists" - Table collision
- "ERROR: column X does not exist" - Schema mismatch

## Naming Convention

```
YYYYMMDDHHMMSS_<action>_<object>.sql
```

Examples:
- `20251215100000_create_widgets.sql`
- `20251215100001_add_rls_policies.sql`
- `20251220100000_update_auth_hook_v2.sql`

## Checklist Before Completing Migration

1. **New table, and this project uses PowerSync for offline/mobile sync?** Add it to the sync publication: `ALTER PUBLICATION <sync_publication> ADD TABLE new_table;`
2. **SECURITY DEFINER / privileged function?** Grant and revoke EXECUTE explicitly
3. **RLS on table?** Both `ENABLE ROW LEVEL SECURITY` and `FORCE ROW LEVEL SECURITY` required
4. **Modifying existing function?** Use `CREATE OR REPLACE` in a new migration file
5. **Adding index?** Use `CREATE INDEX CONCURRENTLY` in its own separate migration file (one index per file)

## Detailed Patterns

For structural examples, read `references/patterns.md` in this skill directory.

**Note:** Examples show idempotent *structure*, not business logic. Actual SQL implementation should come from your feature specs and research docs.
