return {
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		opts = {
			cmdline = {
				-- Bottom command line (in the cmdline area) instead of the
				-- centered floating popup.
				view = "cmdline",
			},
			messages = {
				enabled = true,
			},
			-- Notifications are owned by snacks.notifier, not noice. Leaving this
			-- disabled means noice doesn't touch vim.notify, so the snacks cards
			-- render instead. History/dismiss live on <leader>fn / <leader>un.
			notify = {
				enabled = false,
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
				long_message_to_split = true,
				lsp_doc_border = true,
			},
		},
		keys = {
			{
				"<leader>un",
				function()
					Snacks.notifier.hide()
				end,
				desc = "Dismiss notifications",
			},
		},
	},
}
