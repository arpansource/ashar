#!/usr/bin/env bash
set -euo pipefail

# --- Configuration Variables ---
SERVICE_NAME="ly"
CONFIG_FILE="/etc/ly/config.ini"
TTY_INSTANCE="tty2" # Common TTY for Display Managers

# --- Dependency Checks ---

if ! command -v paru &>/dev/null; then
  echo "❌ paru not found. Please install paru first."
  exit 1
fi

if ! command -v fzf &>/dev/null; then
  echo "❌ fzf not found. Please install fzf first."
  exit 1
fi

# --- 1. Installation ---

echo "📦 Installing/Updating ly..."
paru -S ly --needed --noconfirm

options=("none" "doom" "colormix" "matrix")

echo "🎨 Select a background animation for ly:"
animation=$(printf "%s\n" "${options[@]}" | fzf --prompt="Choose animation: " --height=10 --border --ansi)

if [[ -z "$animation" ]]; then
  echo "No selection made. Defaulting to 'matrix'."
  animation="matrix"
fi

# Conditionally install cmatrix
if [[ "$animation" == "matrix" ]]; then
  echo "📦 Installing cmatrix for selected animation..."
  paru -S cmatrix --needed --noconfirm
fi

# --- 2. Update ly Configuration ---

if [[ -f "$CONFIG_FILE" ]]; then
  echo "🛠 Updating $CONFIG_FILE → animation=$animation"
  sudo sed -i -E "s|^[#[:space:]]*animation[[:space:]]*=[[:space:]]*.*|animation = $animation|" "$CONFIG_FILE"
else
  echo "⚠️ $CONFIG_FILE not found. Creating it..."
  echo "[General]" | sudo tee "$CONFIG_FILE" >/dev/null
  echo "animation=$animation" | sudo tee -a "$CONFIG_FILE" >/dev/null
fi

# --- 3. Robust Service Enablement and Fixes ---

echo "🔍 Searching for the correct ly service unit name..."

# A. Check for the standard simple unit: ly.service
if [[ -f "/usr/lib/systemd/system/${SERVICE_NAME}.service" ]]; then
  UNIT_FILE="${SERVICE_NAME}.service"
  ENABLE_COMMAND="sudo systemctl enable ${UNIT_FILE}"
  echo "✅ Found standard unit: ${UNIT_FILE}"

# B. Check for the template unit: ly@.service
elif [[ -f "/usr/lib/systemd/system/${SERVICE_NAME}@.service" ]]; then
  UNIT_FILE="${SERVICE_NAME}@.service"
  INSTANCE_UNIT="${SERVICE_NAME}@${TTY_INSTANCE}.service"
  ENABLE_COMMAND="sudo systemctl disable getty@${TTY_INSTANCE}.service && sudo systemctl enable ${INSTANCE_UNIT}"
  echo "⚠️ Found template unit: ${UNIT_FILE}. Enabling instance on ${TTY_INSTANCE}."

# C. Service Unit Not Found
else
  echo "❌ Error: Could not find either ly.service or ly@.service in /usr/lib/systemd/system/."
  echo "Please check your package installation."
  exit 1
fi

# --- 4. Execute Fixes and Enable ---

echo "🔄 Disabling conflicting display managers..."
# Attempt to disable common DMs before enabling ly
sudo systemctl disable lightdm.service gdm.service sddm.service || true

echo "🚀 Executing enable command: $ENABLE_COMMAND"
# Using eval to run the command stored in the variable
eval "$ENABLE_COMMAND"

echo "⚙️ Setting system default target to graphical..."
sudo systemctl set-default graphical.target

echo "✅ ly setup complete!"
echo "✨ Background animation set to: $animation"
echo "💡 The system is now configured to start ly on reboot."
