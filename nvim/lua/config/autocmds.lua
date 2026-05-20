local augroup = vim.api.nvim_create_augroup("user_config", {
	clear = true,
})

-- Highlight text after yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 150,
		})
	end,
	desc = "Highlight yanked text",
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local line_count = vim.api.nvim_buf_line_count(0)

		if mark[1] > 0 and mark[1] <= line_count then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
	desc = "Return to last edit position",
})

-- Disable auto comment on new line
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
	desc = "Disable auto comment on new line",
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = {
		"qf",
		"help",
		"man",
		"notify",
		"neotest-summary",
		"neotest-output",
		"neotest-output-panel",
	},
	callback = function(event)
		vim.keymap.set("n", "q", "<cmd>close<CR>", {
			buffer = event.buf,
			silent = true,
			desc = "Close window",
		})

		vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", {
			buffer = event.buf,
			silent = true,
			desc = "Close window",
		})
	end,
	desc = "Close temporary windows with q or Esc",
})
