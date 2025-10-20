#!/bin/bash
set -euo pipefail

if ! command -v hyprland &>/dev/null; then
    paru -S --needed hyprland
else
    echo "✅ Hyprland is already installed."
fi
