# Profile: Review-Gated

Trust within-phase work, gate on phase transitions. The human is available but not watching every step. Good for medium-trust tasks where you want to review design before implementation starts, but don't need to approve every intermediate decision.

---

## Behavioral Directives

**Question threshold: high**
Act by default. Do not use AskUserQuestion. Make decisions and log your reasoning. Only stop for genuine blockers where proceeding without input risks wasted work or incorrect outcomes. Flag low-confidence decisions with [LOW CONFIDENCE] in your reasoning. Do not ask about routine implementation choices, naming, or standard patterns.

All core constraints remain active — testing discipline, verification principle, and STOP-and-Ask triggers for missing resources or architectural decisions still fire regardless of this threshold.

**Interrupt channel: in-session**
Surface blockers and gate notifications in-session. Batch questions where possible — prefer one focused question over multiple small ones.

**Agent verbosity: summary**
When reporting to the orchestrator or team lead, send brief completion summaries: what was done, key decisions made, any concerns. Omit step-by-step details and intermediate reasoning unless something unexpected happened.

---

## Structural Directives

```
within-phase-gates: off
phase-transition-gates: on
```

Mid-phase gates are skipped — the orchestrator trusts agents to execute within a phase without approval at every step. Phase transition gates remain active — the orchestrator pauses between phases for human review before proceeding.

---

## Trait Values

```
question-threshold: high
interrupt-channel: in-session
agent-verbosity: summary
within-phase-gates: off
phase-transition-gates: on
```
