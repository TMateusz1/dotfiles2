-- ~/.config/nvim/lua/plugins/lazygit.lua

return {
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		keys = {
			{
				"<leader>gg",
				"<cmd>LazyGit<CR>",
				desc = "LazyGit",
			},
			{
				"<leader>gG",
				"<cmd>LazyGitCurrentFile<CR>",
				desc = "LazyGit current file",
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
}
