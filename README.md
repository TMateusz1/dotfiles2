# dotfiles2

Terminal-first dotfiles for macOS and Ubuntu. The setup is built around Zsh, tmux, Neovim, mise-managed CLI tools, and Catppuccin Mocha across the terminal stack.

## Layout

```text
.
├── bootstrap.sh
├── check.sh
├── .zshrc
├── .tmux.conf
├── atuin/config.toml
├── git/delta.gitconfig
├── ghostty/config
├── k9s/
├── kitty/
├── lazygit/config.yml
├── mise/config.toml
├── nvim/
├── starship.toml
└── docs/
```

## Bootstrap

Run from the repo root:

```bash
./bootstrap.sh
```

Run it as yourself (not with `sudo`). Conflicting config files are backed up with a `.backup.YYYYMMDDHHMMSS` suffix before symlinks are created.

The bootstrap supports:

- macOS: installs Homebrew when missing, then `git`, Ghostty, Kitty, and FiraCode Nerd Font.
- Ubuntu: installs base apt packages and sets Zsh as the login shell. No GUI terminals are installed.
- Both: installs mise, Oh My Zsh, Zsh plugins, symlinks configs, and runs `mise install`.

Linked config paths:

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

Bootstrap also adds `~/.config/git/delta.gitconfig` to the global Git config
through `include.path`; it does not replace an existing `~/.gitconfig`.

macOS also links:

```text
repo/ghostty/config      -> ~/.config/ghostty/config
repo/kitty               -> ~/.config/kitty
repo/k9s/config.yaml     -> ~/Library/Application Support/k9s/config.yaml
repo/k9s/skins/catppuccin-mocha.yaml -> ~/Library/Application Support/k9s/skins/catppuccin-mocha.yaml
repo/lazygit/config.yml  -> ~/Library/Application Support/lazygit/config.yml
```

## Tooling

Global tools are pinned in [mise/config.toml](mise/config.toml). This includes runtimes, CLIs, Neovim LSP servers, formatters, linters, Go helpers, `tmux`, `kubectl`, `helm`, `k9s`, `jq`, `yq`, `lazygit`, `atuin`, `delta`, and `codex`.

After editing versions:

```bash
mise install
mise prune
```

Details: [docs/mise.md](docs/mise.md)

## Neovim

Neovim is configured under [nvim/](nvim). Lazy plugin specs live in `nvim/lua/plugins/`; core behavior and custom helpers live in `nvim/lua/config/`.

LSP binaries are installed by mise. Neovim configures and starts them from PATH; it does not install tools itself.

Details: [docs/nvim.md](docs/nvim.md)

## Terminals

Ghostty remains the primary macOS terminal. Kitty is configured as the macOS fallback/alternative. Ubuntu is treated as a remote/server environment and does not install terminal GUI apps.

Details: [docs/terminals.md](docs/terminals.md)

## Health Checks

```bash
./check.sh
```
