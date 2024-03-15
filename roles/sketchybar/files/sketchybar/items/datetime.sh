#!/bin/bash

date=(
  icon.drawing=off
  label.font="$FONT:Semibold:12"
  label.padding_left=$(($PADDINGS / 2))
  label.padding_right=$(($PADDINGS * 2))
  y_offset=8
  width=0
  update_freq=60
  script='sketchybar --set $NAME label="$(date "+%a, %b %d")"'
)

clock=(
  ${menu_defaults[@]}
  icon.drawing=off
  label.font="$FONT:Bold:14"
  label.padding_left=$(($PADDINGS * 2))
  label.padding_right=$(($PADDINGS * 2))
  y_offset=-5
  update_freq=60
  popup.align=right
  script='sketchybar --set clock label="$(date "+%l:%M %p" | xargs)"'
)

sketchybar \
  --add item date right \
  --set date "${date[@]}" \
  --subscribe date system_woke \
                   mouse.entered \
                   mouse.exited \
                   mouse.exited.global \
  --add item date.details popup.date \
  --set date.details "${menu_item_defaults[@]}" \
  \
  --add item clock right \
  --set clock "${clock[@]}" \
  --subscribe clock system_woke \
                    mouse.entered \
                    mouse.exited \
                    mouse.exited.global \
  --add item clock.next_event popup.clock \
  --set clock.next_event "${menu_item_defaults[@]}" icon.drawing=off label.padding_left=0 label.max_chars=22 \

lines=(
  event1
  event2
  event3
)

for ((index=0; index<${#lines[@]}-1; index++)); do
  sketchybar --add item cal.$index popup.clock --set cal.$index "${menu_item_defaults[@]}" "${calendar_item[@]}" label="${lines[index]}"
done
