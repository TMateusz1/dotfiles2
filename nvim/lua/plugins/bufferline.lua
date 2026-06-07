-- ~/.config/nvim/lua/plugins/bufferline.lua

local function bufremove(bufnr)
	require("mini.bufremove").delete(bufnr)
end

return {
	{
		"akinsho/bufferline.nvim",
		version = "*",
		event = "VeryLazy",
		dependencies = {
			"nvim-mini/mini.icons",
			"nvim-mini/mini.bufremove",
		},
		keys = {
			{ "]b", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
			{ "[b", "<cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
			{
				"<leader>bp",
				"<cmd>BufferLinePick<CR>",
				desc = "Pick buffer",
			},
			{
				"<leader>bX",
				"<cmd>BufferLineCloseOthers<CR>",
				desc = "Delete other buffers",
			},
			{
				"<leader>bL",
				"<cmd>BufferLineCloseRight<CR>",
				desc = "Delete buffers to the right",
			},
			{
				"<leader>bH",
				"<cmd>BufferLineCloseLeft<CR>",
				desc = "Delete buffers to the left",
			},
		},
		opts = {
			options = {
				mode = "buffers",

				numbers = "none",

				close_command = bufremove,
				right_mouse_command = bufremove,
				left_mouse_command = "buffer %d",
				middle_mouse_command = nil,

				indicator = {
					icon = "▌",
					style = "icon",
				},

				buffer_close_icon = "󰅖",
				modified_icon = "●",
				close_icon = "",
				left_trunc_marker = "",
				right_trunc_marker = "",

				max_name_length = 24,
				max_prefix_length = 15,
				truncate_names = true,
				tab_size = 18,

				diagnostics = "nvim_lsp",

				diagnostics_indicator = function(count, level)
					local icon = level:match("error") and "E" or "W"
					return (" %s:%d"):format(icon, count)
				end,

				color_icons = true,
				show_buffer_icons = true,
				show_buffer_close_icons = true,
				show_close_icon = false,
				show_tab_indicators = true,
				persist_buffer_sort = true,

				separator_style = "thin",

				enforce_regular_tabs = false,
				always_show_bufferline = true,

				hover = {
					enabled = true,
					delay = 200,
					reveal = { "close" },
				},

				sort_by = "insert_after_current",
			},
		},
		config = function(_, opts)
			require("bufferline").setup(opts)
		end,
	},
}
