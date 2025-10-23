#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/arpansource/ashar/main/packages"
BASE_PACKAGES="$REPO_URL/base.sh"
SETUP_GIT="$REPO_URL/git.sh"

LOCAL_ASHAR_DIR="$HOME/ashar"


download_and_run() {
  local script_url=$1
  local tmp_script
  tmp_script=$(mktemp)
  curl -fsSL "$script_url" -o "$tmp_script"
  bash "$tmp_script"
  rm -f "$tmp_script"
}

# upgrade the system
sudo pacman -Syu --noconfirm

# install base packages
download_and_run "$REPO_URL/base.sh"

# install and setup git
download_and_run "$REPO_URL/git.sh"

rm -rf "$ASHAR_DIR"
git clone https://github.com/arpansource/ashar.git "$ASHAR_DIR"

cd ashar

bash "$LOCAL_ASHAR_DIR/installer.sh"
