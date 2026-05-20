-- ~/.config/nvim/lua/config/keymaps.lua

local keymap = vim.keymap.set

keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", {
	desc = "Clear search highlight",
})

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Better window navigation with arrows
keymap("n", "<C-Left>", "<C-w>h", { desc = "Move to left window" })
keymap("n", "<C-Down>", "<C-w>j", { desc = "Move to lower window" })
keymap("n", "<C-Up>", "<C-w>k", { desc = "Move to upper window" })
keymap("n", "<C-Right>", "<C-w>l", { desc = "Move to right window" })

-- Move selected lines
keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered when jumping
keymap("n", "<C-d>", "<C-d>zz", { desc = "Half page down and center" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Half page up and center" })
keymap("n", "n", "nzzzv", { desc = "Next search result and center" })
keymap("n", "N", "Nzzzv", { desc = "Previous search result and center" })

-- Save
keymap("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })

-- Quit
keymap("n", "<leader>Q", "<cmd>quit!<CR>", { desc = "Quit" })
