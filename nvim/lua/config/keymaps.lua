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

local function scroll_and_center(keys)
	vim.cmd.normal({ args = { vim.keycode(keys) }, bang = true })
	vim.cmd("normal! zz")
end

local function search_and_center(keys)
	vim.cmd.normal({ args = { keys }, bang = true })
	vim.cmd("normal! zvzz")
end

local function diagnostic_jump(count)
	vim.diagnostic.jump({ count = count, float = false })
	vim.cmd("normal! zz")

	vim.defer_fn(function()
		vim.diagnostic.open_float(nil, {
			border = "rounded",
			focus = false,
			scope = "line",
			source = true,
		})
	end, 20)
end

keymap("n", "<Esc>", function()
	if close_floating_windows() then
		return
	end

	vim.cmd("nohlsearch")
end, {
	desc = "Close floating windows or clear search highlight",
})

-- Leave terminal mode with a double Esc; a single Esc still reaches the
-- program inside the terminal.
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
keymap("n", "<C-d>", function()
	scroll_and_center("<C-d>")
end, { desc = "Half page down and center" })
keymap("n", "<C-u>", function()
	scroll_and_center("<C-u>")
end, { desc = "Half page up and center" })
keymap("n", "n", function()
	search_and_center("n")
end, { desc = "Next search result and center" })
keymap("n", "N", function()
	search_and_center("N")
end, { desc = "Previous search result and center" })
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
keymap("n", "<leader>xq", function()
	for _, win in pairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 then
			vim.cmd("cclose")
			return
		end
	end
	vim.cmd("copen")
end, { desc = "Toggle quickfix" })
-- Diagnostics. Global (not LspAttach-local) so they also cover nvim-lint
-- diagnostics in buffers without an LSP client.
keymap("n", "]d", function()
	diagnostic_jump(1)
end, { desc = "Next diagnostic" })
keymap("n", "[d", function()
	diagnostic_jump(-1)
end, { desc = "Previous diagnostic" })
keymap("n", "<leader>uv", function()
	-- Toggle rich multi-line diagnostics on the cursor line (0.11+).
	if vim.diagnostic.config().virtual_lines then
		vim.diagnostic.config({ virtual_lines = false, virtual_text = false })
	else
		vim.diagnostic.config({ virtual_lines = { current_line = true }, virtual_text = false })
	end
end, { desc = "Toggle virtual-line diagnostics" })

-- Quit
-- Buffer save/delete mappings live in plugins/buffers.lua.
-- <leader>k closes only a window; <leader>Q quits Neovim with confirmation.
keymap("n", "<leader>k", "<cmd>close<CR>", { desc = "Close window (keep buffer)" })
keymap("n", "<leader>Q", "<cmd>confirm qall<CR>", { desc = "Quit all (confirm save)" })

-- Splits, mirroring tmux prefix bindings:
--   tmux `=` -> split-window -h (side by side)  => vsplit
--   tmux `-` -> split-window -v (stacked)        => split
keymap("n", "<leader>=", "<cmd>vsplit<CR>", { desc = "Split window right (vsplit)" })
keymap("n", "<leader>-", "<cmd>split<CR>", { desc = "Split window below (split)" })
