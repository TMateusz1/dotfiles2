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
		dependencies = {
			-- Ships the textobjects.scm queries the treesitter specs below
			-- read, plus the ]f / [f function motions.
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
				branch = "main",
				keys = {
					{
						"]f",
						function()
							require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
						end,
						mode = { "n", "x", "o" },
						desc = "Next function start",
					},
					{
						"[f",
						function()
							require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
						end,
						mode = { "n", "x", "o" },
						desc = "Previous function start",
					},
				},
				opts = {
					move = {
						-- Record motions in the jumplist so <C-o> goes back.
						set_jumps = true,
					},
				},
			},
		},
		opts = function()
			local ai = require("mini.ai")

			return {
				n_lines = 500,
				custom_textobjects = {
					-- f: function/method definition (default f = call moves to F)
					f = ai.gen_spec.treesitter({
						a = "@function.outer",
						i = "@function.inner",
					}),
					F = ai.gen_spec.function_call(),
					-- o: surrounding block / conditional / loop
					o = ai.gen_spec.treesitter({
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}),
					-- c: type declaration (struct/interface in Go, class elsewhere)
					c = ai.gen_spec.treesitter({
						a = "@class.outer",
						i = "@class.inner",
					}),
				},
			}
		end,
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

					-- C-v / C-s: open the file in a vertical / horizontal split
					-- (matching the snacks pickers). On a directory, just enter it.
					local function map_split(lhs, command, desc)
						map(lhs, function()
							local entry = MiniFiles.get_fs_entry()
							if entry == nil then
								return
							end
							if entry.fs_type == "directory" then
								MiniFiles.go_in()
								return
							end

							local target = MiniFiles.get_explorer_state().target_window
							if target == nil then
								return
							end

							local new_target
							vim.api.nvim_win_call(target, function()
								vim.cmd("belowright " .. command)
								new_target = vim.api.nvim_get_current_win()
							end)

							MiniFiles.set_target_window(new_target)
							MiniFiles.go_in({ close_on_file = true })
						end, desc)
					end

					map_split("<C-v>", "vsplit", "Open in vertical split")
					map_split("<C-s>", "split", "Open in horizontal split")

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
					-- Fixed per-step delay keeps the perceived frame rate constant
					-- regardless of scroll distance (unlike "total", which spreads
					-- a short scroll over only a couple of choppy frames).
					timing = animate.gen_timing.linear({ duration = 12, unit = "step" }),
					subscroll = animate.gen_subscroll.equal({
						-- Don't animate small scrolls (e.g. short C-d/C-u or n/N
						-- jumps of a few lines) — those are the ones that looked
						-- like the screen was freezing. Cap steps so huge jumps
						-- stay snappy too.
						predicate = function(total_scroll)
							return total_scroll > 6
						end,
						max_output_steps = 60,
					}),
				},
				cursor = { enable = false },
				resize = { enable = false },
				open = { enable = false },
				close = { enable = false },
			})
		end,
	},
}
