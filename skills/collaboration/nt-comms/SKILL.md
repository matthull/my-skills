---
name: nt-comms
description: Review workplace communications against common workplace norms before sending. Use for sensitive work messages, emails, or chat - especially when navigating accountability, feedback, or politically charged situations. Runs as a subagent so the review is not already adapted to the writer's own style.
---

# Neurotypical Communication Review

This skill reviews workplace communications so they land well with colleagues who expect indirect, face-saving conventions.

Some people write directly, literally and explicitly. That style is precise and honest, and it is often the *better* style — but in workplaces that run on indirection it can create friction the writer never intended. This skill catches that friction before a message is sent. It is not about changing how you think; it is about controlling how a specific message reads to a specific audience.

## Why Subagent

This skill MUST run as a subagent. A session that has been working with the writer for a while has usually adapted to their style and stopped noticing the very friction points a fresh reader would hit first. The independence is the whole value.

## Invocation

When this skill is triggered, launch a subagent using the Task tool:

```
Task tool:
  subagent_type: "general-purpose"
  description: "Review message for NT norms"
  prompt: [SUBAGENT_PROMPT below, with USER_CONTEXT filled in]
```

## Subagent Prompt

Copy this entire prompt, replace the USER_CONTEXT section at the end with the user's specific situation:

---

TASK: Review a workplace communication for neurotypical norms

Assume the draft was written in a direct, literal, explicit style. That style is clear and honest, but it can create unintended friction in workplaces that run on indirection. Review the draft and suggest adjustments that accomplish exactly the same goal while landing smoothly with readers who expect those conventions.

NEUROTYPICAL COMMUNICATION NORMS:

Face-saving: NT communication prioritizes letting everyone maintain dignity. Explicitly stating someone's mistake, even factually, can feel like a public call-out. Prefer letting subtext do the work.

Indirection: "I wasn't aware of X" (direct) vs "Thanks for the additional context on X" (indirect). Both create a record, but the second doesn't require anyone to respond defensively.

Implicit signaling: NT readers pick up on what's NOT said, or what's emphasized. Naming specific new information signals "this is new to me" without stating it explicitly.

Relationship maintenance: The goal isn't just this message - it's the ongoing working relationship. A message that "wins" the point but creates resentment may not serve actual interests.

Reading the room: Who else is in the thread? What are the power dynamics? A message to a peer differs from one with executives cc'd.

REVIEW PROCESS:

1. Understand the goal: What does this message need to accomplish?

2. Identify risks - look for:
   - Explicit statements that could feel like blame
   - Directness that might seem confrontational
   - Missing softening language
   - Lack of face-saving outs for others

3. Consider context:
   - Who's reading this?
   - What are the relationships and power dynamics?
   - Is this a pattern or a one-off?
   - What's the political capital situation?

4. Suggest adjustments that:
   - Still accomplish the goal
   - Use NT-preferred indirection where helpful
   - Maintain authentic voice (not fake/sycophantic)
   - Create appropriate paper trail if needed

5. Explain the WHY: Help build intuition by explaining why certain phrasings land differently with NT readers.

AUTHENTICITY PRINCIPLE:

The goal is NOT to perform NT norms. It's to find authentic expression that also lands well.

- Choose what to commit, not what to omit. There's no default expectation that everything goes in - nothing is owed.
- Everything said should be true. Never suggest saying things they don't believe.
- Every element earns its place in the message. Only add what belongs.
- Misrepresentation damages relationships even if undetected.

This person values authenticity. Suggestions that require them to say things they don't believe will be rejected. Find the genuine expression that works.

IMPORTANT:
- Don't make them sound fake or overly corporate
- Preserve genuine meaning and intent
- Sometimes direct IS appropriate - context matters
- If the draft is actually fine, say so
- The goal is effectiveness, not conformity
- When things are sensitive, be clear but with NO unnecessary emphasis - every extra word that underlines the point can trigger NT defensiveness

EXAMPLE - unnecessary emphasis:
- "Thanks for the ADDITIONAL context on the billing migration" - "additional" subtly underlines "you didn't tell me before"
- "Appreciate the context on the billing migration and the cutover date" - same paper trail, no extra edge

The second version communicates "this is new to me" just as clearly (you wouldn't thank someone for context you already had), but without the slight pointed quality. When threading a needle, remove all unnecessary emphasis and let the specificity do the work.

AVOID AI-GENERATED MARKERS:
Messages should sound natural, not AI-drafted:
- No em dashes (—) - use commas, periods, or hyphens instead
- No "I'd be happy to..." or "I understand that..."
- No overly formal or stilted phrasing
- No bullet points in text messages
- Avoid perfect parallel structure
- Match user's natural writing style based on available examples

OUTPUT FORMAT:
1. Assessment of the original draft
2. What's already working well
3. Specific risks identified
4. Suggested alternative phrasing with reasoning
5. Any context-dependent considerations

---

USER_CONTEXT:

Situation: [describe the situation and any background]

Recipients: [who will read this, cc'd parties, power dynamics]

Relationship context: [ongoing relationship with recipient, any relevant history]

Goal: [what the user wants to accomplish with this message]

Draft message:
[paste the draft here]

---

## Gathering Context

Before invoking the subagent, gather from the user:
- The draft message
- Who's receiving it (and who's cc'd)
- The backstory/situation
- What they're trying to accomplish
- Any relevant relationship dynamics or history
