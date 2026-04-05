# Dotfiles

Managed with GNU Stow.

## Packages

- `nvim` -> `~/.config/nvim`
- `tmux` -> `~/.tmux.conf`

## Source-first install

This repo is set up for machines where you can build from source in your home directory but should not install distro packages.

This is specifically meant for environments like a school computer where you do not have `sudo` access.

The intended flow is:

```bash
git clone https://github.com/zunimda3/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap-source-tools.sh
./install.sh
```

The bootstrap script installs tools under `~/.local`, not `/usr` or `/usr/local`, and it does not require `sudo`.

## Build prerequisites

These are still needed on the machine before the source builds can work:

- `git`
- `curl`
- `tar`
- `unzip`
- `perl`
- `make`
- a C compiler such as `gcc` or `clang`
- `cmake`
- `pkg-config`
- `autoconf`
- `automake`
- `bison` or `yacc`

This is based on the current official build docs for Stow, tmux, and Neovim.

If your school machine does not already provide that toolchain, building from GitHub source alone will not be enough, because this repo does not use `sudo` and does not install system libraries globally.

## What gets built locally

`./bootstrap-source-tools.sh` clones and installs these into `~/.local`:

- GNU Stow from `https://github.com/aspiers/stow`
- tmux from `https://github.com/tmux/tmux`
- Neovim from `https://github.com/neovim/neovim`

### Important tmux note

tmux also depends on:

- `libevent`
- `ncurses`

The official tmux install docs say those libraries must exist, and if they are not available as packages they need to be built separately from source in user space.

I did not automate local `libevent` and `ncurses` builds here because that is the most machine-specific part of the setup. If tmux fails to configure on the school machine, that will be the first thing to fix.

## PATH

Add this to your shell startup if `~/.local/bin` is not already on `PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Apply the dotfiles

After `stow` is available in `PATH`:

```bash
cd ~/dotfiles
./install.sh
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

- Start tmux, then press `Alt-a` followed by `I` to install tmux plugins.

Configured tmux plugins:

- `tmux-plugins/tpm`
- `fabioluciano/tmux-tokyo-night`
- `tmux-plugins/tmux-resurrect`
- `tmux-plugins/tmux-continuum`

## Notes

- `~/.tmux/resurrect` and `~/.tmux/plugins` are intentionally not stowed. They are machine state and local installs, not portable config.
- `install.sh` only applies the symlinks. It does not build toolchains.
- Nothing in this repo requires `sudo`; all intended installs go under `~/.local`.

## Sources

- GNU Stow install notes: https://raw.githubusercontent.com/aspiers/stow/master/INSTALL.md
- tmux install wiki: https://github.com/tmux/tmux/wiki/Installing
- Neovim README / build notes: https://github.com/neovim/neovim
