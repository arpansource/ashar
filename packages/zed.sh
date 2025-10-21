#!/usr/bin/env bash
set -euo pipefail

# Check if Zed is already installed
if command -v zed &>/dev/null; then
  echo "✅ Zed is already installed at $(command -v zed)"
  zed --version
  exit 0
fi

echo "🚀 Installing Zed..."

# Download and run the official installer
curl -fsSL https://zed.dev/install.sh | sh

# Ensure ~/.local/bin is in PATH
if ! grep -q 'export PATH=\$HOME/.local/bin:\$PATH' ~/.bashrc; then
  echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
  echo "✅ Added ~/.local/bin to PATH in .bashrc"
else
  echo "ℹ️  ~/.local/bin is already in PATH"
fi

# Source the updated .bashrc for current session
# (optional — works only for bash sessions)
if [ -n "${BASH_VERSION:-}" ]; then
  source ~/.bashrc
fi

# Verify installation
if command -v zed &>/dev/null; then
  echo "🎉 Zed installed successfully!"
  zed --version
else
  echo "❌ Zed installation failed. Please check your PATH or rerun the script."
  exit 1
fi


