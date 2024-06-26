#!/bin/sh

# Start the dummy hyprland service so the hypr-session
# target is also started, triggering any dependent
# systemd services.
systemctl start --user hypr-session.target

udiskie --tray &
discord &
avizo-service &
ags &
