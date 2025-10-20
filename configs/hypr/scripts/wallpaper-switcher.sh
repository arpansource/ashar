#!/usr/bin/env bash
# Define your wallpaper directory
WALLPAPER_DIR="$HOME/ashar/configs/wallpapers"

# 1. Kill any existing wbg process to prevent multiple instances
pkill wbg

# 2. Find a random wallpaper file in the specified directory
# It finds files with case-insensitive extensions: jpg, jpeg, png, gif
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) \
    | shuf -n 1)

# 3. Apply the new wallpaper with wbg
if [ -n "$WALLPAPER" ]; then
    echo "Setting wallpaper: $WALLPAPER"
    # wbg will automatically detect all outputs and set the wallpaper
    # Use -o to specify a particular output if needed, e.g., -o eDP-1
    wbg "$WALLPAPER" &
else
    echo "Error: No wallpaper found in $WALLPAPER_DIR"
fi
