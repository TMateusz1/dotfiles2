return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		cmd = "Neotree",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		keys = {
			{
				"<leader>e",
				function()
					require("config.neotree").open_current_file()
				end,
				desc = "Explore focused on current file",
			},
			{
				"<leader>E",
				function()
					require("config.neotree").open_root()
				end,
				desc = "Explore collapsed project root",
			},
		},
		config = function()
			require("config.neotree").setup()
		end,
	},
}
