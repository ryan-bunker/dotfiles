#!/bin/sh

# Start the dummy hyprland service so the hypr-session
# target is also started, triggering any dependent
# systemd services.
systemctl start --user hypr-session.target

# background services
udiskie --tray &
avizo-service &
ags &> ~/ags.log &
