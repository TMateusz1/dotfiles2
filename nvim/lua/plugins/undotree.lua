return {
	{
		"mbbill/undotree",
		init = function()
			-- Mirror Aerial's right-side panel and width. Layout 3 keeps the
			-- undotree and its diff preview stacked in the right column.
			vim.g.undotree_WindowLayout = 3
			vim.g.undotree_SplitWidth = 36
		end,
		cmd = {
			"UndotreeHide",
			"UndotreeShow",
			"UndotreeToggle",
		},
		keys = {
			{
				"<leader>U",
				"<cmd>UndotreeToggle<CR>",
				desc = "Toggle undo history",
			},
		},
	},
}
