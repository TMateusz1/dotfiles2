# mise

`mise/config.toml` owns global CLI/runtime versions. Neovim depends on these shims being available in PATH.

## Runtime Prerequisites

The bootstrap installs these first because other tools use their backends:

- `go`: Go tools and Go LSP helpers.
- `node`: NPM language servers and formatters.
- `uv`: Python CLI backend used by `pipx:yamllint`.

The `pipx:` backend is kept for Python CLIs, but with `uv` installed mise uses `uvx` under the hood, so there is no global Python entry in this repo.

`mise/config.toml` is the only source of pinned versions.

## Neovim Tools

LSP:

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

- `goimports`
- `gofumpt`
- `stylua`
- `shfmt`
- `shellcheck`
- `prettier`
- `ruff`
- `robotframework-robocop`
- `yamlfmt`
- `yamllint`
- `hadolint`

Robot Framework projects still need their own dependencies. Create or activate the repo's `.venv`, install Robot Framework plus any test libraries there, and open Neovim from that environment so `robotcode` sees the same imports as the test runner.

Go helpers:

- `gotestsum`
- `golangci-lint`

Struct-tag and interface generation use the pinned `gopls` language server.

## Commands

Install everything:

```bash
mise install
```

Find the selected binary:

```bash
mise which gopls
mise which k9s
```

Remove old installs after version changes:

```bash
mise prune
```

If a backend tool changes runtime, reinstall that backend group:

```bash
mise install -f "npm:*"
mise install -f "pipx:*"
```
