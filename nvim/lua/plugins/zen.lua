return {
	{
		"folke/twilight.nvim",
		cmd = { "Twilight", "TwilightEnable", "TwilightDisable" },
		opts = {
			dimming = {
				alpha = 0.25,
			},
			context = 0,
			treesitter = true,
		},
		keys = {
			{ "<leader>ud", "<cmd>Twilight<CR>", desc = "Toggle dim (twilight)" },
		},
	},

	{
		"folke/zen-mode.nvim",
		cmd = "ZenMode",
		opts = {
			window = {
				width = 0.75,
			},
			plugins = {
				twilight = { enabled = false },
				gitsigns = { enabled = false },
				tmux = { enabled = false },
			},
		},
		keys = {
			{ "<leader>uz", "<cmd>ZenMode<CR>", desc = "Toggle zen mode" },
		},
	},
}
