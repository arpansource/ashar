#!/usr/bin/env bash
set -euo pipefail

if ! command -v paru &>/dev/null; then
    echo "❌ paru is not installed. Please install paru first."
    exit 1
fi

paru -S grim --needed --noconfirm
