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
-- Leader<q> is mapped in minis.bufremove as buffer delete
-- this mean:
-- leaderk - close window only (keep the buffer open)
-- leaderq - buffer delete (keep the window)
-- leaderQ - close window + delete the buffer that window was showing
-- leaderX - quit all (prompts to save unsaved buffers)
keymap("n", "<leader>k", "<cmd>close<CR>", { desc = "Close window (keep buffer)" })
keymap("n", "<leader>Q", function()
	-- Special / floating windows (quickfix, help, terminal, neotest, ...) have
	-- no real file buffer to delete - just close the window.
	local floating = vim.api.nvim_win_get_config(0).relative ~= ""
	if floating or vim.bo.buftype ~= "" then
		pcall(vim.cmd, "close")
		return
	end

	local buf = vim.api.nvim_get_current_buf()

	-- Close the window first; abort if it refuses (e.g. unsaved changes).
	if not pcall(vim.cmd, "quit") then
		return
	end

	-- Then remove the buffer that window was displaying.
	if vim.api.nvim_buf_is_valid(buf) then
		require("mini.bufremove").delete(buf)
	end
end, { desc = "Quit window + delete buffer" })
keymap("n", "<leader>X", "<cmd>confirm qall<CR>", { desc = "Quit all (confirm save)" })

-- Splits, mirroring tmux prefix bindings:
--   tmux `=` -> split-window -h (side by side)  => vsplit
--   tmux `-` -> split-window -v (stacked)        => split
keymap("n", "<leader>=", "<cmd>vsplit<CR>", { desc = "Split window right (vsplit)" })
keymap("n", "<leader>-", "<cmd>split<CR>", { desc = "Split window below (split)" })
