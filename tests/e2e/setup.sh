#!/usr/bin/env bash
# Bootstrap the E2E test framework.
# Clones denops.vim (needed for its testutil: cli.ts relay + Neovim host) into vendor/.
set -euo pipefail
cd "$(dirname "$0")"

if [ ! -d vendor/denops.vim/.git ]; then
  echo "Cloning denops.vim into vendor/ ..."
  git clone --depth 1 https://github.com/vim-denops/denops.vim vendor/denops.vim
else
  echo "vendor/denops.vim already present (skip)."
fi

# deno >= 2.x is required (uses Deno.Command, jsr imports, import maps).
if ! command -v deno >/dev/null 2>&1 && [ ! -x "$HOME/.deno/bin/deno" ]; then
  echo "ERROR: deno not found. Install from https://deno.land/ and retry." >&2
  exit 1
fi
echo "Setup complete. Run: deno test -A --config deno.jsonc scenarios/"
