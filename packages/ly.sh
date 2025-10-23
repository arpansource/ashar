#!/usr/bin/env bash
set -euo pipefail

paru -S ly --needed --noconfirm

sudo systemctl enable ly
sudo systemctl start ly
