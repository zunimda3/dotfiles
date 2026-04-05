# Dotfiles

Managed with GNU Stow.

## Packages

- `nvim` -> `~/.config/nvim`
- `tmux` -> `~/.tmux.conf`

## Install on a new machine

1. Install base tools:

```bash
# Arch
sudo pacman -S --needed stow neovim tmux git ripgrep fd nodejs npm python gcc make unzip curl tar

# Debian/Ubuntu
sudo apt install stow neovim tmux git ripgrep fd-find nodejs npm python3 build-essential unzip curl tar
```

2. Clone this repo to `~/dotfiles`.

3. Stow the packages:

```bash
cd ~/dotfiles
stow --target="$HOME" nvim tmux
```

Or run:

```bash
~/dotfiles/install.sh
```

## Extra setup required by this config

### Neovim

- Run `nvim` once to let `lazy.nvim` install plugins.
- Run `:MasonToolsInstall` to install formatters and linters.
- Run `:Mason` if any LSP servers are still missing.

This config expects these external capabilities:

- `ripgrep` for Telescope live grep.
- `node` and `npm` for `markdown-preview.nvim` and several Mason-managed JS language servers.
- `gcc`/`cc` and `make` for native plugin builds such as `telescope-fzf-native.nvim`, `LuaSnip` JS regexp support, and Treesitter parser compilation.
- `python3` for Python tooling used by Mason-managed `black`, `isort`, and `pylint`.
- `git`, `curl`, `tar`, and `unzip` for plugin and Mason downloads.
- `lazygit` is optional, but required if you want the `<leader>lg` mapping to work.

LSP servers configured through Mason:

- `ts_ls`
- `html`
- `cssls`
- `tailwindcss`
- `svelte`
- `lua_ls`
- `graphql`
- `emmet_ls`
- `prismals`
- `pyright`
- `eslint`

Formatters and linters configured through Mason:

- `prettier`
- `stylua`
- `isort`
- `black`
- `pylint`
- `eslint_d`

### tmux

- Install TPM on the target machine:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

- Start tmux, then press `prefix` + `I` to install tmux plugins.

Configured tmux plugins:

- `tmux-plugins/tpm`
- `fabioluciano/tmux-tokyo-night`
- `tmux-plugins/tmux-resurrect`
- `tmux-plugins/tmux-continuum`

## Notes

- `~/.tmux/resurrect` and `~/.tmux/plugins` were intentionally not stowed. They are machine state and local installs, not portable config.
