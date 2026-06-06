return {
	{
		"stevearc/quicker.nvim",
		event = "FileType qf",
		opts = {
			-- Buffer-local options applied to the quickfix window
			opts = {
				buflisted = false,
				number = false,
				relativenumber = false,
				signcolumn = "auto",
				winfixheight = true,
				wrap = false,
			},
			-- Syntax-highlight entries and load real buffers for accuracy
			highlight = {
				treesitter = true,
				lsp = true,
				load_buffers = false,
			},
			-- Edit the quickfix buffer and `:w` to apply changes back to files
			edit = {
				enabled = true,
				autosave = "unmodified",
			},
			-- Keep filenames readable without eating the whole window
			max_filename_width = function()
				return math.floor(math.min(95, vim.o.columns / 2))
			end,
			-- In-quickfix keymaps for expanding/collapsing context lines
			keys = {
				{
					">",
					function()
						require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
					end,
					desc = "Expand quickfix context",
				},
				{
					"<",
					function()
						require("quicker").collapse()
					end,
					desc = "Collapse quickfix context",
				},
			},
		},
		keys = {
			{
				"<leader>xq",
				function()
					require("quicker").toggle()
				end,
				desc = "Toggle quickfix window",
			},
			{
				"<leader>xl",
				function()
					require("quicker").toggle({ loclist = true })
				end,
				desc = "Toggle location list",
			},
		},
	},
}
