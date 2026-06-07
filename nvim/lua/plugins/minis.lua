local function is_floating_window()
	local config = vim.api.nvim_win_get_config(0)

	return config.relative ~= ""
end

local function is_special_window()
	local filetype = vim.bo.filetype
	local buftype = vim.bo.buftype

	local special_filetypes = {
		["qf"] = true,
		["help"] = true,
		["man"] = true,

		["neotest-summary"] = true,
		["neotest-output"] = true,
		["neotest-output-panel"] = true,
	}

	if special_filetypes[filetype] then
		return true
	end

	if buftype ~= "" then
		return true
	end

	return false
end

local function smart_close()
	if is_floating_window() or is_special_window() then
		vim.cmd("close")
		return
	end

	require("mini.bufremove").delete(0)
end
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
		"nvim-mini/mini.files",
		version = false,
		opts = {
			-- `=` synchronizes the explorer's pending changes to disk.
			mappings = {
				synchronize = "=",
			},
			windows = {
				preview = false,
				width_focus = 30,
			},
			options = {
				use_as_default_explorer = true,
			},
		},
		keys = {
			{
				"<leader>e",
				function()
					local MiniFiles = require("mini.files")
					-- Toggle: close if open, otherwise open at the current file.
					if not MiniFiles.close() then
						local path = vim.api.nvim_buf_get_name(0)
						if path == "" or vim.fn.filereadable(path) == 0 then
							path = vim.fn.getcwd()
						end
						MiniFiles.open(path)
					end
				end,
				desc = "File explorer (mini.files)",
			},
		},
		config = function(_, opts)
			local MiniFiles = require("mini.files")
			MiniFiles.setup(opts)

			vim.api.nvim_create_autocmd("User", {
				pattern = "MiniFilesBufferCreate",
				callback = function(args)
					local buf = args.data.buf_id
					local map = function(lhs, rhs, desc)
						vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
					end

					-- Arrows: up/down move the cursor, left/right navigate (h/l).
					map("<Down>", "j", "Move down")
					map("<Up>", "k", "Move up")
					map("<Right>", MiniFiles.go_in, "Go in (l)")
					map("<Left>", MiniFiles.go_out, "Go out (h)")

					-- Backspace also goes back (h).
					map("<BS>", MiniFiles.go_out, "Go back (h)")

					-- Enter: directory -> go in; file -> open in current window
					-- and close the explorer.
					map("<CR>", function()
						MiniFiles.go_in({ close_on_file = true })
					end, "Open file / enter dir")

					-- Synchronize with <leader>w too, mirroring the global save map.
					map("<leader>w", MiniFiles.synchronize, "Synchronize (save changes)")
				end,
			})
		end,
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
		"nvim-mini/mini.bufremove",
		version = false,
		config = function()
			require("mini.bufremove").setup()
		end,
		keys = {
			{
				"<leader>q",
				function()
					smart_close()
				end,
				desc = "Smart close",
			},
			{
				"<leader>W",
				function()
					local ok, err = pcall(vim.cmd.write)

					if not ok then
						vim.notify("Save failed: " .. tostring(err), vim.log.levels.ERROR, {
							title = "Buffer",
						})
						return
					end
					require("mini.bufremove").delete(0)
				end,
				desc = "Save and close buffer",
			},
			{
				"<leader>bx",
				function()
					require("mini.bufremove").delete(0)
				end,
				desc = "Delete buffer",
			},
		},
	},

	{
		"nvim-mini/mini.notify",
		version = false,
		lazy = false,
		opts = {
			lsp_progress = {
				enable = false,
			},
			window = {
				config = {
					border = "rounded",
				},
				winblend = 0,
			},
		},
		config = function(_, opts)
			local MiniNotify = require("mini.notify")
			MiniNotify.setup(opts)
			-- Route all `vim.notify` calls through mini.notify.
			vim.notify = MiniNotify.make_notify()
		end,
	},

	{
		"nvim-mini/mini.starter",
		version = false,
		lazy = false,
		config = function()
			local starter = require("mini.starter")

			starter.setup({
				items = {
					{ section = "Menu", name = "Find File", action = function() Snacks.picker.files() end },
					{ section = "Menu", name = "Find Text", action = function() Snacks.picker.grep() end },
					{ section = "Menu", name = "Recent Files", action = function() Snacks.picker.recent() end },
					{
						section = "Menu",
						name = "Config",
						action = function()
							Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
						end,
					},
					{
						section = "Menu",
						name = "Sessions",
						action = function()
							require("persistence").select()
						end,
					},
					{ section = "Menu", name = "Lazy", action = "Lazy" },
					{ section = "Menu", name = "Quit", action = "qa" },
					starter.sections.recent_files(5, false),
				},
				content_hooks = {
					starter.gen_hook.adding_bullet(),
					starter.gen_hook.aligning("center", "center"),
				},
			})
		end,
	},

	{
		"nvim-mini/mini.animate",
		version = false,
		event = "VeryLazy",
		config = function()
			local animate = require("mini.animate")
			-- Smooth scrolling only (replacing Snacks `scroll`); leave the
			-- cursor/window animations off to match the previous behaviour.
			animate.setup({
				scroll = {
					timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
				},
				cursor = { enable = false },
				resize = { enable = false },
				open = { enable = false },
				close = { enable = false },
			})
		end,
	},
}
