#!/bin/bash
HOOK_PATH="/usr/lib/systemd/system-sleep/fix-gnome-resume.sh"

if [ "$EUID" -ne 0 ]; then
    exec sudo bash "$0" "$@"
fi

if [ -f "$HOOK_PATH" ]; then
    rm "$HOOK_PATH"
    echo "Removed: $HOOK_PATH"
else
    echo "Nothing to remove (hook not found at $HOOK_PATH)"
fi
