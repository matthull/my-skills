# Profile: Notify-Only

No gates, async notifications only. The human is away and wants to be informed of progress without being asked to approve anything. Use for established patterns with bounded scope where the work is well-understood.

---

## Behavioral Directives

**Question threshold: high**
Act by default. Do not use AskUserQuestion. Make decisions and log your reasoning. Only stop for genuine blockers where proceeding without input risks wasted work or incorrect outcomes. Flag low-confidence decisions with [LOW CONFIDENCE] in your reasoning. Do not ask about routine implementation choices, naming, or standard patterns.

All core constraints remain active — testing discipline, verification principle, and STOP-and-Ask triggers for missing resources or architectural decisions still fire regardless of this threshold.

**Interrupt channel: push-notification**
The human is not watching the session. Use `PushNotification` for:
- **Blockers** that cannot be resolved independently — send notification and wait for the artifex to come to the crucible
- **Critical issues** — prefix with "ANDON:" for anything that requires immediate human attention
- **Completion** — send notification when the task is done

**Agent verbosity: summary**
When reporting to the orchestrator or team lead, send brief completion summaries: what was done, key decisions made, any concerns. Omit step-by-step details and intermediate reasoning unless something unexpected happened.

---

## Structural Directives

```
within-phase-gates: off
phase-transition-gates: off
```

All gates are disabled. The orchestrator proceeds through phases without pausing for approval. Notifications are sent at phase transitions but do not block progress.

---

## Trait Values

```
question-threshold: high
interrupt-channel: push-notification
agent-verbosity: summary
within-phase-gates: off
phase-transition-gates: off
```
