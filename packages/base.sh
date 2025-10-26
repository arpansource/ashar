#!/usr/bin/env bash
set -euo pipefail


echo "🔍 Checking for multilib repository..."

# Function to safely enable multilib
enable_multilib() {
  local conf="/etc/pacman.conf"
  if ! grep -q "^\[multilib\]" "$conf"; then
    echo "⚙️  Enabling multilib repository..."
    sudo bash -c "cat >> $conf" <<'EOF'

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
    sudo pacman -Sy
  elif ! grep -A1 "^\[multilib\]" "$conf" | grep -q "Include"; then
    echo "⚙️  Fixing incomplete multilib section..."
    sudo sed -i '/^\[multilib\]/a Include = /etc/pacman.d/mirrorlist' "$conf"
    sudo pacman -Sy
  else
    echo "✅ Multilib already enabled."
  fi
}

enable_multilib



echo "→ Installing base dependencies..."

sudo pacman -S --needed --noconfirm base-devel bc iwd fzf curl unzip openssh btop fastfetch less
