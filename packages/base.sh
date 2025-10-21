#!/usr/bin/env bash
set -euo pipefail

echo "→ Installing base dependencies..."

sudo pacman -S --needed --noconfirm base-devel iwd fzf curl unzip
