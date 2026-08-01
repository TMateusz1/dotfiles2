# mise

`mise/config.toml` is the single source of pinned runtime and global CLI
versions. The bootstrap links it to `~/.config/mise/config.toml`, installs the
bootstrap runtimes first, and then installs the complete tool set.

The Zsh configuration runs `mise activate zsh`, so selected binaries and shims
are available in every new shell. Neovim relies on that `PATH`: it configures
LSP servers, formatters, and linters but never downloads them. User binary
directories such as `~/go/bin` are added before mise is activated, so normal
mise activation gives the configured tool versions precedence without enabling
aggressive activation.

## Bootstrap runtimes

These are installed before the remaining entries because other backends need
them:

- `go` builds Go tools and language-server helpers.
- `node` supplies NPM language servers and formatters.
- `uv` is the Python CLI backend used by `pipx:` entries.

There is intentionally no global Python runtime entry. With `uv` installed,
mise runs Python CLI packages through `uvx`; application projects should still
own their Python version and virtual environment.

## Tool groups

Editor and shell foundation:

- Neovim, tmux, fzf, ripgrep, fd, bat, eza, zoxide, Atuin, Starship, and Codex.

Git and infrastructure:

- delta, GitLab CLI (`glab`), LazyGit, kubectl, Helm, k9s, jq, and yq.

Neovim LSP servers:

- `gopls`
- `lua-language-server`
- `yaml-language-server`
- `helm-ls`
- `basedpyright`
- `ruff`
- `robotcode`
- `bash-language-server`
- `dockerfile-language-server-nodejs`
- `@microsoft/compose-language-service`
- `vscode-langservers-extracted`

Formatters and linters:

- `goimports`, `gofumpt`, `golangci-lint`, and `gotestsum`
- `stylua`, `shfmt`, `shellcheck`, and `prettier`
- `ruff`, `robotframework-robocop`, `yamlfmt`, `yamllint`, and `hadolint`

The exact versions are deliberately not duplicated here; read
`mise/config.toml` for the authoritative current pins.

## Go tools and `gopls`

Go command-line tools are installed as independent `go:` entries. In
particular, mise owns `gopls` under its dedicated tool directory; the Go SDK
does not contain or own that executable. This keeps the Go and `gopls` versions
independently pinned and avoids reinstalling `gopls` for every Go version.

Do not also run `go install golang.org/x/tools/gopls@...` for the global setup,
because that creates a second unmanaged copy in `GOBIN` or `~/go/bin`. Confirm
the active single copy with:

```bash
command -v gopls
mise which gopls
gopls version
```

The first two paths should be identical. If an old `~/go/bin/gopls` exists,
remove that unmanaged binary and keep the mise-managed installation.

## Everyday commands

Install missing tools or apply changed pins:

```bash
mise install
```

See what is active and where a binary comes from:

```bash
mise current
mise which gopls
mise which k9s
```

Run a command in the configured environment without relying on shell
activation:

```bash
mise exec -- nvim
mise exec -- gopls version
```

Remove installs no longer referenced by the config after changing versions:

```bash
mise prune
```

Force reinstall a backend group when its underlying runtime changes:

```bash
mise install -f "npm:*"
mise install -f "pipx:*"
```

Inspect mise itself when activation or tool resolution looks wrong:

```bash
mise doctor
mise env
```

## Adding or upgrading a tool

1. Edit the entry in `mise/config.toml`.
2. Run `mise install`.
3. Confirm it with `mise which <tool>` and the tool's version command.
4. Run `./check.sh` from the repository root.
5. Run `mise prune` once the replacement is known to work.

For a new Neovim integration, add the executable to mise first, then configure
Neovim to use the executable from `PATH`. Do not introduce a second installer
such as Mason for the same binary.

## Project-specific Python tools

Robot Framework projects still need their own dependencies. Create or activate
the repository's `.venv`, install Robot Framework and its test libraries there,
and start Neovim from that environment so RobotCode sees the same imports as
the test runner.

The same rule applies to application dependencies in other languages: mise
owns global developer commands; each project owns its dependency graph.

## Troubleshooting

- If a command is missing in an old shell, start a new login shell with
  `exec zsh -l` or run `mise activate zsh` through the configured `.zshrc`.
- If Neovim reports missing LSP tools, compare `:echo $PATH` with
  `mise which <binary>` and start Neovim from an activated shell.
- If `command -v <binary>` differs from `mise which <binary>`, remove any stale
  unmanaged duplicate, ensure custom `PATH` additions occur before
  `mise activate zsh`, and start a new login shell.
- If an NPM or pipx command points at a stale runtime, force reinstall that
  backend group using the commands above.
- If tmux was upgraded while a server was already running, use
  `tmux kill-server` and start it again before checking `tmux -V`.
