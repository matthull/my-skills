---
description: "Transcribe a YouTube video and do something with the transcript. Wraps youtube-to-signal. Use when a YouTube URL appears and the user wants to work with its content — summarize, analyze, extract quotes, review, or anything else."
---

# YouTube Transcribe

Transcribe a YouTube video, then follow the caller's instructions for what to do with the transcript.

## Usage

```
/youtube-transcribe <youtube-url> [instructions for what to do with the transcript]
```

## Workflow

### 1. Transcribe

Extract the URL from the arguments. Run:

```bash
~/.local/bin/youtube-to-signal "<url>" --model small --output-dir /tmp/youtube-transcribe
```

This downloads the audio, transcribes via Whisper, and saves a markdown file to `/tmp/youtube-transcribe/`.

Read the resulting transcript file from `/tmp/youtube-transcribe/` (it will be the most recently created `.md` file there).

### 2. Follow Instructions

If the caller provided instructions beyond the URL, follow them — the transcript is now in your context. Summarize, analyze, extract, review, whatever was asked.

If no instructions were provided, present a brief summary of the video (title, channel, duration) and ask what the user wants to do with the transcript.
