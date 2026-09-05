---
name: waydroid-adb
description: Control Waydroid Android emulator via ADB for Expo/React Native development. This skill should be used when needing to take screenshots of Waydroid, verify app rendering, install APKs, or interact with the Android emulator. Triggers on tasks involving Android emulator verification, mobile app visual testing, or Waydroid troubleshooting.
---

# Waydroid ADB Control

Tools and workflows for controlling Waydroid Android emulator via ADB for Expo/React Native development.

## Session Startup

**Always run the startup script first:**
```bash
<project-root>/scripts/waydroid-dev-start.sh
```

This handles network config, ADB connection, and port forwarding (Metro 8081, Supabase 54321, PowerSync 8080). Takes ~15 seconds.

## Development Build vs Expo Go

**We use a development build** (custom native app) instead of Expo Go because:
- MMKV, PowerSync, and other native modules require custom native code
- Dev builds support all native modules after one-time compile
- Hot reload still works normally via Metro

### First-Time Build
```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
npx expo prebuild --platform android  # Generate android/ folder
npx expo run:android                   # Build + install (~5-10 min)
```

### Subsequent Development
After dev build is installed, start the full dev environment:
```bash
npm run dev
# Starts Supabase + PowerSync + Metro
# App already installed - hot reload works
```

Or start services separately:
```bash
npm run dev:backend  # Supabase + PowerSync only
npm start            # Metro only (if backend already running)
```

### Rebuild Required When
- Adding new native dependencies
- Changing app.json/app.config.js native settings
- After `npm install` of packages with native code

## Error Handling During Emulator Verification

**This applies to ALL emulator use: frontend verification, E2E QA, integration testing, debugging.**

When you observe any console error, network error, debugger warning, or unexpected log output during emulator sessions, you MUST either fix it or explicitly escalate. There is no third option.

**You MUST NEVER:**
- Classify errors as "dev-only noise" and proceed — this is a dismissal, not a resolution
- Label errors as "pre-existing" or "unrelated" without evidence and without escalating
- Note an error in a completion summary and move on without a decision

**You MUST ALWAYS** — for every error observed — do one of:
1. **Fix it** — if the error is caused by your changes or is clearly fixable
2. **Escalate it** — using this format:
   ```
   ESCALATION: [error description + what URL/module/line if available]
   Evidence it is pre-existing: [e.g. "present on main branch before my changes" — or "unknown"]
   Impact: [does it affect the task's functionality?]
   Recommended action: [fix now / defer with reason / ignore with reason]
   Decision needed from user: YES
   ```

Silence is not acceptable. Classify and escalate — never just note and move on.

## Common Operations

### Take Screenshot
```bash
adb exec-out screencap -p > /tmp/screen.png
```
Then use Read tool to view the image.

### Check Status
```bash
waydroid status  # Container state
adb devices      # ADB connection (should show "device")
```

### Launch Dev Build App
```bash
# Launch by package name (dev build)
adb shell am start -n com.anonymous.projectalfalfa/.MainActivity
```

### Force Restart App
```bash
adb shell am force-stop com.anonymous.projectalfalfa
adb shell am start -n com.anonymous.projectalfalfa/.MainActivity
```

### Install APK
```bash
adb install /path/to/app.apk
```

### View Logs (for debugging)
```bash
adb logcat -d | grep -iE "react|expo|error" | tail -30
```

### Toggle Dark Mode
```bash
adb shell cmd uimode night yes   # Enable dark mode
adb shell cmd uimode night no    # Disable dark mode
```

## UI Interaction (USE HELPER SCRIPTS)

**ALWAYS use helper scripts for UI interaction - they can be whitelisted for auto-approval.**

### Tap a Button by Label
```bash
~/.claude/skills/waydroid-adb/scripts/tap-button.sh "Add Todo"
~/.claude/skills/waydroid-adb/scripts/tap-button.sh "Clear All"
~/.claude/skills/waydroid-adb/scripts/tap-button.sh "Cycle Theme"
```

### Get UI Text Values
```bash
~/.claude/skills/waydroid-adb/scripts/get-ui-text.sh "Todos:"    # Returns "Todos: 5"
~/.claude/skills/waydroid-adb/scripts/get-ui-text.sh "DB:"       # Returns "DB: Ready"
~/.claude/skills/waydroid-adb/scripts/get-ui-text.sh "Connected" # Returns "Connected"
```

