#!/bin/bash

# Loads defined colors
source "$CONFIG_DIR/colors.sh"

POPUP_OFF="sketchybar --set wifi popup.drawing=off"
POPUP_CLICK_SCRIPT="sketchybar --set wifi popup.drawing=toggle"

# IS_VPN=$(/usr/local/bin/piactl get connectionstate)
IS_VPN="Disconnected"
CURRENT_WIFI="$(sudo wdutil info)"
IP_ADDRESS="$(ipconfig getifaddr en0)"
SSID="$(echo "$CURRENT_WIFI" | grep -o "\\bSSID *: .*" | sed 's/^SSID *: //')"
CURR_TX="$(echo "$CURRENT_WIFI" | grep -o "\\bTx Rate *: .*" | sed 's/^Tx Rate *: //')"

if [[ $IS_VPN != "Disconnected" ]]; then
  ICON_COLOR=$HIGHLIGHT
  ICON=􀎡
elif [[ $SSID != "" ]]; then
  ICON_COLOR=$LABEL_COLOR
  ICON=󰖩
elif [[ $CURRENT_WIFI = "AirPort: Off" ]]; then
  # ICON_COLOR=$RED
  ICON=􀐾
else
  ICON_COLOR=$(getcolor white 25)
  ICON=􀐾
fi



render_bar_item() {
  sketchybar --set $NAME \
    icon.color=$ICON_COLOR \
    icon=$ICON \
    click_script="$POPUP_CLICK_SCRIPT"
}

render_popup() {
  if [ "$SSID" != "" ]; then
    args=(
      --set wifi click_script="$POPUP_CLICK_SCRIPT"
      --set wifi.ssid label="$SSID"
      --set wifi.strength label="$CURR_TX"
      --set wifi.ipaddress label="$IP_ADDRESS"
      click_script="printf $IP_ADDRESS | pbcopy;$POPUP_OFF"
    )
  else
    args=(
      --set wifi click_script="")
  fi

  sketchybar "${args[@]}" >/dev/null
}

update() {
  render_bar_item
  render_popup
}

popup() {
  sketchybar --set "$NAME" popup.drawing="$1"
}

case "$SENDER" in
"routine" | "forced")
  update
  ;;
"mouse.entered")
  popup on
  ;;
"mouse.exited" | "mouse.exited.global")
  popup off
  ;;
"mouse.clicked")
  popup toggle
  ;;
esac

