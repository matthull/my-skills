---
name: davinci-resolve
description: DaVinci Resolve 20 video editing for developer screencasts. This skill should be used when editing OBS recordings into railscasts-style screencasts — importing footage, removing/replacing audio, speed ramping, voiceover, captions, and export. Triggers on "davinci", "resolve", "screencast", "edit video", "edit recording", or video post-production tasks.
---

# DaVinci Resolve — Screencast Editing

Edit OBS screen recordings into polished developer screencasts (railscasts-style). Covers the end-to-end workflow from raw recording to exported video.

## Environment

- **DaVinci Resolve 20** (free edition) on Arch Linux
- **OBS Studio** recordings in `~/Videos/` (MP4, default OBS output)
- **Finished screencasts** go to `~/Videos/screencasts/`

## Screencast Editing Workflow

The standard workflow for a developer screencast:

### 1. Project Setup

1. Launch DaVinci Resolve (`davinci-resolve` from terminal or app menu)
2. Create new project from Project Manager
3. Switch to **Edit** page (timeline icon at bottom bar)
4. Close unnecessary panels — toggle off **Media Pool** (top-left icon) and **Inspector** (top-right icon) to maximize viewer/timeline space
5. Import: right-click Media Pool area → **Import Media...** → select recording from `~/Videos/`
6. Drag clip from Media Pool to timeline (auto-creates timeline)
7. Set proxy mode for smooth playback: **Playback** menu → **Proxy Mode** → **Half Resolution**

### 2. Remove Original Audio

OBS recordings include system/mic audio that is usually replaced with voiceover.

1. Right-click clip in timeline → **Remove Attributes...**
2. Check **All Audio Attributes** → OK

This strips the audio component from the clip. The video remains intact.

**Note:** "Link/Unlink" for separating audio from video is not available via right-click in Resolve 20. Use Remove Attributes instead.

### 3. Trim Start and End

1. Play from beginning — find where real content starts
2. Park playhead at that point → **Ctrl+B** to split
3. Click the junk segment before the cut → **Backspace** (ripple delete — removes and closes gap)
4. Jump to end of timeline (**End** key), trim the tail the same way

### 4. Speed Ramp Boring Sections

The goal is to show the full workflow without jump cuts — speed up boring parts rather than deleting them.

**Navigation:**
- **Space** — play/pause
- **J / K / L** — rewind / pause / forward (tap J or L multiple times for faster speed)
- **Left/Right arrows** — frame-by-frame
- **End** — jump to end of timeline
- Drag playhead in timeline ruler

**Splitting clips:** Park playhead → **Ctrl+B** to split at playhead. (Blade tool **B** also works but Ctrl+B is more reliable.)

**Speed ramping:**
1. Split at start and end of a boring section using **Ctrl+B**
2. Right-click the boring segment → **Change Speed**
3. Set percentage (e.g. 400% for 4x) and check **Ripple Sequence** to auto-close timeline gaps
4. Repeat for all boring sections

**Matching video speed to audio duration:**
To speed-ramp a video segment so it exactly matches an audio clip's length:
- **Formula:** Speed % = (original video duration / target audio duration) × 100
- **Visual method:** Hold **Ctrl** and drag the right edge of the video clip — this speed-changes (not trims) the clip to fit the new duration

**Compound clips:** Select multiple clips (Ctrl+click) → right-click → **New Compound Clip** to merge them into one. Double-click a compound clip to edit inside it.

### 5. Audio Overlay

After the rough cut is locked, add replacement audio.

**Voiceover (record in Resolve):**
1. Switch to **Fairlight** page (music note icon at bottom bar)
2. Right-click in track header area (far left of timeline) → **Add Track** → **Mono**
3. Set input: click the input routing on the track header → **Patch Input/Output** dialog → Source: **Audio Inputs**, select your ALSA mic input (usually **1: ALSA**), Destination: click your new track → close
4. Arm the track (red **R** button on track header)
5. **Mute the track** (**M** button on track header) to prevent echo/feedback while recording
6. Increase audio buffer if crackling: **DaVinci Resolve** menu → **Preferences** → **Audio** → **Buffer Size** → 1024 or 2048
7. Park playhead where narration starts → press **Record** (red circle in transport controls at bottom) — video plays while you narrate
8. Press **Space** or **Stop** when done

**Voiceover (external file):**
1. Import audio file into Media Pool
2. Drag it onto Audio Track 2 (A2) in the timeline
3. Align with video

**Background music:**
1. Import audio file
2. Drag onto a new audio track (A3)
3. Lower volume: select clip → **Inspector** → **Volume** slider (or right-click → **Set Clip Volume**)
4. Music should be -15dB to -20dB below voiceover

### 6. Zoom Into Code / Image Overlays

**Zoom into a section of video (e.g. a few lines of code):**
1. Split the clip at start and end of the section to zoom (Ctrl+B)
2. Select the middle segment → **Inspector** (Ctrl+I) → **Video → Transform**
3. Increase **Zoom** (e.g. 2.0 for 2x), adjust **Position X/Y** to center on the target area
4. For smooth zoom: click the **diamond keyframe icon** next to Zoom at the start, move playhead a few frames forward, change Zoom value — Resolve auto-creates the transition. Reverse at the end to zoom back out.

**Image overlays (diagrams, screenshots):**
1. Import image into Media Pool
2. Drag onto a track above video (V2/V3)
3. Select image clip → **Inspector** → **Video → Transform** → adjust **Zoom** and **Position** to size/place it

### 7. Contextual Text Annotations

Explanatory text overlays that contextualize what's happening on screen (e.g. "Setting up the config file", "Running the test suite").

