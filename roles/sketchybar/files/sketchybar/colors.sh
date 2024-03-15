#!/bin/bash

# Catppuccin Machiato Color Palette
getcolor() {
  
  color_name=$1
  opacity=$2

  local o100=0xff
  local o75=0xbf
  local o50=0x80
  local o25=0x40
  local o10=0x1a
  local o0=0x00

  local rosewater=#f4dbd6
  local flamingo=#f0c6c6
  local pink=#f5bde6
  local mauve=#c6a0f6
  local red=#ed8796
  local maroon=#ee99a0
  local peach=#f5a97f
  local yellow=#eed49f
  local green=#a6da95
  local teal=#8bd5ca
  local sky=#91d7e3
  local sapphire=#7dc4e4
  local blue=#8aadf4
  local lavender=#b7bdf8
  local text=#cad3f5
  local subtext1=#b8c0e0
  local subtext0=#a5adcb
  local overlay2=#939ab7
  local overlay1=#8087a2
  local overlay0=#6e738d
  local surface2=#5b6078
  local surface1=#494d64
  local surface0=#363a4f
  local base=#24273a
  local mantle=#1e2030
  local crust=#181926

  case $opacity in
    75) local opacity=$o75 ;;
    50) local opacity=$o50 ;;
    25) local opacity=$o25 ;;
    10) local opacity=$o10 ;;
    0) local opacity=$o0 ;;
    *) local opacity=$o100 ;;
  esac

  case $color_name in
    rosewater) local color=$rosewater ;;
    flamingo) local color=$flamingo ;;
    pink) local color=$pink ;;
    mauve) local color=$mauve ;;
    red) local color=$red ;;
    maroon) local color=$maroon ;;
    peach) local color=$peach ;;
    yellow) local color=$yellow ;;
    green) local color=$green ;;
    teal) local color=$teal ;;
    sky) local color=$sky ;;
    sapphire) local color=$sapphire ;;
    blue) local color=$blue ;;
    lavender) local color=$lavender ;;
    text) local color=$text ;;
    subtext1) local color=$subtext1 ;;
    subtext0) local color=$subtext0 ;;
    overlay2) local color=$overlay2 ;;
    overlay1) local color=$overlay1 ;;
    overlay0) local color=$overlay0 ;;
    surface2) local color=$surface2 ;;
    surface1) local color=$surface1 ;;
    surface0) local color=$surface0 ;;
    base) local color=$base ;;
    mantle) local color=$mantle ;;
    crust) local color=$crust ;;
    black) local color=#000000 ;;
    white) local color=#ffffff ;;
    *)
      echo "Invalid color name: $color_name" >&2
      return 1
      ;;
  esac

  echo $opacity${color:1}
}

# Bar and Item colors
export BAR_COLOR=$(getcolor base 50)
export BAR_BORDER_COLOR=$(getcolor lavender 50)
export HIGHLIGHT=$(getcolor blue)
export HIGHLIGHT_75=$(getcolor blue 75)
export HIGHLIGHT_50=$(getcolor blue 50)
export HIGHLIGHT_25=$(getcolor blue 25)
export HIGHLIGHT_10=$(getcolor blue 10)
export ICON_COLOR=$(getcolor lavender)
export ICON_COLOR_INACTIVE=$(getcolor lavender 50)
export LABEL_COLOR=$(getcolor text)
export POPUP_BACKGROUND_COLOR=$(getcolor mantle 25)
export POPUP_BORDER_COLOR=$(getcolor lavender 0)
export SHADOW_COLOR=$(getcolor crust)
export TRANSPARENT=$(getcolor base 0)

export RAINBOW=(
  $(getcolor rosewater)
  $(getcolor lavender)
  $(getcolor sky)
  $(getcolor red)
  $(getcolor green)
  $(getcolor yellow)
  $(getcolor blue)
  $(getcolor pink)
  $(getcolor teal)
  $(getcolor subtext1)
)
