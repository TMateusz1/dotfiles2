local augroup = vim.api.nvim_create_augroup("user_config", {
	clear = true,
})

local function open_empty_startup_directory()
	if vim.fn.argc() ~= 1 then
		return
	end

	local arg = vim.fn.argv(0)
	local dir = vim.fs.normalize(vim.fn.fnamemodify(arg, ":p"))
	local stat = vim.uv.fs_stat(dir)

	if not stat or stat.type ~= "directory" then
		return
	end

	vim.api.nvim_set_current_dir(dir)

	local directory_buf = vim.api.nvim_get_current_buf()

	vim.cmd.enew()

	if vim.api.nvim_buf_is_valid(directory_buf) and not vim.bo[directory_buf].modified then
		pcall(vim.api.nvim_buf_delete, directory_buf, {
			force = true,
		})
	end

	pcall(vim.cmd, "argdelete *")
end

vim.api.nvim_create_autocmd("VimEnter", {
	group = augroup,
	callback = open_empty_startup_directory,
	desc = "Open an empty buffer when Neovim starts with a directory",
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
		"go",
		"gomod",
		"gowork",
	},
	callback = function()
		vim.opt_local.colorcolumn = "120"
	end,
	desc = "Show Go right margin",
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
