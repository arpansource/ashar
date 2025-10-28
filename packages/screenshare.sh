#!/usr/bin/env bash
set -euo pipefail

echo -e "\n🌈 Setting up screen sharing on Hyprland...\n"

# === 1. Required packages ===
PKGS=(
  xdg-desktop-portal
  xdg-desktop-portal-hyprland
  pipewire
  wireplumber
)

echo "→ Installing required packages..."
paru -S --needed --noconfirm "${PKGS[@]}"

# === 2. Remove conflicting portal backends ===
if pacman -Q xdg-desktop-portal-wlr &>/dev/null; then
  echo "→ Removing conflicting package: xdg-desktop-portal-wlr"
  sudo pacman -Rns --noconfirm xdg-desktop-portal-wlr
fi

# === 3. Configure Hyprland as the preferred portal ===
CONFIG_DIR="$HOME/ashar/configs/xdg-desktop-portal"
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_DIR/portals.conf" <<EOF
[preferred]
default=hyprland
EOF

echo "→ Configured preferred portal: $CONFIG_DIR/portals.conf"

# === 4. Restart services ===
echo "→ Restarting PipeWire and portal services..."
systemctl --user daemon-reload
systemctl --user restart pipewire pipewire-pulse wireplumber
systemctl --user restart xdg-desktop-portal xdg-desktop-portal-hyprland

# === 5. Verify status ===
sleep 1
if systemctl --user is-active --quiet xdg-desktop-portal-hyprland; then
  echo "✅ xdg-desktop-portal-hyprland is active."
else
  echo "❌ Failed to start xdg-desktop-portal-hyprland."
  echo "Run 'systemctl --user status xdg-desktop-portal-hyprland' for details."
  exit 1
fi

echo -e "\n🎉 Screen sharing setup completed successfully!"
