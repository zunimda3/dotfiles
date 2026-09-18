#!/usr/bin/env bash

set -e
set -u
set -o pipefail

STOW_TARGET="$HOME"

# Make user-local binaries available to this script.
export PATH="$HOME/.local/bin:$HOME/.fzf/bin:$PATH"

# Detect operating system.
source /etc/os-release

echo "============================="
echo "Starting dotfiles bootstrap"
echo "Detected OS: $ID"

if [ "$ID" != "ubuntu" ]; then
    echo "Unsupported OS: $ID"
    exit 1
fi

# Find the directory containing this script.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Dotfiles DIR: $DOTFILES_DIR"
echo "============================="


# ============================================================
# Bootstrap dependencies
# ============================================================

echo "============================="
echo "Checking bootstrap dependencies"

BOOTSTRAP_PACKAGES=(
    git
    curl
    ca-certificates
    software-properties-common
    zsh
    stow
)

sudo apt update
sudo apt install -y "${BOOTSTRAP_PACKAGES[@]}"

echo "============================="


# ============================================================
# ZSH
# ============================================================

# ============================================================
# ZSH
# ============================================================

echo "============================="
echo "Setting up ZSH"

ZSH_PATH="$(command -v zsh)"

if [ -z "$ZSH_PATH" ]; then
    echo "Failed to find zsh"
    exit 1
fi

CURRENT_USER="$(id -un)"
CURRENT_SHELL="$(getent passwd "$CURRENT_USER" | cut -d: -f7)"

echo "Current login shell: $CURRENT_SHELL"
echo "Zsh path: $ZSH_PATH"

if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
    echo "Changing login shell to zsh"
    chsh -s "$ZSH_PATH"
else
    echo "Login shell already uses zsh"
fi

echo "============================="


# ============================================================
# Stow packages
# ============================================================

echo "============================="
echo "Stow packages"

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

printf '  %s\n' "${PACKAGES[@]}"

echo "============================="


# ============================================================
# Stow function
# ============================================================

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
            echo
            echo "Stow failed for an unexpected reason:"
            echo "$output"
            return 1
        fi

        echo
        echo "Conflicts Detected:"
        printf '  %s\n' "$conflicts"

        read -r -p "Replace conflicting files? [y/N] " answer

        case "$answer" in
            y|Y|yes|YES)
                echo "User chose to replace"

                local backup_suffix
                backup_suffix="$(date +"%Y%m%d-%H%M%S")"

                while read -r conflict; do
                    local conflict_path
                    conflict_path="$STOW_TARGET/$conflict"

                    echo "Backing up: $conflict_path"

                    mv \
                        "$conflict_path" \
                        "$conflict_path.backup-$backup_suffix"
                done <<< "$conflicts"

                stow -d "$DOTFILES_DIR" -t "$STOW_TARGET" "$package"

                printf "%s\n" "Stowing $package: COMPLETED"
                ;;

            *)
                echo "User chose to not replace"
                return 1
                ;;
        esac
    fi
}


# ============================================================
# Dependency installation
# ============================================================

install_dependencies() {
    echo "============================="
    echo "Checking dependencies"

    # --------------------------------------------------------
    # Starship
    # --------------------------------------------------------

    if ! command -v starship >/dev/null; then
        echo "Installing starship..."

        mkdir -p "$HOME/.local/bin"

        curl -sS https://starship.rs/install.sh |
            sh -s -- -y -b "$HOME/.local/bin"
    else
        echo "Starship: already installed"
    fi


    # --------------------------------------------------------
    # fzf
    # --------------------------------------------------------

    local required_fzf_version="0.53.0"
    local current_fzf_version=""

    if command -v fzf >/dev/null; then
        current_fzf_version="$(fzf --version | awk '{print $1}')"
        echo "fzf: $current_fzf_version"
    fi

    if [ -z "$current_fzf_version" ] ||
       [ "$(printf '%s\n' "$required_fzf_version" "$current_fzf_version" | sort -V | head -n1)" != "$required_fzf_version" ]; then

        echo "Installing/updating fzf..."

        if [ ! -d "$HOME/.fzf" ]; then
            git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        elif [ -d "$HOME/.fzf/.git" ]; then
            git -C "$HOME/.fzf" pull --ff-only
        else
            echo "$HOME/.fzf exists but is not an fzf git repository"
            return 1
        fi

        "$HOME/.fzf/install" --bin

        export PATH="$HOME/.fzf/bin:$PATH"

        echo "fzf: $(fzf --version)"
    else
        echo "fzf: version requirement satisfied"
    fi


    # --------------------------------------------------------
    # Zoxide
    # --------------------------------------------------------

    if ! command -v zoxide >/dev/null; then
        echo "Installing zoxide..."

        curl -sSfL \
            https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh |
            sh
    else
        echo "zoxide: already installed"
    fi


    # --------------------------------------------------------
    # Fastfetch
    # --------------------------------------------------------

    if ! command -v fastfetch >/dev/null; then
        echo "Installing fastfetch..."

        sudo add-apt-repository \
            ppa:zhangsongcui3371/fastfetch \
            -y

        sudo apt update
        sudo apt install -y fastfetch
    else
        echo "fastfetch: already installed"
    fi


    # --------------------------------------------------------
    # Eza
    # --------------------------------------------------------

    if ! command -v eza >/dev/null; then
        echo "Installing eza..."
        sudo apt install -y eza
    else
        echo "eza: already installed"
    fi


    # --------------------------------------------------------
    # Yazi
    # --------------------------------------------------------

    if ! command -v yazi >/dev/null; then
        echo "Installing yazi..."

        sudo apt install -y file

        curl -fsSL \
            https://yazi-rs.github.io/builds/yazi-keyring.gpg |
            sudo tee /usr/share/keyrings/yazi-keyring.gpg >/dev/null

        echo \
            'deb [signed-by=/usr/share/keyrings/yazi-keyring.gpg] https://yazi-rs.github.io/builds/ stable main' |
            sudo tee /etc/apt/sources.list.d/yazi.list >/dev/null

        sudo apt update
        sudo apt install -y yazi
    else
        echo "yazi: already installed"
    fi

    echo "============================="
}


# ============================================================
# Run installation
# ============================================================

install_dependencies

for package in "${PACKAGES[@]}"; do
    stow_package "$package" || exit 1
done

echo "============================="
echo "Dotfiles bootstrap completed"
echo "============================="
