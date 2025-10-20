#!/bin/bash
set -euo pipefail

if ! command -v hyprland &>/dev/null; then
    echo "Installing Hyprland..."
    paru -S --needed hyprland
else
    echo "✅ Hyprland is already installed."
fi
