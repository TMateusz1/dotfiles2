return {
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = {
			"BufReadPost",
			"BufNewFile",
		},
		opts = {
			indent = {
				char = "│",
				tab_char = "│",
				highlight = "IblIndent",
			},
			scope = {
				enabled = true,
				char = "┃",
				highlight = "IblScope",
				show_end = false,
				show_start = false,
			},
			exclude = {
				buftypes = {
					"nofile",
					"prompt",
					"quickfix",
					"terminal",
				},
				filetypes = {
					"fzf",
					"help",
					"lazy",
					"man",
					"minifiles",
					"neotest-output",
					"neotest-output-panel",
					"neotest-summary",
					"qf",
				},
			},
		},
	},
}
