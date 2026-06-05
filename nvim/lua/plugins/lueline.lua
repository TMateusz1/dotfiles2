local function lsp_clients()
	local clients = vim.lsp.get_clients({
		bufnr = 0,
	})

	if #clients == 0 then
		return "  No LSP"
	end

	local names = {}

	for _, client in ipairs(clients) do
		table.insert(names, client.name)
	end

	table.sort(names)
	return "  " .. table.concat(names, ",")
end

local palette = require("catppuccin.palettes").get_palette("mocha")

local function mode_theme(color)
	return {
		a = { fg = palette.crust, bg = color, gui = "bold" },
		b = { fg = color, bg = palette.surface0, gui = "bold" },
		c = { fg = palette.text, bg = palette.base },
		x = { fg = palette.subtext0, bg = palette.base },
		y = { fg = color, bg = palette.surface0 },
		z = { fg = palette.crust, bg = color, gui = "bold" },
	}
end

local theme = {
	normal = mode_theme(palette.blue),
	insert = mode_theme(palette.green),
	visual = mode_theme(palette.mauve),
	replace = mode_theme(palette.red),
	command = mode_theme(palette.peach),
	terminal = mode_theme(palette.teal),
	inactive = {
		a = { fg = palette.subtext0, bg = palette.surface0, gui = "bold" },
		b = { fg = palette.subtext0, bg = palette.surface0 },
		c = { fg = palette.surface1, bg = palette.mantle },
		x = { fg = palette.surface1, bg = palette.mantle },
		y = { fg = palette.surface1, bg = palette.mantle },
		z = { fg = palette.subtext0, bg = palette.surface0 },
	},
}

return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-mini/mini.icons",
		},

		event = "VeryLazy",
		opts = {
			options = {
				theme = theme,
				icons_enabled = true,
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				globalstatus = true,
				disabled_filetypes = {
					statusline = {
						"oil",
					},
				},
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					{
						"branch",
						icon = "",
					},
				},
				lualine_c = {
					{
						"filename",
						path = 1,
						symbols = {
							modified = " ●",
							readonly = " 󰌾",
							unnamed = "[No Name]",
							newfile = "[New]",
						},
					},
					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						sections = { "error", "warn", "info", "hint" },
						symbols = {
							error = " ",
							warn = " ",
							info = " ",
							hint = "󰌵 ",
						},
						colored = true,
						update_in_insert = false,
					},
				},

				lualine_x = {
					{
						lsp_clients,
						color = { fg = palette.sky, gui = "bold" },
					},
					{
						"diff",
						symbols = {
							added = " ",
							modified = " ",
							removed = " ",
						},
						colored = true,
					},
				},
				lualine_y = {
					{
						"filetype",
						colored = true,
						icon_only = false,
					},
					"progress",
				},
				lualine_z = {
					{
						"location",
						icon = "",
					},
				},
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
