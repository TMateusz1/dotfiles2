return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-mini/mini.icons",
		},

		event = "VeryLazy",
		opts = {
			options = {
				theme = "auto",
				component_separators = "",
				section_separators = { left = "", right = "" },
				globalstatus = true, -- Jeden pasek dla całego edytora (zamiast dla każdego splita)
			},
			sections = {
				lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
				lualine_b = { "filename", "branch" },
				lualine_c = { "diagnostics" },

				lualine_x = { "diff" },
				lualine_y = { "filetype", "progress" },
				lualine_z = { { "location", separator = { right = "" }, left_padding = 2 } },
			},
			inactive_sections = {
				lualine_a = { "filename" },
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = { "location" },
			},
		},
	},
}
