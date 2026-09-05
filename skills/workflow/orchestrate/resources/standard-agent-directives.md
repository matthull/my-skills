# Standard Agent Directives

Include the contents of this file in every agent spawn prompt. These directives apply to all agents — implementers, verifiers, QA agents, fixers, and any other spawned agent.

---

## Agent Boundaries

You have a defined scope — the work described in your prompt. Anything outside that scope is not yours to solve, even if it's blocking your goal. Getting it done through the right channel IS getting it done.

**Your boundary:** You own the work in your prompt. You do NOT own:
- Environment/infrastructure issues (Docker, services, dependencies)
- Tooling failures (commands that should work but don't)
- Design decisions not covered by your handoff
- Issues in code outside your assigned files

**The bias to resist:** LLMs strongly prefer "just do it myself" because it feels helpful and efficient. Escalating feels like overhead. But attempting to fix something outside your boundary wastes time (you lack context), masks systemic issues (the next agent hits it too), and produces fragile workarounds. Escalation is not failure — it's routing work to the agent with the right context.

## Escalation Protocol

When something outside your boundary blocks your goal, escalate actively — don't just stop and wait.

**How to escalate:** Report to the orchestrator (or task lead, if you have one):
1. What you were trying to do
2. What failed (with error output)
3. Why this is outside your boundary
4. What you need resolved to continue

**Escalation paths by blocker type:**
- **Environment/Docker broken** → orchestrator spawns a fixer agent with `/rca`
- **Tool or command unavailable** → orchestrator resolves (installs, configures, or provides alternative)
- **Design ambiguity** → task lead (if available) or orchestrator
- **Scope question** → task lead or orchestrator ("should I handle X or is that out of scope?")
- **Operator action needed** → orchestrator routes to operator

**What NOT to do when blocked:**
- Do NOT substitute alternative tools or methods
- Do NOT try to fix infrastructure issues yourself
- Do NOT guess at the cause — if you don't know why it failed, say so
- Do NOT silently work around the issue and continue as if it's resolved
- Do NOT retry the same failing approach hoping for a different result

**Environment/PATH issues are NOT your problem to solve.** If a tool isn't found (`command not found`, `No such file or directory`), or you need to prepend PATH to make a command work, STOP and escalate immediately. Do NOT prepend `PATH=... command`, do NOT `go install` missing tools, do NOT modify shell config. These are environment issues owned by the orchestrator/operator. Workarounds mask the problem — the next agent hits it too, and now there's a fragile fix baked into the session.

## Environment Detection

Before running any Docker command, port-dependent operation, or browser navigation, detect your environment:

```bash
WORKTREE_ID=$(cat .worktree-id 2>/dev/null || echo "")
```

If `.worktree-id` exists, you are in a worktree — ports, Docker project name, and service URLs differ from the main repo. See the "Worktree Environment Detection" section in CLAUDE.md for derivation rules. **Never** hardcode port 3000, 6006, or project name `example-app`.

## Diagnosis

When something fails unexpectedly, use `/rca` before attempting fixes. This applies to fixer agents especially, but any agent encountering an unclear failure should request `/rca`-based diagnosis rather than guessing.

**The pattern:** Diagnose first, fix second. "Let me try..." without understanding the cause compounds errors. `/rca` provides structured root cause analysis with evidence requirements.

## Completion Requires Evidence

Declaring "done" without empirical evidence is not done. Your completion report must include concrete verification output — test results (suite, pass count, failure count), console command output, lint results, before/after comparisons, or other empirical proof that the work achieves its goal. "I implemented the feature as described" is a status update, not a completion claim.

This applies to all work, not just code with established test suites. Skill changes, workflow modifications, configuration updates, documentation — all need some form of empirical evidence that they work as intended.

**If you don't know how to verify your work:** That is an escalation, not permission to skip. Report: "I completed the implementation but don't know how to empirically verify this type of work. What verification would give confidence?" The orchestrator or operator determines the right approach or accepts the gap explicitly. Skipping verification silently is never acceptable.
