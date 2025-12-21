#!/bin/bash

# Load global styles, colors and icons
source "$CONFIG_DIR/globalstyles.sh"

SID=$1
DEBUG=0

fill_icons() {
  IFS=$'\n'
  local APPS=($(aerospace list-windows --workspace "$SID" | awk -F'|' '{ print $2 }' | awk '{$1=$1};1' | sort -u))
  local CURRENT_APP=$(aerospace list-windows --focused | awk -F'|' '{ print $2 }' | awk '{$1=$1};1')
  local LABEL ICON BADGE

  debug $FUNCNAME

  for APP in "${APPS[@]}"; do

    ICON=$("$CONFIG_DIR/plugins/app_icon.sh" "$APP")

    if [[ "$APP" == "Messages" ]]; then
      BADGE=$(sqlite3 ~/Library/Messages/chat.db "SELECT text FROM message WHERE is_read=0 AND is_from_me=0 AND text!='' AND date_read=0" | wc -l | awk '{$1=$1};1')
    else
      BADGE=$(lsappinfo -all info -only StatusLabel "$APP" | sed -nr 's/\"StatusLabel\"=\{ \"label\"=\"(.+)\" \}$/\1/p')
    fi

    LABEL+="$ICON"

    if ((${#APPS[@]} > 1)); then
      LABEL+=" "
    fi

  done

  unset IFS

  sketchybar --set $NAME label="$LABEL"
}

highlight_workspace() {

  debug "FOCUSED_WORKSPACE: $FOCUSED_WORKSPACE"

  if [[ "$SID" = "$FOCUSED_WORKSPACE" ]]; then
    SELECTED=true
  else
    SELECTED=false
  fi

  sketchybar --set $NAME icon.highlight=$SELECTED           \
                         label.highlight=$SELECTED          \
                         background.drawing=$SELECTED
}

set_badge() {
  if [[ "$1" =~ ^(10|[1-9])$ ]]; then
    ICONS=(󰲠 󰲢 󰲤 󰲦 󰲨 󰲪 󰲬 󰲮 󰲰 󰿬)
    echo "${ICONS[$1 - 1]}"
  else
    echo ""
  fi
}

mouse_clicked() {
  aerospace workspace $SID
}

debug() {
  if [[ "$DEBUG" -eq 1 ]]; then
    echo ---$(date +"%T")---
    echo $1
    echo sender: $SENDER
    echo sid: $SID
    echo app: $CURRENT_APP
    echo info: $INFO
    echo ---
  fi
}

case "$SENDER" in
  "forced")
    fill_icons
    FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)
    highlight_workspace
    ;;
  "routine" | "space_windows_change" | "front_app_switched")
    fill_icons
    ;;
  "aerospace_workspace_change")
    highlight_workspace
    ;;
  "mouse.clicked")
    mouse_clicked
    ;;
esac
