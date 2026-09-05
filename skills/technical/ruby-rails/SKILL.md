---
name: ruby-rails
description: Ruby/Rails patterns — fixture builder, RSpec organization, migrations, console verification. Load this skill for Ruby on Rails development tasks. Use during coding phases like IMPLEMENT
    as well as technical architecture phases like DESIGN.
---

# Ruby/Rails Practice

Load this skill for any Ruby on Rails work. Core mandates below apply universally. **Then load resource files** based on what you're touching.

## Progressive Disclosure — Resource Loading

Match the files you're working with against this table. **Load every matching resource** using the Read tool before starting work.

| Files you're touching | Load resource |
|---|---|
| `app/models/` | `resources/models.md` |
| `app/controllers/`, `spec/requests/` | `resources/controllers.md` |
| `app/services/`, `app/jobs/`, `app/workers/` | `resources/services.md` |
| `app/views/**/*.jbuilder`, `*_serializer.rb` | `resources/serialization.md` |
| `db/migrate/` | `resources/migrations.md` |

**Multiple matches are expected.** A jbuilder change that adds eager loading touches both serialization and controllers — load both.

**Re-check as you go.** If you discover during work that you're touching a new area (e.g., fixing a jbuilder N+1 leads you into the controller), come back to this table and load the newly relevant resource before continuing.

**For PR reviews:** map the diff's file list against this table.

Resource paths are relative to this skill's directory: `~/.claude/skills/ruby-rails/`

---

## CRITICAL: Fixture Builder Constraint (ABSOLUTE)

**You MUST NEVER create or edit manual fixture .yml files.**

This project uses fixture_builder gem which regenerates ALL fixtures — manual .yml files WILL BE DELETED on next regeneration.

You MUST NEVER:
- Create .yml files in spec/fixtures/ or test/fixtures/
- Edit existing .yml fixture files
- Use `File.write` to generate fixture files

You MUST ALWAYS:
- Define fixtures ONLY in `spec/support/test_data_factory.rb`
- Use FixtureBuilder.configure block
- Regenerate: `rake spec:fixture_builder_rebuild`

---

## CRITICAL: Test Every New Public Method (ABSOLUTE)

Test at the layer where defined:
- Controller action: Request spec (NOT controller spec)
- Client method: Client spec
- Service method: Service spec
- Model method: Model spec
- Helper method: Helper spec

---

## CRITICAL: Spec File Organization (ABSOLUTE)

**ONE spec file per class.** No method-specific spec files.

Use `describe` and `context` blocks to organize within the file.

If you find multiple spec files for one class: consolidate into single file, delete redundant files.

---

## Verification Loops

**Loop 1 (TDD)**: `bundle exec rspec spec/{path}/{filename}_spec.rb`
**Loop 2 (Scoped)**: `./specs/{PROJECT_NAME}/verify-specs.sh` or `bundle exec rspec spec/services/`
**Loop 3 (Console)**: `docker compose exec web bundle exec rails console` — verify data, exercise services

Loop 3 is REQUIRED unless ALL code paths are 100% exercised by unit tests.

---

## Universal Checklist

Before completing any Rails work:
- [ ] ONE spec file per class
- [ ] Every new public method has its own test
- [ ] No manual fixture .yml files created or edited
- [ ] No `Rails.env.production?` usage (use positive environment checks)
- [ ] No caching without documented justification
- [ ] RuboCop passes on modified files
- [ ] No debug statements (`binding.pry`, `puts`)
- [ ] Loaded and followed all matching resource files from routing table above

---

## Universal Anti-patterns

**You MUST NEVER:**
- Create multiple spec files for individual methods
- Add public methods without tests
- Create or edit manual fixture .yml files
- Add boilerplate comments (`# Arrange`, `# Act`, `# Assert`)
- Skip writing tests first (TDD red phase)
- Use raw SQL when ActiveRecord methods exist

**Prefer:**
- Service objects for complex business logic
- Integration tests over unit tests for critical flows
- Fixtures over factories (factories only for request specs or edge cases)
- Named scopes over repeated `where` clauses
- ActiveRecord callbacks only for model concerns