1. In the top icon row of the left panel, click the **T** icon (Titles) — it's next to the sparkle/effects icon
2. Drag **Text** onto a track above your video in the timeline (creates V2)
3. Stretch/shrink the title clip to match how long the context is relevant
4. Select the title clip → toggle **Inspector** (wrench icon, top-right, or **Ctrl+I**)
5. Edit text content, font, size, color, position in the Inspector

## Claude Code Screencast Style Guide

These screencasts show Claude Code sessions — prompting, Claude generating, reviewing output, iterating. The value is expert judgment about what to ask and how to evaluate, not watching Claude type.

### Voiceover Principles

- **Narrate intent, not action.** "I'm going to have Claude build the API endpoint" not "Now I'm typing a prompt." The viewer can see what's happening — explain *why*.
- **Narrate during fast-forward sections especially.** While Claude churns, explain what it's doing and why you prompted it that way. Fast-forward becomes *more* interesting than real-time with expert commentary.
- **Front-load context.** Before each Claude interaction, briefly explain what you're about to ask and why. Then let the clip play/fast-forward.
- **Comment on Claude's output, not the process.** When Claude finishes, pause on the result and narrate what's interesting. Skip narrating the thinking/streaming.

### Pacing

- **Normal speed:** your prompts (viewers want to read them), reviewing Claude's output, test results, key decisions
- **4x-8x speed:** Claude generating responses, long file reads, scrolling output
- **Cut entirely:** false starts, re-prompts where you changed your mind, debugging your own typos

### Annotations

- Label *what phase you're in*: "Prompting", "Reviewing output", "Running tests", "Iterating on feedback"
- Annotate when something surprising or important happens in Claude's output that might scroll by fast
- Caption the prompt text itself if it's not fully visible on screen

### Structure

- Open with 15-30 seconds of "here's what we're building and why"
- Close with "here's what we accomplished" — show the diff or test output
- Each "prompt → Claude works → review output" cycle is a natural segment

### 8. Export

1. Switch to **Deliver** page (rocket icon at bottom bar)
2. Select preset: **YouTube** (1080p) is a good default
3. Verify settings:
   - **Resolution:** 1920x1080 (match your OBS recording)
   - **Frame Rate:** match source (usually 30 or 60fps)
   - **Format:** MP4
   - **Codec:** H.264 (broad compatibility) or H.265 (smaller file)
4. Set **Save to** location: `~/Videos/screencasts/`
5. Click **Add to Render Queue** (bottom-left of settings panel)
6. Click **Render All** (right panel)

**Linux free edition note:** H.264/H.265 codecs are not available — only APV. Export as MOV/APV, then convert with ffmpeg:

```bash
ffmpeg -i output.mov -vf format=yuv420p -c:v libx264 -preset fast -crf 22 -c:a aac -b:a 128k output.mp4
```

The `-vf format=yuv420p` is required because ProRes exports as 10-bit yuv422p10le. Intel Arc QSV encoding (`hevc_qsv`, `av1_qsv`) has not worked — MFX session errors with 10-bit input. CPU libx264 is the proven path.

**Export takes ~40 minutes for a 17-min video** (render + convert). Run ffmpeg with `run_in_background`.

**CRITICAL: Check audio before sharing.** Verify the exported file has audio:
```bash
ffmpeg -i output.mp4 -af volumedetect -f null /dev/null 2>&1 | grep mean_volume
```
If mean_volume is below -80dB, audio is silent. Common cause: voiceover track was muted (M button) during export. Unmute before rendering.

**Consider Descript** for future screencasts — web-based editor with cloud rendering, transcript-based editing, built-in voiceover/captions. Eliminates the ProRes→ffmpeg conversion pain. Resolve remains useful for complex editing but the export workflow on Linux free edition is painful.

## Keyboard Shortcuts Reference

| Action | Shortcut |
|---|---|
| Play/Pause | Space |
| Rewind / Pause / Forward | J / K / L |
| Frame back/forward | Left / Right arrow |
| Blade tool | B |
| Selection tool | A |
| Trim tool | T |
| Undo | Ctrl+Z |
| Ripple delete | Backspace |
| Delete (leave gap) | Delete |
| Fullscreen viewer | Ctrl+F |
| Cinema viewer | Ctrl+Shift+F (Esc to exit) |
| Mark In / Out | I / O |
| Split clip at playhead | Ctrl+B (without switching to blade) |
| Move clip to track above | Alt+Up Arrow |
| Move clip to track below | Alt+Down Arrow |
| Drag clip between tracks | Hold Shift while dragging vertically |

## Viewer Controls

- **Maximize viewer:** Ctrl+F toggles fullscreen viewer
- **Hide panels:** Toggle off Media Pool (top-left icon), Inspector (top-right icon), Effects Library to reclaim space
- **Zoom timeline:** Alt+scroll wheel on the timeline area (not the ruler)

## Linux-Specific Notes

- **Launch:** `davinci-resolve` from terminal, or via desktop launcher
- **OBS output:** Default `~/Videos/` — MP4 files with timestamp names
- **Audio devices:** Fairlight page uses ALSA/PulseAudio. If mic input doesn't appear, check `pavucontrol` for input device routing.
- **GPU:** Resolve prefers NVIDIA on Linux. Intel Arc / AMD may have limited hardware acceleration in free version.
- **Crashes on export:** If Resolve crashes during render, try switching codec from H.265 to H.264, or reduce timeline resolution to 1080p.
- **File permissions:** Resolve may not follow symlinks for media import. Use actual file paths.

## Project Context

Read `resources/domain-skill.md` if it exists for project-specific guidance.
Read `resources/personal-skill.md` if it exists for personal customizations.
