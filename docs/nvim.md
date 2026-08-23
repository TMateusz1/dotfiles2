# Neovim

This is the operating guide for the Neovim configuration in `nvim/`. Both
`<leader>` and `<localleader>` are `Space`; mappings below write that key as
`<leader>` so sequences remain easy to scan. Press `Space` and pause to open
WhichKey when a mapping is forgotten.

## Design

- Lazy.nvim manages plugins; mise owns Neovim and every external binary.
- fzf-lua owns interactive finding. Neo-tree is used only for file browsing.
- Bufferline represents open buffers.
- Catppuccin Mocha supplies the theme and Nerd Font icons; see
  [Colour](#colour) below.
- The native statusline shows mode, Git branch, diagnostics, root-relative file
  path, attached LSP clients, filetype, search count, macro recording, and
  cursor position.
- Formatting is automatic on save; linting runs separately after edits and
  saves. Both can be controlled explicitly.
- Sessions are saved per working directory. The last session is not restored
  blindly on startup, and Neo-tree is closed before saves and after restores.

The project root is resolved from the current file using project markers and
then the working directory. Starting `nvim` from the project root gives the
most predictable search, terminal, test, and session scope.

## Colour

`lua/config/catppuccin.lua` overrides only the groups that are deliberate
decisions; every group not listed there is the upstream flavour. Two rules hold
the scheme together:

**Colour names things, grey carries grammar.** Saturated hues are reserved for
tokens that name something, so scanning for a hue finds a category rather than
a syntax class.

| Colour | Hex | Role |
| --- | --- | --- |
| Yellow | `#f9e2af` | Declared types and constructors |
| Sapphire | `#74c7ec` | Packages and modules (see note below) |
| Blue | `#89b4fa` | Functions and methods |
| Mauve | `#cba6f7` | Keywords and builtin types (`int`, `string`) |
| Teal | `#94e2d5` | Struct fields and properties |
| Green | `#a6e3a1` | Strings |
| Peach | `#fab387` | Constants, numbers, booleans |
| Subtext1 | `#bac2de` | Operators |
| Overlay2 | `#9399b2` | Punctuation |
| Overlay1 | `#7f849c` | Comments |

In Go the `@module` capture covers the `package` declaration only. A package
qualifier inside an expression (`fmt` in `fmt.Sprintf`) is captured as
`@variable` and renders as body text, because gopls semantic tokens are
disabled in `lua/config/lsp.lua`. Enabling them routes it through
`@lsp.type.namespace`, which resolves to the same sapphire.

**Italic means "not code".** Comments are the only italic run on screen, so
slant alone works as a skip signal. `styles.miscs` is set to `{}` for this
reason; left unset, catppuccin italicises modules and tag attributes too.

Chrome sits below code in a deliberate contrast ladder, so nothing in the frame
outranks the text: indent guides `1.80:1`, window separators `2.46:1`, line
numbers `3.36:1`, comments `4.44:1`, code `7:1` and up. The focused window is
marked by the cursorline, not by an accent-coloured separator.

The terminal palette supplies the shared Catppuccin foundation outside Neovim.
Delta additionally declares explicit Mocha diff colours in
`git/delta.gitconfig`.

## Core editing and windows

| Key | Mode | Action |
| --- | --- | --- |
| `<Esc>` | Normal | Close floating windows, otherwise clear search highlight |
| `q:` | Normal | Disabled to prevent accidental command-history windows |
| `q/` / `q?` | Normal | Open forward/backward search history (native Vim) |
| `<C-d>` / `<C-u>` | Normal | Half-page down/up and center |
| `n` / `N` | Normal | Next/previous search result, open folds, and center |
| `<` / `>` | Visual | Indent and keep the selection |
| `J` / `K` | Visual | Move selected lines down/up |
| `<A-j>` / `<A-k>` | Normal or visual | Move line or selection down/up |
| `<leader>=` | Normal | Vertical split to the right |
| `<leader>-` | Normal | Horizontal split below |
| `<leader>k` | Normal | Close the window but keep its buffer |
| `<leader>Q` | Normal | Quit all, asking about unsaved files |
| `<C-h/j/k/l>` | Normal | Move across Neovim windows and tmux panes |
| `<C-Arrow>` | Normal | Arrow-key alternative for the same pane movement |

Temporary help, man, quickfix, and Neotest windows close with `q` or `<Esc>`.
Ordinary `q` remains available for recording macros; only `q:` is disabled.

## Files and buffers

| Key | Action |
| --- | --- |
| `<leader>w` | Save the current file |
| `<leader>W` | Save and close the current buffer |
| `<leader>q` | Smart-close the current buffer, float, special window, or Grug Far |
| `<leader>x` | Delete the current buffer while preserving the editing window |
| `<leader>X` | Delete every other closable buffer |
| `<leader>bn` | Create a new empty buffer |
| `<leader><leader>` / `<leader>fb` | Find open buffers |
| `]b` / `[b` | Next/previous buffer |
| `<leader>b0` | Alternate buffer |
| `<leader>b,` / `<leader>b.` | Move the current buffer left/right in Bufferline |
| `<leader>1`-`<leader>9` | Open that absolute Bufferline ordinal |
| `<leader>0` | Open the final buffer in the full Bufferline list |

Smart close deliberately creates a temporary empty editing buffer when the
last real buffer is closed. This keeps Neo-tree from expanding across the
entire screen. The placeholder disappears automatically when a real buffer is
opened. Bufferline also reserves an offset above Neo-tree, so tabs never draw
over the explorer.

## Sessions

AutoSession restores the session belonging to the current working directory
when Neovim starts without file arguments (or with one directory argument), and
saves it again on exit. It does not restore an unrelated "last used" session.
Sessions are suppressed for the home directory, Downloads, and `/`. Starting
with explicit file arguments does not opt those files into automatic session
saves.

| Command | Action |
| --- | --- |
| `:AutoSession save` | Save the current working-directory session now |
| `:AutoSession restore` | Restore the current working-directory session |
| `:AutoSession search` | Find and restore a saved session |
| `:AutoSession delete` | Delete the current working-directory session |
| `:AutoSession toggle` | Toggle automatic session saving |

## Finding and navigation

All pickers below use fzf-lua and include a preview when the result supports
one.

| Key | Action |
| --- | --- |
| `<leader>ff` | Find files, including hidden files |
| `<leader>fg` | Live grep project text |
| `<leader>/` | Search lines in the current buffer |
| `<leader>fG` | Find Git-changed files |
| `<leader>fb` | Find open buffers |
| `<leader>fs` | Document symbols |
| `<leader>fS` | Live workspace/global symbols |
| `<leader>fd` / `<leader>fD` | Document/workspace diagnostics |
| `<leader>fq` | Browse the quickfix list |
| `<leader>fc` | Browse Ex commands |
| `<leader>fo` | Find TODO/FIXME/BUG comments |
| `<leader>fr` | Project-wide find and replace with Grug Far |
| `<leader>cs` | Toggle the persistent symbols outline on the right |
| `]f` / `[f` | Next/previous function start |
| `]q` / `[q` | Next/previous quickfix item, wrapping at the ends |
| `<leader>uq` | Toggle the quickfix window |
| `]o` / `[o` | Next/previous TODO comment |

## Neo-tree explorer

Neo-tree opens on the left with Git state and file icons. It does not follow
buffer changes automatically, so moving among buffers does not steal explorer
focus or expand directories.

| Key | Context | Action |
| --- | --- | --- |
| `<leader>e` | Anywhere | Open explorer at the project root and reveal the current file |
| `<leader>E` | Anywhere | Open with every directory collapsed and the root focused |
| `=` | Neo-tree | Collapse the focused directory, or a focused file's parent |
| `+` (`Shift-=`) | Neo-tree | Collapse the whole tree and focus its root |
| `<S-CR>` | Neo-tree | Open the focused file and close Neo-tree |
| `<CR>` | Neo-tree | Open or expand using Neo-tree's standard action |
| `q` | Neo-tree | Close Neo-tree |

The remaining create, rename, delete, copy, filter, and help keys are Neo-tree
defaults; press `?` inside the explorer for its current contextual list.

## LSP and diagnostics

Neovim enables an LSP only when its executable is available on `PATH`. Missing
servers produce one combined notification. Mise supplies the global servers;
Python and Robot Framework projects supply their Python-based commands through
their active virtual environment.

| Server | Executable |
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

LSP mappings are buffer-local and appear after a server attaches:

| Key | Mode | Action |
| --- | --- | --- |
| `gd` | Normal | Definitions through fzf-lua |
| `gD` | Normal | Declarations through fzf-lua |
| `gr` | Normal | References through fzf-lua |
| `gi` | Normal | Implementations through fzf-lua |
| `gy` | Normal | Type definitions through fzf-lua |
| `K` | Normal | Hover documentation |
| `<leader>cI` | Normal | Incoming calls through fzf-lua |
| `<leader>ca` | Normal or visual | Code actions through fzf-lua |
| `<leader>cn` | Normal | Rename symbol |
| `<leader>cx` | Normal | Diagnostics for the current line |
| `<leader>cq` | Normal | Put diagnostics in quickfix |
| `<leader>uh` | Normal | Toggle inlay hints when supported |

Visual `<leader>ca` is the general refactoring entry point. Select an expression
or block and use the server's available actions for operations such as extract
variable or extract method; availability depends on that language server.

Diagnostics navigation is global, so it also covers nvim-lint diagnostics:

| Key | Action |
| --- | --- |
| `]d` / `[d` | Next/previous diagnostic, centered with a detail float |
| `<leader>uv` | Toggle multi-line diagnostics for the cursor line |

Message controls are global:

| Key | Action |
| --- | --- |
| `<leader>fm` | Browse the message history |
| `<leader>un` | Dismiss visible notifications |

Fidget displays asynchronous LSP progress when a server reports it. Quiet
servers such as YAML or Docker may attach and work without ever showing a
progress message; use `:LspInfo` to check attachment.

Robot Framework uses RobotCode for `.robot` and `.resource`. Start Neovim from
the project environment (for example with its `.venv` active) so RobotCode sees
the same libraries as the test runner. It reads `robot.toml` or
`pyproject.toml` when present.

The project environment also supplies `ruff` and `robocop` when their LSP,
formatting, or linting integrations are needed. Mise supplies `yamllint`
globally.

## Completion and snippets

Blink provides LSP, path, snippet, and buffer completion. Its menu is automatic
in ordinary editing buffers. In Grug Far it is manual to avoid suggestions
opening while search text is entered. Signature help opens automatically after
function-call trigger characters such as `(`.

| Key | Action while completing |
| --- | --- |
| `<C-Space>` | Open completion and documentation manually |
| `<CR>` | Accept the visible item, otherwise advance a snippet placeholder or insert a newline |
| `<Tab>` | Next snippet placeholder, or accept the visible item |
| `<S-Tab>` | Previous snippet placeholder or completion item |
| `<C-j>` / `<C-n>` | Select next item |
| `<C-p>` | Select previous item |
| `<C-k>` | Show or hide signature help |
| `<C-d>` / `<C-u>` | Scroll completion documentation |
| `<C-e>` | Cancel completion |
| `<Esc>` | Hide completion, then behave normally |
| `<S-CR>` | End an active snippet and insert a normal newline |

Go buffers combine friendly-snippets' general Go set with the specialized local
snippets. Generic YAML receives the local Kubernetes set, Helm templates receive
both Kubernetes and Helm snippets, and Docker Compose snippets are restricted to
the `yaml.docker-compose` filetype. Helm values files intentionally use only the
global snippets plus schema-aware LSP completion.

## Project-wide replace

`<leader>fr` opens Grug Far. In visual mode it seeds the search with the
selection. Completion is off by default in this buffer; press `<C-Space>` when
path or text completion is useful.

After pressing `<Esc>` to enter normal mode, the most useful Grug Far keys are:

| Key | Action |
| --- | --- |
| `<Tab>` / `<S-Tab>` | Move to the next/previous input field |
| `j` / `k` | Move through result lines |
| `<CR>` | Open the selected location |
| `<leader>r` | Replace all matches |
| `<leader>s` | Synchronize all result locations after manual edits |
| `<leader>l` | Synchronize the current result line |
| `<leader>f` | Refresh results |
| `<leader>t` | Open replacement history |
| `<leader>i` | Preview the selected location |
| `<leader>b` | Abort the running search or replacement |
| `g?` | Show the full Grug Far help |
| `<leader>q` | Close Grug Far safely |

Grug Far's default quickfix mapping is intentionally disabled because local
leader is also `Space` and `<leader>q` is reserved for smart close.

## Formatting and linting

Conform owns formatting:

| Filetype | Formatter |
| --- | --- |
| Go | `goimports`, then `gofumpt` |
| Lua | `stylua` |
| Shell | `shfmt -i 4 -ci` |
| Helm templates | Normalize Go-template delimiter spacing |
| YAML | `yamlfmt` |
| JSON/JSONC | `prettier` |
| Markdown | `prettier` |
| Python | `ruff format` |
| Robot Framework | `robocop format` |

| Key or command | Action |
| --- | --- |
| `<leader>cl` | Format the current file or visual selection |
| `<leader>uf` | Toggle format-on-save |
| `:FormatDisable` | Disable format-on-save globally |
| `:FormatDisable!` | Disable it for the current buffer |
| `:FormatEnable` | Re-enable format-on-save |

nvim-lint runs `yamllint` for YAML, Compose, and Helm values; `hadolint` for
Dockerfiles; and `robocop` for Robot Framework. Shell diagnostics come from
`bash-language-server` when `shellcheck` is available.

## Structural editing and undo

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>s` | Normal | Toggle the syntax node between split and joined forms |
| `<leader>U` | Normal | Toggle Undotree's persistent undo-history view |
| `sa{motion}{char}` | Normal | Add surrounding characters around a text object or motion |
| `sa` | Visual | Add surrounding characters to the selection |
| `sd{char}` | Normal | Delete a surrounding pair |
| `sr{old}{new}` | Normal | Replace a surrounding pair |
| `sf` / `sF` | Normal | Find the next/previous surrounding pair |
| `sh` | Normal | Highlight a surrounding pair |
| `sn` | Normal | Change how many lines MiniSurround searches |

MiniAI adds semantic text objects usable with standard operators and visual
selection: `af`/`if` for a function, `aF`/`iF` for a function call,
`ao`/`io` for a block/conditional/loop, and `ac`/`ic` for a class or Go type
declaration.

## Git

| Key | Mode | Action |
| --- | --- | --- |
| `]h` / `[h` | Normal | Next/previous staged or unstaged hunk |
| `<leader>ghp` | Normal | Preview hunk |
| `<leader>ghs` | Normal or visual | Stage/unstage hunk or selected lines |
| `<leader>ghu` | Normal | Undo stage by toggling the hunk |
| `<leader>ghr` | Normal or visual | Reset hunk or selected lines |
| `<leader>ghb` / `<leader>ghB` | Normal | Brief/full blame for the line |
| `<leader>ghl` | Normal | Toggle inline current-line blame |
| `<leader>ghd` | Normal | Diff the current file |
| `<leader>ghD` | Normal | Diff the file against the previous commit |
| `<leader>ght` | Normal | Toggle deleted-line display |
| `<leader>ghw` | Normal | Toggle word diff |
| `<leader>fG` | Normal | Find Git-changed files |
| `<leader>gg` | Normal | Open LazyGit in a project-root floating terminal |

Press `q` in a Gitsigns diff window to close the diff and return to its source.

## Terminals

| Key | Action |
| --- | --- |
| `<leader>` then backtick | Toggle a horizontal terminal at the project root |
| `<leader>Tf` | Toggle a floating terminal at the project root |
| `<leader>gg` | Toggle floating LazyGit at the project root |
| `<Esc><Esc>` | Leave terminal mode; one `<Esc>` still reaches the program |

## Go

Go helpers are attached when `gopls` is active:

| Key | Action |
| --- | --- |
| `<leader>cgl` | Run `golangci-lint run ./...` |
| `<leader>cgo` | Organize imports |
| `<leader>cgd` | Open `go doc` in a float |
| `<leader>cgj` / `<leader>cgJ` | Add/remove JSON struct tags |
| `<leader>cgy` / `<leader>cgY` | Add/remove YAML struct tags |
| `<leader>cge` / `<leader>cgE` | Add/remove env struct tags |
| `<leader>cgi` | Select an interface and implement it with `gopls` |
| `<leader>cgs` | Fill a struct literal |

## Helm and Kubernetes YAML

In `helm` and `yaml.helm-values` buffers:

| Key | Action |
| --- | --- |
| `gd` | Find the `.Values` definition, falling back to LSP definition |
| `<leader>hv` | Pick a key from the chart's `values*.yaml` files |
| `<leader>hgv` | Go to the value under the cursor |

Kubernetes schemas and generated CRD schemas are managed by
`lua/config/kubernetes.lua`. Fetching is manual, so opening YAML never hides a
`kubectl` call:

| Key or command | Action |
| --- | --- |
| `<leader>ckf` / `:KubeCrdSchemas` | Fetch CRD schemas from the current context |
| `<leader>ckp` / `:KubeCrdSchemasPath` | Show the schema cache path |

A successful fetch writes the cache and restarts `yamlls`.

## Go tests

Neotest uses `neotest-golang` and mise's `gotestsum`. Runs use Neotest's
integrated terminal strategy.

| Key | Action |
| --- | --- |
| `<leader>tf` | Run the test at the cursor |
| `<leader>tF` | Run the current file |
| `<leader>tp` | Run the current package |
| `<leader>tP` | Run the entire Go project |
| `<leader>tr` | Rerun the last test |
| `<leader>ts` | Toggle test summary |
| `<leader>to` | Open output for the current test |
| `<leader>tO` | Toggle the output panel |
| `<leader>tq` | Open failed tests in quickfix |
| `<leader>tw` | Toggle watch mode for the current file |
| `<leader>tx` | Stop the active run |

## Maintenance and health

Useful commands:

```vim
:Lazy
:LspInfo
:ConformInfo
:checkhealth lazy
:checkhealth vim.lsp
:checkhealth nvim-treesitter
```

Run the repository-wide validation after configuration or plugin changes:

```bash
./check.sh
```

Plugin declarations live in `nvim/lua/plugins/`; custom behavior belongs in
`nvim/lua/config/`. Neo-tree is the sole configured file explorer.
