local M = {}

function M.setup()
	require("catppuccin").setup({
		flavour = "mocha",
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
				WinSeparator = { fg = colors.lavender, bg = "NONE", bold = true },
				NormalFloat = { fg = colors.text, bg = colors.mantle },
				FloatBorder = { fg = colors.blue, bg = colors.mantle },
				FloatTitle = { fg = colors.blue, bg = colors.mantle, bold = true },
				PmenuSel = { fg = colors.crust, bg = colors.blue },
				Search = { fg = colors.crust, bg = colors.yellow },
				IncSearch = { fg = colors.crust, bg = colors.peach },
				CurSearch = { fg = colors.crust, bg = colors.peach },
				SnippetTabstop = { bg = "NONE", fg = "NONE" },

				User1 = { fg = colors.crust, bg = colors.blue, bold = true },
				User2 = { fg = colors.text, bg = colors.surface0 },
				User3 = { fg = colors.text, bg = "NONE" },
				TabLine = { fg = colors.subtext0, bg = colors.base },
				TabLineSel = { fg = colors.text, bg = colors.surface0, bold = true },
				TabLineFill = { fg = colors.overlay0, bg = colors.base },

				FzfLuaNormal = { fg = colors.text, bg = colors.base },
				FzfLuaBorder = { fg = colors.blue, bg = colors.base },
				FzfLuaTitle = { fg = colors.blue, bg = colors.base, bold = true },
				FzfLuaPreviewNormal = { fg = colors.text, bg = colors.base },
				FzfLuaPreviewBorder = { fg = colors.blue, bg = colors.base },
				FzfLuaPreviewTitle = { fg = colors.blue, bg = colors.base, bold = true },
				FzfLuaCursorLine = { bg = colors.surface0 },
				FzfLuaSearch = { fg = colors.crust, bg = colors.yellow },
				FzfLuaDirPart = { fg = colors.overlay0 },
				FzfLuaFilePart = { fg = colors.text },

				IblIndent = { fg = colors.surface1 },
				IblScope = { fg = colors.mauve, bold = true },

				WhichKey = { fg = colors.blue },
				WhichKeyGroup = { fg = colors.teal },
				WhichKeyDesc = { fg = colors.text },
				WhichKeySeparator = { fg = colors.overlay0 },
				WhichKeyValue = { fg = colors.overlay0 },
			}
		end,
		integrations = {
			blink_cmp = true,
			gitsigns = true,
			mini = true,
			native_lsp = {
				enabled = true,
			},
			treesitter = true,
			which_key = true,
		},
	})

	vim.cmd.colorscheme("catppuccin")

end

return M
