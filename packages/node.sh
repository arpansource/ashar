#!/usr/bin/env bash
set -euo pipefail

FNM_PATH="$HOME/.local/share/fnm"
BASHRC="$HOME/.bashrc"
FNM_INIT_LINE='eval "$(fnm env --use-on-cd)"'

# === 1. Check if fnm is already installed ===
if command -v fnm >/dev/null 2>&1; then
  echo "✅ fnm is already installed: $(fnm --version)"
else
  echo "→ Installing fnm..."
  if ! curl -fsSL https://fnm.vercel.app/install | bash; then
    echo "❌ Failed to install fnm. Please check your network connection."
    exit 1
  fi
fi

# === 2. Check if fnm path setup exists in .bashrc ===
if grep -q "$FNM_INIT_LINE" "$BASHRC"; then
  echo "✅ fnm environment already configured in $BASHRC"
else
  echo "→ Adding fnm environment setup to $BASHRC"
  {
    echo ""
    echo "# fnm (Fast Node Manager) setup"
    echo "export PATH=\"\$HOME/.local/share/fnm:\$PATH\""
    echo "$FNM_INIT_LINE"
  } >> "$BASHRC"
fi

# === 3. Load fnm immediately in current shell (without needing restart) ===
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$FNM_INIT_LINE"
fi

# === 4. Install and use Node.js 22 ===
echo "→ Ensuring Node.js 22 is installed..."
if fnm list | grep -q "v22"; then
  echo "✅ Node.js 22 already installed."
else
  fnm install 22
fi

echo "→ Setting Node.js 22 as default..."
fnm default 22
fnm use 22

echo ""
echo "✅ fnm and Node.js 22 setup complete!"
