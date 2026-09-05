#!/bin/bash
# Find button by content-desc (accessibility label) and tap it
# Usage: tap-button.sh "Button Label"
# Example: tap-button.sh "Add Todo"

if [ -z "$1" ]; then
    echo "Usage: tap-button.sh \"Button Label\""
    exit 1
fi

LABEL="$1"

# Dump UI and find bounds
adb shell uiautomator dump /sdcard/ui.xml 2>/dev/null
BOUNDS=$(adb shell cat /sdcard/ui.xml | grep -o "content-desc=\"$LABEL\"[^>]*bounds=\"\[[0-9]*,[0-9]*\]\[[0-9]*,[0-9]*\]\"" | grep -o "bounds=\"[^\"]*\"" | grep -o "\[.*\]")

if [ -z "$BOUNDS" ]; then
    echo "Button '$LABEL' not found"
    exit 1
fi

# Parse bounds [x1,y1][x2,y2] and calculate center
X1=$(echo "$BOUNDS" | sed 's/\[\([0-9]*\),\([0-9]*\)\]\[\([0-9]*\),\([0-9]*\)\]/\1/')
Y1=$(echo "$BOUNDS" | sed 's/\[\([0-9]*\),\([0-9]*\)\]\[\([0-9]*\),\([0-9]*\)\]/\2/')
X2=$(echo "$BOUNDS" | sed 's/\[\([0-9]*\),\([0-9]*\)\]\[\([0-9]*\),\([0-9]*\)\]/\3/')
Y2=$(echo "$BOUNDS" | sed 's/\[\([0-9]*\),\([0-9]*\)\]\[\([0-9]*\),\([0-9]*\)\]/\4/')

CENTER_X=$(( (X1 + X2) / 2 ))
CENTER_Y=$(( (Y1 + Y2) / 2 ))

adb shell input tap $CENTER_X $CENTER_Y
echo "Tapped '$LABEL' at ($CENTER_X, $CENTER_Y)"
