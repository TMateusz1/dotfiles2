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

local function is_empty_buffer(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
		return false
	end

	return vim.bo[bufnr].buflisted
		and vim.bo[bufnr].buftype == ""
		and vim.api.nvim_buf_get_name(bufnr) == ""
		and not vim.bo[bufnr].modified
		and vim.api.nvim_buf_line_count(bufnr) == 1
		and vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] == ""
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

local function replacement_buffer(current)
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if bufnr ~= current and is_closable_buffer(bufnr) and not is_empty_buffer(bufnr) then
			return bufnr
		end
	end
end

local function new_placeholder(win)
	local bufnr = vim.api.nvim_create_buf(true, false)
	vim.b[bufnr].dotfiles_empty_placeholder = true
	vim.api.nvim_win_set_buf(win, bufnr)
	return bufnr
end

local function close_buffer_keep_window(bufnr)
	bufnr = resolve_bufnr(bufnr)
	local win = vim.api.nvim_get_current_win()
	local replacement = replacement_buffer(bufnr)
	local placeholder

	-- Switch first when it is safe, so deleting the last file can never remove
	-- the editing pane and leave Neo-tree as the only full-width window.
	if not vim.bo[bufnr].modified then
		if replacement then
			vim.api.nvim_win_set_buf(win, replacement)
		else
			placeholder = new_placeholder(win)
		end
	end

	if not confirm_delete(bufnr) then
		if vim.api.nvim_win_is_valid(win) and vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_win_set_buf(win, bufnr)
		end
		if placeholder and vim.api.nvim_buf_is_valid(placeholder) then
			vim.api.nvim_buf_delete(placeholder, { force = true })
		end
		return false
	end

	-- A modified buffer cannot be switched away from before the confirmation.
	-- Once deletion succeeds, enforce the same deterministic replacement.
	if vim.api.nvim_win_is_valid(win) then
		if replacement and vim.api.nvim_buf_is_valid(replacement) then
			if vim.api.nvim_win_get_buf(win) ~= replacement then
				vim.api.nvim_win_set_buf(win, replacement)
			end
		else
			local current = vim.api.nvim_win_get_buf(win)
			if is_empty_buffer(current) then
				vim.b[current].dotfiles_empty_placeholder = true
			elseif current ~= placeholder then
				new_placeholder(win)
			end
		end
	end

	return true
end

local cleanup_scheduled = false

local function cleanup_empty_buffers()
	if cleanup_scheduled then
		return
	end

	cleanup_scheduled = true
	vim.schedule(function()
		cleanup_scheduled = false
		local current = vim.api.nvim_get_current_buf()
		if not vim.api.nvim_buf_is_valid(current) or not vim.bo[current].buflisted then
			return
		end

		-- When :edit reuses the placeholder buffer, it becomes the real buffer.
		if vim.b[current].dotfiles_empty_placeholder and not is_empty_buffer(current) then
			vim.b[current].dotfiles_empty_placeholder = nil
		end

		local empty = {}
		for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
			if is_empty_buffer(bufnr) then
				empty[#empty + 1] = bufnr
			end
		end

		for _, bufnr in ipairs(empty) do
			if
				bufnr ~= current
				and (vim.b[bufnr].dotfiles_empty_placeholder or (#empty == 1 and not is_empty_buffer(current)))
			then
				pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
			end
		end
	end)
end

local function close_current()
	local bufnr = vim.api.nvim_get_current_buf()

	if is_closable_buffer(bufnr) then
		close_buffer_keep_window(bufnr)
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

	close_buffer_keep_window(0)
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
		close_buffer_keep_window(0)
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
		init = function()
			local group = vim.api.nvim_create_augroup("dotfiles-empty-buffer-cleanup", { clear = true })
			vim.api.nvim_create_autocmd({ "BufAdd", "BufEnter" }, {
				group = group,
				callback = cleanup_empty_buffers,
				desc = "Remove the temporary empty buffer after opening another buffer",
			})
		end,
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
