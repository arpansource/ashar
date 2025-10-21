#!/usr/bin/env bash
set -euo pipefail

curl -fsSL https://fnm.vercel.app/install | bash

# source the bashrc after exporting the fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi

source $HOME/.bashrc

fnm install 22
fnm default 22
fnm use 22
corepack enable pnpm
echo "✅ fnm and Node.js 22 with pnpm setup successfully."
