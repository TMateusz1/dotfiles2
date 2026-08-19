return {
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			{
				"rcarriga/nvim-notify",
				opts = {
					background_colour = "#1e1e2e",
					render = "compact",
					stages = "fade_in_slide_out",
					timeout = 2500,
					top_down = true,
				},
			},
		},
		keys = {
			{
				"<leader>fm",
				"<cmd>Noice fzf<CR>",
				desc = "Message history",
			},
			{
				"<leader>un",
				"<cmd>Noice dismiss<CR>",
				desc = "Dismiss notifications",
			},
		},
		opts = {
			cmdline = {
				enabled = true,
				view = "cmdline_popup",
			},
			messages = {
				enabled = true,
				view = "mini",
				view_error = "notify",
				view_warn = "notify",
				view_history = "messages",
				-- Search counts are already rendered in the custom statusline.
				view_search = false,
			},
			-- Blink already supplies a richer command-line completion menu and
			-- knows how to position it beside Noice's floating command palette.
			popupmenu = {
				enabled = false,
			},
			lsp = {
				-- Fidget remains the single owner of LSP progress messages.
				progress = {
					enabled = false,
				},
			},
			presets = {
				command_palette = true,
				long_message_to_split = true,
				lsp_doc_border = true,
			},
			routes = {
				{
					-- The filename is already in the statusline. Hide only successful
					-- write reports; write errors use a different message kind.
					filter = {
						event = "msg_show",
						find = "written$",
						kind = "",
					},
					opts = {
						skip = true,
					},
				},
			},
			views = {
				cmdline_popup = {
					border = {
						padding = { 0, 1 },
						style = "rounded",
					},
					position = {
						col = "50%",
						-- A few clear rows above the global statusline.
						row = -5,
					},
					size = {
						height = "auto",
						width = 64,
					},
				},
			},
		},
	},
}
