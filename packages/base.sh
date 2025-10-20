#!/usr/bin/env bash
set -euo pipefail

echo "→ Installing base dependencies (git, base-devel)..."

sudo pacman -S --needed --noconfirm git base-devel iwd 