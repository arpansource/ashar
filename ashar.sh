#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/arpansource/ashar/main/packages"
ASHAR_DIR="$HOME/ashar"

check_network() {
    if ! ping -c 1 -W 2 8.8.8.8 &>/dev/null && ! ping -c 1 -W 2 1.1.1.1 &>/dev/null; then
        echo "❌ Network connectivity check failed. Please ensure you have internet access."
        exit 1
    fi
}

download_and_run() {
  local script_url=$1
  local tmp_script
  tmp_script=$(mktemp)
  echo "→ Running $(basename "$script_url") ..."
  if ! curl -fsSL "$script_url" -o "$tmp_script"; then
      echo "❌ Failed to download $script_url. Please check your network connection."
      rm -f "$tmp_script"
      exit 1
  fi
  bash "$tmp_script"
  rm -f "$tmp_script"
}

check_network

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
if ! git clone https://github.com/arpansource/ashar.git "$ASHAR_DIR"; then
    echo "❌ Failed to clone repository. Please check your network connection."
    exit 1
fi

# Run installer
echo "→ Running installer..."
bash "$ASHAR_DIR/installer.sh"

echo "✅ Ashar setup complete!"
read -rp "Do you want to restart the machine now? (y/N): " REBOOT_CHOICE </dev/tty
if [[ "$REBOOT_CHOICE" =~ ^[Yy]$ ]]; then
    echo "→ Rebooting..."
    sudo reboot
else
    echo "→ Skipping reboot. Please restart manually when ready."
fi
