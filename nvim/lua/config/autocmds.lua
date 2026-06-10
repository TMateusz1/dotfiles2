local augroup = vim.api.nvim_create_augroup("user_config", {
	clear = true,
})

local startup = require("config.startup")

vim.api.nvim_create_autocmd("VimEnter", {
	group = augroup,
	callback = startup.open_empty_startup_directory,
	desc = "Open an empty buffer when Neovim starts with a directory",
})

-- Highlight text after yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.hl.on_yank({
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

-- Reload files changed outside Neovim (lazygit, go generate, branch switches)
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup,
	callback = function()
		if vim.bo.buftype == "" then
			vim.cmd("checktime")
		end
	end,
	desc = "Reload files changed on disk",
})

-- Keep splits balanced when the terminal (tmux pane) is resized
vim.api.nvim_create_autocmd("VimResized", {
	group = augroup,
	callback = function()
		-- pcall: tabdo is not allowed while the cmdline-window is open (E11).
		local current_tab = vim.fn.tabpagenr()
		pcall(vim.cmd, "tabdo wincmd =")
		pcall(vim.cmd, "tabnext " .. current_tab)
	end,
	desc = "Equalize splits on resize",
})

-- Cursorline only in the focused window
vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
	group = augroup,
	callback = function()
		if vim.bo.buftype == "" or vim.bo.filetype == "qf" then
			vim.wo.cursorline = true
		end
	end,
	desc = "Show cursorline in the active window",
})

vim.api.nvim_create_autocmd("WinLeave", {
	group = augroup,
	callback = function()
		-- Only normal file windows: special buffers (Snacks picker list,
		-- quickfix, mini.files) manage their own cursorline and would lose
		-- their selection highlight if this fired for them.
		if vim.bo.buftype == "" then
			vim.wo.cursorline = false
		end
	end,
	desc = "Hide cursorline in inactive windows",
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
