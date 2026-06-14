-- Trouble is the single panel for diagnostics, symbols, todos, and the
-- quickfix / location lists (it replaced aerial for the outline and
-- quicker for the quickfix window).
return {
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		-- Redirect any native quickfix / location list window (`:copen`,
		-- `:grep`, `:vimgrep`, `:make`, picker "send to quickfix", ...) into
		-- Trouble. The config's own diagnostics / test / Go-command lists call
		-- `:Trouble qflist open` directly, so they never hit this path.
		init = function()
			vim.api.nvim_create_autocmd("BufWinEnter", {
				group = vim.api.nvim_create_augroup("user_trouble_qf_hijack", { clear = true }),
				callback = function(event)
					if vim.bo[event.buf].buftype ~= "quickfix" then
						return
					end

					local is_loclist = vim.fn.win_gettype(vim.api.nvim_get_current_win()) == "loclist"

					vim.schedule(function()
						if is_loclist then
							vim.cmd("silent! lclose")
							vim.cmd("Trouble loclist open")
						else
							vim.cmd("silent! cclose")
							vim.cmd("Trouble qflist open")
						end
					end)
				end,
				desc = "Open native quickfix / loclist in Trouble",
			})
		end,
		opts = {
			focus = true,
			-- Keep the panel out of the way: diagnostics/qf at the bottom,
			-- symbols on the right (outline-style).
			modes = {
				symbols = {
					win = {
						position = "right",
						size = 0.3,
					},
				},
			},
		},
		keys = {
			-- Outline (was aerial's <leader>F): a focused symbols panel on the
			-- right that you jump into and navigate.
			{
				"<leader>F",
				"<cmd>Trouble symbols toggle focus=true<cr>",
				desc = "Code outline (Trouble symbols)",
			},

			-- Diagnostics
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Problems panel (workspace)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Problems panel (buffer)",
			},

			-- Symbols outline (peek without leaving the code window)
			{
				"<leader>xs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols outline (peek)",
			},

			-- Todo comments
			{
				"<leader>xt",
				"<cmd>Trouble todo toggle<cr>",
				desc = "Todo comments (Trouble)",
			},

			-- Quickfix / location lists (was quicker's <leader>xq / <leader>xl)
			{
				"<leader>xq",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix list (Trouble)",
			},
			{
				"<leader>xl",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location list (Trouble)",
			},

			-- LSP references / definitions in a panel
			{
				"<leader>xr",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP references / definitions (Trouble)",
			},
		},
	},
}
