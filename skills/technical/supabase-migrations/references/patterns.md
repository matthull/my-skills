# Supabase Migration Patterns

Structural patterns for idempotent migrations. Examples show the **pattern structure** - actual SQL logic comes from your specs and research.

---

## Tables: Standard CREATE

One-time DDL. Use ALTER TABLE migrations for subsequent changes.

```sql
-- supabase/migrations/YYYYMMDDHHMMSS_create_<table>.sql
CREATE TABLE table_name (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- columns from spec...
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS immediately (if table needs it)
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;
ALTER TABLE table_name FORCE ROW LEVEL SECURITY;

-- If this project uses PowerSync (or a similar sync engine) for offline/mobile
-- sync, and this table should sync to clients, add it to the publication:
ALTER PUBLICATION <sync_publication> ADD TABLE table_name;
```

---

## Functions: CREATE OR REPLACE

Always use `CREATE OR REPLACE` so migrations are idempotent. To modify a function later, create a new migration with the same statement.

```sql
-- supabase/migrations/YYYYMMDDHHMMSS_create_<function>.sql
CREATE OR REPLACE FUNCTION schema.function_name(param_name param_type)
RETURNS return_type
LANGUAGE plpgsql  -- or sql
STABLE  -- or VOLATILE/IMMUTABLE as appropriate
AS $$
DECLARE
  -- declarations...
BEGIN
  -- implementation from spec...
END;
$$;
```

### Updating Functions Later

Create a new migration file, not edit the original:

```sql
-- supabase/migrations/YYYYMMDDHHMMSS_update_<function>_v2.sql
-- Description of what changed

CREATE OR REPLACE FUNCTION schema.function_name(param_name param_type)
RETURNS return_type
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
  -- updated implementation...
END;
$$;
```

---

## RLS Policies: DROP IF EXISTS + CREATE

Policies cannot be replaced. Always drop first for idempotency.

```sql
-- supabase/migrations/YYYYMMDDHHMMSS_add_<table>_rls.sql

-- Ensure RLS is enabled
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;
ALTER TABLE table_name FORCE ROW LEVEL SECURITY;

-- Drop if exists (idempotent)
DROP POLICY IF EXISTS "policy_name" ON table_name;

-- Create policy (USING for SELECT/UPDATE/DELETE, WITH CHECK for INSERT/UPDATE)
CREATE POLICY "policy_name"
ON table_name FOR SELECT  -- or INSERT, UPDATE, DELETE, ALL
TO authenticated  -- or anon, specific role
USING (/* row filter expression from spec */);

-- For INSERT (uses WITH CHECK, not USING)
DROP POLICY IF EXISTS "insert_policy_name" ON table_name;
CREATE POLICY "insert_policy_name"
ON table_name FOR INSERT
TO authenticated
WITH CHECK (/* validation expression from spec */);

-- For UPDATE (can have both)
DROP POLICY IF EXISTS "update_policy_name" ON table_name;
CREATE POLICY "update_policy_name"
ON table_name FOR UPDATE
TO authenticated
USING (/* which rows can be selected for update */)
WITH CHECK (/* validation for new values */);
```

---

## Triggers: DROP IF EXISTS + CREATE

```sql
-- supabase/migrations/YYYYMMDDHHMMSS_add_<trigger>.sql

-- Create trigger function first (uses CREATE OR REPLACE)
CREATE OR REPLACE FUNCTION trigger_function_name()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- trigger logic from spec...
  RETURN NEW;  -- or OLD, or NULL depending on trigger type
END;
$$;

-- Drop and recreate trigger (idempotent)
DROP TRIGGER IF EXISTS trigger_name ON table_name;
CREATE TRIGGER trigger_name
BEFORE INSERT  -- or AFTER, INSTEAD OF; INSERT, UPDATE, DELETE
ON table_name
FOR EACH ROW
EXECUTE FUNCTION trigger_function_name();
```

---

## Indexes: CREATE INDEX CONCURRENTLY (Separate File Per Index)

**Critical:** `CREATE INDEX CONCURRENTLY` cannot run inside a transaction. Each index must be in its own migration file.

```sql
-- supabase/migrations/YYYYMMDDHHMMSS_add_idx_table_column.sql
-- One index per file!

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_table_column ON table_name(column_name);
```

```sql
-- supabase/migrations/YYYYMMDDHHMMSS_add_idx_table_col1_col2.sql
-- Composite index (still needs own file)

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_table_col1_col2 ON table_name(col1, col2);
```

```sql
-- supabase/migrations/YYYYMMDDHHMMSS_add_idx_table_active.sql
-- Partial index

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_table_active ON table_name(column) WHERE active = true;
```

**Why separate files?** PostgreSQL's concurrent index building uses multiple transactions internally. The Supabase CLI runs each migration file as a transaction, so CONCURRENTLY fails if combined with other statements.

---

## Altering Existing Tables

```sql
-- supabase/migrations/YYYYMMDDHHMMSS_alter_<table>_add_<column>.sql

-- Add column
ALTER TABLE table_name ADD COLUMN IF NOT EXISTS column_name column_type;

-- Add foreign key column
ALTER TABLE table_name ADD COLUMN IF NOT EXISTS ref_id UUID REFERENCES other_table(id);

-- Add constraint
ALTER TABLE table_name ADD CONSTRAINT IF NOT EXISTS constraint_name CHECK (...);
```

**Note:** `ADD COLUMN IF NOT EXISTS` requires PostgreSQL 9.6+. Supabase supports this.

---

## Permissions (for sensitive functions)

```sql
-- Grant to specific role
GRANT EXECUTE ON FUNCTION schema.function_name TO role_name;

-- Revoke from public access
REVOKE EXECUTE ON FUNCTION schema.function_name FROM authenticated, anon, public;
```

---

## Common Gotchas

### 1. RLS Must Be Both ENABLED and FORCED

```sql
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;  -- Applies to non-owners
ALTER TABLE table_name FORCE ROW LEVEL SECURITY;   -- Also applies to table owner
```

### 2. Sync Engine Publication (project-specific)

If this project uses a sync engine such as PowerSync for offline/mobile clients, new tables that should sync need to be added to its publication:

```sql
ALTER PUBLICATION <sync_publication> ADD TABLE table_name;
```

### 3. Seed Data Location

Seed data lives in `supabase/seed.sql` and only runs on `db reset`, not `db push`. Use for development/test data only.
