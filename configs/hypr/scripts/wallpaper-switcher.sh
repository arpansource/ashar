#!/usr/bin/env bash

# Define your wallpaper directory
WALLPAPER_DIR="$HOME/.config/wallpapers"

# 1. Check if swww-daemon is running
if ! pgrep -x "swww-daemon" > /dev/null; then
    echo "swww-daemon is not running. Starting it now..."
    swww-daemon &
    sleep 1 # Give it a moment to initialize
fi

# 2. Define a list of smooth transition types for variety
TRANSITIONS=(
    "simple" "fade" "left" "right" "top" "bottom" "wipe" "grow" "center" "outer" "random" "wave"
)
RANDOM_TRANSITION=${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}

# 3. Find a random wallpaper file in the specified directory
# It finds files with case-insensitive extensions: jpg, jpeg, png, gif
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) \
    | shuf -n 1)

# 4. Apply the new wallpaper with a random transition
if [ -n "$WALLPAPER" ]; then
    echo "Setting wallpaper: $WALLPAPER with transition: $RANDOM_TRANSITION"
    swww img "$WALLPAPER" \
        --transition-fps 60 \
        --transition-type "$RANDOM_TRANSITION" \
        --transition-duration 0.7 \
        --transition-pos "center" # Optional: set a transition origin
else
    echo "Error: No wallpaper found in $WALLPAPER_DIR"
fi
