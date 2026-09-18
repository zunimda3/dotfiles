# fzf
export PATH="$HOME/.fzf/bin:$PATH"

# Starship
export PATH="$HOME/.local/bin:$PATH"
eval "$(starship init zsh)"

# Fastfetch
alias ff="clear && fastfetch --config arch"
ff

# Homebrew
if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
fi

export USER="naamir"
export EMAIL="naamir@42kl.edu.my"

# Yazi
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
    command rm -f -- "$tmp"
}

# fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# Eza
alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions --group-directories-first"
unset LS_COLORS

# Zoxide
eval "$(zoxide init --cmd cd zsh)"

# Ssh into zvault
alias zvault="ssh zvault"
