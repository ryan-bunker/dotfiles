#!/bin/sh

systemctl --user stop hypr-session.target

hyprctl dispatch exit
