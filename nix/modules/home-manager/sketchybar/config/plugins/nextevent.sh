#!/bin/bash

render_item() {
  sketchybar --set $NAME label="$(date "+%I:%M %p")"
}

render_popup() {
  theEvent="Please install icalBuddy - brew install ical-buddy."

  sketchybar --set clock.next_event label="$theEvent" click_script="sketchybar --set $NAME popup.drawing=off" >/dev/null

}

update() {
  render_item
}

popup() {
  render_popup
  sketchybar --set "$NAME" popup.drawing="$1"
}

case $SENDER in
  "routine" | "forced")
    update
    ;;
  "mouse.entered")
    popup on
    ;;
  "mouse.exited" | "mouse.exited.global")
    popup off
    ;;
esac
