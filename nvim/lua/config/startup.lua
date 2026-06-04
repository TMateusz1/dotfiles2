local M = {}

function M.open_empty_startup_directory()
	if vim.fn.argc() ~= 1 then
		return false
	end

	local arg = vim.fn.argv(0)
	local dir = vim.fs.normalize(vim.fn.fnamemodify(arg, ":p"))
	local stat = vim.uv.fs_stat(dir)

	if not stat or stat.type ~= "directory" then
		return false
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

	return true
end

return M
