# dotfiles2

Personal dotfiles for a terminal-first development environment. The repo is intentionally small: it keeps the source configuration under version control and uses symlinks to expose those files at the paths expected by Neovim, Ghostty, Starship, tmux, and Yazi.

The whole stack shares one visual language — **Catppuccin Mocha** — across Neovim, Ghostty, tmux, and Starship, so the editor, terminal, status bar, and prompt all match.

## Repository Architecture

```text
.
├── README.md
├── .zshrc
├── .tmux.conf
├── ghostty/
│   └── config
├── nvim/
│   ├── init.lua
│   ├── lazy-lock.json
│   ├── lua/
│   │   ├── config/
│   │   └── plugins/
│   └── snippets/
├── starship.toml
└── yazi/
    ├── keymap.toml
    └── package.toml
```

The repo is split by tool:

- `nvim/` is the complete Neovim configuration.
- `ghostty/config` configures the Ghostty terminal.
- `starship.toml` configures the shell prompt.
- `.zshrc` configures Zsh, guarded shell integrations, aliases, and PATH entries.
- `.tmux.conf` configures tmux.
- `yazi/` configures the Yazi file manager used from tmux.

The Neovim config has two layers:

- `nvim/lua/config/` contains core editor behavior: options, keymaps, autocmds, filetype detection, Go helper functions, the Go struct-tag completion source, Kubernetes schema logic, and Lazy plugin bootstrapping.
- `nvim/lua/plugins/` contains Lazy plugin specs grouped by feature area: completion, LSP, formatting, file explorers, fuzzy finding, Git, UI, notifications, outline, diagnostics, Markdown, testing, Treesitter, and helper plugins.

`nvim/init.lua` is intentionally thin. It loads the core modules in this order:

```lua
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.filetypes")
require("config.kubernetes").setup()
require("config.lazy")
```

This means base editor behavior is configured before Lazy loads plugins.

## Tooling Overview

This setup expects these tools to be available on the machine:

- `nvim` 0.11 or newer for the editor.
- `git` for Lazy plugin bootstrap and Git integrations.
- `tmux` for terminal multiplexing.
- `fzf` for tmux selectors and Neovim fuzzy finding.
- `rg` and `fd` for fast search and file discovery.
- `lazygit` for the Neovim LazyGit integration.
- `yazi` for the tmux file manager popup.
- `codex` and `npx` for CodeCompanion's Codex integrations.
- `go` for Go tooling, tests, and helper commands.
- `rustup` / the Rust toolchain for `cargo`, `rustfmt`, and `clippy`.
- `kubectl` for generating Kubernetes CRD schemas.
- `starship` for the prompt.
- `ghostty` for terminal configuration.
- A Nerd Font, specifically `FiraCode Nerd Font` in the Ghostty config.

Neovim uses Mason to install many language tools automatically, but system binaries such as `git`, `go`, `cargo`, `rustfmt`, `clippy`, `kubectl`, `tmux`, `fzf`, `rg`, `fd`, `starship`, `lazygit`, and `yazi` should be installed outside Neovim.

## Creating Symlinks

The repo is meant to stay at `~/dev/dotfiles2`. The active config files should be symlinked into the locations used by each tool.

Create target directories first:

```bash
mkdir -p ~/.config
mkdir -p ~/.config/ghostty
```

Create the symlinks:

```bash
ln -s ~/dev/dotfiles2/nvim ~/.config/nvim
ln -s ~/dev/dotfiles2/yazi ~/.config/yazi
ln -s ~/dev/dotfiles2/ghostty/config ~/.config/ghostty/config
ln -s ~/dev/dotfiles2/starship.toml ~/.config/starship.toml
ln -s ~/dev/dotfiles2/.tmux.conf ~/.tmux.conf
ln -s ~/dev/dotfiles2/.zshrc ~/.zshrc
```

If a target file already exists, move it out of the way first:

```bash
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.config/yazi ~/.config/yazi.backup
mv ~/.config/starship.toml ~/.config/starship.toml.backup
mv ~/.config/ghostty/config ~/.config/ghostty/config.backup
mv ~/.zshrc ~/.zshrc.backup
```

To verify the links:

```bash
ls -l ~/.config/nvim
ls -l ~/.config/ghostty/config
ls -l ~/.config/starship.toml
ls -l ~/.zshrc
```

## Neovim Configuration

### Core Options

`nvim/lua/config/options.lua` sets the baseline editor behavior:

- Leader and local leader are both space.
- Absolute and relative line numbers are enabled.
- Mouse support is enabled.
- netrw is disabled because file exploration is handled by mini.files.
- Clipboard uses `unnamedplus`.
- Indentation uses spaces with a width of 4.
- Search uses ignorecase plus smartcase; `:substitute` shows a live preview with off-screen matches in a split (`inccommand=split`).
- `confirm` prompts to save instead of failing `:q` on unsaved changes.
- Visual block mode can extend past line ends (`virtualedit=block`).
- The jumplist behaves like a stack (`jumpoptions=stack`).
- The terminal/tmux window title shows the current file (`title`).
- UI defaults include true color, cursorline, signcolumn, no wrapping, global statusline, rounded window borders, and clean command/status display.
- Split defaults are `splitright` and `splitbelow`.
- Swap and backup files are disabled; persistent undo is enabled.
- Completion uses `menu`, `menuone`, and `noselect`.
- Invisible characters are shown for trailing spaces and non-breaking spaces; tabs render as blank.
- OSC52 clipboard integration is enabled automatically over SSH when available.

The config also customizes separator fill characters and highlights `WinSeparator`.

### Keymaps

Leader is `<Space>`. Most mappings are discoverable in Neovim with `<leader>` through which-key, and `<leader>fk` opens a searchable list of keymaps.

Core editing and window movement:

| Key | Action |
| --- | --- |
| `<Esc>` | Close floating windows; otherwise clear search highlighting |
| `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>` | Move to the left, lower, upper, or right Neovim window or tmux pane |
| `<C-Left>`, `<C-Down>`, `<C-Up>`, `<C-Right>` | Same Neovim window or tmux pane movement with arrow keys |
| `<A-j>`, `<A-k>` | Move the current line or visual selection down/up |
| Visual `J`, Visual `K` | Move the selected lines down/up |
| Visual `<`, `>` | Indent and keep the selection |
| Terminal `<Esc><Esc>` | Leave terminal mode (works in neotest/dap consoles too) |
| `<C-d>`, `<C-u>` | Half-page down/up and keep the cursor centered |
| `n`, `N` | Next/previous search result and keep the cursor centered |
| `]q`, `[q` | Next/previous quickfix item |
| `<leader>xx` | Close the current buffer, prompting for unsaved changes |
| `<leader>xX` | Close all listed file or scratch buffers except the current one |
| `<leader>xn` | Open a new scratch buffer |
| `<leader>xq`, `<leader>xl` | Toggle the quickfix/location list in Trouble |
| `<leader>xs` | Trouble symbols outline (peek) |
| `<leader>xr` | Trouble LSP references/definitions panel |
| `<leader>xt` | Trouble todo-comment list |
| `q`, `<Esc>` in temporary windows | Close quickfix, help, man, notify, and neotest windows |

