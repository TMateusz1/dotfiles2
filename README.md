# dotfiles2

Terminal-first dotfiles for macOS and Ubuntu. The environment is built around
Zsh, tmux, Neovim, mise-managed tools, Nerd Font icons, and Catppuccin Mocha.

## Quick start

Clone the repository, enter it, and run:

```bash
./bootstrap.sh
```

Run the script as your normal user, not with `sudo`. It is safe to rerun:
existing targets are left alone when already linked, and conflicting files are
moved to a timestamped `.backup.YYYYMMDDHHMMSS` path.

After installation, start a login shell and verify the setup:

```bash
exec zsh -l
./check.sh
tc
```

`tc` attaches to or creates the `core` tmux session. Use `tc work` for a named
session, then open `nvim` in the project you want to work on.

## Daily workflow

| Context | Key or command | Action |
| --- | --- | --- |
| Shell | `Ctrl-F` | Search shell history with fzf |
| Shell | `tc [name]` | Attach, create, or switch tmux session |
| tmux | `Ctrl-Space` | Prefix key |
| tmux | `Ctrl-h/j/k/l` | Move across tmux panes and Neovim splits |
| tmux | `Ctrl-Space g` | Open LazyGit popup |
| Neovim | `Space` | Leader and local-leader key |
| Neovim | `Space f f` / `Space f g` | Find files / live grep |
| Neovim | `Space e` / `Space E` | Explorer at current file / collapsed root |
| Neovim | `Space q` | Smart-close the current buffer or tool window |
| Neovim | `Space p p` / `Space p 1`-`5` | Add a Harpoon location / jump to it |
| Neovim | `Space f r` | Project-wide find and replace |
| Neovim | `Space g g` | Open LazyGit in a floating terminal |

The complete Neovim keymap reference is in [docs/nvim.md](docs/nvim.md).
Shell, tmux, terminal, and clipboard behavior is in
[docs/terminals.md](docs/terminals.md).

## What bootstrap installs

- macOS: Homebrew when missing, Git, Ghostty, Kitty, FiraCode Nerd Font, and
  JetBrainsMono Nerd Font.
- Ubuntu: the base build and shell packages required by this repository, then
  Zsh as the login shell. GUI terminals are not installed.
- Both: mise, Oh My Zsh, the configured Zsh plugins, symlinked configuration,
  and all tools pinned by mise.

The script currently supports macOS and Ubuntu only. Network access and the
platform package manager are required for the first installation.

## Repository layout

```text
.
├── bootstrap.sh          # install packages, link config, install mise tools
├── check.sh              # static checks and headless Neovim health checks
├── .zshrc                # shell integrations, aliases, and tc helper
├── .tmux.conf            # tmux workflow and Catppuccin statusline
├── atuin/                # shell history
├── git/                  # delta Git include
├── ghostty/              # primary macOS terminal
├── k9s/                  # Kubernetes TUI and skin
├── kitty/                # alternative terminal
├── lazygit/              # Git TUI
├── mise/                 # pinned runtimes and command-line tools
├── nvim/                 # Neovim configuration, plugins, and snippets
├── starship.toml         # shell prompt
└── docs/                 # focused operating guides
```

## Linked configuration

Common links:

```text
repo/.tmux.conf          -> ~/.tmux.conf
repo/.zshrc              -> ~/.zshrc
repo/atuin/config.toml   -> ~/.config/atuin/config.toml
repo/git/delta.gitconfig -> ~/.config/git/delta.gitconfig
repo/k9s/config.yaml     -> ~/.config/k9s/config.yaml
repo/k9s/skins/catppuccin-mocha.yaml -> ~/.config/k9s/skins/catppuccin-mocha.yaml
repo/lazygit/config.yml  -> ~/.config/lazygit/config.yml
repo/mise/config.toml    -> ~/.config/mise/config.toml
repo/nvim                -> ~/.config/nvim
repo/starship.toml       -> ~/.config/starship.toml
```

The delta file is added to the global Git configuration with `include.path`;
bootstrap does not replace `~/.gitconfig`.

macOS also links:

```text
repo/ghostty/config      -> ~/.config/ghostty/config
repo/kitty               -> ~/.config/kitty
repo/k9s/config.yaml     -> ~/Library/Application Support/k9s/config.yaml
repo/k9s/skins/catppuccin-mocha.yaml -> ~/Library/Application Support/k9s/skins/catppuccin-mocha.yaml
repo/lazygit/config.yml  -> ~/Library/Application Support/lazygit/config.yml
```

## Tool ownership

[mise/config.toml](mise/config.toml) is the single source of pinned runtime and
CLI versions. It owns Neovim itself, LSP servers, formatters, linters, tmux,
Kubernetes tools, fzf/ripgrep/fd, Git TUIs, and other shell utilities. Neovim
only starts binaries found on `PATH`; it does not install them.

After changing a version:

```bash
mise install
mise prune
./check.sh
```

See [docs/mise.md](docs/mise.md) for tool categories and troubleshooting.

## Documentation

- [Neovim guide and complete configured keymaps](docs/nvim.md)
- [mise tools and maintenance](docs/mise.md)
- [Zsh, tmux, terminals, and clipboard](docs/terminals.md)

When behavior changes, update the relevant focused guide and keep this README
as the short entry point.
