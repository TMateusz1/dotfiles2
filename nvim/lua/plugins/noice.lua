return {
	{
		"folke/noice.nvim",
		lazy = false,
		dependencies = {
			"MunifTanjim/nui.nvim",
			{
				"rcarriga/nvim-notify",
				opts = {
					timeout = 3000,
					render = "wrapped-compact",
					stages = "fade",
					top_down = true,
					max_width = function()
						return math.floor(vim.o.columns * 0.40)
					end,
				},
			},
		},
		opts = {
			cmdline = {
				-- Bottom command line (in the cmdline area) instead of the
				-- centered floating popup.
				view = "cmdline",
			},
			messages = {
				enabled = true,
				view = "notify",
				view_error = "notify",
				view_warn = "notify",
				view_history = "messages",
				view_search = "virtualtext",
			},
			notify = {
				enabled = true,
				view = "notify",
			},
			lsp = {
				progress = {
					enabled = true,
				},
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			presets = {
				bottom_search = true,
				-- command_palette would re-center the cmdline + completion menu
				-- as a popup; left off so `:` stays on the bottom line.
				command_palette = false,
				lsp_doc_border = true,
			},
		},
		keys = {
			{
				"<leader>fn",
				"<cmd>Noice history<CR>",
				desc = "Notification history",
			},
			{
				"<leader>un",
				"<cmd>Noice dismiss<CR>",
				desc = "Dismiss notifications",
			},
		},
	},
}
