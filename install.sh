#!/bin/bash
set -e

HOOK_PATH="/usr/lib/systemd/system-sleep/fix-gnome-resume.sh"

if [ "$EUID" -ne 0 ]; then
    echo "Re-running with sudo..."
    exec sudo bash "$0" "$@"
fi

# Find the user running gnome-shell
USERNAME=$(ps -o user= -p "$(pgrep -f gnome-shell | head -1)" 2>/dev/null | tr -d ' ')
if [ -z "$USERNAME" ]; then
    echo "Error: could not detect a running GNOME session."
    echo "Make sure you are running this while logged into GNOME."
    exit 1
fi

USER_ID=$(id -u "$USERNAME")
DBUS="unix:path=/run/user/${USER_ID}/bus"

echo "Detected GNOME session for user: $USERNAME (UID: $USER_ID)"

# Detect which dock extension is enabled
ENABLED=$(sudo -u "$USERNAME" DBUS_SESSION_BUS_ADDRESS="$DBUS" gnome-extensions list --enabled 2>/dev/null)

if echo "$ENABLED" | grep -q "ubuntu-dock@ubuntu.com"; then
    DOCK_EXT="ubuntu-dock@ubuntu.com"
elif echo "$ENABLED" | grep -q "dash-to-dock@micxgx.gmail.com"; then
    DOCK_EXT="dash-to-dock@micxgx.gmail.com"
else
    echo "Error: could not find ubuntu-dock or dash-to-dock in enabled extensions."
    echo "Enabled extensions:"
    echo "$ENABLED"
    echo ""
    echo "If you use a different dock, edit $HOOK_PATH after install"
    echo "and replace DOCK_EXT with your extension ID."
    DOCK_EXT="ubuntu-dock@ubuntu.com"
fi

echo "Using dock extension: $DOCK_EXT"

cat > "$HOOK_PATH" << EOF
#!/bin/bash
[ "\$1" = "post" ] || exit 0
sleep 3

USERNAME=\$(ps -o user= -p "\$(pgrep -f gnome-shell | head -1)" 2>/dev/null | tr -d ' ')
[ -z "\$USERNAME" ] && exit 0

USER_ID=\$(id -u "\$USERNAME")
DBUS="unix:path=/run/user/\${USER_ID}/bus"
DOCK_EXT="${DOCK_EXT}"

sudo -u "\$USERNAME" DBUS_SESSION_BUS_ADDRESS="\$DBUS" gnome-extensions disable "\$DOCK_EXT"
sleep 1
sudo -u "\$USERNAME" DBUS_SESSION_BUS_ADDRESS="\$DBUS" gnome-extensions enable "\$DOCK_EXT"
EOF

chmod +x "$HOOK_PATH"
echo ""
echo "Installed: $HOOK_PATH"
echo "Done. The fix will apply automatically on every resume from suspend."
