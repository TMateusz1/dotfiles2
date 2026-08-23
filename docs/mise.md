# mise

`mise/config.toml` is the single source of pinned runtime and global CLI
versions. It also declares the common dotfile symlinks; `mise/config.macos.toml`
adds the terminal and macOS application paths. The bootstrap installs mise,
applies those declarations, installs the bootstrap runtimes first, and then
installs the complete tool set.

## Bootstrap a machine

Clone the repository and run the bootstrap as the normal user:

```bash
git clone <repository-url> ~/dev/dotfiles2
cd ~/dev/dotfiles2
./bootstrap.sh
exec zsh -l
```

The first run must use `./bootstrap.sh` because mise is not installed yet. The
script installs the supported platform prerequisites, mise, Oh My Zsh and its
plugins, applies the declared dotfile links, and installs every pinned tool.
It is safe to rerun: correct links are retained and conflicting targets are
moved to timestamped backup paths.

Verify a new machine from the checkout:

```bash
mise current
mise run dotfiles:status
mise run check
tc
```

## Apply future repository updates

After pulling reviewed changes, use the repository tasks instead of manually
recreating links or installing individual tools:

```bash
git pull --ff-only
git diff ORIG_HEAD -- mise/ bootstrap.sh .zshrc .tmux.conf nvim/ docs/
mise run dotfiles:status
mise run dotfiles:sync
mise run tools:sync
mise run check
exec zsh -l
```

The tasks have distinct responsibilities:

- `dotfiles:status` reports whether every declared target is applied.
- `dotfiles:sync` applies the common and active platform-specific links.
- `tools:sync` installs the bootstrap runtimes first, then all exact pins.
- `check` validates shell, structured configuration, tmux, and Neovim.
- `bootstrap:fresh` reruns the complete platform bootstrap. Use it when an
  update changes Homebrew/apt packages, Oh My Zsh setup, or bootstrap behavior;
  routine config and version updates normally need only the narrower tasks.

Read the pulled diff before applying it. In particular, version changes should
include evidence that the security gate below was completed. Do not run
`mise prune` as part of routine synchronization: it belongs at the end of an
intentional, successfully verified version upgrade.

The repository-level `.miserc.toml` enables platform config discovery before
mise selects configuration files. It is also linked to the global mise config
directory, so both the first and future `mise bootstrap` runs include the
macOS declarations automatically without `-E macos`.

Bootstrap reads the declared targets and their state from
`mise bootstrap dotfiles status --json`. It installs the pinned `jq` first,
leaves correct links alone, backs up targets reported as different, and asks
mise to apply the declarations. The target list therefore lives only in mise
configuration rather than being duplicated in the shell script.

## Repository task reference

Project-scoped tasks live in the root `mise.toml`; they are available only from
this checkout and are not exported by the global `mise/config.toml` link.

```bash
mise run bootstrap:fresh  # complete machine bootstrap when mise already exists
mise run dotfiles:sync    # apply [dotfiles] directly with mise
mise run dotfiles:status  # inspect declared link state
mise run tools:sync       # install pinned tools in dependency-safe order
mise run check            # run the repository checks
```

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
- `uv` provides Python package and virtual-environment tooling.

There is intentionally no global Python runtime. Application projects own their
Python version, virtual environment, and application-specific commands. Mise
supplies `uv` to create and maintain them, plus the global `yamllint` used by
Neovim across YAML projects.

## Tool groups

Editor and shell foundation:

- Neovim, tmux, fzf, ripgrep, fd, bat, eza, zoxide, Atuin, Starship, and Codex.

Git and infrastructure:

- delta, GitLab CLI (`glab`), LazyGit, kubectl, Helm, k9s, Skaffold, ko, jq,
  and yq.

Neovim LSP servers:

- `gopls`
- `lua-language-server`
- `yaml-language-server`
- `helm-ls`
- `basedpyright`
- `bash-language-server`
- `dockerfile-language-server-nodejs`
- `@microsoft/compose-language-service`
- `vscode-langservers-extracted`

Formatters and linters:

- `goimports`, `gofumpt`, `golangci-lint`, and `gotestsum`
- `stylua`, `shfmt`, `shellcheck`, and `prettier`
- `yamlfmt`, `yamllint`, and `hadolint`

The exact versions are deliberately not duplicated here; read
`mise/config.toml` for the authoritative current pins.

## Go tools and `gopls`

Go command-line tools are independent mise entries. Tools with supported
release binaries (`golangci-lint`, `gotestsum`, and `gofumpt`) use mise's normal
registry entries. `gopls` and `goimports` use the `go:` backend because their
official distribution is built with `go install`. Both backends keep every
tool separately pinned instead of coupling it to the installed Go SDK.

Do not also install configured tools manually with `go install` or Homebrew,
because that creates unmanaged copies in locations such as `GOBIN`,
`~/go/bin`, or `/opt/homebrew/bin`. Confirm the active copies with:

```bash
for tool in golangci-lint gopls gotestsum gofumpt goimports; do
  command -v "$tool"
  mise which "$tool"
done
```

For each tool, the two paths should be identical. Remove only the unmanaged
duplicate and keep the mise-managed installation.

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
```

Inspect mise itself when activation or tool resolution looks wrong:

```bash
mise doctor
mise env
```

## Adding or upgrading a tool

Before changing a pin in `mise/config.toml`:

1. Select the latest stable, non-prerelease release only after it has been
   public for at least 72 hours. Verify its timestamp from the official release
   or registry rather than a search result or version number.
2. Read the official release and migration notes from the current pin through
   the candidate. Check upstream security advisories and the relevant GitHub or
   ecosystem advisory database for both versions.
3. Use `mise tool <name>` and the mise registry information to confirm that the
   backend still resolves to the official upstream project. Keep an exact pin
   and verify published checksums or signatures when available.
4. Check for relevant macOS, Ubuntu, shell, tmux, Neovim, runtime, or workflow
   regressions. Keep dependent Go, Node, and Python-backed tools compatible
   with their pinned runtimes.

A critical or actively exploited vulnerability may justify bypassing the
72-hour age requirement. Record the advisory and reason for the exception, but
still perform the source, compatibility, installation, and behavior checks.

Make changes in small logical batches, then install and validate:

```bash
mise install go node uv
mise install
mise current
mise which <tool>
<tool> --version
mise run check
```

Smoke-test every affected tool and its user-facing integration; a version
command alone is not sufficient. For example, check Neovim LSP/formatting after
changing an editor tool and start an isolated tmux server after changing tmux.
Only after all replacement versions work may the old installs be removed:

```bash
mise prune
```

Never use an unreviewed bulk `mise upgrade --bump` result, a floating version,
or `mise prune` before the replacements pass.

For a new Neovim integration, add a global executable to mise first, then
configure Neovim to use it from `PATH`. Python executables are the exception:
keep them in the application project's environment. Do not introduce a second
global installer such as Mason for the same binary.

## Project-specific Python tools

Python and Robot Framework projects provide `ruff`, `robotcode`, and `robocop`
when those integrations are needed. Create or activate the project's virtual
environment with `uv`, install the commands alongside its application and test
dependencies, and start Neovim from that environment so every tool sees the
same imports as the test runner. Mise supplies `yamllint` globally.

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
