eval "$(starship init zsh)"
alias ff="fastfetch --config arch"
ff

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
export PATH="$HOME/.local/bin:$PATH"

export USER="$(id -un)"
export EMAIL="naamir@42kl.edu.my"

# Yazi settings
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}

#Set up fzf key bindings and fuzzy completions
eval "$(fzf --zsh)"

# Eza (better ls)
alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions --group-directories-first"
unset LS_COLORS

# Zoxide (better cd)
eval "$(zoxide init zsh)"
alias z="cd"
