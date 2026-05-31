# dotfiles2

Personal dotfiles for a terminal-first development environment. The repo is intentionally small: it keeps the source configuration under version control and uses symlinks to expose those files at the paths expected by Neovim, Ghostty, and Starship.

## Repository Architecture

```text
.
├── README.md
├── ghostty/
│   └── config
├── nvim/
│   ├── init.lua
│   ├── lazy-lock.json
│   ├── lua/
│   │   ├── config/
│   │   └── plugins/
│   └── snippets/
└── starship.toml
```

The repo is split by tool:

- `nvim/` is the complete Neovim configuration.
- `ghostty/config` configures the Ghostty terminal.
- `starship.toml` configures the shell prompt.

The Neovim config has two layers:

- `nvim/lua/config/` contains core editor behavior: options, keymaps, autocmds, filetype detection, Go helper functions, Kubernetes schema logic, and Lazy plugin bootstrapping.
- `nvim/lua/plugins/` contains Lazy plugin specs grouped by feature area: completion, LSP, formatting, file explorers, fuzzy finding, Git, UI, Markdown, testing, Treesitter, and helper plugins.

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

- `nvim` for the editor.
- `git` for Lazy plugin bootstrap and Git integrations.
- `tmux` for terminal multiplexing.
- `fzf` for tmux selectors and Neovim fuzzy finding.
- `rg` and `fd` for fast search and file discovery.
- `lazygit` for the Neovim LazyGit integration.
- `go` for Go tooling, tests, and helper commands.
- `kubectl` for generating Kubernetes CRD schemas.
- `starship` for the prompt.
- `ghostty` for terminal configuration.
- A Nerd Font, specifically `FiraCode Nerd Font` in the Ghostty config.

