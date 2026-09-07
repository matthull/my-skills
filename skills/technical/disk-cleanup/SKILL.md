---
name: disk-cleanup
description: Analyze disk usage and clean package and container caches on an Arch Linux workstation. Use when the user mentions disk space, storage, cleanup, or that a drive is full.
---

# /disk-cleanup

Analyze disk usage and clean package/container caches on an Arch Linux workstation.

**Trigger:** User mentions disk space, storage, cleanup, or "drive is full."

## Analysis Phase

Run these commands to build a usage picture. Start broad, drill into the big items.

### 1. Overall State

```bash
df -h /
```

### 2. Top-Level Scan

Measure `/home/<user>/*` and `/home/<user>/.*` (hidden dirs) separately:

```bash
du -sh /home/<user>/* 2>/dev/null > /tmp/du-home.txt
sort -rh /tmp/du-home.txt > /tmp/du-home-sorted.txt

du -sh /home/<user>/.* 2>/dev/null > /tmp/du-hidden.txt
sort -rh /tmp/du-hidden.txt > /tmp/du-hidden-sorted.txt
```

Then read the sorted files. The usual suspects for hidden dirs:
- `~/.cache` (yay, pip, uv, yarn, npm, Cypress, Playwright, puppeteer, huggingface, browsers)
- `~/.local/share` (Steam, vosk, waydroid, whisper models, flatpak)
- `~/.npm`, `~/.gradle`, `~/.gem`, `~/.nvm`, `~/.rustup`, `~/.cargo`

### 3. Docker

```bash
docker system df        # Summary: images, containers, volumes, build cache
docker system df -v     # Verbose: per-image and per-volume breakdown
```

Check for orphaned worktree Docker environments — containers/volumes from worktrees that no longer exist. Compare `docker ps -a --format "{{.Names}}"` against `git worktree list`.

### 4. System Caches

```bash
du -sh /var/cache/pacman 2>/dev/null   # pacman package cache
du -sh /var/log 2>/dev/null            # system logs
du -sh /opt 2>/dev/null                # optional packages (DaVinci Resolve, etc.)
```

## Cleanup Commands (Safe)

All of these are safe — they clear caches that will be rebuilt on demand. No data loss risk.

### Package Manager Caches

| Cache | Command | Notes |
|-------|---------|-------|
| yay (AUR builds) | `yay -Sc --noconfirm` | Often the single biggest hog (100GB+). Clears build source + compiled packages. |
| pacman | `paccache -r` | Keeps last 3 versions. Use `paccache -rk1` to keep only 1. |
| npm | `npm cache clean --force` | |
| yarn | `yarn cache clean` | |
| pip | `pip cache purge` | |
| uv | `uv cache clean` | |
| Go build | `go clean -cache` | |
| Gradle | `rm -rf ~/.gradle/caches` | Only if not actively building Android |

### Docker

| What | Command | Notes |
|------|---------|-------|
| Dangling images | `docker image prune -f` | Images not tagged or referenced |
| All unused images | `docker image prune -a -f` | Images not used by any container. **Will require rebuild next time.** |
| Orphaned volumes | `docker volume prune -f` | Volumes not attached to any container |
| Full cleanup | `docker system prune -a --volumes -f` | Nuclear option: images + containers + volumes + networks |

### Example App Worktree Docker Cleanup

When removing a example-app worktree, always run the cleanup script first:

```bash
cd /path/to/worktree
../../example-app/scripts/wtp-cleanup-env.sh
```

This tears down Docker containers and volumes for that worktree's project (`example-app-wt-{ID}`). Without it, `wtp remove` leaves orphaned Docker resources.

**Known gap:** `wtp remove` does not call this script automatically. It must be run manually before worktree removal.

### Browser/Test Tool Caches

These are large and safe to clear, but will re-download on next use:

| Cache | Location | Clear command |
|-------|----------|---------------|
| Cypress | `~/.cache/Cypress` | `rm -rf ~/.cache/Cypress` |
| Playwright | `~/.cache/ms-playwright` | `rm -rf ~/.cache/ms-playwright` |
| Puppeteer | `~/.cache/puppeteer` | `rm -rf ~/.cache/puppeteer` |
| Selenium | `~/.cache/selenium` | `rm -rf ~/.cache/selenium` |

## Verification

After cleanup, verify with `df -h /` and compare before/after.

## What NOT to Clean Without Asking

- `~/Videos`, `~/Pictures`, `~/docs` — personal media, operator decides
- `~/.local/share/Steam` — games, operator decides
- `~/.local/share/vosk`, `~/.cache/huggingface` — ML models, may be in active use
- `/var/lib/docker` — never rm directly, use Docker CLI
- Any git repo or worktree directory
