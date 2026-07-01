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

local root_markers = {
	".git",
	"go.mod",
	"package.json",
	"Cargo.toml",
	"pyproject.toml",
	"flake.nix",
	"Makefile",
}

local function existing_path_or_cwd(path)
	if path ~= "" and vim.uv.fs_stat(path) ~= nil then
		return path
	end

	return vim.fn.getcwd()
end

local function current_buffer_path()
	return existing_path_or_cwd(vim.api.nvim_buf_get_name(0))
end

local function project_root()
	local path = current_buffer_path()
	local stat = vim.uv.fs_stat(path)
	local start = stat and stat.type == "directory" and path or vim.fs.dirname(path)
	local marker = vim.fs.find(root_markers, { path = start, upward = true })[1]

	return marker and vim.fs.dirname(marker) or vim.fn.getcwd()
end

local minifiles_preview_scheduled = false

local function focused_minifiles_entry()
	local files = require("mini.files")
	local state = files.get_explorer_state()

	if state == nil then
		return nil, nil
	end

	local focused_path = state.branch[state.depth_focus]

	for _, window in ipairs(state.windows) do
		if window.path == focused_path and vim.api.nvim_win_is_valid(window.win_id) then
			local buf_id = vim.api.nvim_win_get_buf(window.win_id)
			local line = vim.api.nvim_win_get_cursor(window.win_id)[1]
			if line < 1 or line > vim.api.nvim_buf_line_count(buf_id) then
				return nil, state
			end

			local ok, entry = pcall(files.get_fs_entry, buf_id, line)
			if not ok then
				return nil, state
			end

			return entry, state
		end
	end

	return nil, state
end

local function update_minifiles_directory_preview()
	if minifiles_preview_scheduled then
		return
	end

	minifiles_preview_scheduled = true

	vim.schedule(function()
		minifiles_preview_scheduled = false

		local entry, state = focused_minifiles_entry()
		if entry == nil or state == nil then
			return
		end

		local next_path = state.branch[state.depth_focus + 1]

		if entry.fs_type == "directory" and next_path == entry.path then
			return
		end

		if entry.fs_type ~= "directory" and next_path == nil then
			return
		end

		local branch = {}
		for depth = 1, state.depth_focus do
			branch[depth] = state.branch[depth]
		end
		if entry.fs_type == "directory" then
			branch[state.depth_focus + 1] = entry.path
		end

		require("mini.files").set_branch(branch, { depth_focus = state.depth_focus })
	end)
end

return {
	{
		"nvim-mini/mini.files",
		version = false,
		lazy = false,
		dependencies = {
			"nvim-mini/mini.icons",
		},
		opts = {
			mappings = {
				close = "q",
				go_in = "<CR>",
				go_in_plus = "<S-CR>",
				go_out = "<Left>",
				go_out_plus = "<S-Left>",
				mark_goto = "'",
				mark_set = "m",
				reset = "",
				reveal_cwd = "@",
				show_help = "g?",
				synchronize = "=",
				trim_left = "<",
				trim_right = ">",
			},
			options = {
				permanent_delete = false,
				use_as_default_explorer = false,
				lsp_timeout = 1000,
			},
			windows = {
				preview = false,
				width_focus = 44,
				width_nofocus = 22,
			},
		},
		config = function(_, opts)
			require("mini.files").setup(opts)

			vim.api.nvim_create_autocmd("User", {
				group = vim.api.nvim_create_augroup("user_minifiles", { clear = true }),
				pattern = "MiniFilesBufferCreate",
				callback = function(args)
					local map_opts = { buffer = args.data.buf_id, desc = "Open entry" }

					vim.keymap.set("n", "<Right>", function()
						require("mini.files").go_in()
					end, map_opts)
					vim.keymap.set("n", "l", function()
						require("mini.files").go_in()
					end, map_opts)
					vim.keymap.set("n", "h", function()
						require("mini.files").go_out()
					end, { buffer = args.data.buf_id, desc = "Go to parent" })
				end,
			})

			vim.api.nvim_create_autocmd("User", {
				group = vim.api.nvim_create_augroup("user_minifiles", { clear = false }),
				pattern = "MiniFilesWindowUpdate",
				callback = update_minifiles_directory_preview,
			})
		end,
		keys = {
			{
				"<leader>e",
				function()
					require("mini.files").open(current_buffer_path(), false)
				end,
				desc = "Explore current file directory",
			},
			{
				"<leader>E",
				function()
					require("mini.files").open(project_root(), false)
				end,
				desc = "Explore project root",
			},
		},
	},

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
