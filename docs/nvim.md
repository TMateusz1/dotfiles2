# Neovim

## Structure

```text
nvim/
├── init.lua
├── lua/config/
├── lua/plugins/
└── snippets/
```

`init.lua` loads core modules, then Lazy. Plugin specs stay thin; custom behavior goes in `lua/config/`.

## Theme

Neovim uses Catppuccin Mocha through `catppuccin/nvim`. Local highlights are limited to the native statusline and UI details not covered by the theme integrations.

## LSP

LSP setup is split in two places:

- `nvim/lua/plugins/lsp.lua`: plugin declarations only.
- `nvim/lua/config/lsp.lua`: LSP server settings, diagnostics, and LSP keymaps.

All LSP binaries come from mise. Neovim checks PATH and enables available servers:

| Server | Binary |
| --- | --- |
| `gopls` | `gopls` |
| `lua_ls` | `lua-language-server` |
| `dockerls` | `docker-langserver` |
| `docker_compose_language_service` | `docker-compose-langserver` |
| `yamlls` | `yaml-language-server` |
| `helm_ls` | `helm_ls` or `helm-ls` |
| `jsonls` | `vscode-json-language-server` |
| `bashls` | `bash-language-server` |
| `basedpyright` | `basedpyright-langserver` |
| `ruff` | `ruff` |
| `robotcode` | `robotcode` |

Missing LSP tools are reported once with a single notification.

Buffer-local mappings are set on `LspAttach`. Location pickers (`gd`, `gD`,
`gr`, `gi`, `gy`) and `<leader>ca` are listed in the Navigation UI table; the
remaining actions:

| Key | Action |
| --- | --- |
| `K` | Hover documentation |
| `<leader>cn` | Rename symbol |
| `<leader>cI` | Incoming calls |
| `<leader>cx` | Line diagnostics float |
| `<leader>cq` | Send diagnostics to the quickfix list |
| `<leader>uh` | Toggle inlay hints (when the server supports them) |

Diagnostics navigation is global (also covering nvim-lint buffers without an
LSP client): `]d` / `[d` jump to the next/previous diagnostic, and `<leader>uv`
toggles rich virtual-line diagnostics on the cursor line.

Robot Framework support uses RobotCode for `.robot` and `.resource` files. For real projects, run Neovim from the project environment, for example after activating `.venv` or through `mise activate`, so RobotCode can import the same Python libraries your tests use. RobotCode also reads project config from `robot.toml` or `pyproject.toml`.

## Navigation UI

Interactive navigation uses `fzf-lua`, Neo-tree, `bufferline.nvim`, and `toggleterm.nvim`.

