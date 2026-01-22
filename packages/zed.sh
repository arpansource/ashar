#!/usr/bin/env bash
set -euo pipefail

if command -v zed &>/dev/null; then
  echo "✅ Zed is already installed at $(command -v zed)"
  zed --version
  exit 0
fi

echo "🚀 Installing Zed..."
if ! curl -fsSL https://zed.dev/install.sh | sh; then
  echo "❌ Failed to install Zed. Please check your network connection."
  exit 1
fi

if ! grep -q 'export PATH=\$HOME/.local/bin:\$PATH' ~/.bashrc; then
  echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
  echo "✅ Added ~/.local/bin to PATH in .bashrc"
else
  echo "ℹ️  ~/.local/bin is already in PATH"
fi

# Make sure the current shell can find Zed
export PATH="$HOME/.local/bin:$PATH"

# Verify installation
if [[ -x "$HOME/.local/bin/zed" ]]; then
  echo "🎉 Zed installed successfully!"
  "$HOME/.local/bin/zed" --version
else
  echo "❌ Zed installation failed. Please check your PATH or rerun the script."
  exit 1
fi