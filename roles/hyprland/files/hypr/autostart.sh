#!/bin/sh

# Start the dummy hyprland service so the hypr-session
# target is also started, triggering any dependent
# systemd services.
systemctl start --user hyprland.service

discord &
avizo-service &
eww open eww-statusbar
