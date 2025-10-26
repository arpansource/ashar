#!/usr/bin/env bash
set -euo pipefail

# Check if bun is already installed
if command -v bun >/dev/null 2>&1; then
  echo "✅ bun is already installed: $(bun --version)"
  exit 0
fi

curl -fsSL https://bun.sh/install | bash
