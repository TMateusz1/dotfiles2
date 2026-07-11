return {
	{
		"stevearc/aerial.nvim",
		cmd = {
			"AerialClose",
			"AerialGo",
			"AerialNavClose",
			"AerialNavOpen",
			"AerialNavToggle",
			"AerialOpen",
			"AerialOpenAll",
			"AerialToggle",
		},
		keys = {
			{
				"<leader>cs",
				"<cmd>AerialToggle! right<CR>",
				desc = "Symbols outline",
			},
		},
		opts = {
			backends = {
				"lsp",
				"treesitter",
				"markdown",
				"man",
			},
			filter_kind = false,
			layout = {
				default_direction = "right",
				min_width = 28,
				width = 36,
			},
			show_guides = true,
			attach_mode = "window",
		},
	},
}
