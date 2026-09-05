# Models

## Associations

- Declare associations at the top of the class, before validations and scopes
- Use `dependent:` on every `has_many` — choose `:destroy`, `:nullify`, or `:restrict_with_error`
- Polymorphic associations: always verify both sides exist before traversing (use `respond_to?` or type checks in shared code paths)
- When adding a new association, check if existing queries need `includes` updated

## Scopes

- Prefer named scopes over repeated `where` clauses
- Scopes should be composable — avoid scopes that merge unrelated concerns
- Never use `default_scope` for business logic filtering (existing `default_scope` like `preview: false` is an exception — understand it, don't add new ones)
- Scope names should read naturally when chained: `Quote.surfaceable.with_recipient`

## Callbacks

- Use callbacks only for model-internal concerns (setting defaults, maintaining derived state)
- Never use callbacks for side effects that cross model boundaries (sending emails, creating other records) — use service objects
- Prefer `before_validation` over `before_save` for data normalization
- Never use `after_commit` for business logic — use it only for cache invalidation or async job enqueue

## Validations

- Validate at the model level, not just the database level
- Use custom validators for complex business rules
- Prefer `validates :field, presence: true` over `validates_presence_of :field`

## Testing Models

- Test scopes with concrete assertions on returned records, not just SQL
- Test validations: both positive (valid) and negative (invalid with specific error)
- Test callbacks indirectly through their observable effects
- Use fixtures for standard data, factories only for edge cases requiring specific attribute combinations

## Checklist

- [ ] Every `has_many` has a `dependent:` strategy
- [ ] No business logic in callbacks that crosses model boundaries
- [ ] Scopes are composable and clearly named
- [ ] All new validations have both positive and negative tests
