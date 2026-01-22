#!/usr/bin/env bash
set -euo pipefail

if ! command -v paru &>/dev/null; then
    echo "❌ paru is not installed. Please install paru first."
    exit 1
fi

echo -e "\n🌈 Setting up screen sharing on Hyprland...\n"

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


# Check if we're in a Wayland session
if [ -n "${WAYLAND_DISPLAY-}" ]; then
  echo "🎨 Wayland session detected → restarting services..."
  systemctl --user restart pipewire pipewire-pulse wireplumber xdg-desktop-portal xdg-desktop-portal-hyprland
  echo "✅ Services restarted successfully!"
else
  echo "⚠️ No Wayland session detected (running in TTY)."
  echo "➡️ Skipping portal service restart — they will auto-start when you launch Hyprland."
fi


echo -e "\n🎉 Screen sharing setup completed successfully!"