Save, quit, and buffers:

| Key | Action |
| --- | --- |
| `<leader>w` | Save file |
| `<leader>k` | Close window, keep the buffer open |
| `<leader>q` | Smart close: close special/floating window or delete current buffer (keeps window) |
| `<leader>W` | Save and delete current buffer |
| `<leader>Q` | Quit Neovim, prompting to save unsaved buffers |
| `<leader>=` | Split window right (vsplit) — mirrors tmux `prefix =` |
| `<leader>-` | Split window below (split) — mirrors tmux `prefix -` |
| `[b`, `]b` | Previous/next buffer |
| `<leader>bx` | Delete current buffer |

Completion and snippets:

| Key | Action |
| --- | --- |
| `<C-space>` | Show LSP completion; include Go struct tags in Go buffers; also attach Kubernetes schemas in YAML buffers |
| `<Tab>` | Smart: cycle the menu if you're navigating it (an item is highlighted), else jump to the next snippet placeholder, else select the next completion item |
| `<S-Tab>` | Smart: same as `<Tab>` in reverse (previous placeholder / previous item) |
| `<Esc>` in a snippet | Stop the active snippet and leave insert/select mode |
| `<C-j>`, `<C-k>` | Select next/previous completion item |
| `<C-d>`, `<C-u>` in completion docs | Scroll documentation down/up |
| `<C-e>` | Cancel completion |
| Command-line `<C-space>` | Show command-line completion |
| Command-line `<Tab>`, `<S-Tab>` | Accept/select command-line completion |
| Command-line `<Up>`, `<Down>`, `<C-k>`, `<C-j>` | Move through command-line completion items |

Find and search with FZF-Lua:

