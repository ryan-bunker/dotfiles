#!/bin/bash

# Load global styles, colors, and icons
source "$CONFIG_DIR/globalstyles.sh"

# Defaults
spaces=(
  background.height=24
  background.corner_radius=$PADDINGS
  padding_left=0
  padding_right=0
  icon.padding_left=$PADDINGS
  icon.padding_right=2
  icon.highlight_color=$(getcolor surface1)
  label.padding_right=$PADDINGS
  label.highlight_color=$(getcolor surface1)
)

# Register custom event - this will be used by aerospace to notify of workspace changes
sketchybar --add event aerospace_workspace_change

# Get all spaces
SPACES=($(aerospace list-workspaces --all))

sketchybar --add item space.left left \
  --set space.left width=$(($PADDINGS / 2)) \
  padding_left=0 padding_right=0 \
  icon.padding_left=0 icon.padding_right=0 \
  label.padding_left=0 label.padding_right=0

for SID in "${SPACES[@]}"; do
  sketchybar --add item space.$SID left \
    --set space.$SID "${spaces[@]}" \
    background.color=${RAINBOW[SID]} \
    icon.color=${RAINBOW[SID]} \
    label.color=${RAINBOW[SID]} \
    script="$PLUGIN_DIR/app_space.sh $SID" \
    icon=$SID \
    --subscribe space.$SID mouse.clicked front_app_switched aerospace_workspace_change space_windows_change

  sketchybar --set space.$SID background.drawing=off
done

sketchybar --add item space.right left \
  --set space.right width=$(($PADDINGS / 2)) \
  padding_left=0 padding_right=0 \
  icon.padding_left=0 icon.padding_right=0 \
  label.padding_left=0 label.padding_right=0
