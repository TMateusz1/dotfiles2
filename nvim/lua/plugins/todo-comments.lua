return {
	{
		"folke/todo-comments.nvim",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			{
				"]o",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Next TODO comment",
			},
			{
				"[o",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "Previous TODO comment",
			},
			{
				"<leader>fo",
				"<cmd>TodoFzfLua<CR>",
				desc = "Find TODO comments",
			},
		},
		opts = {},
	},
}
