#!/usr/bin/env bash
set -euo pipefail

if ! command -v paru &>/dev/null; then
    echo "❌ paru is not installed. Please install paru first."
    exit 1
fi

if ! command -v hyprland &>/dev/null; then
    paru -S --needed --noconfirm hyprland
else
    echo "✅ Hyprland is already installed."
fi
