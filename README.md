# dotfiles2

Terminal-first dotfiles for macOS and Ubuntu. The environment is built around
Zsh, tmux, Neovim, mise-managed tools, Nerd Font icons, and Catppuccin Mocha.

## Bootstrap a machine

Clone the repository, enter it, and run:

```bash
./bootstrap.sh
```

Run the script as your normal user, not with `sudo`. It is safe to rerun:
dotfiles already applied by mise are left alone, and conflicting targets are
moved to timestamped `.backup.YYYYMMDDHHMMSS` paths before mise creates the
links.

Once mise is installed, the common maintenance workflows are available as
repository tasks:

```bash
mise run bootstrap:fresh  # run the complete bootstrap from this checkout
mise run dotfiles:sync    # apply declared links with mise
mise run dotfiles:status  # inspect link state
mise run tools:sync       # install every pinned tool
mise run check            # run repository validation
```

The first run on a machine without mise must still use `./bootstrap.sh`.

After installation, start a login shell and verify the setup:

```bash
exec zsh -l
./check.sh
tc
```

`tc` attaches to or creates the `core` tmux session. Use `tc work` for a named
session, then open `nvim` in the project you want to work on.

## Apply future repository updates

After pulling changes to this repository, review the diff and synchronize the
declared links and pinned tools:

```bash
git pull --ff-only
git diff ORIG_HEAD -- mise/ bootstrap.sh .zshrc .tmux.conf nvim/ docs/
mise run dotfiles:status
mise run dotfiles:sync
mise run tools:sync
mise run check
exec zsh -l
```

`dotfiles:sync` applies the links declared in mise. Use `bootstrap:fresh`
instead when a repository update changes platform packages, Oh My Zsh setup,
or bootstrap behavior. Do not run `mise prune` merely after pulling: prune only
after replacement versions have been reviewed, installed, and verified. See
[docs/mise.md](docs/mise.md) for the complete maintenance and upgrade workflow.

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
| Neovim | `Space f r` | Project-wide find and replace |
| Neovim | `Space g g` | Open LazyGit in a floating terminal |

The complete Neovim keymap reference is in [docs/nvim.md](docs/nvim.md).
Shell, tmux, terminal, and clipboard behavior is in
[docs/terminals.md](docs/terminals.md).

## What bootstrap installs

- macOS: Homebrew when missing, Git, Kitty, and JetBrainsMono Nerd Font.
- Ubuntu: the base build and shell packages required by this repository, then
  Zsh as the login shell. GUI terminals are not installed.
- Both: mise, Oh My Zsh, the configured Zsh plugins, symlinked configuration,
  and all tools pinned by mise.

The script currently supports macOS and Ubuntu only. Network access and the
platform package manager are required for the first installation.

## Repository layout

```text
.
├── bootstrap.sh          # install packages and mise, then bootstrap the environment
├── check.sh              # static checks and headless Neovim health checks
├── .zshrc                # shell integrations, aliases, and tc helper
├── .tmux.conf            # tmux workflow and Catppuccin statusline
├── atuin/                # shell history
├── bat/                  # pager theme, shared with delta
├── git/                  # delta Git include
├── k9s/                  # Kubernetes TUI and skin
├── kitty/                # alternative terminal
├── lazygit/              # Git TUI
├── mise/                 # pinned runtimes and command-line tools
├── mise.toml             # repository-scoped maintenance tasks
├── nvim/                 # Neovim configuration, plugins, and snippets
├── starship.toml         # shell prompt
└── docs/                 # focused operating guides
```

## Linked configuration

Common links are declared in `mise/config.toml` and applied by
`mise bootstrap dotfiles apply`:

```text
repo/.tmux.conf          -> ~/.tmux.conf
repo/.zshrc              -> ~/.zshrc
repo/atuin/config.toml   -> ~/.config/atuin/config.toml
repo/bat/config          -> ~/.config/bat/config
repo/git/delta.gitconfig -> ~/.config/git/delta.gitconfig
repo/k9s/config.yaml     -> ~/.config/k9s/config.yaml
repo/k9s/skins/catppuccin-mocha.yaml -> ~/.config/k9s/skins/catppuccin-mocha.yaml
repo/lazygit/config.yml  -> ~/.config/lazygit/config.yml
repo/mise/config.macos.toml -> ~/.config/mise/config.macos.toml
repo/mise/config.toml    -> ~/.config/mise/config.toml
repo/.miserc.toml        -> ~/.config/mise/miserc.toml
repo/nvim                -> ~/.config/nvim
repo/starship.toml       -> ~/.config/starship.toml
```

The delta file is added to the global Git configuration with `include.path`;
bootstrap does not replace `~/.gitconfig`.

`mise/config.macos.toml` adds these links on macOS:

```text
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

Version changes must pass the repository's 72-hour security gate before the
pin is edited. After reviewing the release, advisories, backend, and platform
compatibility, install and verify the replacement before pruning the old one.
The complete procedure is in [docs/mise.md](docs/mise.md).

The final local sequence is:

```bash
mise install
./check.sh
mise prune
```

See [docs/mise.md](docs/mise.md) for tool categories and troubleshooting.

## Documentation

- [Neovim guide and complete configured keymaps](docs/nvim.md)
- [mise tools and maintenance](docs/mise.md)
- [Zsh, tmux, terminals, and clipboard](docs/terminals.md)

When behavior changes, update the relevant focused guide and keep this README
as the short entry point.
