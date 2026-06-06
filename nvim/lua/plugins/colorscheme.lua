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
				cmp = true,
				mini = true,
			},
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin")
		end,
	},
}
