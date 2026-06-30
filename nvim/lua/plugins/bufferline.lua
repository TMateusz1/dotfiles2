local keys = {
	{ "]b", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
	{ "[b", "<cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
	{ "<leader>bl", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
	{ "<leader>bh", "<cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
	{ "<leader>bb", "<cmd>BufferLinePick<CR>", desc = "Pick buffer" },
	{ "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "Pin buffer" },
	{ "<leader>b,", "<cmd>BufferLineMovePrev<CR>", desc = "Move buffer left" },
	{ "<leader>b.", "<cmd>BufferLineMoveNext<CR>", desc = "Move buffer right" },
	{ "<leader>b0", "<cmd>BufferLineGoToBuffer -1<CR>", desc = "Go to last visible buffer" },
	{ "<leader>bX", "<cmd>BufferLineCloseOthers<CR>", desc = "Delete other buffers" },
	{ "<leader>bL", "<cmd>BufferLineCloseRight<CR>", desc = "Delete buffers to the right" },
	{ "<leader>bH", "<cmd>BufferLineCloseLeft<CR>", desc = "Delete buffers to the left" },
}

for i = 1, 9 do
	table.insert(keys, {
		("<leader>%d"):format(i),
		("<cmd>BufferLineGoToBuffer %d<CR>"):format(i),
		desc = ("Go to buffer %d"):format(i),
	})
	table.insert(keys, {
		("<A-%d>"):format(i),
		("<cmd>BufferLineGoToBuffer %d<CR>"):format(i),
		desc = ("Go to buffer %d"):format(i),
	})
end

return {
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = {
			"nvim-mini/mini.icons",
		},
		event = "VeryLazy",
		keys = keys,
		opts = {
			options = {
				mode = "buffers",
				numbers = "ordinal",
				diagnostics = "nvim_lsp",
				separator_style = "thin",
				always_show_bufferline = true,
				show_buffer_close_icons = true,
				show_close_icon = false,
				close_command = function(bufnr)
					require("mini.bufremove").delete(bufnr, false)
				end,
				right_mouse_command = function(bufnr)
					require("mini.bufremove").delete(bufnr, false)
				end,
				offsets = {
					{
						filetype = "neo-tree",
						text = "Explorer",
						text_align = "center",
						separator = true,
					},
				},
				hover = {
					enabled = true,
					delay = 150,
					reveal = { "close" },
				},
			},
		},
	},
}
