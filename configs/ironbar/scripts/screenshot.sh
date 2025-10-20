#!/bin/bash
OUTPUT_DIR="$HOME/Pictures/screenshots"
OUTPUT_FILE="$OUTPUT_DIR/satty-$(date '+%Y%m%d-%H%M%S').png"

mkdir -p "$OUTPUT_DIR" # creates if doesn't exist
grim -g "$(slurp -w 0 -c '#ff0000ff')" -t png - | satty \
    --filename - \
    --fullscreen \
    --output-filename "$OUTPUT_FILE" \
    --copy-command "wl-copy"
