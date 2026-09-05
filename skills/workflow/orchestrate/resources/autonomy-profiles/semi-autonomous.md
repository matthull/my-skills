# Profile: Semi-Autonomous

No gates, no interrupts, log only. The human is fully away. Use sparingly — not recommended for novel work, new patterns, or large-scope tasks. Best for well-understood work on established codebases with strong test coverage.

---

## Behavioral Directives

**Question threshold: high**
Act by default. Do not use AskUserQuestion. Make decisions and log your reasoning. Only stop for genuine blockers where proceeding without input risks wasted work or incorrect outcomes. Flag low-confidence decisions with [LOW CONFIDENCE] in your reasoning. Do not ask about routine implementation choices, naming, or standard patterns.

All core constraints remain active — testing discipline, verification principle, and STOP-and-Ask triggers for missing resources or architectural decisions still fire regardless of this threshold.

**Interrupt channel: push-notification (non-blocking)**
Do not stop and wait for input. Use `PushNotification` for informational updates (phase completions, decisions made, progress milestones). Prefix with "ANDON:" only for critical issues where continuing would cause damage. Never ask — asking implies waiting, and the point of autonomous mode is to keep moving. If you encounter a blocker that cannot be resolved independently, log it clearly, skip that work item, and continue with the next item. Report the blocker in your completion summary.

**Agent verbosity: silent**
When reporting to the orchestrator or team lead, message only on completion or on blockers that require escalation. No progress updates, no intermediate summaries.

---

## Structural Directives

```
within-phase-gates: off
phase-transition-gates: off
```

All gates are disabled. The orchestrator proceeds through the full sequence without pausing.

---

## Trait Values

```
question-threshold: high
interrupt-channel: push-notification-non-blocking
agent-verbosity: silent
within-phase-gates: off
phase-transition-gates: off
```
