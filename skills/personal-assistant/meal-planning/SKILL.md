---
name: meal-planning
description: Meal planning, recipe management, and shopping list creation. Covers the full arc from "what sounds good?" through recipe extraction, ADHD-friendly formatting, shopping lists, and pinned Keep notes for watch access. Triggers on "meal plan", "what should I eat", "recipe", "shopping list", "grocery", or when the artifex wants help with food for the week.
---

# Meal Planning

Help the artifex plan meals, manage recipes, build shopping lists, and get food into the house. This is life-domain work — attunement-centered, not optimization-centered.

## Core Principles

### Balance efficiency with enjoyment

The artifex needs BOTH:
- **Easy protein floor** — protein shakes, grab-and-go items, batch-cooked staples. The survival layer so eating happens even on low-EF days.
- **Novelty and cooking enjoyment** — actual cooking, new recipes, project dishes, going out to eat. The thriving layer so food isn't just fuel.

Too much efficiency kills motivation ("boring, same thing again"). Too much novelty creates unsustainable EF load. The balance shifts week to week based on energy and desire. Never optimize one at the expense of the other.

### Small lists, flexible plans

Giant optimized shopping lists don't work. The right shopping list is:
- A few specific items for specific recipes
- Easy staples to restock
- Room to wing it at the store and the butcher

The plan is loose. "I'll make cheesecake this week and lentil soup and go to the butcher" is a plan. A day-by-day meal calendar is not — that's a system to abandon.

### Desire-first, not should-first

Start from "what sounds good?" not "what's optimal?" If the artifex wants to make cheesecake, that's the plan. If they want to go to a nice restaurant solo, that's the plan. The system serves desire, not the other way around.

### Space-making is real work

Cleaning the kitchen, shopping, prepping — these have real EF cost. Acknowledging that cost and making space for it is part of meal planning, not a separate concern.

## Recipe Format

Recipes live in `<recipe-directory>/` as markdown files. The format is ADHD-friendly — exhaustive step-by-step walkthrough of the entire cooking process. Nothing assumed, nothing to look up.

### Format rules

1. **Every mention of an ingredient includes its quantity.** Never "add the onion" — always "add the 1 chopped yellow onion."
2. **No forward/backward references.** Never "see above" or "as prepared earlier." Each step is self-contained.
3. **Step by step, linear.** Read top to bottom, do what it says, never jump around.
4. **Nothing assumed.** "Chop the onion fine" not "prep the onion."

### Recipe template

```markdown
# Recipe Name

**Source:** [where it came from — URL or book]
**Serves:** X
**Time:** X min prep, X min cook
**Net carbs:** Xg per serving (if the operator tracks them)
**Good for:** [batch prep / solo cooking / project cooking / kid-friendly / etc]

---

## What You Need

[All ingredients with exact measurements]

## Check Pantry First

**Likely have:** [common pantry items]
**Need to buy:** [what's not typically on hand]

## Shopping

[What to get, from where if it matters]

## Kitchen Prep

[Get the space ready — equipment, clear counter, preheat]

## Mise en Place

[Everything prepped before heat goes on — chopped, measured, laid out.
All quantities listed. Everything visible before cooking starts.]

## Cook

[Step by step. Exhaustive. All quantities inline with every ingredient mention.
No jumping around. Linear from start to finish.]

## Storage

[How it keeps, how long, reheating notes, freezing notes]

## Notes

[Anything learned from making it, variations, skip-if-solo notes, kid preferences]
```

## Recipe Extraction

When the artifex provides a recipe (URL, PDF, typed, photo):

1. Extract the complete recipe with all ingredients and steps
2. Save in full-process format to `<recipe-directory>/[name].md`
3. Create a condensed **pinned Keep checklist** version for watch access — a standalone cooking guide with all steps and quantities, plus a GitHub link to the full recipe
4. Commit and push to the life repo

The Keep note IS the cooking companion. It should be followable step-by-step without opening anything else.

## Shopping List

When building a shopping list:

1. Start from what the artifex wants to cook/eat (desire-first)
2. Check what's already in pantry (ask, don't assume)
3. Build a **pinned Keep checklist** organized by store/section
4. Keep it small. Include room for "whatever looks good" items.
5. The butcher shop model: sometimes the plan is "go see what's there." That's valid.

## Dietary Constraints

The operator may have standing dietary constraints — carb limits, allergies, macro
targets. Record the specifics in `resources/personal-skill.md`, not here, and read
them from there. Where constraints exist:
- Note the relevant macro per serving on recipes when applicable
- Prefer substitutions that fit the constraint (e.g. alternative sweeteners or flours)
- Keep any standing priority (protein, fiber, sodium) in view when suggesting meals
- Treat constraints as context, not as a veto over what the operator actually wants.
  If they want to make something that isn't perfectly optimized, that's fine.

## Existing Recipe Collection

Prior recipes exist in `<older-recipe-collection>/`. These are in an older format. Pull over and reformat as needed — don't migrate wholesale.

Key patterns from the old collection:
- Sheet pan batch cooking (chicken thighs, sausages, beef chunks, vegetables)
- Instant Pot batch cooking (chili, shredded beef, taco meat)
- Assembly meals from pre-cooked components
- Zero-prep convenience items (yogurt parfaits, hard-boiled eggs, deli turkey)

These are valuable as the "easy protein floor" but should not dominate the recipe collection. The collection should also include project recipes, interesting dishes, and things that are fun to cook.
