# My Claude Skills

This repo holds various Claude skills I've developed over the past year.

There are a number of software development skills, but also some for other domains like project management and personal assistant.

## Plugin Architecture

These skills use a natural language dependency inversion system. I came up with this to facilitate using the same skills across projects or teams.

| Layer | File | What it provides |
|-------|------|-----------------|
| **Core** | `SKILL.md` | Universal logic |
| **Domain** | `resources/domain-skill.md` | Project-specific bindings (test commands, CI system, conventions) |
| **Personal** | `resources/personal-skill.md` | User preferences (notification channel, autonomy level) |

See [docs/plugin-architecture.md](docs/plugin-architecture.md) for the full spec.
