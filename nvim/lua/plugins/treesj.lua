return {
	{
		"Wansmer/treesj",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		keys = {
			{
				"<leader>s",
				function()
					require("treesj").toggle()
				end,
				desc = "Toggle split/join",
			},
		},
		opts = {
			use_default_keymaps = false,
			check_syntax_error = true,
			max_join_length = 120,
		},
	},
}
