#!/usr/bin/env sh

MONITOR_STATE=$(hyprctl monitors all | awk '/Monitor/ { print $2 }')

set -- $MONITOR_STATE

if [ "$#" -eq '1' ]; then
  echo "Only one monitor connected. Exiting early"
  exit
fi

STATE=$(awk -F '=' '/DISPLAY_STATE=/ {print $2}' ~/.config/hypr/state.conf)
FILEPATH="$HOME/.config/hypr/state.conf"

case "$STATE" in
Primary)
  sed -i 's/DISPLAY_STATE=Primary/DISPLAY_STATE=Secondary/' "$FILEPATH"
  hyprctl keyword monitor "$1,highres,0x0,2"
  hyprctl keyword monitor "$2,disable"
  notify-send -i video-display "Primary screen only"
  ;;
Secondary)
  sed -i 's/DISPLAY_STATE=Secondary/DISPLAY_STATE=Extend/' "$FILEPATH"
  hyprctl keyword monitor "$2,preferred,auto,auto"
  hyprctl keyword monitor "$1,disable"
  notify-send -i video-display "Secondary screen only"
  ;;
Extend)
  sed -i 's/DISPLAY_STATE=Extend/DISPLAY_STATE=Primary/' "$FILEPATH"
  hyprctl keyword monitor "$1,highres,0x0,2"
  notify-send -i video-display "Extend screens"
  ;;
esac
