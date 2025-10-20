#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
PKG_DIR="$DOTFILES_DIR/packages"

echo ""
echo "================================"
echo "=   ASHAR Dotfiles Installer   ="
echo "================================"
echo ""

# Make sure the system is up to date
sudo pacman -Syu

# Always install base first
bash "$PKG_DIR/base.sh"

# Then paru
bash "$PKG_DIR/paru.sh"

# Then loop over the rest of the packages
for script in "$PKG_DIR"/*.sh; do
    case "$(basename "$script")" in
        base.sh|paru.sh)
            continue ;; # skip base and paru
        *)
            name=$(basename "$script" .sh)
            echo ""
            echo "→ Installing $name..."
            bash "$script"
            ;;
    esac
done

echo ""
echo "=== All packages installed ==="
echo ""

# Now apply symlinks
echo "→ Applying config symlinks..."
bash "$DOTFILES_DIR/link.sh"

echo "✅ Done!"
