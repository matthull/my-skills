# Autonomy Profiles

Profiles modulate default posture — how readily to ask, how to communicate, whether to gate. **Core constraints are never overridden.** Testing discipline, verification, STOP-and-Ask triggers for missing resources or architectural decisions — these always fire regardless of active profile.

---

## Traits

Profiles are compositions of independent traits. Two categories:

### Behavioral Traits (influence LLM posture via prompt language)

| Trait | Values | What it controls |
|---|---|---|
| `question-threshold` | `low` / `high` | How readily to stop and ask vs act independently. `low` = collaborate on decisions. `high` = act by default, only stop for genuine blockers. |
| `interrupt-channel` | `in-session` / `push-notification` / `push-notification-non-blocking` | How to surface blockers and notifications. `in-session` = direct conversation. `push-notification` = async via `PushNotification`, may wait for replies. `push-notification-non-blocking` = notify/andon only, never ask (never wait). Fall back to `in-session` if PushNotification is not available. |
| `agent-verbosity` | `full-report` / `summary` / `silent` | How much agents report back to the orchestrator. Affects context consumption. |

### Structural Traits (control flow decisions read by orchestrator)

| Trait | Values | What it controls |
|---|---|---|
| `within-phase-gates` | `on` / `off` | Mid-phase decision points (e.g., approve task list before handoffs). Orchestrator skips gates annotated `[requires: within-phase-gates]` when `off`. |
| `phase-transition-gates` | `on` / `off` | Gates between phases (e.g., approve DESIGN before IMPLEMENT). Orchestrator skips gates annotated `[requires: phase-transition-gates]` when `off`. |

### Adding New Traits

A new trait requires:
1. Definition in this index (name, values, what it controls, category)
2. Rendered text in each profile file that includes it
3. For behavioral traits: the profile file's prose covers it (hook-injected or conversation-loaded)
4. For structural traits: gate annotations in sequence/mode files that reference it

---

## Profiles

| Profile | Posture | When to use |
|---|---|---|
| **supervised** | Full human visibility at every decision point | Default. Human at keyboard, collaborative session. |
| **review-gated** | Trust within-phase work, gate phase transitions | Human available but not watching every step. Medium-trust tasks. |
| **notify-only** | No gates, async notifications only | Human away, wants updates. Established patterns, bounded scope. |
| **semi-autonomous** | No gates, no interrupts, log only | Human fully away. Use sparingly — not recommended for novel work. |

### Profile Trait Compositions

```
                    supervised  review-gated  notify-only  semi-autonomous
question-threshold  low         high          high         high
interrupt-channel   in-session  in-session    push-notif   push-notif-non-blocking
agent-verbosity     full-report summary       summary      silent
within-phase-gates  on          off           off          off
phase-transition    on          on            off          off
```

### Custom Profiles

Operators can specify inline trait overrides at invocation:
- Named profile: `autonomy: review-gated`
- Override: `autonomy: review-gated, within-phase-gates: on`
- Ad-hoc: `question-threshold: high, interrupt-channel: push-notification`

Custom profile files can be added to this directory following the same format.

---

## Activation

Profiles are activated by skills (`/autonomous`, `/collab`, or orchestrator at sequence start):
1. Read the profile file from this directory
2. Output the Behavioral Directives section into the conversation (immediate context)
3. Write the full profile to `/tmp/claude-sessions/{session_id}/autonomy-profile.txt` (persistence + optional reinforcement)

The session file serves two consumers:
- **Reinforcement system** (if present): re-injects behavioral directives each turn
- **Orchestrator**: reads structural traits for gate decisions

## Propagation

When spawning agents, include the behavioral directives in the agent's prompt. Agents don't need structural traits — gates are orchestrator-level decisions. Include a brief preamble:

```
## Active Autonomy Profile: {profile-name}
{behavioral directives section from profile}
```
