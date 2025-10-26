#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/arpansource/ashar/main/packages"
ASHAR_DIR="$HOME/ashar"

download_and_run() {
  local script_url=$1
  local tmp_script
  tmp_script=$(mktemp)
  echo "→ Running $(basename "$script_url") ..."
  curl -fsSL "$script_url" -o "$tmp_script"
  bash "$tmp_script"
  rm -f "$tmp_script"
}

# Upgrade system
echo "→ Upgrading system..."
sudo pacman -Syu --noconfirm

# Install base packages
download_and_run "$REPO_URL/base.sh"

# Install and setup git
download_and_run "$REPO_URL/git.sh"

# Clean up old clone
echo "→ Cleaning up old repo..."
rm -rf "$ASHAR_DIR"

# Clone fresh repo
echo "→ Cloning latest ashar repo..."
git clone https://github.com/arpansource/ashar.git "$ASHAR_DIR"

# Run installer
echo "→ Running installer..."
bash "$ASHAR_DIR/installer.sh"

# reboot
echo "✅ Ashar setup complete! Let's restart the machine."
sudo reboot
