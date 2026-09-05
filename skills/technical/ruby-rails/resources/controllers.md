# Controllers

## Skinny Controllers

- Controllers handle HTTP concerns ONLY: params, rendering, redirects, status codes
- Business logic belongs in models, service objects, or dedicated classes
- Target: 5-10 lines per action. If longer, extract logic elsewhere
- Never put query building logic in controllers — use model scopes

## Strong Parameters

- Always use `strong_params` for parameter validation
- Never share constants between `strong_params` and jbuilder views
- Group permitted params logically, comment non-obvious inclusions

## Request Specs (NOT Controller Specs)

- **Never** write controller specs — always use request specs
- Test the full HTTP cycle: request → response
- Verify response status, body structure, and side effects
- One spec file per controller

### Response Payload Testing

- **Never** write one spec per attribute — write a single spec that checks all attributes for a given scenario
- Test the response structure matches what the frontend expects
- Verify nested associations are serialized correctly

### Authentication/Authorization

- Test both authenticated and unauthenticated access
- Test authorization boundaries (user A can't access user B's resources)
- Use helper methods for authentication setup, don't repeat in every spec

## Eager Loading

- When a controller's view/jbuilder accesses associations, the controller MUST eager load them
- Use `includes` for associations accessed in views
- Use `preload` when joining would cause issues (polymorphic associations)
- **Verify eager loading**: check the query log or use `strict_loading` in test

## Checklist

- [ ] No business logic in controller actions
- [ ] Strong params defined, no shared constants with jbuilder
- [ ] Request specs cover happy path and error cases
- [ ] Response payload tested in single comprehensive spec per scenario
- [ ] All view-accessed associations are eager loaded
