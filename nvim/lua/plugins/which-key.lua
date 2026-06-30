-- ~/.config/nvim/lua/plugins/which-key.lua

return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "modern",

			delay = function(ctx)
				-- Show faster after leader, slower for other mappings
				return ctx.plugin and 0 or 300
			end,

			icons = {
				mappings = true,
				keys = {
					Space = "SPC",
					CR = "RET",
					Esc = "ESC",
				},
			},

			win = {
				border = "rounded",
				padding = { 1, 2 },
			},

			layout = {
				width = { min = 20 },
				spacing = 3,
			},

			spec = {
				{ "<leader>b", group = "Buffers" },
				{ "<leader>f", group = "Find" },
				{ "<leader>g", group = "Git" },
				{ "<leader>gh", group = "Git Hunks" },
				{ "<leader>c", group = "Code" },
				{ "<leader>cg", group = "Go" },
				{ "<leader>ck", group = "Kubernetes" },
				{ "<leader>d", group = "Debug" },
				{ "<leader>M", group = "Markdown" },
				{ "<leader>t", group = "Tests" },
				{ "<leader>u", group = "UI / Toggles" },
				{ "<leader>x", group = "Buffers / Lists" },
			},
		},
	},
}
