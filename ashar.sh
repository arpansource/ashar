#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/arpansource/ashar/main/packages"
BASE_PACKAGES="$REPO_URL/base.sh"
SETUP_GIT="$REPO_URL/git.sh"

LOCAL_ASHAR_DIR="$HOME/ashar"

# upgrade the system
sudo pacman -Syu --noconfirm

# install base packages
bash "$BASE_PACKAGES"

# install and setup git
bash "$SETUP_GIT"

rm -rf "$ASHAR_DIR"
git clone https://github.com/arpansource/ashar.git "$ASHAR_DIR"

cd ashar

bash "$LOCAL_ASHAR_DIR/installer.sh"
