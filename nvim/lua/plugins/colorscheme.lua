-- VSCode Dark+ token colors, applied as fg-only overrides on top of
-- catppuccin. Background, UI chrome, statusline etc. stay catppuccin —
-- only code text changes. Toggle with <leader>uc.
local vscode_syntax_enabled = false

local function vscode_syntax_overrides()
	local c = {
		blue = "#569CD6", -- keywords, storage, builtins
		lightblue = "#9CDCFE", -- variables, parameters, properties
		teal = "#4EC9B0", -- types, classes, namespaces
		yellow = "#DCDCAA", -- functions, methods
		orange = "#CE9178", -- strings
		green = "#6A9955", -- comments
		palegreen = "#B5CEA8", -- numbers
		pink = "#C586C0", -- control flow, preprocessor
		constblue = "#4FC1FF", -- constants, enum members
		fg = "#D4D4D4", -- operators, punctuation
		escape = "#D7BA7D", -- string escapes
		regex = "#D16969", -- regex literals
		gray = "#808080", -- tag delimiters
	}

	return {
		-- Comments
		Comment = { fg = c.green, italic = true },
		["@comment"] = { fg = c.green, italic = true },

		-- Keywords: plain ones blue, control flow pink (VSCode's split)
		Keyword = { fg = c.blue },
		Statement = { fg = c.blue },
		["@keyword"] = { fg = c.blue },
		["@keyword.function"] = { fg = c.blue },
		["@keyword.operator"] = { fg = c.blue },
		Conditional = { fg = c.pink },
		Repeat = { fg = c.pink },
		Exception = { fg = c.pink },
		Include = { fg = c.pink },
		PreProc = { fg = c.pink },
		["@keyword.conditional"] = { fg = c.pink },
		["@keyword.repeat"] = { fg = c.pink },
		["@keyword.return"] = { fg = c.pink },
		["@keyword.exception"] = { fg = c.pink },
		["@keyword.import"] = { fg = c.pink },
		["@keyword.directive"] = { fg = c.pink },

		-- Strings
		String = { fg = c.orange },
		Character = { fg = c.orange },
		["@string"] = { fg = c.orange },
		SpecialChar = { fg = c.escape },
		["@string.escape"] = { fg = c.escape },
		["@string.regexp"] = { fg = c.regex },

		-- Numbers / booleans / constants
		Number = { fg = c.palegreen },
		Float = { fg = c.palegreen },
		["@number"] = { fg = c.palegreen },
		["@number.float"] = { fg = c.palegreen },
		Boolean = { fg = c.blue },
		["@boolean"] = { fg = c.blue },
		Constant = { fg = c.constblue },
		["@constant"] = { fg = c.constblue },
		["@constant.builtin"] = { fg = c.blue },

		-- Functions
		Function = { fg = c.yellow },
		["@function"] = { fg = c.yellow },
		["@function.call"] = { fg = c.yellow },
		["@function.method"] = { fg = c.yellow },
		["@function.method.call"] = { fg = c.yellow },
		["@function.builtin"] = { fg = c.yellow },
		["@function.macro"] = { fg = c.yellow },
		["@attribute"] = { fg = c.yellow },

		-- Types
		Type = { fg = c.teal },
		Structure = { fg = c.teal },
		["@type"] = { fg = c.teal },
		["@type.definition"] = { fg = c.teal },
		["@type.builtin"] = { fg = c.blue },
		["@constructor"] = { fg = c.teal },
		["@module"] = { fg = c.teal },

		-- Variables / identifiers
		Identifier = { fg = c.lightblue },
		["@variable"] = { fg = c.lightblue },
		["@variable.parameter"] = { fg = c.lightblue },
		["@variable.member"] = { fg = c.lightblue },
		["@property"] = { fg = c.lightblue },
		["@variable.builtin"] = { fg = c.blue },

		-- Operators / punctuation
		Operator = { fg = c.fg },
		Delimiter = { fg = c.fg },
		["@operator"] = { fg = c.fg },
		["@punctuation.delimiter"] = { fg = c.fg },
		["@punctuation.bracket"] = { fg = c.fg },
		["@punctuation.special"] = { fg = c.blue },

		-- Markup tags (HTML/JSX)
		["@tag"] = { fg = c.blue },
		["@tag.attribute"] = { fg = c.lightblue },
		["@tag.delimiter"] = { fg = c.gray },

		-- LSP semantic tokens, so they don't paint catppuccin colors back
		-- over the treesitter groups above
		["@lsp.type.class"] = { fg = c.teal },
		["@lsp.type.struct"] = { fg = c.teal },
		["@lsp.type.interface"] = { fg = c.teal },
		["@lsp.type.enum"] = { fg = c.teal },
		["@lsp.type.type"] = { fg = c.teal },
		["@lsp.type.namespace"] = { fg = c.teal },
		["@lsp.type.enumMember"] = { fg = c.constblue },
		["@lsp.type.function"] = { fg = c.yellow },
		["@lsp.type.method"] = { fg = c.yellow },
		["@lsp.type.macro"] = { fg = c.yellow },
		["@lsp.type.variable"] = { fg = c.lightblue },
		["@lsp.type.parameter"] = { fg = c.lightblue },
		["@lsp.type.property"] = { fg = c.lightblue },
		["@lsp.type.keyword"] = { fg = c.blue },
	}
end

local function set_vscode_syntax(state)
	vscode_syntax_enabled = state
	if state then
		for group, hl in pairs(vscode_syntax_overrides()) do
			vim.api.nvim_set_hl(0, group, hl)
		end
	else
		-- Reloading catppuccin restores all original highlights (including
		-- custom_highlights below).
		vim.cmd.colorscheme("catppuccin")
	end
end

return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavour = "mocha", -- latte, frappe, macchiato, mocha
			transparent_background = false,
			term_colors = true,
			dim_inactive = {
				enabled = false,
			},
			styles = {
				comments = { "italic" },
				conditionals = {},
				loops = {},
				functions = {},
				keywords = {},
				strings = {},
				variables = {},
				numbers = {},
				booleans = {},
				properties = {},
				types = {},
			},
			custom_highlights = function(colors)
				return {
					-- Thick, solid window separators (chars set via fillchars in options.lua)
					WinSeparator = { fg = colors.lavender, bg = "NONE", bold = true },
					-- indent-blankline guide: catppuccin defaults this to surface0,
					-- which is nearly invisible on the base bg. surface1 is the
					-- visible-but-subtle level (close to VSCode's indent guides).
					IblIndent = { fg = colors.surface1 },
					-- Active scope line (mini.indentscope) drawn over the static ibl
					-- guides: brighter + bold so the current block stands out a bit.
					MiniIndentscopeSymbol = { fg = colors.overlay1, bold = true },
				}
			end,
			integrations = {
				treesitter = true,
				native_lsp = {
					enabled = true,
				},
				which_key = true,
				gitsigns = true,
				mason = true,
				neotree = true,
				cmp = true,
				mini = true,
				noice = true,
				notify = true,
				indent_blankline = {
					enabled = true,
				},
			},
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin")

			-- Active buffer tab: keep catppuccin's bold + italic but strip the
			-- red underline it draws under the current label. Done as a full
			-- nvim_set_hl replace (not custom_highlights, whose deep-merge keeps
			-- the underline flag); re-applied on the <leader>uc colorscheme reload.
			local function fix_tabline_hl()
				local hl = vim.api.nvim_get_hl(0, { name = "MiniTablineCurrent", link = false })
				hl.underline = nil
				hl.undercurl = nil
				hl.sp = nil
				hl.bold = true
				hl.italic = true
				vim.api.nvim_set_hl(0, "MiniTablineCurrent", hl)
			end
			fix_tabline_hl()
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "catppuccin",
				callback = fix_tabline_hl,
				desc = "Strip the red underline from the active mini.tabline label",
			})

			vim.keymap.set("n", "<leader>uc", function()
				set_vscode_syntax(not vscode_syntax_enabled)
				vim.notify(
					vscode_syntax_enabled and "VSCode code colors enabled" or "VSCode code colors disabled",
					vim.log.levels.INFO,
					{
						title = "UI",
					}
				)
			end, {
				desc = "Toggle VSCode code colors",
			})
		end,
	},
}
