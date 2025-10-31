#!/usr/bin/env bash
set -euo pipefail

# === 1. Ask for installation ===
read -rp "Do you want to setup docker on this machine? (y/N): " INSTALL_DOCKER </dev/tty
if [[ ! "$INSTALL_DOCKER" =~ ^[Yy]$ ]]; then
    echo "Aborting docker setup..."
    exit 0
fi

# === 2. install docker ===
paru -S docker docker-compose --needed --noconfirm


# === 3. enable docker service ===
echo "→ Enabling Docker service so that it gets started every time machine boots up..."
sudo systemctl enable docker


# === 3. enable start service ===
echo "→ Starting Docker service (in background)..."
sudo systemctl start docker &>/dev/null &

# Wait briefly to allow service to come up
sleep 2

if sudo systemctl is-active --quiet docker; then
    echo "✅ Docker service is running."
    echo "→ Adding current user to docker group"
else
    echo "❌ Docker service failed to start. Showing logs:"
    sudo journalctl -u docker --no-pager -n 20
fi
