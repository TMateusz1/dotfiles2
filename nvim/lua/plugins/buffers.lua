local special_filetypes = {
	help = true,
	man = true,
	["neotest-output"] = true,
	["neotest-output-panel"] = true,
	["neotest-summary"] = true,
	qf = true,
}

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, {
		title = "Buffer",
	})
end

local function resolve_bufnr(bufnr)
	if bufnr == nil or bufnr == 0 then
		return vim.api.nvim_get_current_buf()
	end

	return bufnr
end

local function is_floating_window(win)
	local config = vim.api.nvim_win_get_config(win or 0)

	return config.relative ~= ""
end

local function is_special_buffer(bufnr)
	bufnr = resolve_bufnr(bufnr)

	if special_filetypes[vim.bo[bufnr].filetype] then
		return true
	end

	return vim.bo[bufnr].buftype ~= ""
end

local function is_closable_buffer(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) or not vim.bo[bufnr].buflisted then
		return false
	end

	local buftype = vim.bo[bufnr].buftype
	return buftype == "" or buftype == "nofile"
end

local function confirm_delete(bufnr)
	bufnr = resolve_bufnr(bufnr)

	if not vim.api.nvim_buf_is_valid(bufnr) then
		return true
	end

	local ok, err = pcall(vim.cmd, string.format("confirm bdelete %d", bufnr))
	if not ok then
		notify("Could not close buffer: " .. tostring(err), vim.log.levels.ERROR)
		return false
	end

	return not vim.api.nvim_buf_is_valid(bufnr) or not vim.bo[bufnr].buflisted
end

local function delete(bufnr, force)
	bufnr = resolve_bufnr(bufnr)

	if force then
		local ok, err = pcall(vim.cmd, string.format("bdelete! %d", bufnr))
		if not ok then
			notify("Could not close buffer: " .. tostring(err), vim.log.levels.ERROR)
			return false
		end

		return true
	end

	return confirm_delete(bufnr)
end

local function close_current()
	local bufnr = vim.api.nvim_get_current_buf()

	if is_closable_buffer(bufnr) then
		confirm_delete(bufnr)
		return
	end

	pcall(vim.cmd, "close")
end

local function close_others()
	local current = vim.api.nvim_get_current_buf()

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if bufnr ~= current and is_closable_buffer(bufnr) and not confirm_delete(bufnr) then
			return
		end
	end
end

local function smart_close()
	if is_floating_window() or is_special_buffer() then
		vim.cmd("close")
		return
	end

	delete(0)
end

local function save()
	local ok, err = pcall(vim.cmd.write, { bang = true })

	if not ok then
		notify("Save failed: " .. tostring(err), vim.log.levels.ERROR)
	end

	return ok
end

local function save_and_close()
	if save() then
		delete(0)
	end
end

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
		"<leader>bX",
		close_others,
		desc = "Delete other buffers",
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
		"<cmd>BufferLineGoToBuffer -1<CR>",
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
		("<cmd>BufferLineGoToBuffer %d<CR>"):format(target),
		desc = ("Go to buffer %d"):format(target),
	}
end

vim.list_extend(keys, {
	{
		"<leader>w",
		save,
		desc = "Save file",
	},
	{
		"<leader>W",
		save_and_close,
		desc = "Save and close buffer",
	},
	{
		"<leader>q",
		smart_close,
		desc = "Smart close",
	},
	{
		"<leader>bx",
		close_current,
		desc = "Delete buffer",
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
		keys = keys,
		opts = {
			options = {
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
