#!/usr/bin/env bash
set -euo pipefail

# Check dependencies
if ! command -v paru &>/dev/null; then
  echo "❌ paru not found. Please install paru first."
  exit 1
fi

if ! command -v fzf &>/dev/null; then
  echo "❌ fzf not found. Please install fzf first."
  exit 1
fi

# Install ly
paru -S ly --needed --noconfirm

options=("none" "doom" "colormix" "matrix")

echo "🎨 Select a background animation for ly:"
animation=$(printf "%s\n" "${options[@]}" | fzf --prompt="Choose animation: " --height=10 --border --ansi)

if [[ -z "$animation" ]]; then
  echo "No selection made. Defaulting to 'none'."
  animation="none"
fi


# Conditionally install cmatrix
if [[ "$animation" == "matrix" ]]; then
  paru -S cmatrix --needed --noconfirm
fi

# Update ly configuration
config_file="/etc/ly/config.ini"

if [[ -f "$config_file" ]]; then
  echo "🛠 Updating $config_file → animation=$animation"
  sudo sed -i "s/^animation=.*/animation=$animation/" "$config_file"
else
  echo "⚠️ $config_file not found. Creating it..."
  echo "[General]" | sudo tee "$config_file" >/dev/null
  echo "animation=$animation" | sudo tee -a "$config_file" >/dev/null
fi

# Enable ly service
sudo systemctl enable ly

echo "✅ ly setup complete!"
echo "✨ Background animation set to: $animation"
