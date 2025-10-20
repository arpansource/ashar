#!/usr/bin/env bash

# Define gradients as a simple array: "Name|CSS_LINEAR_GRADIENT_VALUE"
GRADIENTS=(
    "Deep Sea|linear-gradient(90deg, #4b79a1, #283e51)"
    "Deep Space|linear-gradient(to right, #000000, #434343)"
    "Lizard|linear-gradient(90deg, #304352, #d7d2cc)"
    "Netflix|linear-gradient(90deg, #8e0e00, #1f1c18)"
    "Steel Gray|linear-gradient(to right, #1f1c2c, #928dab);"
    "Synthwave|linear-gradient(135deg, #483D8B, #FF0099)"
    "Twitch|linear-gradient(90deg, #6441a5, #2a0845)"
    "Virgin America|linear-gradient(to right, #7b4397, #dc2430)"
)

# Define the location of your Ironbar CSS file
# This path is common for users using the default Ironbar setup.
IRONBAR_CSS_FILE="$HOME/.config/ironbar/style.css"
GRADIENT_BG_CSS_FILE="$HOME/.config/ironbar/gradient-bg.css"


# 1. Prepare data for fzf
# Extract only the names for the TUI display
GRADIENT_NAMES=$(for item in "${GRADIENTS[@]}"; do echo "$item" | cut -d'|' -f1; done)

# 2. Launch fzf TUI for selection
SELECTED_NAME=$(echo "$GRADIENT_NAMES" | fzf --prompt="Select Ironbar Gradient: " --height 40%)

if [[ -z "$SELECTED_NAME" ]]; then
    echo "Selection cancelled."
    exit 0
fi

SELECTED_GRADIENT_VALUE=""
for item in "${GRADIENTS[@]}"; do
    NAME=$(echo "$item" | cut -d'|' -f1)
    if [[ "$NAME" == "$SELECTED_NAME" ]]; then
        SELECTED_GRADIENT_VALUE=$(echo "$item" | cut -d'|' -f2)
        break
    fi
done

if [[ -z "$SELECTED_GRADIENT_VALUE" ]]; then
    echo "Error: Gradient value not found."
    exit 1
fi

# Check if style.css exists....
if [[ ! -f "$IRONBAR_CSS_FILE" ]]; then
    echo "Error: Ironbar CSS file not found at $IRONBAR_CSS_FILE"
    exit 1
fi

# Check if gradient-bg.css exists....
if [[ ! -f "$GRADIENT_BG_CSS_FILE" ]]; then
    echo "Error: Ironbar gradient bg CSS file not found at $IRONBAR_CSS_FILE"
    exit 1
fi

# Temporary file for editing
TEMP_CSS_FILE=$(mktemp)

# Replace all background values with the selected gradient
if sed "s/^[[:space:]]*background:.*$/    background: ${SELECTED_GRADIENT_VALUE};/" \
   "$GRADIENT_BG_CSS_FILE" > "$TEMP_CSS_FILE"; then

    mv "$TEMP_CSS_FILE" "$GRADIENT_BG_CSS_FILE"
    echo "✅ Successfully set Ironbar gradients to: $SELECTED_NAME"

    # here I want to trigger a save event on $IRONBAR_CSS_FILE
    tmp=$(mktemp)
    cp -- "$IRONBAR_CSS_FILE" "$tmp" && mv -- "$tmp" "$IRONBAR_CSS_FILE"
else
    rm -f "$TEMP_CSS_FILE"
    echo "❌ Error: Could not modify the gradient CSS file."
    exit 1
fi