| Key | Action |
| --- | --- |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>/` | Fuzzy search lines in the current buffer |
| `<leader>fu` | Undo history (preview and restore any undo state) |
| `<leader>fG` | Git changed files |
| `<leader>fb` | Find buffers |
| `<leader>fr` | Recent files |
| `<leader>fc` | Find Neovim config files |
| `<leader>fw`, `<leader>fW` | Grep word/WORD under cursor |
| `<leader>fh` | Help tags |
| `<leader>fk` | Keymaps |
| `<leader>fs`, `<leader>fS` | Document/workspace symbols |
| `<leader>fd`, `<leader>fD` | Document/workspace diagnostics |
| `<leader>fq` | Quickfix list |
| `<leader>fR` | Resume last picker |
| `<leader>ft` | All todo comments |
| `<leader>fT` | Todo/Fix/Fixme only |

Files and project navigation:

| Key | Action |
| --- | --- |
| `<leader>e` | Toggle the mini.files explorer (focused on the current file) |
| `<leader>F` | Toggle the code outline (Trouble symbols, focused) |

> Oil (`<leader>E`) is temporarily disabled — `oil.lua` is mocked out (`if true then return {} end`) while trialling mini.files. The full Oil config is kept for re-enabling.

Code, LSP, diagnostics, and formatting:

**Quick navigation** (bare keys — fast muscle-memory access):

| Key | Action |
| --- | --- |
| `gd`, `gD` | Go to definition/declaration (FZF picker) |
| `gr`, `gi`, `gy` | References, implementations, type definitions (FZF picker) |
| `K` | Hover documentation |

**Code navigation** (discoverable via `<leader>c`):

| Key | Action |
| --- | --- |
| `<leader>cd`, `<leader>cD` | Go to definition/declaration |
| `<leader>cy` | Go to type definition |
| `<leader>cu` | Find usages (references without declaration) |
| `<leader>fs`, `<leader>fS` | Document/workspace symbols (under the find prefix) |
| `<leader>cF` | LSP finder (definitions + references + implementations) |
| `<leader>cI`, `<leader>cO` | Incoming/outgoing calls |

**Code actions**:

| Key | Action |
| --- | --- |
| `<leader>ca` | Code action in normal or visual mode |
| `<leader>cr` | References (FZF picker) |
| `<leader>cn` | Rename symbol |
| `<leader>co` | Organize imports |
| `<leader>cf` | Fix all |
| `<leader>cl` | Format file or visual selection |
| `<leader>cc`, `<leader>cC` | Run/refresh code lens when supported |

**Diagnostics & LSP**:

| Key | Action |
| --- | --- |
| `<leader>cx`, `<leader>cq` | Line diagnostics / diagnostics quickfix |
| `]d`, `[d` | Next/previous diagnostic with float |
| `]t`, `[t` | Next/previous todo comment |
| `]f`, `[f` | Next/previous function start (Treesitter; works as a motion, e.g. `d]f`) |
| `<leader>cL`, `<leader>cR` | LSP info / restart LSP |
| `<leader>uh` | Toggle inlay hints when supported |
| `<leader>uv` | Toggle rich virtual-line diagnostics on the cursor line |

Go-specific code mappings (only active in Go buffers):

| Key | Action |
| --- | --- |
| `<leader>ci` | Implement interface: put the cursor in a struct, then pick the interface from a live picker (type `fmt.Str` → `fmt.Stringer`); `impl` stubs are inserted after the struct |
| `<leader>cgd` | Show `go doc` for the symbol under the cursor in a floating window |
| `<leader>cgm` | Run `go mod tidy` |
| `<leader>cgg` | Run `go generate ./...` |
| `<leader>cgl` | Run `golangci-lint run ./...` |
| `<leader>cgj` / `<leader>cgJ` | Add / remove `json` struct tags on the struct under the cursor (`gomodifytags`) |
| `<leader>cgy` / `<leader>cgY` | Add / remove `yaml` struct tags on the struct under the cursor (`gomodifytags`) |
| `<leader>cge` / `<leader>cgE` | Add / remove `env` struct tags for `caarlos0/env/v11` on the struct under the cursor (`gomodifytags`) |

`<leader>ci` replaces the old "go to implementations" leader mapping — use the bare `gi` for navigation to implementations. `<leader>ci` and `<leader>cg` mappings are wired only when `gopls` is attached.

Git:

| Key | Action |
| --- | --- |
| `<leader>gc`, `<leader>gC` | Git commits/all commits for current buffer |
| `<leader>gb` | Git branches |
| `<leader>gl` | Git line commits |
| `<leader>gs` | Git stash |
| `]h`, `[h` | Next/previous Git hunk (staged and unstaged, matching the sign column) |
| `<leader>ghp` | Preview hunk |
| `<leader>ghs`, `<leader>ghr` | Stage/reset hunk or visual selection |
| `<leader>ghu` | Un-stage hunk under cursor (`stage_hunk` toggles on staged hunks) |
| `<leader>ghb`, `<leader>ghB` | Blame line/full blame line |
| `<leader>ghl` | Toggle inline blame |
| `<leader>ghd`, `<leader>ghD` | Diff file against index/previous commit |
| `<leader>ght`, `<leader>ghw` | Toggle deleted lines/word diff |

Tests:

| Key | Action |
| --- | --- |
| `<leader>tf` | Test current function |
| `<leader>tF` | Test current file |
| `<leader>tp` | Test current package |
| `<leader>tP` | Test entire project |
| `<leader>tr` | Rerun last test |
| `<leader>ts` | Toggle test summary |
| `<leader>to`, `<leader>tO` | Open test output/toggle output panel |
| `<leader>tq` | Open failed-test quickfix list; navigate with `]q` / `[q` |
| `<leader>tw` | Watch current file |
| `<leader>tx` | Stop tests |

UI and toggles:

| Key | Action |
| --- | --- |
| `<leader>uc` | Toggle VSCode Dark+ code colors (fg-only overlay on catppuccin) |
| `<leader>fn` | Notification history |
| `<leader>uf` | Toggle format-on-save |
| `<leader>uh` | Toggle inlay hints |
| `<leader>um` | Toggle the compact, right-side minimap |
| `<leader>un` | Dismiss visible notifications |
| `<leader>uv` | Toggle rich virtual-line diagnostics on the cursor line |

Markdown:

| Key | Action |
| --- | --- |
| `<leader>Md` | Toggle rendered Markdown view |
| `<leader>MD` | Open rendered Markdown preview in a side window |

Surround editing from `mini.surround`:

| Key | Action |
| --- | --- |
| `sa` | Add surrounding |
| `sd` | Delete surrounding |
| `sr` | Replace surrounding |
| `sf`, `sF` | Find surrounding to the right/left |
| `sh` | Highlight surrounding |
| `sn` | Update surrounding search line count |

Text objects (`vaf` whole function, `dif` delete function body, `vac` type declaration, `vio` inside block, `cia` change argument, ...) come from `mini.ai` — see the Text Objects section under Mini Plugins for the full table.

### Autocmds

`nvim/lua/config/autocmds.lua` adds small quality-of-life behavior:

- Highlight yanked text for 150 ms.
- Restore the cursor to the last edit position when reopening a file.
- Reload files changed on disk on focus gain or after a terminal command (lazygit, `go generate`, branch switches).
- Equalize splits when the terminal or tmux pane is resized.
- Show the cursorline only in the focused window.
- Disable automatic comment continuation on new lines.
- Let temporary windows such as quickfix, help, man, notify, and neotest windows close with `q` or `<Esc>`.

### Filetype Detection

`nvim/lua/config/filetypes.lua` improves YAML-related filetypes:

- Docker Compose files are detected as `yaml.docker-compose`.
- Helm templates under chart directories are detected as `helm`.
- Helm values files under chart directories are detected as `yaml.helm-values`.
- Common Helm paths such as `deploy/helm`, `helm/`, and `helmfile*.yaml` are recognized.

This matters because LSP, snippets, formatting, highlighting, and schema behavior are filetype-driven.

### Lazy Plugin Manager

`nvim/lua/config/lazy.lua` bootstraps `lazy.nvim` into Neovim's data directory if it is missing, prepends it to runtimepath, then imports all plugin specs from `nvim/lua/plugins/`.

Lazy settings:

- Default install colorscheme is `catppuccin`.
- Plugin update checker is enabled but notifications are disabled.
- Change detection notifications are disabled.
- Lazy UI uses rounded borders.

The lockfile is `nvim/lazy-lock.json`.

## Neovim Plugins

### Sessions

`nvim/lua/plugins/session.lua` configures `rmagatti/auto-session`.

Neovim sessions are saved and restored per current working directory. Starting Neovim with a single directory argument, for example `nvim .`, restores the session for that directory if one exists. Opening a specific file, for example `nvim main.rs`, does not auto-save a directory session.

Global last-session restore, git-branch-specific sessions, cwd-change session switching, legacy `Session*` commands, and startup session picker setup are disabled; the intended workflow is one session per project directory.

### Theme

`nvim/lua/plugins/colorscheme.lua` installs and configures Catppuccin:

- Flavor: `mocha`.
- Terminal colors enabled.
- Transparent background disabled.
- Comment text is italic.
- Integrations are enabled for Treesitter, native LSP, which-key, gitsigns, Mason, completion, noice, indent-blankline, and the mini plugins.
- `<leader>uc` toggles a VSCode Dark+ palette over the **code text only** (foreground overrides on top of catppuccin); the UI chrome, statusline, and backgrounds stay catppuccin.

The same Catppuccin Mocha direction is used by Ghostty, tmux, and Starship, so the terminal, status bar, prompt, and editor share one visual language.

### Completion

`nvim/lua/plugins/blink.lua` configures `saghen/blink.cmp`:

- Loads on `InsertEnter`.
- Completion sources are LSP, path, snippets, buffer, and Go struct tags; Lua buffers add the lazydev source for Neovim/plugin API completions.
- Snippets use friendly-snippets plus local snippets from `nvim/snippets/`.
- Kubernetes snippets from friendly-snippets are filtered out so the local Kubernetes snippets take precedence. friendly-snippets' Go set stays enabled: it provides the general-purpose snippets (`tys`, `for`, `forr`, `meth`, `tdt`, ...) while the local `go.json` adds specialized ones under non-colliding prefixes.
- Documentation and completion windows use rounded borders.
- Go completions that come from unimported packages use a `go doc` fallback when `gopls` does not return full completion documentation.
- Go struct fields get tag completions for `json`, `yaml`, `bson`, `xml`, `toml`, `mapstructure`, `db`, `env`, `validate`, and common HTTP binding tags.
- Ghost text and signature help are enabled.
- Completion is shown inside snippet placeholders (`completion.trigger.show_in_snippet = true`), so e.g. the receiver-type field of a `meth` snippet gets type suggestions.
- Auto-brackets are decided only from the completion item kind (Function/Method); the semantic-token fallback is disabled so struct/type completions are not turned into a call (no more `Config()` when you mean the type `Config`).
- `<Tab>`/`<S-Tab>` are "smart": if the completion menu is open and an item is highlighted they cycle the menu; otherwise, inside a snippet they jump to the next/previous placeholder; otherwise they select the next/previous menu item. So at a snippet placeholder Tab jumps by default, but once you start navigating the menu (e.g. with `<C-j>`) Tab keeps cycling it — accept with `<CR>`.
- `<Esc>` stops the active snippet before leaving insert/select mode.
- `<C-j>` and `<C-k>` move through completion items, `<CR>` accepts.
- `<C-space>` shows LSP completions, includes Go struct-tag completions in Go buffers, and tries to attach Kubernetes schemas to suitable YAML buffers.
- Command-line completion is enabled for `:` commands.

### LSP

`nvim/lua/plugins/lsp.lua` configures the language server stack:

- `mason.nvim` provides tool installation UI.
- `mason-tool-installer.nvim` installs formatters, linters, debuggers, and Go helpers.
- `mason-lspconfig.nvim` installs and enables LSP servers.
- `nvim-lspconfig` defines diagnostics UI and buffer-local LSP keymaps.
- `schemastore.nvim` provides JSON/YAML schemas.
- `helm-ls.nvim` improves Helm template editing.
- `lazydev.nvim` feeds `lua_ls` Neovim/plugin type definitions per-`require` when editing Lua.

Installed LSP servers:

- `gopls`
- `lua_ls`
- `rust_analyzer`
- `dockerls`
- `docker_compose_language_service`
- `yamlls`
- `helm_ls`
- `jsonls` (schemastore-backed validation and completion)
- `bashls` (runs shellcheck for shell diagnostics)

Mason-managed tools:

- Go: `goimports`, `gofumpt`, `golines`, `delve`, `gotestsum`, `gomodifytags`, `impl`, `golangci-lint`
- General: `stylua`, `shfmt`, `shellcheck`, `prettier`, `yamlfmt`, `yamllint`, `hadolint`

LSP behavior:

- Diagnostics use signs and underlines, with virtual text disabled by default; `<leader>uv` toggles rich `virtual_lines` diagnostics on the cursor line.
- Floating diagnostic windows use rounded borders and show sources.
- On attach, the default Neovim 0.11+ LSP maps that shadow the bare `gr` (`grr`, `gri`, `grn`, `gra`, `grt`, `grx`, `gO`) are deleted so the FZF-backed `gr` fires instantly with no `timeoutlen` delay.
- `gopls` enables gofumpt, unimported package completions, staticcheck, govulncheck (`vulncheck = "Imports"` — vulnerability diagnostics on `go.mod` requires whose vulnerable code is reachable), semantic tokens, selected analyses, code lenses, and inlay hints support.
- `lua_ls` runs with a minimal static config; workspace libraries (the Neovim runtime and plugin type definitions) are injected per-`require` by `folke/lazydev.nvim`, which also adds a blink completion source so plugin APIs (`FzfLua`, `require("conform")`, ...) complete while editing this config.
- `rust_analyzer` enables all Cargo features and runs `clippy` for checks.
- `yamlls` validates YAML, uses schemastore data, supports Kubernetes schemas, and reads the local CRD schema cache. Its formatter is disabled — conform owns YAML formatting via `yamlfmt`.
- `helm_ls` delegates YAML behavior to `yaml-language-server` and recognizes `values*.yaml`.

Common LSP mappings:

- `gd`/`gD` definition/declaration, `gr`/`gi`/`gy` references/implementations/type definitions (all via FZF picker), `K` hover
- `<leader>cd`/`<leader>cD` definition/declaration, `<leader>cy` type definition, `<leader>cu` usages (use bare `gi` for implementations; `<leader>ci` is repurposed to implement-interface in Go buffers)
- `<leader>fs`/`<leader>fS` document/workspace symbols, `<leader>cF` LSP finder, `<leader>cI`/`<leader>cO` calls
- `<leader>ca` code action, `<leader>cr` references, `<leader>cn` rename, `<leader>co` organize imports, `<leader>cf` fix all
- `<leader>cc`/`<leader>cC` run/refresh code lens
- `<leader>cx` line diagnostics, `<leader>cq` diagnostics quickfix; `]d`/`[d` and `<leader>uv` are global maps (`config/keymaps.lua`), so they also cover nvim-lint diagnostics in buffers without an LSP client
- `<leader>cL` LSP info, `<leader>cR` restart LSP
- `<leader>uh` toggles inlay hints when supported, `<leader>uv` toggles virtual-line diagnostics

Go-specific mappings (active only while `gopls` is attached):

- `<leader>cgm` runs `go mod tidy`.
- `<leader>cgg` runs `go generate ./...`.
- `<leader>cgl` runs `golangci-lint run ./...`.
- `<leader>cgd` shows `go doc` for the symbol under the cursor in a floating window.
- `<leader>cgj` / `<leader>cgJ` add / remove json struct tags via `gomodifytags`.
- `<leader>cgy` / `<leader>cgY` add / remove yaml struct tags via `gomodifytags`.
- `<leader>cge` / `<leader>cgE` add / remove env struct tags for `caarlos0/env/v11` via `gomodifytags`.
- `<leader>ci` implements an interface on a chosen struct via `impl`.

### Go Helpers

`nvim/lua/config/go.lua` centralizes project-root detection, Go command execution, and code-generation helpers:

- Project root is detected from `go.work`, `go.mod`, or `.git`.
- Go commands run from the project root; failed command output is written to the quickfix list.
- Helper functions expose organize imports, fix all, `go mod tidy`, `go generate ./...`, and `golangci-lint run ./...`.
- Code-generation helpers use Treesitter to find the struct under the cursor and drive the Mason-installed tools:
  - Per-tag add/remove helpers → `gomodifytags` (`json`, `yaml`, and `env`).
  - `implement_interface` → takes the struct **under the cursor**, then opens a live gopls workspace-symbol picker filtered to interfaces. Results are always displayed as `package.Name` using the short package name (searching `Stringer` shows `fmt.Stringer`; an interface from `sigs.k8s.io/controller-runtime/pkg/client` shows as `client.Object`, not the full import path), so same-named interfaces from different packages are distinguishable without the noise. On selection the symbol's import path is resolved with `go list` so it works for stdlib, dependency, and workspace interfaces, and `impl`'s generated method stubs are inserted right after the struct. The receiver name is derived from the struct name (e.g. `Widget` → `w *Widget`). If the picker is unavailable it falls back to a manual interface prompt.

### Kubernetes and YAML

`nvim/lua/config/kubernetes.lua` provides Kubernetes-aware YAML behavior:

- Defines broad file patterns for Kubernetes manifests under paths such as `k8s`, `kubernetes`, `deploy`, `deployment`, `manifests`, `base`, `overlays`, `clusters`, and `argocd`.
- Adds a Kubernetes schema association for those patterns.
- Adds a Helm Chart schema for `Chart.yaml`.
- Detects YAML buffers that contain both `apiVersion:` and `kind:`.
- Avoids treating Helm template files containing `{{` as plain Kubernetes manifests.
- Dynamically attaches the Kubernetes schema to individual YAML files that look like manifests.
- Generates a CRD schema catalog from the current `kubectl` context.
- Also ingests the operator's own CRDs from `config/crd/bases/*.yaml` (the kubebuilder/operator-sdk layout) so its sample custom resources validate and complete **before** the CRD is ever applied to a cluster. This runs automatically once per project (when a `config/crd/bases` directory exists) and converts the local YAML to JSON with an offline `kubectl create --dry-run=client` call — no cluster contact.
- Adds an OpenShift-specific cache path for OpenShift CRDs.

User commands:

- `:KubeCrdSchemas` generates CRD schemas from the current cluster.
- `:KubeCrdSchemasLocal` generates CRD schemas from the project's local `config/crd/bases/*.yaml` files (no cluster needed).
- `:KubeCrdSchemasPath` prints the local CRD schema cache path.
- `:KubeSchemaAttach` attaches the Kubernetes schema to the current YAML buffer if it looks like a manifest.

The CRD schema cache lives under Neovim state:

```text
stdpath("state")/kubernetes/crd-catalog
```

### Formatting

`nvim/lua/plugins/formatting.lua` configures `conform.nvim`.

Formatters by filetype:

- Go: `goimports`, `gofumpt`, `golines`
- Lua: `stylua`
- Rust: `rustfmt`
- Shell: `shfmt`
- YAML: `yamlfmt`
- Docker Compose YAML: `yamlfmt`
- Helm values YAML: `yamlfmt`
- JSON and JSONC: `prettier`
- Markdown: `prettier`

`golines` is configured with `--max-len=120`.

Formatting runs on save. For Go files this also runs `goimports`, so imports are added, removed, and sorted before the file is written.

Formatting runs on save by default, but can be toggled:

- `<leader>cl` formats the current file or visual selection on demand.
- `<leader>uf` toggles format-on-save globally (with a notification).
- `:FormatDisable` disables format-on-save globally; `:FormatDisable!` disables it for the current buffer only; `:FormatEnable` re-enables it.

The `format_on_save` hook checks `vim.g.disable_autoformat` / `vim.b.disable_autoformat`, so the toggle takes effect on the next save. Manual `<leader>cl` always formats regardless of the toggle.

### Linting

`nvim/lua/plugins/lint.lua` wires `mfussenegger/nvim-lint` so the Mason-installed linters actually produce diagnostics (formatting and LSP do not cover these):

- `yamllint` runs on `yaml`, `yaml.docker-compose`, and `yaml.helm-values` buffers. It is invoked with `-d relaxed` so the noisy stylistic warnings (line length, comment spacing, document-start) are dropped and only real problems — duplicate keys, bad indentation, syntax errors — surface. Helm templates are filetype `helm`, so `{{ }}` files are never linted as YAML.
- `hadolint` runs on `dockerfile` buffers.

Shell scripts are not wired through nvim-lint: `bashls` runs `shellcheck` itself and reports through LSP diagnostics.

Linters run on read, write, and leaving insert mode. Diagnostics appear through the normal diagnostic UI (`<leader>cx`, `]d`/`[d`, `<leader>fd`).

### Treesitter

`nvim/lua/plugins/treesitter.lua` uses the `main` branch of `nvim-treesitter`.

Installed parsers:

- `bash`, `c`, `css`, `dockerfile`, `go`, `gomod`, `gosum`, `gowork`, `helm`, `html`, `javascript`, `json`, `lua`, `markdown`, `markdown_inline`, `python`, `query`, `regex`, `rust`, `sql`, `tsx`, `typescript`, `vim`, `vimdoc`, `yaml`

Treesitter highlighting is enabled on filetype events for the supported languages. `jsonc` is registered to use the JSON parser.

### Indent Guides

Indent guides come from two plugins working together:

- **Static guides** — `nvim/lua/plugins/indent.lua` configures `indent-blankline.nvim` (`ibl`): a plain `│` on **every** indent level, no animation, its own treesitter scope **disabled**. `tab_char` is set explicitly so tab-indented files (Lua, Go) draw the line instead of an invisible space (ibl otherwise inherits the blank `listchars` tab). The guide colour is overridden to `surface1` in `colorscheme.lua` (catppuccin's default `surface0` is nearly invisible on the base background).
- **Active scope** — `mini.indentscope` (in `minis.lua`) draws the line for the block under the cursor a bit bolder (`overlay1` + bold, no animation). It's **indentation-based**, so it always matches the block you're visually in — unlike ibl's treesitter scope, which snaps to the outer syntactic scope when the cursor sits on a block's opening/closing line.

Together they replace the removed indent-guide module.

### Fuzzy Finding and Picker

`nvim/lua/plugins/fzf.lua` configures `ibhagwan/fzf-lua` as the unified fuzzy finder and registers it for `vim.ui.select`.

File search excludes `.git`, `.vscode`, `node_modules`, `dist`, `build`, `target`, and `.idea`. Hidden files and symlinks are followed. Previews use FZF-Lua's builtin previewer.

Mappings:

- `<leader>ff` find files
- `<leader>fg` live grep
- `<leader>/` fuzzy search lines in the current buffer
- `<leader>fu` undo history
- `<leader>fG` Git changed files
- `<leader>fb` buffers
- `<leader>fr` recent files
- `<leader>fc` config files
- `<leader>fw` grep word under cursor
- `<leader>fW` grep WORD under cursor
- `<leader>fh` help tags
- `<leader>fk` keymaps
- `<leader>fs` document symbols
- `<leader>fS` workspace symbols (live, via LSP)
- `<leader>fd` document diagnostics
- `<leader>fD` workspace diagnostics
- `<leader>fq` quickfix list
- `<leader>fR` resume last picker

### File Explorers

`mini.files` (`<leader>e`, declared in `nvim/lua/plugins/minis.lua`) is the file explorer:

- `<leader>e` toggles a floating miller-columns explorer, opened focused on the current file (or the cwd for unnamed buffers); pressing it again closes it. Preview is disabled.
- `<CR>` / `<Right>` go **in**: a directory is entered (explorer stays open), a file is opened **and the explorer closes**. `<BS>` / `<Left>` go **back** out one level (collapsing that column). `l` / `h` keep mini.files' default soft go-in / go-out; `q` closes.
- The explorer buffer is editable: create/rename/move/delete entries as text and apply with `=` (synchronize).
- Deletes go to trash; rename/move use LSP file methods. Icons come from mini.icons.

> Oil (the editable column-mode manager, `<leader>E`) is temporarily mocked out in `oil.lua` (`if true then return {} end`); its full config is kept for re-enabling. neo-tree was removed.

### Git

Git support is split between gitsigns and FZF-Lua. (LazyGit is available from tmux with `Ctrl-Space g`; the in-editor `<leader>gg` mapping remains removed.)

`nvim/lua/plugins/gitsigns.lua`:

- Shows add/change/delete/untracked signs in the signcolumn.
- Follows file moves.
- Attaches to untracked files.
- Supports hunk navigation, staging, reset, preview, blame, diffs, deleted line toggles, and word diff toggles.

Mappings:

- `]h` / `[h` next/previous hunk — navigates both staged and unstaged hunks in the current file
- `<leader>ghp` preview hunk
- `<leader>ghs` stage hunk
- `<leader>ghr` reset hunk
- `<leader>ghu` un-stage hunk under cursor (staging is a toggle)
- `<leader>ghb` blame line
- `<leader>ghB` full blame line
- `<leader>ghl` toggle inline blame
- `<leader>ghd` diff current file
- `<leader>ghD` diff current file against previous commit
- `<leader>ght` toggle deleted lines
- `<leader>ghw` toggle word diff

### Tabline and Statusline

Both are mini.nvim modules (declared in `nvim/lua/plugins/minis.lua` and `nvim/lua/plugins/statusline.lua`), themed automatically by catppuccin's `mini` integration (`MiniTabline*` / `MiniStatusline*` groups) — no hand-built palette table.

`mini.tabline` renders buffer tabs:

- `]b` next buffer, `[b` previous buffer (plain `:bnext` / `:bprevious`).
- File icons come from mini.icons; modified buffers and same-name disambiguation are handled automatically.
- Note: it has no buffer-pick or close-button equivalents (the old `<leader>bp`/`bX`/`bL`/`bH` are gone); use `<leader>fb` to jump buffers and `<leader>bx` to delete one.

`mini.statusline` configures the global statusline (intentionally compact):

- Left: abbreviated mode (`N`/`I`/`V`), Git branch, and diagnostic counts.
- Right: attached LSP server names (e.g. `gopls, lua_ls`), filetype + icon, and a compact `line:col`.
- Shows a `@register` macro-recording indicator (refreshed via `RecordingEnter`/`RecordingLeave`).
- Filename is shown as the name only (`%t`), not the path.
- Uses global statusline mode (`laststatus=3`, already set in `options.lua`).

### Autopairs

`nvim/lua/plugins/pairs.lua` configures `nvim-autopairs`. It skips generated
closing delimiters for `(`, `[`, `{`, quotes, and backticks; its built-in
multi-character rules also pair Markdown fences (` ``` `).

### Mini Plugins

`nvim/lua/plugins/minis.lua` uses the mini.nvim suite for several core behaviors:

- `mini.ai` — extra text objects, including Treesitter-powered ones (see Text Objects below).
- `mini.surround` — surround operations (mappings below).
- `mini.animate` — smooth scroll animation for Page Up/Down, `<C-d>`, `<C-u>`, and other viewport changes; cursor and window animations stay off.
- `mini.map` — optional compact right-side file overview, toggled with `<leader>um`.
- `mini.icons` — icons plus `nvim-web-devicons` compatibility (used by mini.files, mini.tabline, mini.statusline, blink, and more).
- `mini.bufremove` — layout-preserving buffer deletion, wired into `<leader>q`, `<leader>W`, and `<leader>bx`.
- `mini.files` — the file explorer (`<leader>e`, see the File Explorers section).
- `mini.tabline` — buffer tabs (see the Tabline and Statusline section).
- `mini.statusline` — the global statusline (see the Tabline and Statusline section).
- `mini.indentscope` — bolder line for the active indent scope (indentation-based), layered on the static indent-blankline guides (see Indent Guides). Disabled in special buffers; themed by the catppuccin `mini` integration.

`mini.starter` (start screen) remains **commented out** in `minis.lua`; its spec is kept behind a block comment for easy re-enabling.

`nvim/lua/plugins/map.lua` configures `mini.map`: it is hidden by default and toggled with `<leader>um`. It appears on the right at a compact width and marks the current line and visible viewport.

Notifications and the command line are handled by **noice** (see the Notifications section). The file explorer is **mini.files** (see File Explorers).

Surround mappings:

- `sa` add
- `sd` delete
- `sf` find
- `sF` find left
- `sh` highlight
- `sr` replace
- `sn` update search line count

### Text Objects

`mini.ai` extends the built-in `a`/`i` text objects. The Treesitter-powered ones (queries come from `nvim-treesitter-textobjects`, which also provides the `]f`/`[f` function motions) understand Go syntax:

| Object | Selects | Examples |
| --- | --- | --- |
| `af` / `if` | function or method **definition** (around / body only) | `vaf` select whole func, `dif` delete its body, `yif` yank body |
| `aF` / `iF` | function **call** | `diF` delete the call's arguments, `vaF` select `foo(x, y)` |
| `ao` / `io` | surrounding block, conditional, or loop | `vio` inside the enclosing `if`/`for`, `dao` delete the whole block |
| `ac` / `ic` | type declaration (struct/interface) | `vac` select the whole `type Widget struct {...}` |
| `aa` / `ia` | argument (built-in) | `cia` change one argument, `daa` delete it including the comma |
| `a?` / `i?` | prompted — type any two delimiters | `vi?` then e.g. `(` and `)` |

All of them compose with operators like native text objects (`d`, `c`, `y`, `v`). Two extras worth knowing:

- **Next/last variants**: insert `n` or `l` after `a`/`i` to target the *next* or *previous* object without moving the cursor first — `vinf` selects inside the next function, `cina` changes the first argument of the next call, `valc` selects the previous type declaration.
- **Dot-repeat and counts work**: `2daa` deletes two arguments; a repeated `.` after `dif` deletes the next function body you jump to.

### Markdown

`nvim/lua/plugins/md-reader.lua` configures `render-markdown.nvim` for rendered Markdown inside Neovim.

Mappings:

- `<leader>Md` toggles rendered Markdown view.
- `<leader>MD` opens rendered preview in a side window.

### Testing

`nvim/lua/plugins/tests.lua` configures `neotest` with `neotest-golang`.

Mappings:

- `<leader>tf` test current function
- `<leader>tF` test current file
- `<leader>tp` test current package
- `<leader>tP` test entire project
- `<leader>tr` rerun last test
- `<leader>ts` toggle test summary
- `<leader>to` open test output
- `<leader>tO` toggle output panel
- `<leader>tq` open the failed-test quickfix list; use `]q` / `[q` to navigate across files
- `<leader>tw` watch current file
- `<leader>tx` stop tests

The Go adapter uses `gotestsum`. If `gotestsum` is missing, the plugin build step tries to install it with `go install gotest.tools/gotestsum@latest`.

### Debugging

`nvim/lua/plugins/dap.lua` configures `nvim-dap` with `nvim-dap-ui`, `nvim-dap-virtual-text`, and `nvim-dap-go`. Delve is resolved from the Mason install first, falling back to `dlv` on `PATH`. The UI opens automatically when a session launches/attaches and closes when it terminates. Breakpoint, condition, log-point, and stopped signs use the diagnostic highlight groups.

Mappings (all under the `<leader>d` group):

| Key | Action |
| --- | --- |
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint (prompts for condition) |
| `<leader>dp` | Log point (prompts for message) |
| `<leader>dc` | Continue / start |
| `<leader>dC` | Run to cursor |
| `<leader>di`, `<leader>do`, `<leader>dO` | Step into / over / out |
| `<leader>dr` | Restart |
| `<leader>dl` | Run last |
| `<leader>dt` | Terminate |
| `<leader>du` | Toggle debug UI |
| `<leader>de` | Evaluate expression (normal or visual) |
| `<leader>df`, `<leader>ds`, `<leader>dS` | Float frames / scopes / wide scopes |
| `<leader>dg`, `<leader>dG` | Debug current / last Go test |

### Trouble (panel for diagnostics, symbols, lists)

`nvim/lua/plugins/trouble.lua` configures `folke/trouble.nvim` as the single panel for diagnostics, the symbol outline, todos, LSP references, and the quickfix/location lists. It replaced **aerial** (outline) and **quicker** (quickfix window).

| Key | Action |
| --- | --- |
| `<leader>F` | Code outline — focused symbols panel on the right (jump in and navigate) |
| `<leader>xs` | Symbols outline — peek without leaving the code window |
| `<leader>xt` | Todo-comment list |
| `<leader>xr` | LSP references / definitions panel |
| `<leader>xq` / `<leader>xl` | Quickfix / location list |

Trouble also **hijacks the native quickfix and location list windows**: any `:copen`, `:grep`, `:vimgrep`, `:make`, or picker "send to quickfix" opens in Trouble instead of the plain window (a `BufWinEnter` autocmd registered in the plugin's `init`). The config's own lists — diagnostics (`<leader>cq`), failed tests (`<leader>tq`), and failed Go commands (`<leader>cg…`) — populate the quickfix list with `setqflist` and then call `:Trouble qflist open` directly.

Inside any Trouble panel, `<CR>` jumps to the item, `o` jumps and stays, and `q` / `<Esc>` close. `]q` / `[q` still navigate the underlying quickfix list as usual.

> Note: this drops quicker's **editable quickfix** (`:w` from the qf buffer to apply edits back to files) and `>` / `<` context expansion — Trouble has no equivalent. Use `:cdo` / `:cfdo` if you need batch edits across quickfix entries.

### Todo Comments

`nvim/lua/plugins/todo.lua` configures `folke/todo-comments.nvim`.

Highlights `TODO`, `FIXME`, `FIX`, `HACK`, `WARN`, `PERF`, `NOTE`, `TEST` keywords in comments with distinct colors. Works in all filetypes.

- `]t` / `[t` jump to the next/previous todo comment in the buffer.
- `<leader>ft` opens an FZF picker with all todo comments in the project.
- `<leader>fT` filter to `TODO`, `FIX`, `FIXME` only — the actionable ones.

### AI with CodeCompanion

`nvim/lua/plugins/codecompanion.lua` configures `olimorris/codecompanion.nvim` around OpenAI Codex:

- Codex is the default chat adapter, connected through `@zed-industries/codex-acp`.
- The ACP adapter uses the existing ChatGPT subscription login and is launched through `npx`.
- The CLI interaction opens the locally installed `codex` command in a Neovim terminal.
- The action palette uses FZF-Lua and chat opens in a vertical side window.

Key mappings:

- `<leader>aa` open CodeCompanion actions.
- `<leader>ac` toggle the Codex chat.
- `<leader>ad` add the visual selection to the current chat.
- `<leader>an` open a new Codex chat.
- `<leader>at` open the Codex CLI terminal.

### Picker Stack

`nvim/lua/plugins/fzf.lua` is the central picker integration (`ibhagwan/fzf-lua`).

It owns:

- File, grep, buffer, history, help, command, diagnostic, quickfix/location, git, todo, and LSP pickers.
- `vim.ui.select`, so code actions and other selection prompts use the same picker backend.
- FZF-Lua's builtin previewer for file, grep, git, and diagnostic results.

Buffer deletion, the tabline, the statusline, scrolling animation, and the minimap are handled by mini.nvim (`mini.bufremove`, `mini.tabline`, `mini.statusline`, `mini.animate`, `mini.map`); the file explorer is mini.files; notifications and the command line are handled by noice, while ordinary messages stay native. (`mini.starter` is currently commented out.) See the Mini Plugins, File Explorers, and Notifications sections.

### Notifications and Command Line

Notifications and the command line are owned by one plugin: `folke/noice.nvim` (`nvim/lua/plugins/noice.lua`, depending only on `nui.nvim`). Ordinary command output such as `:echo 'xxx'` stays in Neovim's native message area.

- **Notifications**: `vim.notify` is routed through noice's own `mini` view, so there is no `nvim-notify` dependency. `<leader>fn` runs `:Noice history`; `<leader>un` runs `:Noice dismiss`.
- The command line (`:`) renders on the **bottom line** (`cmdline` view, with the `command_palette` preset off so it isn't re-centered); search (`/`, `?`) uses the classic bottom line too (`bottom_search` preset).
- LSP progress is shown, and LSP hover/signature markdown is rendered with a border (`lsp_doc_border`).

### which-key

`nvim/lua/plugins/which-key.lua` documents the leader-key layout.

Top-level groups:

- `<leader>a` AI (CodeCompanion)
- `<leader>b` buffers
- `<leader>f` find
- `<leader>g` Git
- `<leader>gh` Git hunks
- `<leader>c` code
- `<leader>cg` Go
- `<leader>d` debug
- `<leader>M` Markdown
- `<leader>t` tests
- `<leader>u` UI/toggles
- `<leader>x` buffer actions and lists (quickfix, location list, Trouble)

Every leader mapping in the config carries a `desc`, and the spec also documents the bare-key and bracket-pair mappings (`gd`/`gr`/`gi`, `]h`/`[h`, `]d`/`[d`, `]t`/`[t`, `]q`/`[q`, `]b`/`[b`), so `which-key` and `<leader>fk` stay an accurate map of the whole keyboard layout.

The UI uses the modern preset, rounded borders, compact key labels, and a shorter delay for leader-triggered mappings.

## Snippets

Local snippets live in `nvim/snippets/`.

`package.json` registers snippets for:

- Go
- YAML
- Helm

For Go, general-purpose snippets (structs `tys`, interfaces `tyi`, `for`/`fori`/`forr` loops, methods `meth`/`fum`, goroutines `go`/`gf`, benchmarks `bf`, table tests `tdt`, ...) come from friendly-snippets. The local `go.json` adds specialized snippets under prefixes that do not collide with friendly-snippets:

- `if err != nil` and wrapped errors (`iferr`, `errw`)
- HTTP handlers (`httphandler`, `httphandlerm`)
- tests, subtests, table tests (`test`, `tRun`, `tt`)
- `select` with context (`selectctx`)
- controller-runtime reconciliation helpers (`reconcile`, `kget`, `ownerref`)

`kubernetes.json` includes snippets for:

- Deployment
- Service
- ConfigMap
- Secret
- Ingress
- Namespace
- Job
- CronJob
- Pod
- CustomResourceDefinition
- RBAC Role

## Ghostty

`ghostty/config` configures the terminal:

- Theme: `Catppuccin Mocha`
- Background opacity: `0.97`
- No window padding.
- Native macOS titlebar style.
- Font: `FiraCode Nerd Font`
- Font size: `16`
- Ligature-related font features enabled.
- Cursor blink enabled.

This config assumes the font is installed locally. If Ghostty opens with missing glyphs or fallback symbols, install `FiraCode Nerd Font` or change `font-family`.

## Starship

`starship.toml` configures a compact two-line prompt.

Global behavior:

- Adds a newline between prompts.
- Command timeout is 1000 ms.
- Uses the `catppuccin_mocha` palette defined in the file.

Prompt format:

```text
directory git_branch git_status git_state golang python docker_context helm
jobs character                                                 [cmd_duration]
```

`cmd_duration` renders right-aligned via `right_format`.

Enabled prompt modules:

- Directory, truncated to 3 segments and rooted at the repository when possible.
- Git branch.
- Git status with compact symbols for ahead, behind, modified, staged, deleted, untracked, and other states.
- Git state: rebase/merge/cherry-pick progress (e.g. `REBASING 2/5`); reads `.git` state files only, no subprocess.
- Go indicator (symbol only — no `go version` subprocess).
- Python version.
- Helm chart indicator (symbol only — rendering the version would exec `helm` on every prompt, measured at ~700 ms).
- Background job count next to the prompt character.
- Command duration on the right when a command takes at least 1500 ms.
- Prompt character with different colors for success, error, and Vim command mode.

Disabled or hidden modules:

- Kubernetes is disabled intentionally to keep context/namespace out of the prompt.
- Docker context is configured but disabled.
- Package, Node.js, Rust, Java, AWS, GCloud, Azure, Terraform, username, and hostname are disabled.

## tmux

tmux is configured by this repo through `.tmux.conf`. The prefix is `Ctrl-Space`, and the most important raw commands are listed here so session and window management does not depend on wrapper scripts.

Pane navigation is integrated with Neovim. `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>` and `<C-Left>`, `<C-Down>`, `<C-Up>`, `<C-Right>` move between Neovim windows first, then cross into adjacent tmux panes when pressed at a Neovim edge. Outside Neovim, the same keys move directly between tmux panes.

### Sessions

List sessions:

```bash
tmux list-sessions
tmux ls
```

Create a new named session:

```bash
tmux new-session -s work
tmux new -s work
```

Create a new named session in a specific directory:

```bash
tmux new-session -s work -c ~/dev/project
```

Create a detached session:

```bash
tmux new-session -d -s work
```

Attach to a session:

```bash
tmux attach-session -t work
tmux attach -t work
tmux a -t work
```

Switch to another session from inside tmux:

```bash
tmux switch-client -t work
```

Detach from the current session:

```bash
tmux detach-client
```

Kill a session:

```bash
tmux kill-session -t work
```

Rename the current session:

```bash
tmux rename-session new-name
```

### Grouped Sessions

A grouped session shares windows with another session but has its own attached client state. This is useful when opening the same workspace from another terminal.

Create a grouped session from an existing session:

```bash
tmux new-session -t work -s work-side
```

Create a detached grouped session:

```bash
tmux new-session -d -t work -s work-side
```

Attach to the grouped session:

```bash
tmux attach-session -t work-side
```

Destroy the grouped session when no client is attached:

```bash
tmux set-option -t work-side destroy-unattached on
```

Kill the grouped session:

```bash
tmux kill-session -t work-side
```

### Windows

List windows:

```bash
tmux list-windows
tmux lsw
```

Create a new window:

```bash
tmux new-window
tmux neww
```

Create a named window:

```bash
tmux new-window -n editor
```

Create a named window in a specific directory:

```bash
tmux new-window -n editor -c ~/dev/project
```

Select a window by index:

```bash
tmux select-window -t 1
```

Rename the current window:

```bash
tmux rename-window editor
```

Kill the current window:

```bash
tmux kill-window
```

Kill a window by index:

```bash
tmux kill-window -t 1
```

### Panes

Split horizontally:

```bash
tmux split-window -h
```

Split vertically:

```bash
tmux split-window -v
```

Split in a specific directory:

```bash
tmux split-window -h -c ~/dev/project
```

Move between panes:

```bash
tmux select-pane -L
tmux select-pane -R
tmux select-pane -U
tmux select-pane -D
```

Kill the current pane:

```bash
tmux kill-pane
```

### Config Reload

Reload the default tmux config:

```bash
tmux source-file ~/.tmux.conf
```

Reload a config from inside tmux command mode:

```tmux
source-file ~/.tmux.conf
```

This config also binds prefix `r` to reload `~/.tmux.conf`, so press `Ctrl-Space r` inside tmux.

You can also reload through command mode with `Ctrl-Space :`, then run:

```tmux
source-file ~/.tmux.conf
```

### Prefix Bindings

This config changes the tmux prefix to `Ctrl-Space`. Press the prefix first, release it, then press the binding key.

Print every active binding on the current machine:

```bash
tmux list-keys
tmux lsk
```

Session bindings:

- `Ctrl-Space d` detach from the current session.
- `Ctrl-Space s` choose a session.
- `Ctrl-Space $` rename the current session.
- `Ctrl-Space (` switch to the previous session.
- `Ctrl-Space )` switch to the next session.

Window bindings:

- `Ctrl-Space c` create a new window in the current pane directory.
- `Ctrl-Space ,` rename the current window.
- `Ctrl-Space &` kill the current window.
- `Ctrl-Space w` choose a window from a list.
- `Ctrl-Space n` move to the next window.
- `Ctrl-Space p` move to the previous window.
- `Ctrl-Space l` move to the previously selected window.
- `Ctrl-Space C-]` / `Ctrl-Space C-[` roll to the next/previous window — repeatable: hold the prefix once, then tap `C-]`/`C-[` (repeat window is 1 s).
- `Ctrl-Space 0` through `Ctrl-Space 9` select a window by index.
- `Ctrl-Space .` move the current window to another index.

Pane bindings:

- `Ctrl-Space =` split the current pane left/right in the current pane directory.
- `Ctrl-Space -` split the current pane top/bottom in the current pane directory.
- `Ctrl-Space H` / `J` / `K` / `L` resize the pane left / down / up / right by 5 cells (repeatable).
- `Ctrl-Space x` kill the current pane.
- `Ctrl-Space z` zoom or unzoom the current pane.
- `Ctrl-Space o` move to the next pane.
- `Ctrl-Space ;` move to the previously active pane.
- `Ctrl-Space q` show pane numbers.
- `Ctrl-Space {` move the current pane left.
- `Ctrl-Space }` move the current pane right.
- `Ctrl-Space Space` cycle pane layouts.
- `Ctrl-Space Ctrl-o` rotate panes forward.
- `Ctrl-Space Alt-o` rotate panes backward.
- `Ctrl-Space !` break the current pane into a new window.

Popup and project helper bindings:

- `Ctrl-Space g` open LazyGit in a popup in the current pane directory.
- `Ctrl-Space e` open Yazi in a popup in the current pane directory.

Copy mode and command bindings:

- `Ctrl-Space [` enter copy mode.
- `Ctrl-Space ]` paste the most recent buffer.
- `Ctrl-Space :` open the tmux command prompt.
- `Ctrl-Space ?` list key bindings.
- `Ctrl-Space t` show a clock.
- `Ctrl-Space r` reload `~/.tmux.conf`.

## Maintenance

### Updating Plugins

Open Neovim and use Lazy:

```vim
:Lazy
```

Common operations:

- Sync plugins: `:Lazy sync`
- Update plugins: `:Lazy update`
- Check plugin status: `:Lazy health`

Commit changes to `nvim/lazy-lock.json` when plugin versions are intentionally updated.

### Installing Mason Tools

Mason tools install automatically on startup through `mason-tool-installer.nvim`.

Manual UI:

```vim
:Mason
```

### Checking Neovim Health

```vim
:checkhealth
```

Useful targeted checks:

```vim
:checkhealth lazy
:checkhealth codecompanion
:checkhealth vim.lsp
:checkhealth nvim-treesitter
```

### Kubernetes Schema Refresh

When changing clusters or adding CRDs:

```vim
:KubeCrdSchemas
```

To inspect where schemas are stored:

```vim
:KubeCrdSchemasPath
```

### Adding New Neovim Config

Use the existing structure:

- Put editor behavior in `nvim/lua/config/`.
- Put plugin specs in `nvim/lua/plugins/`.
- Keep `init.lua` as a loader only.
- Prefer adding feature-focused plugin files over growing unrelated files.
- Add key descriptions so which-key remains useful.
- Add external tools to Mason only when they are editor-managed tools; keep system dependencies documented here.

### Adding Snippets

Add snippets under `nvim/snippets/` and register the file in `nvim/snippets/package.json`.

Local snippets are loaded by `blink.cmp` from:

```text
stdpath("config")/snippets
```

Because `~/.config/nvim` is a symlink to this repo's `nvim/` directory, snippet edits in the repo are picked up by Neovim.
