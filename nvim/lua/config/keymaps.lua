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
keymap("n", "]q", "<cmd>cnext<CR>zz", { desc = "Next quickfix item" })
keymap("n", "[q", "<cmd>cprev<CR>zz", { desc = "Previous quickfix item" })

-- Save
-- leaderW is mapped in minis.bufremove as save + buffer delete, same as leaderw + leaderq
keymap("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
-- Quit
-- Leader<q> is mapped in minis.bufremove as buffer delete
-- this mean:
-- leaderq - buffer delete
-- leaderQ - window Quit
-- leaderC - close vim
keymap("n", "<leader>Q", "<cmd>quit<CR>", { desc = "Quit window" })
keymap("n", "<leader>C", "<cmd>quitall!<CR>", { desc = "Quit all force" })
