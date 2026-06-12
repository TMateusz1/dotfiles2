return {
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		opts = {},
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Problems panel (workspace)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Problems panel (buffer)",
			},
			{
				"<leader>xs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols outline",
			},
			{
				"<leader>xt",
				"<cmd>Trouble todo toggle<cr>",
				desc = "Todo comments (Trouble)",
			},
		},
	},
}
