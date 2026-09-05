---
name: manual-qa
description: Claude QA Engineer procedures — automated AND "manual" testing via tools before human UAT. Load this skill when Claude must verify features end-to-end via tools rather than deferring to human.
---

# Manual QA Practice

**Claude is the QA Engineer.** All testing (automated AND "manual") happens before handoff to human.

**"Manual" testing means using tools** — not deferring to human:
- **Mobile**: Waydroid + ADB screenshots, Maestro flows
- **Web**: Browser automation, DevTools console, network inspection
- **API**: curl/httpie, console verification, response inspection
- **Backend**: Rails console, database queries, log inspection

---

## CRITICAL: Tools Unavailable Protocol

If Claude cannot complete verification because tools are unavailable:

1. **IMMEDIATELY STOP** — Do not proceed without verification
2. **Do NOT hand off with "please manually verify"**
3. **Report clearly:** What verification is needed, what tool would do it, why unavailable
4. **Ask for guidance:** Setup help, alternative approach, defer task

**You MUST NEVER:**
- Hand off with "please manually test [X]" when Claude should have tested it
- Skip verification and hope for the best
- Assume human will catch issues Claude should have caught

---

## QA Gate Checklist

Claude completes ALL before handoff:
- [ ] Automated tests passing (Loop 1 + Loop 2)
- [ ] "Manual" verification complete via tools (Loop 3)
- [ ] All edge cases tested
- [ ] Error states verified (trigger errors, confirm behavior)
- [ ] Data persistence verified (create, query, confirm in DB)
- [ ] No console errors/warnings
- [ ] Performance acceptable

---

## Available QA Tools

**Mobile (React Native/Expo):**
- `adb exec-out screencap -p > /tmp/screen.png` — Screenshot
- `adb shell am start/force-stop` — Launch/restart app
- ADB tap scripts for UI interaction

**Web (Browser):**
- Browser MCP tools (navigate, screenshot, click, fill)
- DevTools console and network inspection

**Backend (Rails/API):**
- Rails console for data verification
- curl/httpie for API testing
- Docker logs for error inspection

---

## Human UAT (After Claude QA Complete)

**Claude handles ALL testing.** Human (Product Manager) does UAT on a thoroughly tested feature:
- Final product acceptance
- Subjective UX evaluation
- Exploratory testing (optional)
- Sign-off for release

**The handoff should be:**
> "Feature is fully tested. All automated tests pass. I verified the full user flow via [tools used]. Edge cases tested: [list]. Ready for your UAT sign-off."

**NOT:**
> "Tests pass. Please manually verify [list of things Claude should have tested]."

---

## Anti-patterns

**You MUST NEVER:**
- Defer "manual" testing to human — use tools instead
- Hand off with "please verify [X]" when tools could verify it
- Skip edge case testing because "tests pass"
- Assume UI works without visual verification via tools
- Mark complete without verifying data persistence
- Test only happy path

**Claude MUST:**
- Use available tools for visual verification
- Test with production-like data volumes
- Verify both UI (via screenshots) and database state
- Test with multiple user roles/permissions
- Document unexpected behavior found during testing
- Hand off with verification evidence