| Key | Action |
| --- | --- |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>/` | Search current buffer lines |
| `<leader>fG` | Git changed files |
| `<leader>fb` | Find buffers |
| `<leader>fs` / `<leader>fS` | Document/live workspace symbols |
| `<leader>cs` | Persistent symbols outline on the right |
| `<leader>fd` / `<leader>fD` | Document/workspace diagnostics |
| `<leader>fq` | Quickfix list |
| `<leader>fc` | Commands |
| `<leader>fo` | Find TODO/FIXME/BUG comments with fzf-lua |
| `<leader>fp` | Harpoon marks with line and file preview |
| `gd`, `gD`, `gr`, `gi`, `gy` | LSP locations through fzf-lua |
| `<leader>ca` | LSP code actions through fzf-lua |
| `<leader>e` | Open Neo-tree on the left, focused on the current file |
| `<leader>E` | Open Neo-tree on the left with the project root collapsed and focused |
| `=` (in Neo-tree) | Collapse the focused directory, or the parent of a focused file |
| `+` (in Neo-tree) | Collapse all directories and focus the root |
| `<S-CR>` (in Neo-tree) | Open the focused file and close Neo-tree |
| `<leader>1`-`<leader>9` / `<leader>0` | Jump to visible bufferline slots / last visible buffer |
| `<leader>q` | Delete the current buffer while preserving the editing window |
| `<leader>bn` / `<leader>bx` / `<leader>bX` | New buffer / close buffer / close other buffers |
| `<leader>b,` / `<leader>b.` | Move current buffer left/right |
| `<leader>gg` | LazyGit in a floating terminal |
| `[o` / `]o` | Previous/next TODO comment |
| `<leader>U` | Toggle visual undo history |
| `<leader>s` | Toggle the syntax node between joined and split forms |

Harpoon marks are persistent per project and keep their file, line, column, and
source text. They can include multiple locations in the same file. If edits
move a marked line, Harpoon relocates it to the nearest matching line.

| Key | Action |
| --- | --- |
| `<leader>pp` | Add the current file and line |
| `<leader>P` | Inspect, reorder, or delete marks in a floating window |
| `<leader>p1`-`<leader>p5` | Open mark 1-5 |
| `<leader>fp` | Find all project marks with preview |

## Formatting

`conform.nvim` owns formatting.

| Filetype | Formatter |
| --- | --- |
| Go | `goimports`, `gofumpt` |
| Lua | `stylua` |
| Shell | `shfmt -i 4 -ci` |
| Helm templates | normalize Go-template delimiter spacing |
| YAML | `yamlfmt` |
| JSON/JSONC | `prettier` |
| Markdown | `prettier` |
| Python | `ruff format` |
| Robot Framework | `robocop format` |

Controls:

- `<leader>cl`: format current file or selection.
- `<leader>uf`: toggle format-on-save.
- `:FormatDisable`: disable format-on-save globally.
- `:FormatDisable!`: disable format-on-save for the current buffer.
- `:FormatEnable`: re-enable format-on-save.

## Linting

`nvim-lint` runs standalone linters:

- `yamllint` for YAML, Docker Compose YAML, and Helm values YAML.
- `hadolint` for Dockerfiles.
- `robocop` for Robot Framework.

Shell diagnostics come from `bash-language-server` when `shellcheck` is available.

## Go

Go helpers remain in `nvim/lua/config/go.lua`.

Common Go mappings are active when `gopls` attaches:

| Key | Action |
| --- | --- |
| `<leader>cgl` | Run `golangci-lint run ./...` |
| `<leader>cgo` | Organize imports |
| `<leader>cgd` | Open Go docs |
| `<leader>cgj` / `<leader>cgJ` | Add/remove JSON struct tags |
| `<leader>cgy` / `<leader>cgY` | Add/remove YAML struct tags |
| `<leader>cge` / `<leader>cgE` | Add/remove env struct tags |
| `<leader>cgi` | Implement selected interface with `gopls` |
| `<leader>cgs` | Fill struct literal |

## Helm and YAML

Helm uses `helm_ls` and custom helpers in `nvim/lua/config/helm.lua`. In `helm`
and `yaml.helm-values` buffers these mappings are attached:

| Key | Action |
| --- | --- |
| `gd` | Jump to the `.Values` definition under the cursor, falling back to LSP definition |
| `<leader>hv` | Pick a value from the chart's `values*.yaml` files |
| `<leader>hgv` | Go to the value under the cursor |

Kubernetes schemas and CRD schema generation live in `nvim/lua/config/kubernetes.lua`.
CRD schema fetching is manual to avoid hidden `kubectl` calls when opening YAML files. A successful fetch writes the schema cache and restarts `yamlls`.

Useful commands:

```vim
:KubeCrdSchemas
:KubeCrdSchemasPath
```

Useful mappings:

| Key | Action |
| --- | --- |
| `<leader>ckf` | Fetch CRD schemas from the current kubectl context |
| `<leader>ckp` | Show CRD schema cache path |

## Tests

Go tests use `neotest-golang` and the `gotestsum` binary from mise.

## Health

```vim
:checkhealth lazy
:checkhealth vim.lsp
:checkhealth nvim-treesitter
```

From the repository root, run `./check.sh` for all static and headless checks.
