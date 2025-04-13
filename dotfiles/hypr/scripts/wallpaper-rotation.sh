#!/usr/bin/env sh

WALLPAPER_DIRECTORY="$HOME/Documents/Google Drive/Afbeeldingen/Wallpapers"

hyprctl hyprpaper reload , "$(find "$WALLPAPER_DIRECTORY" -type f | shuf -n 1)"