### Dump UI Hierarchy
```bash
~/.claude/skills/waydroid-adb/scripts/ui-dump.sh                 # Full dump
~/.claude/skills/waydroid-adb/scripts/ui-dump.sh "Add Todo"      # Filter for pattern
```

### Launch/Restart App
```bash
~/.claude/skills/waydroid-adb/scripts/app-launch.sh              # Launch app
~/.claude/skills/waydroid-adb/scripts/app-launch.sh --restart    # Force restart
```

### Take Screenshot
```bash
~/.claude/skills/waydroid-adb/scripts/screenshot.sh              # Save to /tmp/waydroid_screen.png
~/.claude/skills/waydroid-adb/scripts/screenshot.sh /tmp/test.png
```

### React Native Specifics
- **Buttons**: Use `content-desc` (set via `accessibilityLabel` prop)
- **Text**: Use `text` attribute
- **Views with testID**: Check `resource-id` (may have package prefix)

### Manual ADB Commands (fallback)
```bash
adb shell input text "hello"              # Type text (no spaces)
adb shell input keyevent KEYCODE_BACK     # Back button (keyevent 4)
adb shell input keyevent KEYCODE_ENTER    # Enter key (keyevent 66)
adb shell input keyevent 61               # TAB - move to next field
adb shell input swipe 500 1000 500 500    # Swipe up (x1 y1 x2 y2)
```

### Form Input Best Practices

**IMPORTANT:** When filling forms (login, signup, etc.):

1. **Use TAB to navigate fields** - More reliable than tapping each field
2. **Use TAB + SPACE to submit** - From last field, TAB to button then SPACE to press
3. **Avoid special characters** - `!`, `@`, `#` don't work reliably via ADB text input
4. **Clear fields first** - Text appends rather than replaces; clear before entering

### Login Flow (Recommended)

```bash
# 1. Get coordinates from ui-dump (one-time)
~/.claude/skills/waydroid-adb/scripts/ui-dump.sh | grep -E 'Email|Password|Sign In'

# 2. Tap email field (use coordinates from ui-dump, typically ~708,793)
adb shell input tap 708 793
sleep 1

# 3. Enter email
adb shell input text 'staff-a@test.com'

# 4. TAB to password field
adb shell input keyevent 61

# 5. Enter password (no special chars - test password is TestPass123)
adb shell input text 'TestPass123'

# 6. TAB to Sign In button, then SPACE to press it
adb shell input keyevent 61
adb shell input keyevent 62
```

**Alternative: Use tap-button.sh** (if button has accessibility label):
```bash
adb shell input keyevent 4                           # Dismiss keyboard first
~/.claude/skills/waydroid-adb/scripts/tap-button.sh "Sign In"
```

### Test Credentials

| User | Email | Password | Business | Role |
|------|-------|----------|----------|------|
| staff-a | staff-a@test.com | TestPass123 | Farm A | staff |
| staff-b | staff-b@test.com | TestPass123 | Farm B | staff |
| customer-a | customer-a@test.com | TestPass123 | Farm A | customer |

**Note:** Passwords intentionally have no special characters for ADB compatibility.

## Workflows

### Verify App Rendering (Dev Build)
1. Run startup script (if not already done)
2. Start Metro: `npm start`
3. Launch app: `adb shell am start -n com.anonymous.projectalfalfa/.MainActivity`
4. Take screenshot: `adb exec-out screencap -p > /tmp/screen.png`
5. View with Read tool

### Hot Reload Verification
1. Take screenshot
2. Make code change and save
3. Wait 3-4 seconds
4. Take another screenshot
5. Compare to verify change reflected

### Debug Loading Issues
1. Check Metro is running: `ss -tlnp | grep 8081`
2. Check adb reverse: `adb reverse --list`
3. Check logs: `adb logcat -d | grep -iE "react|expo|error" | tail -30`
4. Force restart app and retry

### Test Persistence (State Survives Restart)
1. Take screenshot showing initial state
2. Change state in app (e.g., theme preference)
3. Take screenshot showing changed state
4. Force quit: `adb shell am force-stop com.anonymous.projectalfalfa`
5. Relaunch app
6. Take screenshot - state should be preserved

## Scripts

All scripts are in `~/.claude/skills/waydroid-adb/scripts/` and can be whitelisted.

| Script | Purpose | Example |
|--------|---------|---------|
| `screenshot.sh` | Take screenshot | `screenshot.sh /tmp/test.png` |
| `status.sh` | Full status check | `status.sh` |
| `tap-button.sh` | Tap button by label | `tap-button.sh "Add Todo"` |
| `get-ui-text.sh` | Get text from UI | `get-ui-text.sh "Todos:"` |
| `ui-dump.sh` | Dump/filter UI hierarchy | `ui-dump.sh "pattern"` |
| `app-launch.sh` | Launch/restart app | `app-launch.sh --restart` |

