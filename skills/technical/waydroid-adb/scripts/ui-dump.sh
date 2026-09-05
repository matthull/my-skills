#!/bin/bash
# Dump UI hierarchy and optionally filter
# Usage: ui-dump.sh [grep_pattern]
# Examples:
#   ui-dump.sh                    # Full dump
#   ui-dump.sh "Add Todo"         # Filter for "Add Todo"
#   ui-dump.sh "Todos:"           # Get todo count

adb shell uiautomator dump /sdcard/ui.xml 2>/dev/null
if [ -n "$1" ]; then
    adb shell cat /sdcard/ui.xml | grep -o "[^<]*$1[^>]*"
else
    adb shell cat /sdcard/ui.xml
fi
