# Dotfiles

Managed with GNU Stow.

## Packages

- `nvim` -> `~/.config/nvim`
- `tmux` -> `~/.tmux.conf`

## Recommended flow for 42

For a 42 school computer, use the portable bootstrap first:

```bash
git clone https://github.com/zunimda3/dotfiles.git ~/dotfiles
cd ~/dotfiles
./check-42-env.sh
./bootstrap-portable-tools.sh
export PATH="$HOME/.local/bin:$PATH"
./install.sh
```

This is designed for a machine where you do not have `sudo`.

## Why this flow

42 machines are programming-focused, so some low-level tools are usually already present. Based on 42-specific community docs and the normal 42 curriculum:

- Very likely present:
  - `git`
  - `curl`
  - `tar`
  - `unzip`
  - `perl`
  - `make`
  - `cc` or `clang`
  - `yacc` or `bison`
- Mixed or likely missing:
  - `cmake`
  - `pkg-config`
  - `autoconf`
  - `automake`
  - `ripgrep`
  - `node`
  - `npm`
  - `lazygit`
- Machine-specific:
  - `libevent`
  - `ncurses`

The likely-present items are consistent with 42's C-focused workflow and community notes that school machines already ship a compiler toolchain, while missing tools are often installed by students with 42Homebrew or a similar user-space setup.

## Bootstraps

### `bootstrap-portable-tools.sh`

This is the recommended path on a restricted machine.

It avoids local source builds where possible:

- installs GNU Stow from the official GNU release tarball into `~/.local`
- installs tmux from the current `tmux-builds` release into `~/.local/bin`
- installs Neovim from the current official prebuilt release archive into `~/.local`

This reduces the prerequisite set substantially. In practice it mainly needs:

- `git`
- `curl`
- `tar`
- `unzip`
- `perl`
- `make`

### `bootstrap-source-tools.sh`

This is the fallback if you explicitly want to build everything from GitHub source.

It installs under `~/.local`, not `/usr` or `/usr/local`, and does not require `sudo`. But it does require a fuller toolchain:

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

If the school machine does not already provide that toolchain, the source-build path will fail.

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
- If `node`, `npm`, or `ripgrep` are missing on the school machine, Neovim will still start, but some plugins and LSP workflows will be reduced until you install those tools.

## 42-specific fallback

If the school machine is missing too many tools even for the portable bootstrap, the most realistic fallback is a user-space Homebrew setup used by many 42 students:

- `https://github.com/omimouni/42homebrew`

That is not the default path in this repo, but it is the next thing I would recommend on a 42 machine if the built-in environment is too minimal.

## Sources

- GNU Stow install notes: https://raw.githubusercontent.com/aspiers/stow/master/INSTALL.md
- tmux static builds releases: https://github.com/tmux/tmux-builds/releases
- tmux install wiki: https://github.com/tmux/tmux/wiki/Installing
- Neovim releases: https://github.com/neovim/neovim/releases
- 42 community setup note for no-admin machines: https://sebastienwae.github.io/debugging-42/
- 21/42 community FAQ referencing local Homebrew on school Macs: https://github.com/daniiomir/faq_for_school_21
