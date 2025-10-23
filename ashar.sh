#!/usr/bin/env bash
set -euo pipefail

BASE_PACKAGES="$HOME/ashar/packages/base.sh"
SETUP_GIT="$HOME/ashar/packages/git.sh"

# upgrade the system
sudo pacman -Syu --noconfirm

# install base packages
bash "$BASE_PACKAGES"

# install and setup git
bash "$SETUP_GIT"
