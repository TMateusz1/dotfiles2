-- ~/.config/nvim/lua/plugins/minis.lua

return {
	{
		"nvim-mini/mini.ai",
		version = false,
		event = "VeryLazy",
		opts = {
			n_lines = 500,
		},
	},

	{
		"nvim-mini/mini.surround",
		version = false,
		event = "VeryLazy",
		opts = {
			mappings = {
				add = "sa",
				delete = "sd",
				find = "sf",
				find_left = "sF",
				highlight = "sh",
				replace = "sr",
				update_n_lines = "sn",
			},
		},
	},

	{
		"nvim-mini/mini.pairs",
		version = false,
		event = "InsertEnter",
		opts = {},
	},

	{
		"nvim-mini/mini.icons",
		version = false,
		lazy = true,
		opts = {},
		init = function()
			package.preload["nvim-web-devicons"] = function()
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
	},
	{
		"nvim-mini/mini.bufremove",
		version = false,
		keys = {
			{
				"<leader>q",
				function()
					require("mini.bufremove").delete(0, false)
				end,
				desc = "Delete buffer",
			},
			{
				"<leader>bx",
				function()
					require("mini.bufremove").delete(0, false)
				end,
				desc = "Delete buffer",
			},
		},
		opts = {},
	},
}
