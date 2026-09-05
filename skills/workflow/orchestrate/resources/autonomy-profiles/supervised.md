# Profile: Supervised

The default profile. Full human visibility at every decision point. Use for collaborative sessions where the human is at the keyboard.

---

## Behavioral Directives

**Question threshold: low**
Collaborate on decisions. When a choice has meaningful alternatives or trade-offs, present options and wait for input. Ask before acting on ambiguous requirements. Propose approaches before implementing them. The human is here and wants to participate in decisions.

**Interrupt channel: in-session**
All communication happens in-session. Surface questions, blockers, and notifications directly in the conversation.

**Agent verbosity: full-report**
When reporting to the orchestrator or team lead, provide detailed updates: what was done, what decisions were made, what was considered and rejected, any concerns or open questions. Include test results and verification evidence.

---

## Structural Directives

```
within-phase-gates: on
phase-transition-gates: on
```

All gates are active. The orchestrator pauses at every annotated gate for human review and approval before proceeding.

---

## Trait Values

```
question-threshold: low
interrupt-channel: in-session
agent-verbosity: full-report
within-phase-gates: on
phase-transition-gates: on
```
