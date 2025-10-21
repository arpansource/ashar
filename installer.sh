#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
PKG_DIR="$DOTFILES_DIR/packages"
PACKAGE_LIST_FILE="$DOTFILES_DIR/package-list.txt"

echo ""
echo "================================"
echo "=   ASHAR Dotfiles Installer   ="
echo "================================"
echo ""

# Make sure the system is up to date
sudo pacman -Syu --noconfirm

# Read packages from package-list.txt (comma-separated)
# Read and clean packages from the comma-separated list
mapfile -t PACKAGES < <(tr -d '\r\n' < "$PACKAGE_LIST_FILE" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

# Loop over packages in the order defined
for name in "${PACKAGES[@]}"; do
    script="$PKG_DIR/$name.sh"
    if [[ ! -f "$script" ]]; then
        echo "❌  Error: Installer for $name not found at $script"
        exit 1
    fi

    echo ""
    echo "→ Installing $name..."
    bash "$script"
done

echo ""
echo "=== All packages installed ==="
echo ""

# Apply symlinks
echo "→ Applying config symlinks..."
bash "$DOTFILES_DIR/link.sh"

echo "✅ Done!"