## Offline Testing

**IMPORTANT:** Waydroid airplane mode does NOT work for simulating offline conditions.

Waydroid runs as a container using the host's network stack. Setting `airplane_mode_on=1` via ADB changes the Android setting but doesn't actually disconnect network access:

```bash
# This does NOT work to simulate offline:
adb shell settings put global airplane_mode_on 1
# Container still has network access via host
```

### Simulating Offline Mode

**Method 1: Stop Backend Services (Recommended)**

For testing offline behavior (e.g., session persistence when auth server unreachable):

```bash
# Stop Supabase services
docker stop supabase-db supabase-kong supabase-auth

# Test app behavior while backend is down
adb shell am force-stop com.anonymous.projectalfalfa
adb shell am start -n com.anonymous.projectalfalfa/.MainActivity

# Verify offline handling (screenshots, logcat)
~/.claude/skills/waydroid-adb/scripts/screenshot.sh /tmp/offline-test.png

# Restart services when done
docker start supabase-db supabase-kong supabase-auth
```

**Method 2: Block Host Network (More Invasive)**

For complete network isolation, block traffic at the host level:

```bash
# Block all traffic to backend ports
sudo iptables -A OUTPUT -p tcp --dport 54321 -j DROP  # Supabase
sudo iptables -A OUTPUT -p tcp --dport 8080 -j DROP   # PowerSync

# Test offline behavior...

# Remove blocks when done
sudo iptables -D OUTPUT -p tcp --dport 54321 -j DROP
sudo iptables -D OUTPUT -p tcp --dport 8080 -j DROP
```

### Verifying Offline State

The app's PowerSync indicator shows connectivity:
- **"Connected"** - Network available, auth valid
- **"Offline"** - Network unavailable or auth failed
- **Error banner** - Connection issues (check message for details)

Use logcat to verify offline handling:
```bash
adb logcat -d | grep -E '(MMKV|Session|backup|offline)' | tail -20
```

---

## Troubleshooting

### Supabase Auth Network Errors After Auth Testing

**Symptoms:** `TypeError: Network request failed` / `AuthRetryableFetchError` errors in logcat and as dev overlays on cold start.

**Root cause:** The Supabase JS client is initialized as a module-level singleton in `SupabaseConnector.ts` with `autoRefreshToken: true`. When Expo Router bundles the route graph, it includes `(auth)/login.tsx` → `@/lib/auth/signIn.ts` → `supabaseConnector`. If MMKV has a cached auth session from previous test logins, the Supabase client auto-refreshes it on startup — but `localhost:54321` is unreachable from Waydroid.

**Fix:** Clear all app data to remove the cached session:
```bash
adb shell pm clear com.anonymous.projectalfalfa
adb shell am start -n com.anonymous.projectalfalfa/.MainActivity
```

**Recurrence:** This reoccurs any time auth testing writes a session to MMKV and then demo mode is tested afterward. Standard practice: clear app data when switching from auth testing to demo mode testing.

---

### Container FROZEN State (ADB Commands Hang)

**Symptoms:**
- ADB commands hang indefinitely (screenshot, shell, etc.)
- `adb devices` shows `192.168.240.112:5555 offline`
- Commands time out or never return

**Diagnosis:**
```bash
waydroid status
# Look for: Container: FROZEN
```

**Cause:** Waydroid has a power-saving feature that freezes the container after idle timeout. When frozen, all network and ADB communication fails.

**Fix:**
```bash
sudo waydroid container unfreeze
```

Then retry your ADB command. The startup script (`waydroid-dev-start.sh`) handles this automatically, but if you've been idle for a while mid-session, you may need to unfreeze manually.

**Prevention:** The startup script now detects and unfreezes automatically. If you encounter this mid-session, just run the unfreeze command above.

### ADB Connection Issues

If ADB won't connect even after unfreeze:
```bash
# Full reconnect sequence
adb kill-server
adb start-server
adb connect 192.168.240.112:5555
```

If still failing, re-run the startup script which handles network, iptables, and ADB:
```bash
<project-root>/scripts/waydroid-dev-start.sh
```

## Reference

For detailed setup, troubleshooting, and known issues, see:
- Project docs: `<project-root>/docs/waydroid-setup.md`
- Skill reference: `references/setup-guide.md`
