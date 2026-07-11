-- ~/.config/nvim/lua/plugins/tmux-navigator.lua

return {
	{
		"christoomey/vim-tmux-navigator",
		init = function()
			vim.g.tmux_navigator_no_mappings = 1
		end,
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
		},
		keys = {
			{ "<C-h>", "<cmd>TmuxNavigateLeft<CR>", desc = "Move to left window or tmux pane" },
			{ "<C-j>", "<cmd>TmuxNavigateDown<CR>", desc = "Move to lower window or tmux pane" },
			{ "<C-k>", "<cmd>TmuxNavigateUp<CR>", desc = "Move to upper window or tmux pane" },
			{ "<C-l>", "<cmd>TmuxNavigateRight<CR>", desc = "Move to right window or tmux pane" },
			{ "<C-Left>", "<cmd>TmuxNavigateLeft<CR>", desc = "Move to left window or tmux pane" },
			{ "<C-Down>", "<cmd>TmuxNavigateDown<CR>", desc = "Move to lower window or tmux pane" },
			{ "<C-Up>", "<cmd>TmuxNavigateUp<CR>", desc = "Move to upper window or tmux pane" },
			{ "<C-Right>", "<cmd>TmuxNavigateRight<CR>", desc = "Move to right window or tmux pane" },
		},
	},
}
