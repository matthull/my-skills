#!/bin/bash
# Launch or restart the app
# Usage: app-launch.sh [--restart]

PACKAGE="com.anonymous.projectalfalfa"
ACTIVITY="$PACKAGE/.MainActivity"

if [ "$1" = "--restart" ]; then
    adb shell am force-stop $PACKAGE
    sleep 1
fi

adb shell am start -n $ACTIVITY
