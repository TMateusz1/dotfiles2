return {
	{
		"folke/snacks.nvim",
		event = "VeryLazy",
		opts = {
			-- Only the input module: a floating, bordered replacement for
			-- vim.ui.input() (rename, :FormatDisable prompts, etc.) that matches
			-- the rest of the UI instead of the plain cmdline prompt.
			input = {
				enabled = true,
				win = {
					border = "rounded",
				},
			},
		},
	},
}
