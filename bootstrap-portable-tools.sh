#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local}"
SRC_DIR="${SRC_DIR:-$HOME/.local/src}"
BIN_DIR="$PREFIX/bin"
OPT_DIR="$PREFIX/opt"
STOW_VERSION="${STOW_VERSION:-2.4.1}"
TMUX_RELEASE_API="${TMUX_RELEASE_API:-https://api.github.com/repos/tmux/tmux-builds/releases/latest}"
NVIM_RELEASE_API="${NVIM_RELEASE_API:-https://api.github.com/repos/neovim/neovim/releases/latest}"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required command: $1" >&2
    exit 1
  fi
}

os_name() {
  case "$(uname -s)" in
    Linux) printf 'linux' ;;
    Darwin) printf 'macos' ;;
    *)
      echo "unsupported OS: $(uname -s)" >&2
      exit 1
      ;;
  esac
}

arch_name() {
  case "$(uname -m)" in
    x86_64|amd64) printf 'x86_64' ;;
    arm64|aarch64) printf 'arm64' ;;
    *)
      echo "unsupported architecture: $(uname -m)" >&2
      exit 1
      ;;
  esac
}

latest_asset_url() {
  local api_url="$1"
  local pattern="$2"
  curl -fsSL "$api_url" | grep -Eo 'https://[^"]+' | grep -E "$pattern" | head -n 1
}

install_stow() {
  local dir="$SRC_DIR/stow-$STOW_VERSION"
  local tarball="$SRC_DIR/stow-$STOW_VERSION.tar.gz"
  local url="https://ftp.gnu.org/gnu/stow/stow-$STOW_VERSION.tar.gz"

  mkdir -p "$SRC_DIR" "$BIN_DIR" "$OPT_DIR"

  if [ ! -x "$BIN_DIR/stow" ]; then
    curl -fsSL "$url" -o "$tarball"
    rm -rf "$dir"
    tar -xzf "$tarball" -C "$SRC_DIR"
    (
      cd "$dir"
      ./configure --prefix="$PREFIX"
      make
      make install
    )
  fi
}

install_tmux() {
  local os arch url tmpdir target
  os="$(os_name)"
  arch="$(arch_name)"
  url="$(latest_asset_url "$TMUX_RELEASE_API" "tmux-[^/]+-${os}-${arch}\\.tar\\.gz$")"

  if [ -z "$url" ]; then
    echo "could not find a tmux prebuilt binary for ${os}-${arch}" >&2
    exit 1
  fi

  tmpdir="$(mktemp -d)"
  target="$OPT_DIR/tmux"
  curl -fsSL "$url" -o "$tmpdir/tmux.tar.gz"
  mkdir -p "$target" "$BIN_DIR"
  tar -xzf "$tmpdir/tmux.tar.gz" -C "$target"
  ln -sf "$target/tmux" "$BIN_DIR/tmux"
  rm -rf "$tmpdir"
}

install_neovim() {
  local os arch url tmpdir extracted target
  os="$(os_name)"
  arch="$(arch_name)"
  url="$(latest_asset_url "$NVIM_RELEASE_API" "nvim-${os}-${arch}\\.tar\\.gz$")"

  if [ -z "$url" ]; then
    echo "could not find a Neovim prebuilt archive for ${os}-${arch}" >&2
    exit 1
  fi

  tmpdir="$(mktemp -d)"
  target="$OPT_DIR/nvim"
  curl -fsSL "$url" -o "$tmpdir/nvim.tar.gz"
  rm -rf "$target"
  mkdir -p "$target" "$BIN_DIR"
  tar -xzf "$tmpdir/nvim.tar.gz" -C "$target"
  extracted="$(find "$target" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
  ln -sf "$extracted/bin/nvim" "$BIN_DIR/nvim"
  rm -rf "$tmpdir"
}

main() {
  need_cmd git
  need_cmd curl
  need_cmd tar
  need_cmd unzip
  need_cmd perl
  need_cmd make

  mkdir -p "$BIN_DIR" "$OPT_DIR" "$SRC_DIR"

  install_stow
  install_tmux
  install_neovim

  cat <<EOF
portable installs completed under: $PREFIX

make sure this is in your PATH before running install.sh:
  export PATH="$PREFIX/bin:\$PATH"
EOF
}

main "$@"
