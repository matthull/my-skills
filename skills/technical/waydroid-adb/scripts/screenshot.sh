#!/bin/bash
# Take a screenshot from Waydroid via ADB
# Usage: screenshot.sh [output_path]
# Default output: /tmp/waydroid_screen.png

OUTPUT_PATH="${1:-/tmp/waydroid_screen.png}"

# Check ADB connection
if ! adb devices | grep -q "device$"; then
    echo "ERROR: No ADB device connected"
    echo "Try: adb connect 192.168.240.112:5555"
    exit 1
fi

# Take screenshot
if adb exec-out screencap -p > "$OUTPUT_PATH" 2>/dev/null; then
    FILE_SIZE=$(stat -f%z "$OUTPUT_PATH" 2>/dev/null || stat -c%s "$OUTPUT_PATH" 2>/dev/null)
    if [ "$FILE_SIZE" -gt 1000 ]; then
        echo "Screenshot saved to: $OUTPUT_PATH"
        echo "Size: $FILE_SIZE bytes"
        echo ""
        echo "Use the Read tool to view the screenshot."
    else
        echo "ERROR: Screenshot appears empty (size: $FILE_SIZE bytes)"
        echo "Waydroid may be frozen. Try: waydroid show-full-ui"
        exit 1
    fi
else
    echo "ERROR: Failed to take screenshot"
    exit 1
fi
