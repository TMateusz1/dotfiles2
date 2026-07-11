# Terminals

Terminal GUI apps are installed by bootstrap on macOS only. The Ghostty and Kitty configs can still be linked manually on Linux desktop/Hypr machines when those terminals are installed there.

## Ghostty

Ghostty is the primary terminal.

Config:

```text
ghostty/config -> ~/.config/ghostty/config
```

Style:

- Theme: Catppuccin Mocha
- Font: FiraCode Nerd Font
- Font size: 16
- Background opacity: 0.97
- macOS titlebar is tinted to the Catppuccin Mocha background.
- OSC52 clipboard read/write is allowed for trusted remote Neovim/tmux sessions.

## Kitty

Kitty is the portable fallback/alternative terminal.

Config:

```text
kitty/ -> ~/.config/kitty
```

Files:

- `kitty/kitty.conf`
- `kitty/catppuccin-mocha.conf`

Style matches Ghostty:

- Theme: Catppuccin Mocha
- Font: FiraCode Nerd Font
- Font size: 16
- Background opacity: 0.97
- macOS titlebar is tinted to the Catppuccin Mocha background.

Kitty reads `PATH`, `EDITOR`, and `VISUAL` from the login shell so actions such as opening the config editor with `Cmd+,` see mise shims.

Modified Enter keys are mapped to CSI-u sequences so terminal apps can distinguish `Shift+Enter`, `Alt+Enter`, `Ctrl+Enter`, and `Ctrl+Shift+Enter`.

## SSH, tmux, and Clipboard

tmux is installed by mise, not by apt or Homebrew. After upgrading tmux with mise, stop the old server with `tmux kill-server` before checking `tmux -V`.

Remote copy/paste is handled through OSC52:

- Neovim over SSH uses a custom OSC52 provider for `"+y`, `"+p`, and regular `y`/`p` because `clipboard=unnamedplus` is enabled.
- Inside tmux, Neovim delegates clipboard access to tmux (`load-buffer -w`, `refresh-client -l`, `save-buffer -`) instead of waiting for a raw OSC52 response.
- tmux has `set-clipboard on`, `allow-passthrough on`, `Ms` OSC52 capability, and advertises clipboard support for `xterm-kitty` and `xterm-ghostty`.
- Ghostty and Kitty allow remote OSC52 clipboard writes and reads, so trusted remote tools can copy to and read from the local desktop clipboard.

Practical flow:

- Copy from remote Neovim/tmux to the local desktop clipboard: use Neovim `y` or tmux copy-mode `y`.
- Paste from macOS into remote shell/Neovim: `Cmd+V` is the most reliable path.
- Paste from macOS clipboard with Neovim `p`: supported through OSC52 read; if a specific remote path blocks it, use `Cmd+V`.

## Installation

On macOS, `./bootstrap.sh` installs both terminals and the font automatically:

```bash
brew install --cask ghostty kitty font-fira-code-nerd-font
```

The bootstrap takes no flags. On Ubuntu, no GUI terminals are installed; link
the configs manually if a desktop terminal is present.