Neovim uses Mason to install many language tools automatically, but system binaries such as `git`, `go`, `kubectl`, `tmux`, `fzf`, `rg`, `fd`, `starship`, and `lazygit` should be installed outside Neovim.

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
ln -s ~/dev/dotfiles2/ghostty/config ~/.config/ghostty/config
ln -s ~/dev/dotfiles2/starship.toml ~/.config/starship.toml
ln -s ~/dev/dotfiles2/.tmux.conf ~/.tmux.conf
```

If a target file already exists, move it out of the way first:

```bash
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.config/starship.toml ~/.config/starship.toml.backup
mv ~/.config/ghostty/config ~/.config/ghostty/config.backup
```

To verify the links:

```bash
ls -l ~/.config/nvim
ls -l ~/.config/ghostty/config
ls -l ~/.config/starship.toml
```

## Neovim Configuration

### Core Options

`nvim/lua/config/options.lua` sets the baseline editor behavior:

- Leader and local leader are both space.
- Absolute and relative line numbers are enabled.
- Mouse support is enabled.
- netrw is disabled because file exploration is handled by Oil and Neo-tree.
- Clipboard uses `unnamedplus`.
- Indentation uses spaces with a width of 4.
- Search uses ignorecase plus smartcase.
- UI defaults include true color, cursorline, signcolumn, no wrapping, global statusline, rounded window borders, and clean command/status display.
- Split defaults are `splitright` and `splitbelow`.
- Swap and backup files are disabled; persistent undo is enabled.
- Completion uses `menu`, `menuone`, and `noselect`.
- Invisible characters are displayed for tabs, trailing spaces, and non-breaking spaces.
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
| `<C-d>`, `<C-u>` | Half-page down/up and keep the cursor centered |
| `n`, `N` | Next/previous search result and keep the cursor centered |
| `]q`, `[q` | Next/previous quickfix item |
| `q`, `<Esc>` in temporary windows | Close quickfix, help, man, notify, and neotest windows |

Save, quit, and buffers:

| Key | Action |
| --- | --- |
| `<leader>w` | Save file |
| `<leader>q` | Smart close: close special/floating window or delete current buffer |
| `<leader>W` | Save and delete current buffer |
| `<leader>Q` | Quit current window |
| `<leader>C` | Force-quit all Neovim windows |
| `[b`, `]b` | Previous/next buffer |
| `[[`, `]]` | Previous/next buffer |
| `<leader>bx` | Delete current buffer |
| `<leader>bp` | Pick buffer from bufferline |
| `<leader>bX` | Delete all other buffers |
| `<leader>bH`, `<leader>bL` | Delete buffers to the left/right |
| `<leader>bE` | Open Neo-tree buffers view |

Completion and snippets:

| Key | Action |
| --- | --- |
| `<C-space>` | Show LSP completion; include Go struct tags in Go buffers; also attach Kubernetes schemas in YAML buffers |
| `<Tab>` | Accept selected completion or jump forward in a snippet |
| `<S-Tab>` | Jump backward in a snippet |
| `<C-j>`, `<C-k>` | Select next/previous completion item |
| `<C-d>`, `<C-u>` in completion docs | Scroll documentation down/up |
| `<C-e>` | Cancel completion |
| Command-line `<C-space>` | Show command-line completion |
| Command-line `<Tab>`, `<S-Tab>` | Accept/select command-line completion |
| Command-line `<Up>`, `<Down>`, `<C-k>`, `<C-j>` | Move through command-line completion items |

Find and search with fzf-lua:

| Key | Action |
| --- | --- |
| `<leader>ff` | Find files |
| `<leader>fe` | Hierarchical fzf file explorer |
| `<leader>fg` | Live grep |
| `<leader>fG` | Git changed files |
| `<leader>fb` | Find buffers |
| `<leader>fr` | Recent files |
| `<leader>fc` | Find Neovim config files |
| `<leader>fw`, `<leader>fW` | Grep word/WORD under cursor |
| `<leader>fh` | Help tags |
| `<leader>fk` | Keymaps |
| `<leader>f:` | Commands |
| `<leader>fj` | Jump list |
| `<leader>fm` | Marks |
| `<leader>f;`, `<leader>f/` | Command/search history |
| `<leader>fd`, `<leader>fD` | Document/workspace diagnostics |
| `<leader>fq`, `<leader>fl` | Quickfix/location list |
| fzf `<Esc>` | Hide picker |
| fzf `<C-d>`, `<C-u>` | Scroll preview down/up |
| fzf `<C-q>` | Select all and accept |
| fzf explorer `<Enter>` | Open file or descend into directory |
| fzf explorer `<C-o>`, `<C-r>` | Go to parent directory/refresh current directory |

Files and project navigation:

| Key | Action |
| --- | --- |
| `<leader>e` | Open Oil column-mode file manager |
| `-` | Open Oil parent directory in a float |
| `<leader>E` | Toggle Neo-tree filesystem view |
| `<leader>gE` | Toggle Neo-tree Git status view |
| `<leader>bE` | Toggle Neo-tree buffers view |
| Oil `<CR>`, `l`, `<Right>` | Smart open file or directory |
| Oil `h`, `<Left>`, `<BS>` | Smart back |
| Oil `<C-v>`, `<C-s>`, `<C-t>` | Open in vertical split, split, or tab |
| Oil `q`, `<Esc>` | Close all Oil columns |
| Oil `-`, `_` | Parent directory/current working directory |
| Oil `` ` ``, `~` | Set cwd/tab cwd to selected directory |
| Oil `g.`, `R` | Toggle hidden files/refresh |
| Neo-tree `<CR>`, `l`, `h` | Open item/close node |
| Neo-tree `o`, `O`, `r`, `d`, `m`, `c` | Add file, add directory, rename, delete, move, copy |
| Neo-tree `y`, `x`, `p` | Copy, cut, paste through clipboard |
| Neo-tree `.`, `R`, `?` or `g?` | Toggle hidden, refresh, help |

Code, LSP, diagnostics, and formatting:

| Key | Action |
| --- | --- |
| `gd`, `gD` | Go to definition/declaration |
| `gr`, `gi`, `gy` | References, implementations, type definitions through fzf-lua |
| `K` | Hover documentation |
| `<leader>ca` | Code action in normal or visual mode |
| `<leader>cl` | Format file or visual selection |
| `<leader>cr` | Rename symbol |
| `<leader>co` | Organize imports |
| `<leader>cf` | Fix all |
| `<leader>cF` | LSP finder |
| `<leader>cu` | Find usages without declaration |
| `<leader>cI`, `<leader>cO` | Incoming/outgoing calls |
| `<leader>cc`, `<leader>cC` | Run/refresh code lens when supported |
| `<leader>cs`, `<leader>cS` | Document/workspace symbols |
| `<leader>ci`, `<leader>cR` | LSP info/restart LSP |
| `<leader>cd`, `<leader>cq` | Line diagnostics/diagnostics quickfix |
| `]d`, `[d` | Next/previous diagnostic with float |
| `<leader>uh` | Toggle inlay hints when supported |

Go-specific code mappings:

| Key | Action |
| --- | --- |
| `<leader>cgm` | Run `go mod tidy` |
| `<leader>cgg` | Run `go generate ./...` |
| `<leader>cgv` | Run `govulncheck ./...` |

Git:

| Key | Action |
| --- | --- |
| `<leader>gg` | Open LazyGit |
| `<leader>gG` | Open LazyGit for current file |
| `<leader>gc`, `<leader>gC` | Git commits/all commits for current buffer |
| `<leader>gb` | Git branches |
| `<leader>gE` | Neo-tree Git status view |
| `]h`, `[h` | Next/previous Git hunk |
| `<leader>ghp` | Preview hunk |
| `<leader>ghs`, `<leader>ghr` | Stage/reset hunk or visual selection |
| `<leader>ghu` | Undo staged hunk |
| `<leader>ghb`, `<leader>ghB` | Blame line/full blame line |
| `<leader>ghl` | Toggle inline blame |
| `<leader>ghd`, `<leader>ghD` | Diff file against index/previous commit |
| `<leader>ght`, `<leader>ghw` | Toggle deleted lines/word diff |
| Neo-tree Git `A`, `ga`, `gu`, `gr` | Add all, add file, unstage file, revert file |
| Neo-tree Git `gc`, `gp`, `gg` | Commit, push, commit and push |

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
| `<leader>tq`, `<leader>tQ` | Next/previous failed test |
| `<leader>tw` | Watch current file |
| `<leader>tx` | Stop tests |

Markdown:

| Key | Action |
| --- | --- |
| `<leader>md` | Toggle rendered Markdown view |
| `<leader>mD` | Open rendered Markdown preview in a side window |
| `<leader>me` | Toggle browser Markdown preview |

Surround editing from `mini.surround`:

| Key | Action |
| --- | --- |
| `sa` | Add surrounding |
| `sd` | Delete surrounding |
| `sr` | Replace surrounding |
| `sf`, `sF` | Find surrounding to the right/left |
| `sh` | Highlight surrounding |
| `sn` | Update surrounding search line count |

### Autocmds

`nvim/lua/config/autocmds.lua` adds small quality-of-life behavior:

- Highlight yanked text for 150 ms.
- Restore the cursor to the last edit position when reopening a file.
- Disable automatic comment continuation on new lines.
- Show a 120-column guide for Go files.
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

### Theme

`nvim/lua/plugins/colorscheme.lua` installs and configures Catppuccin:

- Flavor: `mocha`.
- Terminal colors enabled.
- Transparent background disabled.
- Comment text is italic.
- Integrations are enabled for Treesitter, native LSP, Telescope-compatible surfaces, which-key, gitsigns, Mason, completion, and mini plugins.

The same Catppuccin Mocha direction is used by Ghostty and Starship, so the terminal, prompt, and editor share one visual language.

### Completion

`nvim/lua/plugins/blink.lua` configures `saghen/blink.cmp`:

- Loads on `InsertEnter`.
- Completion sources are LSP, path, snippets, buffer, and Go struct tags.
- Snippets use friendly-snippets plus local snippets from `nvim/snippets/`.
- Kubernetes snippets from friendly-snippets are filtered out so the local Kubernetes snippets take precedence.
- Documentation and completion windows use rounded borders.
- Go completions that come from unimported packages use a `go doc` fallback when `gopls` does not return full completion documentation.
- Go struct fields get tag completions for `json`, `yaml`, `bson`, `xml`, `toml`, `mapstructure`, `db`, `env`, `validate`, and common HTTP binding tags.
- Ghost text and signature help are enabled.
- `<Tab>` accepts the selected completion or jumps through snippets.
- `<S-Tab>` jumps backward through snippets.
- `<C-j>` and `<C-k>` move through completion items.
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

Installed LSP servers:

- `gopls`
- `lua_ls`
- `dockerls`
- `docker_compose_language_service`
- `yamlls`
- `helm_ls`

Mason-managed tools:

- Go: `goimports`, `gofumpt`, `golines`, `delve`, `staticcheck`, `gotestsum`, `gomodifytags`, `impl`, `gotests`
- General: `stylua`, `shfmt`, `prettier`, `yamlfmt`, `yamllint`, `hadolint`

LSP behavior:

- Diagnostics use signs and underlines, with virtual text disabled.
- Floating diagnostic windows use rounded borders and show sources.
- `gopls` enables gofumpt, unimported package completions, staticcheck, semantic tokens, selected analyses, code lenses, and inlay hints support.
- `lua_ls` is configured for Neovim Lua, LuaJIT, `vim` globals, local config workspace, and disabled telemetry.
- `yamlls` validates YAML, uses schemastore data, supports Kubernetes schemas, and reads the local CRD schema cache.
- `helm_ls` delegates YAML behavior to `yaml-language-server` and recognizes `values*.yaml`.

Common LSP mappings:

- `gd` definition
- `gD` declaration
- `gr` references through fzf-lua
- `gi` implementations through fzf-lua
- `gy` type definitions through fzf-lua
- `K` hover documentation
- `<leader>ca` code action
- `<leader>cr` rename
- `<leader>co` organize imports
- `<leader>cf` fix all
- `<leader>cF` LSP finder
- `<leader>cu` usages
- `<leader>cI` incoming calls
- `<leader>cO` outgoing calls
- `<leader>cc` run code lens
- `<leader>cC` refresh code lens
- `<leader>cs` document symbols
- `<leader>cS` workspace symbols
- `<leader>ci` LSP info
- `<leader>cR` restart LSP
- `<leader>cd` line diagnostics
- `<leader>cq` diagnostics quickfix
- `]d` and `[d` navigate diagnostics
- `<leader>uh` toggles inlay hints when supported

Go-specific mappings:

- `<leader>cgm` runs `go mod tidy`.
- `<leader>cgg` runs `go generate ./...`.
- `<leader>cgv` runs `govulncheck ./...`; if `govulncheck` is not installed, it falls back to `go run golang.org/x/vuln/cmd/govulncheck@latest ./...`.

### Go Helpers

`nvim/lua/config/go.lua` centralizes project-root detection and Go command execution:

- Project root is detected from `go.work`, `go.mod`, or `.git`.
- Go commands run from the project root.
- Failed command output is written to the quickfix list.
- Helper functions expose organize imports, fix all, `go mod tidy`, `go generate ./...`, and vulnerability checks.

### Kubernetes and YAML

`nvim/lua/config/kubernetes.lua` provides Kubernetes-aware YAML behavior:

- Defines broad file patterns for Kubernetes manifests under paths such as `k8s`, `kubernetes`, `deploy`, `deployment`, `manifests`, `base`, `overlays`, `clusters`, and `argocd`.
- Adds a Kubernetes schema association for those patterns.
- Adds a Helm Chart schema for `Chart.yaml`.
- Detects YAML buffers that contain both `apiVersion:` and `kind:`.
- Avoids treating Helm template files containing `{{` as plain Kubernetes manifests.
- Dynamically attaches the Kubernetes schema to individual YAML files that look like manifests.
- Generates a local CRD schema catalog from the current `kubectl` context.
- Adds an OpenShift-specific cache path for OpenShift CRDs.

User commands:

- `:KubeCrdSchemas` generates CRD schemas from the current cluster.
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
- Shell: `shfmt`
- YAML: `yamlfmt`
- Docker Compose YAML: `yamlfmt`
- Helm values YAML: `yamlfmt`
- JSON and JSONC: `prettier`
- Markdown: `prettier`

`golines` is configured with `--max-len=120`.

Mapping:

- `<leader>cl` formats the current file or visual selection.

### Treesitter

`nvim/lua/plugins/treesitter.lua` uses the `main` branch of `nvim-treesitter`.

Installed parsers:

- `bash`, `c`, `css`, `dockerfile`, `go`, `gomod`, `gosum`, `gowork`, `helm`, `html`, `javascript`, `json`, `lua`, `markdown`, `markdown_inline`, `python`, `query`, `regex`, `sql`, `tsx`, `typescript`, `vim`, `vimdoc`, `yaml`

Treesitter highlighting is enabled on filetype events for the supported languages. `jsonc` is registered to use the JSON parser.

### Fuzzy Finding

`nvim/lua/plugins/fzf.lua` configures `fzf-lua`.

Mappings:

- `<leader>ff` find files
- `<leader>fe` hierarchical file explorer picker
- `<leader>fg` live grep
- `<leader>fG` Git changed files
- `<leader>fb` buffers
- `<leader>fr` recent files
- `<leader>fc` config files
- `<leader>fw` grep word under cursor
- `<leader>fW` grep WORD under cursor
- `<leader>fh` help tags
- `<leader>fk` keymaps
- `<leader>f:` commands
- `<leader>fj` jump list
- `<leader>fm` marks
- `<leader>f;` command history
- `<leader>f/` search history
- `<leader>gc` Git commits
- `<leader>gb` Git branches
- `<leader>gC` Git commits for the current buffer
- `<leader>fd` document diagnostics
- `<leader>fD` workspace diagnostics
- `<leader>fq` quickfix list
- `<leader>fl` location list

File search uses `fd` where available and falls back to `rg --files`. Hidden files and symlinks are included, while noisy directories such as `.git`, `.vscode`, `node_modules`, `dist`, `build`, `target`, and `.idea` are excluded. `<leader>fe` is intentionally different from `<leader>ff`: it behaves like a hierarchy browser, showing one directory level at a time with `../`, directories first, file/directory previews, Enter to descend/open, `<C-o>` to go up, and `<C-r>` to refresh.

### File Explorers

`nvim/lua/plugins/file-explorers.lua` configures two complementary file explorers.

Neo-tree is used as a project tree:

- `<leader>E` toggles filesystem tree.
- `<leader>gE` toggles Git status tree.
- `<leader>bE` toggles buffers tree.
- Sources are filesystem, buffers, and Git status.
- The tree follows the current file.
- Hidden files are visible, but `.git`, `.idea`, and `.vscode` are hidden by name.
- Git status actions are mapped inside the Git status source.

Oil is used as an editable file manager:

- `<leader>e` opens the custom floating column-mode file manager.
- `-` opens Oil at the parent directory.
- Directory navigation opens additional floating columns up to a depth of 3.
- Selecting a file opens it in the original editor window and closes the Oil columns.
- `h`, left arrow, and backspace go back.
- `l`, right arrow, and enter open.
- `<C-v>`, `<C-s>`, and `<C-t>` open in vertical split, split, and tab.
- `q` and `<Esc>` close all Oil columns.
- `g.` toggles hidden files.
- Deletes go to trash.
- Oil uses LSP file methods for rename/move support.

### Git

Git support is split between gitsigns, fzf-lua, Neo-tree, and LazyGit.

`nvim/lua/plugins/gitsigns.lua`:

- Shows add/change/delete/untracked signs in the signcolumn.
- Follows file moves.
- Attaches to untracked files.
- Supports hunk navigation, staging, reset, preview, blame, diffs, deleted line toggles, and word diff toggles.

Mappings:

- `]h` next hunk
- `[h` previous hunk
- `<leader>ghp` preview hunk
- `<leader>ghs` stage hunk
- `<leader>ghr` reset hunk
- `<leader>ghu` undo staged hunk
- `<leader>ghb` blame line
- `<leader>ghB` full blame line
- `<leader>ghl` toggle inline blame
- `<leader>ghd` diff current file
- `<leader>ghD` diff current file against previous commit
- `<leader>ght` toggle deleted lines
- `<leader>ghw` toggle word diff

`nvim/lua/plugins/lazygit.lua`:

- `<leader>gg` opens LazyGit.
- `<leader>gG` opens LazyGit for the current file.

### Bufferline and Statusline

`nvim/lua/plugins/bufferline.lua` configures buffer tabs:

- `]b`, `[[` next buffer
- `[b`, `]]` previous buffer
- `<leader>bp` pick buffer
- `<leader>bX` close other buffers
- `<leader>bL` close buffers to the right
- `<leader>bH` close buffers to the left

Diagnostics are shown in the bufferline. Neo-tree gets a left offset labeled `Project`.

`nvim/lua/plugins/lueline.lua` configures the global statusline:

- Shows mode, branch, filename, diagnostics, active LSP clients, diff, filetype, progress, and location.
- Uses global statusline mode.
- Disables the statusline for Neo-tree and Oil windows.

### Mini Plugins

`nvim/lua/plugins/minis.lua` uses:

- `mini.ai` for better text objects.
- `mini.surround` for surround operations.
- `mini.pairs` for autopairs.
- `mini.icons` for icons and `nvim-web-devicons` compatibility.
- `mini.bufremove` for buffer deletion without breaking window layout.

Surround mappings:

- `sa` add
- `sd` delete
- `sf` find
- `sF` find left
- `sh` highlight
- `sr` replace
- `sn` update search line count

### Markdown

`nvim/lua/plugins/md-reader.lua` configures:

- `render-markdown.nvim` for rendered Markdown inside Neovim.
- `markdown-preview.nvim` for browser preview.

Mappings:

- `<leader>md` toggles rendered Markdown view.
- `<leader>mD` opens rendered preview in a side window.
- `<leader>me` toggles browser preview.

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
- `<leader>tq` next failed test
- `<leader>tQ` previous failed test
- `<leader>tw` watch current file
- `<leader>tx` stop tests

The Go adapter uses `gotestsum`. If `gotestsum` is missing, the plugin build step tries to install it with `go install gotest.tools/gotestsum@latest`.

### which-key

`nvim/lua/plugins/which-key.lua` documents the leader-key layout.

Top-level groups:

- `<leader>b` buffers
- `<leader>f` find
- `<leader>g` Git
- `<leader>c` code
- `<leader>cg` Go
- `<leader>t` tests
- `<leader>u` UI/toggles

The UI uses the modern preset, rounded borders, compact key labels, and a shorter delay for leader-triggered mappings.

## Snippets

Local snippets live in `nvim/snippets/`.

`package.json` registers snippets for:

- Go
- YAML
- Helm

`go.json` includes snippets for:

- `for` loops
- `if err != nil`
- wrapped errors
- HTTP handlers
- tests, subtests, table tests, benchmarks
- goroutines and `select`
- controller-runtime reconciliation helpers

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
directory git_branch git_status golang python docker_context helm cmd_duration
character
```

Enabled prompt modules:

- Directory, truncated to 3 segments and rooted at the repository when possible.
- Git branch.
- Git status with compact symbols for ahead, behind, modified, staged, deleted, untracked, and other states.
- Go indicator.
- Python version with pyenv version name support.
- Helm version.
- Command duration when a command takes at least 1500 ms.
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
- `Ctrl-Space 0` through `Ctrl-Space 9` select a window by index.
- `Ctrl-Space .` move the current window to another index.

Pane bindings:

- `Ctrl-Space =` split the current pane left/right in the current pane directory.
- `Ctrl-Space -` split the current pane top/bottom in the current pane directory.
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
