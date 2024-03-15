#!/bin/bash

APP=$1

case "$APP" in
slack)
  ICON=$ICON_APP_SLACK
  COLOR=${RAINBOW[0]}
  APP_NAME=Slack
  ;;
discord)
  ICON=$ICON_APP_DISCORD
  COLOR=${RAINBOW[1]}
  APP_NAME=Discord
  ;;
outlook)
  ICON=$ICON_APP_OUTLOOK
  COLOR=${RAINBOW[2]}
  APP_NAME="Microsoft Outlook"
  ;;
teams)
  ICON=$ICON_APP_TEAMS
  COLOR=${RAINBOW[3]}
  APP_NAME="Microsoft Teams (work or school)"
  ;;
esac

messages=(
  icon="$ICON"
  icon.color=$ICON_COLOR_INACTIVE
  icon.highlight_color=$COLOR
  icon.padding_right=0
  label.padding_left=0
  label.color=$COLOR
  label.font.size=12
  update_freq=5
  script="$PLUGIN_DIR/messages.sh \"$APP_NAME\""
)

sketchybar \
  --add item messages.$APP right \
  --set messages.$APP "${messages[@]}"
