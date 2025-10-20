#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
PKG_DIR="$DOTFILES_DIR/packages" # all the installers for packages live in this directory

echo "Instaling paru if not already installed"
bash $PKG_DIR/paru.sh

echo ""
echo "================================"
echo "=   ASHAR Dotfiles Installer   ="
echo "================================"

for script in "$PKG_DIR"/*.sh; do
    if [ "$(basename "$script")" != "paru.sh" ]; then
        name=$(basename "$script" .sh)
        echo ""
        echo "→ Installing $name..."

        bash "$script"
    fi
done


echo ""
echo "=== All packages installed ==="
echo ""

# Now apply symlinks
echo "→ Applying config symlinks..."
bash "$DOTFILES_DIR/link.sh"

echo "✅ Done! Now you can reboot the system"
