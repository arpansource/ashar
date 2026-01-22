#!/usr/bin/env bash
set -euo pipefail

# Your repo config dir
DOTFILES_DIR="$HOME/ashar/configs"

# List of apps to symlink
APPS=("hypr" "wallpapers" "alacritty" "mako" "ironbar" "tofi" "xdg-desktop-portal")

for app in "${APPS[@]}"; do
    src="$DOTFILES_DIR/$app"
    dest="$HOME/.config/$app"

    if [ ! -e "$src" ]; then
        echo "⚠️  Source directory $src does not exist. Skipping..."
        continue
    fi

    mkdir -p "$(dirname "$dest")"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "🗑️  Removing existing $dest"
        rm -rf "$dest"
    fi

    echo "🔗 Linking $src → $dest"
    ln -s "$src" "$dest"
done

echo "✅ All symlinks created successfully."
