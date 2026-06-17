return {
	{
		"kdheepak/lazygit.nvim",
		lazy = true,
		cmd = "LazyGit",
		init = function()
			vim.g.lazygit_floating_window_scaling_factor = 0.92
			vim.g.lazygit_floating_window_winblend = 0
			vim.g.lazygit_floating_window_border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
		end,
		keys = {
			{
				"<leader>gg",
				"<cmd>LazyGit<CR>",
				desc = "LazyGit",
			},
		},
	},
}
