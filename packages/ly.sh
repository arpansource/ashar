#!/usr/bin/env bash
set -euo pipefail

paru -S ly cmatrix --needed --noconfirm

sudo systemctl enable ly
