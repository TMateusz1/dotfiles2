local buffers = require("config.buffers")

local keys = {
	{
		"]b",
		"<cmd>BufferLineCycleNext<CR>",
		desc = "Next buffer",
	},
	{
		"[b",
		"<cmd>BufferLineCyclePrev<CR>",
		desc = "Previous buffer",
	},
	{
		"<leader>bn",
		function()
			vim.cmd("enew")
		end,
		desc = "New buffer",
	},
	{
		"<leader>0",
		function()
			-- The ex-command only supports visible-position jumps (hidden when
			-- the bufferline is too narrow to show every buffer); the Lua API
			-- takes an `absolute` flag to index the full buffer list instead.
			require("bufferline").go_to(-1, true)
		end,
		desc = "Go to last buffer",
	},
	{
		"<leader>b0",
		"<cmd>buffer #<CR>",
		desc = "Go to alternate buffer",
	},
	{
		"<leader>b,",
		"<cmd>BufferLineMovePrev<CR>",
		desc = "Move buffer left",
	},
	{
		"<leader>b.",
		"<cmd>BufferLineMoveNext<CR>",
		desc = "Move buffer right",
	},
}

for index = 1, 9 do
	local target = index

	keys[#keys + 1] = {
		("<leader>%d"):format(target),
		function()
			require("bufferline").go_to(target, true)
		end,
		desc = ("Go to buffer %d"):format(target),
	}
end

vim.list_extend(keys, {
	{
		"<leader>w",
		buffers.save,
		desc = "Save file",
	},
	{
		"<leader>W",
		buffers.save_and_close,
		desc = "Save and close buffer",
	},
	{
		"<leader>q",
		buffers.smart_close,
		desc = "Smart close",
	},
	{
		"<leader>x",
		buffers.close_current,
		desc = "Delete buffer",
	},
	{
		"<leader>X",
		buffers.close_others,
		desc = "Delete other buffers",
	},
})

return {
	{
		"akinsho/bufferline.nvim",
		version = "*",
		event = "VeryLazy",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		init = buffers.setup,
		keys = keys,
		opts = {
			options = {
				offsets = {
					{
						filetype = "neo-tree",
						text = "File Explorer",
						text_align = "center",
						separator = true,
					},
				},
				numbers = "ordinal",
				diagnostics = "nvim_lsp",
				diagnostics_indicator = function(count, level)
					local icon = level:match("error") and "" or ""

					return (" %s%d"):format(icon, count)
				end,
				show_buffer_close_icons = false,
				show_close_icon = false,
				show_tab_indicators = false,
				persist_buffer_sort = true,
				separator_style = "thin",
				always_show_bufferline = true,
			},
		},
	},
}
