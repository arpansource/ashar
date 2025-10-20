#!/usr/bin/env bash

# Your repo config dir
DOTFILES_DIR="$HOME/ashar/configs"

# List of apps to symlink
APPS=("hypr" "wallpapers" "alacritty" "mako" "ironbar" "tofi")

for app in "${APPS[@]}"; do
    src="$DOTFILES_DIR/$app"
    dest="$HOME/.config/$app"

    # Remove existing config if it's a dir/symlink
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "Removing existing $dest"
        rm -rf "$dest"
    fi

    echo "Linking $src → $dest"
    ln -s "$src" "$dest"
done
