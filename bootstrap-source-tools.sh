#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local}"
SRC_DIR="${SRC_DIR:-$HOME/.local/src}"
JOBS="${JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2)}"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required command: $1" >&2
    exit 1
  fi
}

clone_or_update() {
  local repo="$1"
  local dir="$2"
  local branch="${3:-}"

  if [ -d "$dir/.git" ]; then
    git -C "$dir" fetch --depth 1 origin ${branch:+$branch}
    if [ -n "$branch" ]; then
      git -C "$dir" checkout "$branch"
      git -C "$dir" reset --hard "origin/$branch"
    fi
  else
    if [ -n "$branch" ]; then
      git clone --depth 1 --branch "$branch" "$repo" "$dir"
    else
      git clone --depth 1 "$repo" "$dir"
    fi
  fi
}

build_stow() {
  local dir="$SRC_DIR/stow"
  clone_or_update "https://github.com/aspiers/stow.git" "$dir"
  (
    cd "$dir"
    autoreconf -iv
    ./configure --prefix="$PREFIX"
    make -j"$JOBS"
    make install
  )
}

build_tmux() {
  local dir="$SRC_DIR/tmux"
  clone_or_update "https://github.com/tmux/tmux.git" "$dir"
  (
    cd "$dir"
    sh autogen.sh
    ./configure --prefix="$PREFIX"
    make -j"$JOBS"
    make install
  )
}

build_neovim() {
  local dir="$SRC_DIR/neovim"
  clone_or_update "https://github.com/neovim/neovim.git" "$dir" "stable"
  (
    cd "$dir"
    make distclean >/dev/null 2>&1 || true
    make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX="$PREFIX" -j"$JOBS"
    make install
  )
}

main() {
  need_cmd git
  need_cmd curl
  need_cmd tar
  need_cmd unzip
  need_cmd perl
  need_cmd make
  need_cmd cmake
  need_cmd pkg-config
  need_cmd autoconf
  need_cmd automake

  if ! command -v cc >/dev/null 2>&1 && ! command -v gcc >/dev/null 2>&1 && ! command -v clang >/dev/null 2>&1; then
    echo "missing required C compiler: cc, gcc, or clang" >&2
    exit 1
  fi

  if ! command -v bison >/dev/null 2>&1 && ! command -v yacc >/dev/null 2>&1; then
    echo "missing required parser generator: bison or yacc" >&2
    exit 1
  fi

  mkdir -p "$PREFIX" "$SRC_DIR"

  build_stow
  build_tmux
  build_neovim

  cat <<EOF
source installs completed under: $PREFIX

make sure this is in your PATH before running install.sh:
  export PATH="$PREFIX/bin:\$PATH"
EOF
}

main "$@"
