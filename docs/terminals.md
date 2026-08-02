# Shell, tmux, and terminals

Ghostty is the primary macOS terminal and Kitty is the fallback. Zsh and tmux
provide the same working model locally, over SSH, and on Ubuntu servers.
Catppuccin Mocha and Nerd Font icons are used throughout.

## Zsh workflow

The shell loads mise, Oh My Zsh, Starship, Atuin, zoxide, fzf, and the available
configured Zsh plugins. Put machine-only commands and secrets in
`~/.zshrc.local`; the tracked `.zshrc` sources it near the end, immediately
before `zsh-syntax-highlighting`.

| Command or key | Action |
| --- | --- |
| `tc` | Attach/create the `core` tmux session |
| `tc work` | Attach/create `work`, or switch to it from inside tmux |
| `Ctrl-F` | Search command history with fzf |
| `cd <query>` | Use zoxide's ranked directory jump |
| `ls` | eza listing |
| `ll` | Detailed one-entry-per-line eza listing with Git state |
| `la` | Detailed eza listing with Git state |
| `lt` | Two-level eza tree |

Atuin remains the history database, but its Up-arrow binding is disabled so the
normal shell behavior stays available. `$EDITOR` and `$VISUAL` are both Neovim.

## tmux keys

The prefix is `Ctrl-Space` rather than tmux's default `Ctrl-b`. In the table,
`Prefix` means press `Ctrl-Space`, release it, then press the listed key.

| Key | Action |
| --- | --- |
| `Prefix r` | Reload `~/.tmux.conf` |
| `Prefix =` | Split side by side in the current directory |
| `Prefix -` | Split above/below in the current directory |
| `Prefix c` | New window in the current directory |
| `Prefix s` | Choose a session; items 1-9 have numeric shortcuts |
| `Prefix w` | Choose a window in the current session |
| `Prefix Ctrl-[` / `Prefix Ctrl-]` | Previous/next window; repeat without re-pressing prefix |
| `Prefix H/J/K/L` | Resize the active pane by five cells |
| `Prefix g` | Open an 80% LazyGit popup in the current directory |
| `Prefix [` | Enter vi-style copy mode |
| `v` / `y` in copy mode | Begin selection / copy and leave copy mode |
| `Esc` in copy mode | Cancel copy mode |
| `Ctrl-h/j/k/l` | Move between tmux panes and Neovim splits |
| `Ctrl-Arrow` | Arrow-key alternative for pane movement |

Pane navigation is Neovim- and fzf-aware: the same unprefixed movement key is
sent into those applications when they are focused and otherwise moves the
tmux pane. Windows and panes are numbered from 1, mouse support is enabled, and
the scrollback limit is 100,000 lines.

After upgrading mise's tmux while an old server is alive, restart it before
checking the version:

```bash
tmux kill-server
tmux -V
```

## Ghostty

Ghostty is installed on macOS and linked as:

```text
ghostty/config -> ~/.config/ghostty/config
```

Configured appearance and behavior:

- Catppuccin Mocha theme with a blue focused-split divider.
- JetBrainsMono Nerd Font at 16 pt and 115% cell height.
- Background opacity `0.97` with a matching macOS titlebar.
- Balanced terminal ligatures and a blinking cursor.
- OSC52 clipboard reads and writes for trusted remote sessions.

## Kitty

Kitty is installed as the portable alternative and linked as:

```text
kitty/ -> ~/.config/kitty
```

It uses the same Catppuccin theme, JetBrainsMono Nerd Font at 16 pt, 115% cell
height, `0.97` opacity, and matching titlebar. Kitty reads `PATH`, `EDITOR`, and
`VISUAL` from the login shell so actions such as `Cmd-,` see mise shims.

| Key | Action |
| --- | --- |
| `Cmd-1` through `Cmd-5` | Select Kitty tab 1-5 |
| `Shift-Enter` | Send a distinguishable CSI-u sequence |
| `Alt-Enter` | Send a distinguishable CSI-u sequence |
| `Ctrl-Enter` | Send a distinguishable CSI-u sequence |
| `Ctrl-Shift-Enter` | Send a distinguishable CSI-u sequence |

tmux is configured to pass those extended keys through to terminal
applications when its installed version supports them.

## SSH and clipboard

OSC52 connects remote Neovim and tmux sessions to the local desktop clipboard:

- Neovim uses the system clipboard by default, including ordinary `y` and `p`.
- Inside tmux, Neovim delegates clipboard transfer to tmux instead of waiting
  for a raw terminal response.
- tmux enables clipboard capability and passthrough for Ghostty and Kitty.
- Both terminal configurations permit clipboard reads and writes. Only use
  those settings with remote hosts you trust.

Practical behavior:

- In remote Neovim, `y` copies to the local desktop and `p` reads from it.
- In tmux copy mode, `y` copies the selection to the local desktop.
- `Cmd-V` is the most reliable fallback for pasting into a remote shell or
  Neovim if an intermediate SSH path blocks OSC52 reads.

## Installation scope

On macOS, bootstrap installs Ghostty, Kitty, and both FiraCode and JetBrainsMono
Nerd Fonts. The active terminal configurations use JetBrainsMono Nerd Font.

Ubuntu bootstrap intentionally installs no GUI terminal. The Ghostty or Kitty
configuration can be linked manually on a Linux desktop where that terminal and
font are already installed.
