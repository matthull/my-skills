---
name: supabase-sql
description: Supabase SQL application logic — RLS policies, auth hooks, triggers, pgTAP testing. Load this skill for Supabase database work.
---

# Supabase SQL Practice

## pgTAP Testing (REQUIRED)

All SQL application logic MUST have pgTAP tests.

**Test location**: `supabase/tests/`
**Run tests**: `npm run test:db`

Required test scenarios:
- Happy path for each operation (SELECT, INSERT, UPDATE, DELETE)
- Cross-tenant isolation (user from Business A cannot access Business B data)
- Role-based access (staff vs customer permissions)
- Edge cases (NULL values, missing claims)

---

## Auth Gotchas

**Auth hook vs raw_app_meta_data** (multi-tenant apps need BOTH):
- Auth hook modifies JWT claims -> used by RLS policies via `auth.jwt()`
- `auth.users.raw_app_meta_data` -> used by app code via `session.user.app_metadata`
- If app can't read business_id but RLS works, check raw_app_meta_data

**jsonb_set doesn't create intermediate objects:**
- Setting nested path fails silently if parent key doesn't exist
- Must ensure parent object exists before setting nested keys

---

## Verification Loops

**Loop 1 (Unit)**: pgTAP tests pass (`npm run test:db`)
**Loop 2 (Integration)**: Application can use the SQL correctly — test via app code or psql
**Loop 3 (E2E)**: Full user flow — login as test user, perform action, verify correct data

---

## Migration Checklist

Before marking complete:
- [ ] Migration file created with timestamp prefix
- [ ] pgTAP tests written and passing
- [ ] `npx supabase db reset` succeeds
- [ ] Seed data works with new SQL logic
- [ ] No breaking changes to existing RLS policies
- [ ] Auth hook changes tested with actual login flow
