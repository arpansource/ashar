#!/usr/bin/env bash
set -euo pipefail

is_bun_installed() {
  command -v bun >/dev/null 2>&1
}

BUN_LINES=$(cat <<'EOF'
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
EOF
)

# 1. Check if bun already available
if is_bun_installed; then
  echo "✅ bun is already installed: $(bun --version)"
  exit 0
fi

# 2. Source .bash_profile to load PATH if it exists
if [[ -f "$HOME/.bash_profile" ]]; then
  # shellcheck disable=SC1090
  source "$HOME/.bash_profile"
fi

# 3. Check again after sourcing
if is_bun_installed; then
  echo "✅ bun is available after sourcing .bash_profile: $(bun --version)"
  exit 0
fi

# 4. Move bun PATH setup from .bash_profile → .bashrc if found
if [[ -f "$HOME/.bash_profile" ]]; then
  if grep -q 'BUN_INSTALL' "$HOME/.bash_profile" || grep -q '\.bun/bin' "$HOME/.bash_profile"; then
    echo "🔁 Moving Bun PATH setup from .bash_profile → .bashrc..."
    # Remove Bun lines from .bash_profile
    sed -i '/BUN_INSTALL/d' "$HOME/.bash_profile"
    sed -i '/\.bun\/bin/d' "$HOME/.bash_profile"
    
    # Append to .bashrc if not already there
    if ! grep -q 'BUN_INSTALL' "$HOME/.bashrc" && ! grep -q '\.bun/bin' "$HOME/.bashrc"; then
      echo "$BUN_LINES" >> "$HOME/.bashrc"
    fi
  fi
fi

# 5. Check if bun still not installed — then install it
if ! is_bun_installed; then
  echo "⬇️ Installing Bun..."
  if ! curl -fsSL https://bun.sh/install | bash; then
    echo "❌ Failed to install Bun. Please check your network connection."
    exit 1
  fi
fi

# 6. Source updated .bashrc so it works immediately
if [[ -f "$HOME/.bashrc" ]]; then
  # shellcheck disable=SC1090
  source "$HOME/.bashrc"
fi

# 7. Verify installation
if is_bun_installed; then
  echo "✅ Bun installed successfully: $(bun --version)"
else
  echo "❌ Bun installation completed but command not found. Please restart your terminal."
fi