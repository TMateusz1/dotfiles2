-- ~/.config/nvim/lua/config/keymaps.lua

local keymap = vim.keymap.set

local function close_floating_windows()
	local closed = false

	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_win_is_valid(win) then
			local config = vim.api.nvim_win_get_config(win)

			if config.relative ~= "" then
				vim.api.nvim_win_close(win, false)
				closed = true
			end
		end
	end

	return closed
end

local function confirm_delete_buffer(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return true
	end

	local ok, err = pcall(vim.cmd, string.format("confirm bdelete %d", bufnr))
	if not ok then
		vim.notify("Could not close buffer: " .. tostring(err), vim.log.levels.ERROR, {
			title = "Buffer",
		})
		return false
	end

	-- `:confirm bdelete` returns normally when its prompt is cancelled.
	return not vim.api.nvim_buf_is_valid(bufnr) or not vim.bo[bufnr].buflisted
end

local function is_closable_buffer(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) or not vim.bo[bufnr].buflisted then
		return false
	end

	local buftype = vim.bo[bufnr].buftype
	return buftype == "" or buftype == "nofile"
end

local function close_other_buffers()
	local current = vim.api.nvim_get_current_buf()
	local buffers = vim.api.nvim_list_bufs()

	for _, bufnr in ipairs(buffers) do
		if bufnr ~= current and is_closable_buffer(bufnr) and not confirm_delete_buffer(bufnr) then
			return
		end
	end
end

local function new_scratch_buffer()
	local bufnr = vim.api.nvim_create_buf(true, true)

	vim.bo[bufnr].bufhidden = "hide"
	vim.bo[bufnr].buftype = "nofile"
	vim.bo[bufnr].swapfile = false
	vim.api.nvim_win_set_buf(0, bufnr)
end

keymap("n", "<Esc>", function()
	if close_floating_windows() then
		return
	end

	vim.cmd("nohlsearch")
end, {
	desc = "Close floating windows or clear search highlight",
})

-- Leave terminal mode with a double Esc (covers neotest/dap consoles too;
-- a single Esc still reaches the program inside the terminal)
keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Stay in visual mode while indenting
keymap("v", "<", "<gv", { desc = "Indent left and reselect" })
keymap("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Move selected lines
keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
keymap("n", "<A-j>", "<cmd>move .+1<CR>==", { desc = "Move line down" })
keymap("n", "<A-k>", "<cmd>move .-2<CR>==", { desc = "Move line up" })
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered when jumping
keymap("n", "<C-d>", "<C-d>zz", { desc = "Half page down and center" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Half page up and center" })
keymap("n", "n", "nzzzv", { desc = "Next search result and center" })
keymap("n", "N", "Nzzzv", { desc = "Previous search result and center" })
keymap("n", "]q", function()
	if not pcall(vim.cmd, "cnext") then
		pcall(vim.cmd, "cfirst")
	end
	vim.cmd("normal! zz")
end, { desc = "Next quickfix item" })
keymap("n", "[q", function()
	if not pcall(vim.cmd, "cprev") then
		pcall(vim.cmd, "clast")
	end
	vim.cmd("normal! zz")
end, { desc = "Previous quickfix item" })
keymap("n", "<leader>cks", "<cmd>KubeCrdSchemas<CR>", { desc = "Generate CRD schemas from cluster" })
keymap("n", "<leader>ckl", "<cmd>KubeCrdSchemasLocal<CR>", { desc = "Generate CRD schemas from local files" })
keymap("n", "<leader>cka", "<cmd>KubeSchemaAttach<CR>", { desc = "Attach Kubernetes schema to buffer" })

keymap("n", "<leader>xq", function()
	for _, win in pairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 then
			vim.cmd("cclose")
			return
		end
	end
	vim.cmd("copen")
end, { desc = "Toggle quickfix" })
keymap("n", "<leader>xx", function()
	local bufnr = vim.api.nvim_get_current_buf()

	if is_closable_buffer(bufnr) then
		confirm_delete_buffer(bufnr)
		return
	end

	pcall(vim.cmd, "close")
end, { desc = "Close current buffer" })
keymap("n", "<leader>xX", close_other_buffers, { desc = "Close other buffers" })
keymap("n", "<leader>xn", new_scratch_buffer, { desc = "New scratch buffer" })
-- Diagnostics. Global (not LspAttach-local) so they also cover nvim-lint
-- diagnostics in buffers without an LSP client.
keymap("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
keymap("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })
keymap("n", "<leader>uv", function()
	-- Toggle rich multi-line diagnostics on the cursor line (0.11+).
	if vim.diagnostic.config().virtual_lines then
		vim.diagnostic.config({ virtual_lines = false, virtual_text = false })
	else
		vim.diagnostic.config({ virtual_lines = { current_line = true }, virtual_text = false })
	end
end, { desc = "Toggle virtual-line diagnostics" })

-- Save
-- leaderW is mapped in minis.bufremove as save + buffer delete, same as leaderw + leaderq
keymap("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
-- Quit
-- <leader>q is mapped in mini.bufremove: it closes special/floating windows
-- and otherwise deletes the current buffer while keeping the window.
-- <leader>k closes only a window; <leader>Q quits Neovim with confirmation.
keymap("n", "<leader>k", "<cmd>close<CR>", { desc = "Close window (keep buffer)" })
keymap("n", "<leader>Q", "<cmd>confirm qall<CR>", { desc = "Quit all (confirm save)" })

-- Splits, mirroring tmux prefix bindings:
--   tmux `=` -> split-window -h (side by side)  => vsplit
--   tmux `-` -> split-window -v (stacked)        => split
keymap("n", "<leader>=", "<cmd>vsplit<CR>", { desc = "Split window right (vsplit)" })
keymap("n", "<leader>-", "<cmd>split<CR>", { desc = "Split window below (split)" })

-- LazyGit in a floating terminal
keymap("n", "<leader>gg", function()
	local buf = vim.api.nvim_create_buf(false, true)
	local width = math.floor(vim.o.columns * 0.92)
	local height = math.floor(vim.o.lines * 0.92)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
	})
	vim.fn.termopen("lazygit", {
		on_exit = function()
			vim.api.nvim_win_close(win, true)
		end,
	})
	vim.cmd("startinsert")
end, { desc = "LazyGit" })
