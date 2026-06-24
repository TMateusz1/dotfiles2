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
							require("nvim-treesitter-textobjects.move").goto_next_start(
								"@function.outer",
								"textobjects"
							)
						end,
						mode = { "n", "x", "o" },
						desc = "Next function start",
					},
					{
						"[f",
						function()
							require("nvim-treesitter-textobjects.move").goto_previous_start(
								"@function.outer",
								"textobjects"
							)
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
		"nvim-mini/mini.tabline",
		version = false,
		dependencies = {
			"nvim-mini/mini.icons",
		},
		event = "VeryLazy",
		opts = {
			show_icons = true,
		},
		keys = {
			-- mini.tabline has no custom cycle commands; plain buffer nav keeps
			-- the same ]b / [b motions bufferline used.
			{ "]b", "<cmd>bnext<CR>", desc = "Next buffer" },
			{ "[b", "<cmd>bprevious<CR>", desc = "Previous buffer" },
		},
	},

	--[[
	{
		"nvim-mini/mini.files",
		version = false,
		dependencies = {
			"nvim-mini/mini.icons",
		},
		opts = {
			-- Preview disabled per request.
			windows = {
				preview = false,
			},
			mappings = {
				-- Enter: directory → go in (explorer stays); file → open it and
				-- close the explorer ("hard in").
				go_in_plus = "<CR>",
				-- Backspace: go back out one level and collapse that column.
				go_out_plus = "<BS>",
				-- Freed up from its default <BS> binding.
				reset = "",
			},
		},
		init = function()
			-- Arrow aliases: <Right> = in (mirrors <CR>), <Left> = back (mirrors
			-- <BS>). Done per-buffer because mini.files binds one key per action.
			vim.api.nvim_create_autocmd("User", {
				pattern = "MiniFilesBufferCreate",
				group = vim.api.nvim_create_augroup("user_minifiles_arrows", { clear = true }),
				callback = function(args)
					local mf = require("mini.files")
					local buf = args.data.buf_id
					vim.keymap.set("n", "<Right>", function()
						mf.go_in({ close_on_file = true })
					end, { buffer = buf, desc = "Go in (file: open & close)" })
					vim.keymap.set("n", "<Left>", function()
						mf.go_out()
						mf.trim_right()
					end, { buffer = buf, desc = "Go back" })
				end,
			})
		end,
		keys = {
			{
				"<leader>e",
				function()
					local mf = require("mini.files")
					-- Toggle: close if already open, otherwise open focused on the
					-- current file (falls back to cwd for unnamed buffers).
					if not mf.close() then
						local buf = vim.api.nvim_buf_get_name(0)
						mf.open(buf ~= "" and buf or vim.uv.cwd())
					end
				end,
				desc = "File explorer (mini.files)",
			},
		},
	},
	--]]

	{
		"nvim-mini/mini.indentscope",
		version = false,
		event = { "BufReadPre", "BufNewFile" },
		opts = function()
			local indentscope = require("mini.indentscope")

			return {
				symbol = "│",
				-- No animation: draw the active-scope line instantly. This is the
				-- bolder "current block" guide layered on top of the static
				-- indent-blankline guides (it's indentation-based, so it always
				-- matches the block under the cursor, unlike ibl's treesitter scope).
				draw = {
					delay = 0,
					animation = indentscope.gen_animation.none(),
				},
				options = { try_as_border = true },
			}
		end,
		init = function()
			-- Don't draw the scope line in special / non-code buffers.
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("user_indentscope_disable", { clear = true }),
				pattern = {
					"help",
					"man",
					"qf",
					"lazy",
					"mason",
					"minifiles",
					"checkhealth",
					"gitcommit",
					"fzf",
				},
				callback = function()
					vim.b.miniindentscope_disable = true
				end,
			})
		end,
	},

	-- mini.starter is commented out for now. Re-enable it by removing the
	-- --[[ ... --]] block-comment markers around its spec.
	--[[
	{
		"nvim-mini/mini.starter",
		version = false,
		lazy = false,
		config = function()
			local starter = require("mini.starter")

			starter.setup({
				items = {
					{ section = "Menu", name = "Find File", action = function() require("fzf-lua").files() end },
					{ section = "Menu", name = "Find Text", action = function() require("fzf-lua").live_grep() end },
					{ section = "Menu", name = "Recent Files", action = function() require("fzf-lua").oldfiles() end },
					{
						section = "Menu",
						name = "Config",
						action = function()
							require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
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
	--]]

	{
		"nvim-mini/mini.animate",
		version = false,
		event = "VeryLazy",
		config = function()
			local animate = require("mini.animate")

			-- Scroll-only animation: a short, high-frequency sequence feels fluid
			-- without making page navigation feel delayed.
			animate.setup({
				scroll = {
					-- Fixed per-step timing maintains smooth motion for both <C-d>/<C-u>
					-- and PageUp/PageDown, while easing out avoids an abrupt stop.
					timing = animate.gen_timing.linear({
						duration = 8,
						easing = "out",
						unit = "step",
					}),
					subscroll = animate.gen_subscroll.equal({
						-- One-line moves stay instant; page jumps use at most 40 frames
						-- (320ms), preventing long-distance scrolling from becoming slow.
						max_output_steps = 40,
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
