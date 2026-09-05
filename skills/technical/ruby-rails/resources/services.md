# Services

## When to Use a Service Object

- Business logic that spans multiple models
- Complex operations that don't belong in a single model
- Operations with multiple steps that should succeed or fail together
- Logic that would make a model or controller too large

## Structure

- One public method per service (usually `call` or a descriptive verb)
- Initialize with dependencies, execute with `call`
- Return a result object or raise on failure — never return mixed types
- Keep services focused: one service = one operation

## Naming

- Name after the operation: `CreateApprovalRequest`, `PublishTestimonial`, `ReconcileSubscription`
- Place in `app/services/` with subdirectories for domains if needed
- Suffix with the action, not "Service": prefer `PublishTestimonial` over `TestimonialPublishService`

## Testing Services

- Test the public interface (input → output/side effects)
- Test edge cases and error conditions
- Mock external dependencies (APIs, mailers), not internal collaborators
- Service specs belong in `spec/services/`

## Jobs and Workers

- Jobs are thin wrappers around services — the job calls the service
- Never put business logic directly in a job class
- Test the service thoroughly; job specs only verify correct service invocation

## Checklist

- [ ] Single public method per service
- [ ] No mixed return types
- [ ] Comprehensive spec coverage including error paths
- [ ] Jobs delegate to services, not implement logic
