#!/usr/bin/env bash
set -euo pipefail

if command -v paru &>/dev/null; then
    echo "✅ Paru is already installed."
    exit 0
fi

echo "→ Installing paru..."

git clone https://aur.archlinux.org/paru.git /tmp/paru
(
    cd /tmp/paru
    makepkg -si --noconfirm
)
rm -rf /tmp/paru
