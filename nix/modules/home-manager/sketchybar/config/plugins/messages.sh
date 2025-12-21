#!/bin/bash

APP=$1

render() {
  BADGE=$(lsappinfo -all info -only StatusLabel "$APP" | sed -nr 's/\"StatusLabel\"=\{ \"label\"=\"(.+)\" \}$/\1/p')

  if [[ -z "$BADGE" ]]; then
    HIGHLIGHT=off
  else
    HIGHLIGHT=on
  fi

  sketchybar --set $NAME icon.highlight=$HIGHLIGHT label=$BADGE
}

echo "messages -- $SENDER for $APP"
case "$SENDER" in
  "routine" | "forced")
    render
  ;;
esac
