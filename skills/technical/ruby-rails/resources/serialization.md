# Serialization (Jbuilder)

## N+1 Prevention (CRITICAL)

Every association accessed in a jbuilder view **MUST** be eager loaded in the controller. This is the single most common performance issue in this codebase.

**The pattern that causes N+1:**
```ruby
# jbuilder (in a loop)
json.array! @records do |record|
  json.association record.some_association.first  # ← SQL query per iteration
end
```

**How to verify:** If a jbuilder accesses `record.association` inside a loop, check the controller for `includes(:association)` or `preload(:association)`. If missing, it's an N+1.

**Polymorphic associations need special care:**
- Use `preload` (not `includes`) for polymorphic associations — `includes` can't optimize polymorphic joins
- When accessing associations through a polymorphic, nest the preload: `preload(approvable: [:renderable_testimonials])`

## Type Guards for Polymorphic Associations

When iterating over polymorphic collections (e.g., approvables that could be Quote or SurveyResponse):
- **Always** guard with `respond_to?` or a `case` on type before accessing type-specific associations
- Never assume all polymorphic types have the same associations

```ruby
# GOOD — guarded
testimonial = approvable.renderable_testimonials.first if approvable.respond_to?(:renderable_testimonials)

# GOOD — case statement
case recommendation.recommendable_type
when 'Quote'
  json.testimonial recommendable.renderable_testimonials.first
end

# BAD — will error on SurveyResponse
json.testimonial recommendable.renderable_testimonials.first
```

## Response Structure

- Use jbuilder files for JSON response structures, not model constants
- Never share constants between strong_params and jbuilder
- Keep response structures consistent across endpoints for the same model
- Nest related data under descriptive keys

## Testing Serialization

- Request specs verify the full serialized response
- Check that nested associations are present and correctly structured
- Test with and without optional associations (nil cases)
- One comprehensive spec per scenario, not one per attribute

## Checklist

- [ ] Every association accessed in jbuilder is eager loaded in controller
- [ ] Polymorphic associations use `preload` not `includes`
- [ ] Type guards on all polymorphic association access
- [ ] No shared constants between strong_params and jbuilder
- [ ] Request specs verify response structure
