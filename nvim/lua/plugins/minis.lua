-- ~/.config/nvim/lua/plugins/minis.lua

return {
	{
		"nvim-mini/mini.ai",
		version = false,
		event = "VeryLazy",
		opts = {
			n_lines = 500,
		},
	},

	{
		"nvim-mini/mini.surround",
		version = false,
		event = "VeryLazy",
		opts = {
			mappings = {
				add = "sa",
				delete = "sd",
				find = "sf",
				find_left = "sF",
				highlight = "sh",
				replace = "sr",
				update_n_lines = "sn",
			},
		},
	},

	{
		"nvim-mini/mini.pairs",
		version = false,
		event = "InsertEnter",
		opts = {},
	},

	{
		"nvim-mini/mini.icons",
		version = false,
		lazy = true,
		opts = {},
		init = function()
			package.preload["nvim-web-devicons"] = function()
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
	},
	{
		"nvim-mini/mini.files",
		version = false,
		lazy = false,
		dependencies = {
			{
				"nvim-mini/mini.icons",
				version = false,
				config = function()
					require("mini.icons").setup()
				end,
			},
		},
		opts = {
			options = {
				use_as_default_explorer = true,
			},
			windows = {
				max_number = 3,
				preview = false,
				width_focus = 30,
				width_nofocus = 30,
				width_preview = 30,
			},
		},
		keys = {
			{
				"<leader>e",
				function()
					local MiniFiles = require("mini.files")

					if MiniFiles.close() then
						return
					end

					local bufname = vim.api.nvim_buf_get_name(0)
					local path = vim.fn.filereadable(bufname) == 1 and bufname or vim.fn.getcwd()

					MiniFiles.open(path, false)
				end,
				desc = "Toggle Mini Files",
			},
		},
		config = function(_, opts)
			local MiniFiles = require("mini.files")
			MiniFiles.setup(opts)

			vim.api.nvim_create_autocmd("User", {
				pattern = "MiniFilesBufferCreate",
				callback = function(args)
					local buf_id = args.data.buf_id

					vim.keymap.set("n", "<Up>", "k", { buffer = buf_id, desc = "Move up" })
					vim.keymap.set("n", "<Down>", "j", { buffer = buf_id, desc = "Move down" })
					vim.keymap.set("n", "<Left>", MiniFiles.go_out, { buffer = buf_id, desc = "Go out" })

					-- Zwykła prawa strzałka:
					-- katalog = wejdź
					-- plik = otwórz i zamknij explorer
					vim.keymap.set("n", "<Right>", function()
						MiniFiles.go_in({ close_on_file = true })
					end, { buffer = buf_id, desc = "Go in" })

					-- Shift + Right = jak L
					vim.keymap.set("n", "<S-Right>", function()
						MiniFiles.go_in({ close_on_file = true })
					end, { buffer = buf_id, desc = "Go in plus" })

					-- Shift + Left = jak H
					vim.keymap.set("n", "<S-Left>", function()
						MiniFiles.go_out()
						MiniFiles.trim_right()
					end, { buffer = buf_id, desc = "Go out plus" })
				end,
			})
		end,
	},
	{
		"nvim-mini/mini.bufremove",
		version = false,
		keys = {
			{
				"<leader>x",
				function()
					require("mini.bufremove").delete(0, false)
				end,
				desc = "Delete buffer",
			},
			{
				"<leader>bx",
				function()
					require("mini.bufremove").delete(0, false)
				end,
				desc = "Delete buffer",
			},
		},
		opts = {},
	},
}
