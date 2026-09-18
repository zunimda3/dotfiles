#!/usr/bin/env bash

set -e
set -u
set -o pipefail

STOW_TARGET="$HOME"

echo "============================="
echo "Starting dotfiles installation..."
echo "============================="

echo "============================="
source /etc/os-release
echo "Detected OS: $ID"
echo "============================="

echo "============================="
echo "check dotfiles dir"
DOTFILES_DIR="$HOME/.dotfiles"
echo "Dotfiles DIR: $DOTFILES_DIR"
echo "============================="

if [ -d "$DOTFILES_DIR" ]; then
  echo "Dotfiles directory already exists: $DOTFILES_DIR"
  exit 1
fi

echo "============================="
echo "clone from repo"
git clone --branch asahi https://github.com/zunimda3/dotfiles.git "$DOTFILES_DIR"
ls "$DOTFILES_DIR"
echo "============================="

echo "============================="
echo "check stow package"
PACKAGES=(
    eza
    fastfetch
    ghostty
    hypr
    nvim
    starship
    tmux
    waybar
    zsh
    )
for package in "${PACKAGES[@]}"; do
    echo "Package: $package"
done
if ! command -v stow > /dev/null; then
  echo "GNU Stow is not installed"
  if [ "$ID" = "ubuntu" ]; then
    sudo apt install stow
    if command -v stow > /dev/null; then
      echo "GNU Stow installed"
    fi
  else
    echo "Unsupported OS: $ID"
    exit 1
  fi
fi
echo "============================="

stow_package() {
    local package="$1"

    printf "%s" "Stowing $package: "

    if output=$(stow -n -v -d "$DOTFILES_DIR" -t "$STOW_TARGET" "$package" 2>&1); then
      stow -d "$DOTFILES_DIR" -t "$STOW_TARGET" "$package"
      printf "%s\n" "COMPLETED"

    else
      conflicts=$(
            printf '%s\n' "$output" |
            grep "existing target" |
            sed 's/.*: //' || true
      )

      if [ -z "$conflicts" ]; then
          echo "Stow failed for an unexpected reason: "
          echo "$output"
          exit 1
      fi

      echo "Conflicts Detected"
      printf '%s\n' "$conflicts"

      read -r -p "Replace conflicting files? [y/N] " answer

      if [ "$answer" = "y" ]; then
        echo "User chose to replace"

        BACKUP_SUFFIX="$(date +"%Y%m%d-%H%M%S")"

        while read -r conflict; do
          conflict_path="$STOW_TARGET/$conflict"
          echo "Backing up: $conflict_path"
          mv "$conflict_path" "$conflict_path.backup-$BACKUP_SUFFIX"
        done <<< "$conflicts"

        stow -d "$DOTFILES_DIR" -t "$STOW_TARGET" "$package"
        printf "%s\n" "Stowing $package: COMPLETED"

      else
        echo "User chose to not replace"
        exit 1
      fi
    fi
}

install_dependencies() {
    echo "============================="
    echo "Checking dependencies"
    echo "============================="

    # Starship
    if ! command -v starship > /dev/null; then
        echo "Installing starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    # fzf
    if [ ! -d "$HOME/.fzf" ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    fi

    "$HOME/.fzf/install" --bin

    export PATH="$HOME/.fzf/bin:$PATH"

    # zoxide
    if ! command -v zoxide > /dev/null; then
        echo "Installing zoxide..."
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi

    # fastfetch
    if ! command -v fastfetch > /dev/null; then
        echo "Installing fastfetch..."
        sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
        sudo apt update
        sudo apt install fastfetch -y
    fi

    # eza
    if ! command -v eza > /dev/null; then
        echo "Installing eza..."
        sudo apt install eza -y
    fi

    # Yazi
    if ! command -v yazi > /dev/null; then
        echo "Installing yazi..."

        curl -fsSL \
            https://yazi-rs.github.io/builds/yazi-keyring.gpg |
            sudo tee /usr/share/keyrings/yazi-keyring.gpg > /dev/null

        echo 'deb [signed-by=/usr/share/keyrings/yazi-keyring.gpg] https://yazi-rs.github.io/builds/ stable main' |
            sudo tee /etc/apt/sources.list.d/yazi.list > /dev/null


        sudo apt update
        sudo apt install yazi -y
    fi

    echo "============================="
}

install_dependencies

for package in "${PACKAGES[@]}"; do
    stow_package "$package"
done
