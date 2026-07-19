return {
	{
		"j-hui/fidget.nvim",
		event = "VeryLazy",
		opts = {
			notification = {
				-- Use Fidget only for LSP progress; preserve the built-in
				-- notification behavior used throughout this config.
				override_vim_notify = false,
			},
		},
	},
}
