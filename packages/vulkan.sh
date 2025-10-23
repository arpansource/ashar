#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Checking for multilib repository..."

# Function to safely enable multilib
enable_multilib() {
  local conf="/etc/pacman.conf"
  if ! grep -q "^\[multilib\]" "$conf"; then
    echo "⚙️  Enabling multilib repository..."
    sudo bash -c "cat >> $conf" <<'EOF'

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
    sudo pacman -Sy
  elif ! grep -A1 "^\[multilib\]" "$conf" | grep -q "Include"; then
    echo "⚙️  Fixing incomplete multilib section..."
    sudo sed -i '/^\[multilib\]/a Include = /etc/pacman.d/mirrorlist' "$conf"
    sudo pacman -Sy
  else
    echo "✅ Multilib already enabled."
  fi
}

enable_multilib

echo "🧩 Installing Vulkan base packages..."
sudo pacman -S --needed --noconfirm vulkan-tools vulkan-icd-loader

# Install 32-bit Vulkan loader only if multilib is now available
if pacman -Sl multilib &>/dev/null; then
  sudo pacman -S --needed --noconfirm lib32-vulkan-icd-loader || true
fi

GPU_INFO=$(lspci | grep -E "VGA|3D|Display" || true)
echo "🔍 GPU detected:"
echo "$GPU_INFO"

if echo "$GPU_INFO" | grep -qi "nvidia"; then
  echo "🟢 NVIDIA GPU detected"
  sudo pacman -S --needed --noconfirm nvidia-utils lib32-nvidia-utils opencl-nvidia
elif echo "$GPU_INFO" | grep -qi "amd"; then
  echo "🟣 AMD GPU detected"
  sudo pacman -S --needed --noconfirm vulkan-radeon lib32-vulkan-radeon mesa lib32-mesa opencl-mesa
elif echo "$GPU_INFO" | grep -qi "intel"; then
  echo "🔵 Intel GPU detected"
  sudo pacman -S --needed --noconfirm vulkan-intel lib32-vulkan-intel mesa lib32-mesa opencl-mesa
else
  echo "⚠️ Could not detect a supported GPU vendor."
fi

echo "✅ Vulkan setup complete!"
echo "Run 'vulkaninfo | less' to verify your Vulkan installation."
