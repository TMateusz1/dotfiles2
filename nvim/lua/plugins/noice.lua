return {
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			{
				-- Backend for noice's notification view: animated, rounded
				-- popup cards that stack in the TOP-RIGHT corner.
				"rcarriga/nvim-notify",
				opts = {
					-- Anchor to the top-right and stack new notifications
					-- downward from there.
					top_down = true,
					-- Smooth fade-in, slide-out animation.
					stages = "fade_in_slide_out",
					-- Compact cards that still wrap long messages.
					render = "wrapped-compact",
					timeout = 3000,
					fps = 60,
					max_width = 64,
					max_height = 12,
					-- Set an explicit background so nvim-notify doesn't warn about
					-- a transparent bg; matches the catppuccin mocha `base` so the
					-- popups blend with the editor (colored per-level by the
					-- catppuccin `notify` integration).
					background_colour = "#1e1e2e",
					icons = {
						ERROR = "",
						WARN = "",
						INFO = "",
						DEBUG = "",
						TRACE = "✎",
					},
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
			},
			-- Route all vim.notify calls through noice → nvim-notify, so they
			-- show as pretty popups in the top-right corner. History is available
			-- via <leader>fn (require("noice").cmd("history")).
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
				long_message_to_split = true,
				lsp_doc_border = true,
			},
		},
		keys = {
			{
				"<leader>un",
				function()
					require("noice").cmd("dismiss")
				end,
				desc = "Dismiss notifications",
			},
		},
	},
}
