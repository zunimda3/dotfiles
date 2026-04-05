#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v stow >/dev/null 2>&1; then
  echo "stow is not installed" >&2
  exit 1
fi

stow --restow --dir="$ROOT" --target="$HOME" nvim tmux

echo "stowed: nvim tmux"
