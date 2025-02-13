#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

render_item() {

  PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
  CHARGING=$(pmset -g batt | grep 'AC Power')
  CHARGING_LABEL="Not charging"
  ICOLOR=$LABEL_COLOR
  LCOLOR=$LABEL_COLOR
  DRAWING="off"
  BG_DRAWING="off"

  if ! [[ "$PERCENTAGE" =~ ^[0-9]+$ ]]; then
    exit 0
  fi

  case ${PERCENTAGE} in
  9[0-9] | 100)
    ICON="􀛨"
    ;;
  [6-8][0-9])
    ICON="􀺸"
    ;;
  [3-5][0-9])
    ICON="􀺶"
    ;;
  [1-2][1-9]|20)
    ICON="􀛩"
    ICOLOR=$(getcolor yellow)
    LCOLOR=$ICOLOR
    DRAWING="on"
    ;;
  *)
    ICON="􀛪"
    ICOLOR=$(getcolor red)
    LCOLOR=$ICOLOR
    DRAWING="on"
    ;;
  esac

  if (( PERCENTAGE < 6 )); then
    BG_DRAWING=on
  fi

  if [[ $CHARGING != "" ]]; then
    ICON="􀢋"
    CHARGING_LABEL="Charging"
    ICOLOR=$ICON_COLOR
    LCOLOR=$LABEL_COLOR
    if (( PERCENTAGE > 94 )); then
      ICOLOR=$(getcolor green)
    fi
    DRAWING=off
  else
    ICON+=" "
  fi

  sketchybar --set $NAME \
    background.drawing=$BG_DRAWING \
    icon=$ICON \
    icon.color=$ICOLOR \
    icon.highlight=$BG_DRAWING \
    label=$PERCENTAGE% \
    label.color=$LCOLOR \
    label.highlight=$BG_DRAWING \
    label.drawing=$DRAWING
}

render_popup() {
  sketchybar --set $NAME.details label="$PERCENTAGE% (${CHARGING_LABEL})"
}

update() {
  render_item
  render_popup
}

label_toggle() {

  DRAWING_STATE=$(sketchybar --query $NAME | jq -r '.label.drawing')

  if [[ $DRAWING_STATE == "on" ]]; then
    DRAWING="off"
  else
    DRAWING="on"
  fi

  sketchybar --set $NAME label.drawing=$DRAWING
}

popup() {
  sketchybar --set "$NAME" popup.drawing="$1"
}

echo "battery -- sender: $SENDER"
case "$SENDER" in
  "mouse.clicked")
    label_toggle
    ;;
  "routine" | "forced" | "power_source_change")
    update
    ;;
  "mouse.entered")
    popup on
    ;;
  "mouse.exited" | "mouse.exited.global")
    popup off
    ;;
esac
