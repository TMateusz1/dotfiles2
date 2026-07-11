-- ~/.config/nvim/lua/config/options.lua

local opt = vim.opt

-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Mouse
opt.mouse = "a"

-- Disable netrw; file exploration is handled by mini.files.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Clipboard
-- On macOS this uses the system clipboard provider.
opt.clipboard = "unnamedplus"

-- Tabs and indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true
opt.breakindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Live preview for :substitute (and :normal etc.), including a split window
-- showing off-screen matches.
opt.inccommand = "split"

-- UI
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.mousescroll = "ver:1,hor:2"
opt.pumheight = 14
opt.showmode = false
opt.ruler = false
opt.laststatus = 3
opt.splitkeep = "screen"

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Quickfix: reuse an open window for the target buffer, otherwise the last window
opt.switchbuf = "useopen,uselast"

-- Prompt to save instead of failing :q / :e on unsaved changes
opt.confirm = true

-- Allow the cursor past line ends in visual block mode (clean column edits)
opt.virtualedit = "block"

-- Jumplist behaves like a stack: jumping after <C-o> discards the forward list
opt.jumpoptions = "stack"

-- Show the current file in the terminal / tmux window title
opt.title = true

-- Session restore: keep buffers, tabs, splits, window sizes, cwd, folds, and
-- buffer-local options such as filetype.
opt.sessionoptions = {
	"blank",
	"buffers",
	"curdir",
	"folds",
	"help",
	"tabpages",
	"winsize",
	"winpos",
	"terminal",
	"localoptions",
	"globals",
}

-- Files
opt.swapfile = false
opt.backup = false
opt.undofile = true

-- Performance
opt.updatetime = 250
opt.timeoutlen = 400

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }

-- Better diff
opt.diffopt:append("linematch:60")

-- Invisible characters. Render tabs as blank so indentation is marked only by
-- indent guides (no overlapping "»" glyph); still flag trailing whitespace and
-- non-breaking spaces.
opt.list = true
opt.listchars = {
	tab = "  ",
	trail = "·",
	nbsp = "␣",
}

-- Keep command line clean unless needed
opt.cmdheight = 1

-- Disable intro screen
opt.shortmess:append("I")

opt.winborder = "rounded"

require("config.clipboard").setup()

-- Heavy box-drawing chars for thick, solid window separators.
-- Color is set via WinSeparator in plugins/colorscheme.lua so it survives
-- the colorscheme load (which would otherwise reset the highlight).
vim.opt.fillchars = {
	vert = "┃",
	horiz = "━",
	horizup = "┻",
	horizdown = "┳",
	vertleft = "┫",
	vertright = "┣",
	verthoriz = "╋",
}
