#!/usr/bin/env bash
set -euo pipefail

# Check if fnm is already installed
if command -v fnm >/dev/null 2>&1; then
  echo "✅ fnm is already installed: $(fnm --version)"
  exit 0
fi

# Install fnm
echo "→ Installing fnm..."
curl -fsSL https://fnm.vercel.app/install | bash

# Load fnm immediately in this shell
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --use-on-cd)"
fi

# Optional: source bashrc if you want to refresh shell setup
if [ -f "$HOME/.bashrc" ]; then
  # shellcheck disable=SC1090
  source "$HOME/.bashrc"
fi

# Install and set up Node.js 22
echo "→ Installing Node.js 22..."
fnm install 22
fnm default 22
fnm use 22

echo ""
echo "✅ fnm and Node.js 22 setup successfully."
