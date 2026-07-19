return {
	{
		"MagicDuck/grug-far.nvim",
		cmd = "GrugFar",
		keys = {
			{
				"<leader>fr",
				"<cmd>GrugFar<CR>",
				desc = "Find and replace",
			},
			{
				"<leader>fr",
				":GrugFar<CR>",
				mode = "x",
				desc = "Find and replace selection",
			},
		},
		opts = {
			keymaps = {
				-- <localleader> is also Space, so the default quickfix mapping
				-- would shadow the global <leader>q smart-close mapping.
				qflist = false,
			},
		},
	},
}
