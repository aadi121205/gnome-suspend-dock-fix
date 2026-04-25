# GNOME Suspend Dock Fix

Fixes a common GNOME bug where the dock (taskbar) breaks after resuming from suspend — pinned apps disappear, leaving only the app grid button, and workspaces may stop responding.

Tested on Ubuntu 24.04+ with GNOME 46–50. Likely affects any distro using `ubuntu-dock` or `dash-to-dock`.

## The Problem

When your laptop resumes from suspend, the `ubuntu-dock` or `dash-to-dock` GNOME extension crashes. On X11 you can recover by reloading GNOME Shell (`Alt+F2` → type `r`), but on Wayland there is no in-session reload — you have to log out.

## The Fix

A systemd sleep hook that automatically restarts the dock extension a few seconds after every resume. No reboot or logout needed.

## Install

```bash
git clone https://github.com/YOUR_USERNAME/gnome-suspend-dock-fix
cd gnome-suspend-dock-fix
chmod +x install.sh
./install.sh
```

The installer:
- Auto-detects your running GNOME session user
- Auto-detects whether you use `ubuntu-dock` or `dash-to-dock`
- Installs a hook at `/usr/lib/systemd/system-sleep/fix-gnome-resume.sh`

Suspend and resume once to confirm it works.

## Uninstall

```bash
./uninstall.sh
```

## Using a different dock extension

If you use a dock other than `ubuntu-dock` or `dash-to-dock`, install first, then edit the hook:

```bash
sudo nano /usr/lib/systemd/system-sleep/fix-gnome-resume.sh
```

Replace `DOCK_EXT=` with your extension's ID. You can find it with:

```bash
gnome-extensions list --enabled
```

## How it works

`/usr/lib/systemd/system-sleep/` scripts are run by systemd on every suspend and resume. The hook waits 3 seconds after resume (for the GNOME session to stabilise), then disables and re-enables the dock extension via `gnome-extensions`, which resets its state cleanly.

## Troubleshooting

**Dock still broken after resume** — increase the sleep delay in the hook from `3` to `5`:
```bash
sudo nano /usr/lib/systemd/system-sleep/fix-gnome-resume.sh
```

**Check if the hook ran:**
```bash
sudo journalctl -b -g "fix-gnome-resume"
```

**Extension ID not found** — run `gnome-extensions list --enabled` and set `DOCK_EXT` manually in the hook.
