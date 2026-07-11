return {
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "┃" },
				change = { text = "┃" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "┃" },
				untracked = { text = "┃" },
			},

			signs_staged = {
				add = { text = "┃" },
				change = { text = "┃" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "┃" },
				untracked = { text = "┃" },
			},

			signcolumn = true,
			numhl = false,
			linehl = false,
			word_diff = false,

			watch_gitdir = {
				follow_files = true,
			},

			auto_attach = true,
			attach_to_untracked = true,

			current_line_blame = false,

			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 500,
				ignore_whitespace = false,
			},

			current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",

			sign_priority = 6,
			update_debounce = 100,
			status_formatter = nil,
			max_file_length = 40000,

			preview_config = {
				border = "rounded",
				style = "minimal",
				relative = "cursor",
				row = 0,
				col = 1,
			},

			on_attach = function(bufnr)
				local gitsigns = require("gitsigns")

				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, {
						buffer = bufnr,
						desc = desc,
					})
				end

				-- Navigation. Target "all" hunks (staged + unstaged) so that
				-- ]h / [h stop at every current-file hunk shown in the sign column.
				map("n", "]h", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gitsigns.nav_hunk("next", { target = "all" })
					end
				end, "Next git hunk")

				map("n", "[h", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gitsigns.nav_hunk("prev", { target = "all" })
					end
				end, "Previous git hunk")

				-- Hunk actions
				map("n", "<leader>ghp", gitsigns.preview_hunk, "Preview hunk")
				map("n", "<leader>ghs", gitsigns.stage_hunk, "Stage hunk")
				map("n", "<leader>ghr", gitsigns.reset_hunk, "Reset hunk")
				-- undo_stage_hunk is deprecated upstream; stage_hunk now toggles,
				-- so on a staged hunk it un-stages it.
				map("n", "<leader>ghu", gitsigns.stage_hunk, "Undo stage hunk (toggle)")

				map("v", "<leader>ghs", function()
					gitsigns.stage_hunk({
						vim.fn.line("."),
						vim.fn.line("v"),
					})
				end, "Stage selected hunk")

				map("v", "<leader>ghr", function()
					gitsigns.reset_hunk({
						vim.fn.line("."),
						vim.fn.line("v"),
					})
				end, "Reset selected hunk")

				-- Blame
				map("n", "<leader>ghb", function()
					gitsigns.blame_line({
						full = false,
					})
				end, "Blame line")

				map("n", "<leader>ghB", function()
					gitsigns.blame_line({
						full = true,
					})
				end, "Full blame line")

				map("n", "<leader>ghl", function()
					gitsigns.toggle_current_line_blame()
				end, "Toggle inline blame")

				-- Diff
				local function map_q_to_close_diff(source_win)
					local diff_win = vim.api.nvim_get_current_win()

					if diff_win == source_win then
						for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
							if win ~= source_win and vim.wo[win].diff then
								diff_win = win
								break
							end
						end
					end

					local diff_buf = vim.api.nvim_win_get_buf(diff_win)
					vim.keymap.set("n", "q", function()
						if vim.api.nvim_win_is_valid(diff_win) then
							vim.api.nvim_win_close(diff_win, false)
						end
						if vim.api.nvim_win_is_valid(source_win) then
							vim.api.nvim_set_current_win(source_win)
							vim.cmd("diffoff")
						end
					end, {
						buffer = diff_buf,
						desc = "Close git diff",
					})
				end

				map("n", "<leader>ghd", function()
					local source_win = vim.api.nvim_get_current_win()
					gitsigns.diffthis()
					vim.schedule(function()
						map_q_to_close_diff(source_win)
					end)
				end, "Diff this file")

				map("n", "<leader>ghD", function()
					local source_win = vim.api.nvim_get_current_win()
					gitsigns.diffthis("~")
					vim.schedule(function()
						map_q_to_close_diff(source_win)
					end)
				end, "Diff this file against previous commit")

				-- Toggles
				map("n", "<leader>ght", gitsigns.toggle_deleted, "Toggle deleted lines")
				map("n", "<leader>ghw", gitsigns.toggle_word_diff, "Toggle word diff")
			end,
		},
	},
}
