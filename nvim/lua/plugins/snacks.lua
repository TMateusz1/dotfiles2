return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		lazygit = {
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
