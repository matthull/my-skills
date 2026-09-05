#!/bin/bash
# Get text values from UI matching a pattern
# Usage: get-ui-text.sh "pattern"
# Examples:
#   get-ui-text.sh "Todos:"     # Returns "Todos: 5"
#   get-ui-text.sh "DB:"        # Returns "DB: Ready"
#   get-ui-text.sh "Connected"  # Returns "Connected"

if [ -z "$1" ]; then
    echo "Usage: get-ui-text.sh \"pattern\""
    exit 1
fi

PATTERN="$1"

adb shell uiautomator dump /sdcard/ui.xml 2>/dev/null
adb shell cat /sdcard/ui.xml | grep -oE "text=\"[^\"]*$PATTERN[^\"]*\"" | sed 's/text="//;s/"$//'
