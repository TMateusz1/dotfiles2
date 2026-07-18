return {
	{
		"mbbill/undotree",
		cmd = {
			"UndotreeHide",
			"UndotreeShow",
			"UndotreeToggle",
		},
		keys = {
			{
				"<leader>uu",
				"<cmd>UndotreeToggle<CR>",
				desc = "Toggle undo history",
			},
		},
	},
}
