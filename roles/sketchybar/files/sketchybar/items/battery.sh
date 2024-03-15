#!/bin/bash

battery=(
  "${menu_defaults[@]}"
  background.height=26
  background.corner_radius=$HALF_PADDINGS
  background.color=$(getcolor red)
  background.drawing=off
  icon.padding_right=0
  icon.font.style=Light
  icon.highlight_color=$(getcolor surface1)
  # icon.highlight=on
  label.highlight_color=$(getcolor surface1)
  # label.highlight=on
  update_freq=60
  popup.align=right
  script="$PLUGIN_DIR/battery.sh"
  updates=when_shown
)

sketchybar \
  --add item battery right \
  --set battery "${battery[@]}" \
  --subscribe battery power_source_change \
                      mouse.entered \
                      mouse.exited \
                      mouse.exited.global \
                      mouse.clicked \
  --add item battery.details popup.battery \
  --set battery.details "${menu_item_defaults[@]}" icon.drawing=off label.padding_left=0

