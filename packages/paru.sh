#!/usr/bin/env bash

set -euo pipefail

echo "Checking for paru..."

if command -v paru &>/dev/null; then
    echo "✅ paru is already installed"
    paru --version
else
    echo "paru not found. Installing..."

    # Ensure base-devel and git are installed
    if ! command -v git &>/dev/null; then
        sudo pacman -S --needed --noconfirm git base-devel
    fi

    # Clone paru AUR repo
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/paru.git "$tmpdir"
    cd "$tmpdir"

    # Build and install
    makepkg -si --noconfirm

    # Cleanup
    cd -
    rm -rf "$tmpdir"

    echo "paru installed successfully ✅"
    paru --version
fi
