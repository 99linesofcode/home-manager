#!/usr/bin/env sh

export SWWW_TRANSITION_FPS=60
export SWWW_TRANSITION_STEP=2

INTERVAL=900 # 15m
WALLPAPER_DIRECTORY="$HOME/Pictures/Wallpapers/The Mandolorian/"

while true; do
  find "$WALLPAPER_DIRECTORY" | sort -R | head -n 1 | sed 's/ /\\ /g' | xargs swww img && sleep "$INTERVAL"
done
