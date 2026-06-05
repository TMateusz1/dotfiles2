return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		lazygit = {
			enabled = true,
		},
		explorer = {
			enabled = true,

			-- Same philosophy as your previous mini.files setup:
			-- do not replace netrw automatically.
			replace_netrw = false,
			trash = true,
		},

		-- Snacks explorer is picker-backed.
		picker = {
			enabled = true,
		},
		notifier = {
			enabled = true,
			timeout = 3000,
			style = "fancy", -- "compact" | "minimal" | "fancy"
			width = { min = 40, max = 0.4 },
			height = { min = 1, max = 0.6 },
			margin = { top = 0, right = 1, bottom = 0 },
			padding = true,
			sort = { "level", "added" },
			icons = {
				error = " ",
				warn = " ",
				info = " ",
				debug = " ",
				trace = " ",
			},
		},
	},
	keys = {
		{
			"<leader>e",
			function()
				Snacks.explorer.reveal()
			end,
			desc = "Snacks explorer",
		},
		{
			"<leader>se",
			function()
				Snacks.explorer()
			end,
			desc = "Snacks explorer cwd",
		},
		{
			"<leader>gg",
			function()
				Snacks.lazygit()
			end,
			desc = "LazyGit",
		},
		{
			"<leader>gG",
			function()
				Snacks.lazygit.log_file()
			end,
			desc = "LazyGit current file",
		},
	},
}
