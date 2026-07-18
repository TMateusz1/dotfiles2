return {
	{
		"Wansmer/treesj",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		keys = {
			{
				"<leader>jt",
				function()
					require("treesj").toggle()
				end,
				desc = "Toggle split/join",
			},
			{
				"<leader>js",
				function()
					require("treesj").split()
				end,
				desc = "Split syntax node",
			},
			{
				"<leader>jj",
				function()
					require("treesj").join()
				end,
				desc = "Join syntax node",
			},
		},
		opts = {
			use_default_keymaps = false,
			check_syntax_error = true,
			max_join_length = 120,
		},
	},
}
