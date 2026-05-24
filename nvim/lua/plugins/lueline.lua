local function lsp_clients()
	local clients = vim.lsp.get_clients({
		bufnr = 0,
	})

	if #clients == 0 then
		return "No LSP"
	end

	local names = {}

	for _, client in ipairs(clients) do
		table.insert(names, client.name)
	end

	table.sort(names)
	return table.concat(names, ",")
end

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
				component_separators = { left = "│", right = "│" },
				section_separators = "",
				globalstatus = true,
				disabled_filetypes = {
					statusline = {
						"neo-tree",
						"oil",
					},
				},
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch" },
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
							error = "E:",
							warn = "W:",
							info = "I:",
							hint = "H:",
						},
					},
				},

				lualine_x = { lsp_clients, "diff" },
				lualine_y = { "filetype", "progress" },
				lualine_z = { "location" },
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
