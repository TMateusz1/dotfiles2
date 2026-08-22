local M = {}

local function assert_equal(actual, expected, label)
	assert(
		vim.deep_equal(actual, expected),
		("%s: expected %s, got %s"):format(label, vim.inspect(expected), vim.inspect(actual))
	)
end

function M.run()
	local buffers = require("config.buffers")
	buffers.setup()

	local function is_listed(bufnr)
		return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted
	end

	local readonly_path = vim.fn.tempname()
	vim.fn.writefile({ "original" }, readonly_path)

	vim.cmd.edit(vim.fn.fnameescape(readonly_path))
	vim.api.nvim_buf_set_lines(0, 0, -1, false, { "changed" })
	vim.bo.readonly = true

	local previous_confirm = vim.o.confirm
	local previous_notify = vim.notify
	vim.o.confirm = false
	vim.notify = function() end
	local saved = buffers.save()
	vim.notify = previous_notify
	vim.o.confirm = previous_confirm

	assert(not saved, "read-only save unexpectedly succeeded")
	assert(vim.bo.modified, "read-only save cleared the modified flag")
	assert_equal(vim.fn.readfile(readonly_path), { "original" }, "read-only file contents")

	vim.bo.readonly = false
	vim.cmd.edit({ bang = true })

	local discard = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_name(discard, vim.fn.tempname())
	local keep = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_name(keep, vim.fn.tempname())
	vim.api.nvim_win_set_buf(0, keep)

	buffers.close_others()
	assert(is_listed(keep), "current buffer was deleted by close_others")
	assert(not is_listed(discard), "other buffer survived close_others")
	assert_equal(vim.api.nvim_get_current_buf(), keep, "current buffer after close_others")

	buffers.close_current()
	local placeholder = vim.api.nvim_get_current_buf()
	assert(not is_listed(keep), "current buffer survived close_current")
	assert(vim.b[placeholder].dotfiles_empty_placeholder, "last-buffer close did not create a placeholder")

	local replacement = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_name(replacement, vim.fn.tempname())
	vim.api.nvim_win_set_buf(0, replacement)
	assert(
		vim.wait(500, function()
			return not is_listed(placeholder)
		end, 10),
		"placeholder was not cleaned up after opening a real buffer"
	)

	pcall(vim.api.nvim_buf_delete, replacement, { force = true })
	vim.fn.delete(readonly_path)
	print("buffers-regression-ok")
end

return M
