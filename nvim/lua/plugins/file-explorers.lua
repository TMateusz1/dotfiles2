local oil_max_column_depth = 3

local function is_oil_win(win)
	if not win or not vim.api.nvim_win_is_valid(win) then
		return false
	end

	local buf = vim.api.nvim_win_get_buf(win)
	return vim.bo[buf].filetype == "oil"
end

local function find_main_win()
	local origin = vim.t.oil_origin_win

	if origin and vim.api.nvim_win_is_valid(origin) and not is_oil_win(origin) then
		return origin
	end

	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_win_is_valid(win) and not is_oil_win(win) then
			return win
		end
	end

	return nil
end

local function get_oil_column_wins()
	local wins = vim.t.oil_column_wins or {}
	local valid_wins = {}

	for _, win in ipairs(wins) do
		if is_oil_win(win) then
			table.insert(valid_wins, win)
		end
	end

	vim.t.oil_column_wins = valid_wins
	return valid_wins
end

local function clamp(value, min, max)
	return math.max(min, math.min(value, max))
end

local function resize_oil_columns()
	local wins = get_oil_column_wins()
	local count = #wins

	if count == 0 then
		return
	end

	local editor_width = vim.o.columns
	local editor_height = vim.o.lines - vim.o.cmdheight
	local gap = 1
	local total_width = math.min(math.floor(editor_width * 0.92), editor_width - 4)
	local total_height = math.min(math.floor(editor_height * 0.86), editor_height - 4)
	local inactive_width = 0
	local active_width = total_width

	if count > 1 then
		local inactive_space = total_width - 54 - (gap * (count - 1))

		inactive_width = clamp(math.floor(inactive_space / (count - 1)), 22, 42)
		active_width = total_width - (inactive_width * (count - 1)) - (gap * (count - 1))
		active_width = math.max(active_width, 24)
	end

	local row = math.max(1, math.floor((editor_height - total_height) / 2))
	local col = math.max(1, math.floor((editor_width - total_width) / 2))

	for index, win in ipairs(wins) do
		local width = index == count and active_width or inactive_width
		local config = vim.api.nvim_win_get_config(win)

		config.relative = "editor"
		config.row = row
		config.col = col
		config.width = width
		config.height = total_height
		config.zindex = 44 + index

		pcall(vim.api.nvim_win_set_config, win, config)
		col = col + width + gap
	end
end

local function close_oil_windows(keep_win)
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if win ~= keep_win and vim.api.nvim_win_is_valid(win) and is_oil_win(win) then
			pcall(vim.api.nvim_win_close, win, true)
		end
	end

	vim.t.oil_column_wins = keep_win and is_oil_win(keep_win) and { keep_win } or {}
end

local function close_oil_columns_after(win)
	local wins = get_oil_column_wins()
	local next_wins = {}
	local found = false

	for _, column_win in ipairs(wins) do
		if found then
			pcall(vim.api.nvim_win_close, column_win, true)
		else
			table.insert(next_wins, column_win)
		end

		if column_win == win then
			found = true
		end
	end

	vim.t.oil_column_wins = found and next_wins or wins
end

local function track_oil_column(win)
	if not is_oil_win(win) then
		return
	end

	local wins = get_oil_column_wins()

	for _, existing_win in ipairs(wins) do
		if existing_win == win then
			resize_oil_columns()
			return
		end
	end

	table.insert(wins, win)

	while #wins > oil_max_column_depth do
		local old_win = table.remove(wins, 1)

		pcall(vim.api.nvim_win_close, old_win, true)
	end

	vim.t.oil_column_wins = wins
	resize_oil_columns()
end

local function oil_open_column_mode()
	local current_win = vim.api.nvim_get_current_win()

	vim.t.oil_origin_win = is_oil_win(current_win) and find_main_win() or current_win
	close_oil_windows()
	require("oil").open_float(nil, nil, function()
		track_oil_column(vim.api.nvim_get_current_win())
	end)
end

local oil_smart_back

local function oil_smart_select()
	local oil = require("oil")
	local entry = oil.get_cursor_entry()

	if not entry then
		return
	end

	if entry.type == "directory" then
		if entry.name == ".." then
			oil_smart_back()
			return
		end

		close_oil_columns_after(vim.api.nvim_get_current_win())

		oil.select({
			handle_buffer_callback = function(bufnr)
				local dir = vim.api.nvim_buf_get_name(bufnr)

				if dir == "" then
					return
				end

				oil.open_float(dir, nil, function()
					track_oil_column(vim.api.nvim_get_current_win())
				end)
			end,
		})
		return
	end

	local target_win = find_main_win() or vim.api.nvim_get_current_win()

	oil.select({
		handle_buffer_callback = function(bufnr)
			if vim.api.nvim_win_is_valid(target_win) then
				vim.api.nvim_set_current_win(target_win)
				vim.api.nvim_win_set_buf(target_win, bufnr)
				close_oil_windows(target_win)
			else
				vim.api.nvim_set_current_buf(bufnr)
				close_oil_windows(vim.api.nvim_get_current_win())
			end
		end,
	})
end

oil_smart_back = function()
	local wins = get_oil_column_wins()

	if #wins > 1 then
		local current_win = vim.api.nvim_get_current_win()
		local last_win = table.remove(wins)
		local previous_win = wins[#wins]

		vim.t.oil_column_wins = wins
		pcall(vim.api.nvim_win_close, last_win, true)

		if vim.api.nvim_win_is_valid(previous_win) then
			vim.api.nvim_set_current_win(previous_win)
		elseif vim.api.nvim_win_is_valid(current_win) then
			vim.api.nvim_set_current_win(current_win)
		end

		resize_oil_columns()
		return
	end

	require("oil").open(nil, nil, function()
		track_oil_column(vim.api.nvim_get_current_win())
	end)
end

return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		cmd = "Neotree",
		keys = {
			{
				"<leader>E",
				"<cmd>Neotree toggle filesystem reveal left<CR>",
				desc = "Explorer",
			},
			{
				"<leader>gE",
				"<cmd>Neotree toggle git_status left<CR>",
				desc = "Git status tree",
			},
			{
				"<leader>bE",
				"<cmd>Neotree toggle buffers left<CR>",
				desc = "Buffers tree",
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-mini/mini.icons",
		},
		opts = {
			close_if_last_window = false,
			popup_border_style = "rounded",
			enable_git_status = true,
			enable_diagnostics = true,

			sources = {
				"filesystem",
				"buffers",
				"git_status",
			},

			source_selector = {
				winbar = true,
				statusline = false,
				sources = {
					{
						source = "filesystem",
						display_name = " 󰉓 Files ",
					},
					{
						source = "buffers",
						display_name = " 󰈙 Buffers ",
					},
					{
						source = "git_status",
						display_name = " 󰊢 Git ",
					},
				},
			},

			default_component_configs = {
				indent = {
					with_expanders = true,
					expander_collapsed = "",
					expander_expanded = "",
				},
				icon = {
					folder_closed = "",
					folder_open = "",
					folder_empty = "󰜌",
					default = "󰈙",
				},
				git_status = {
					symbols = {
						added = "A",
						modified = "M",
						deleted = "D",
						renamed = "R",
						untracked = "X",
						ignored = "I",
						unstaged = "U",
						staged = "S",
						conflict = "C",
					},
				},
			},

			window = {
				position = "left",
				width = 35,
				mappings = {
					["<space>"] = "none",

					["<CR>"] = "open",
					["l"] = "open",
					["h"] = "close_node",

					["o"] = "add",
					["O"] = "add_directory",
					["r"] = "rename",
					["d"] = "delete",
					["m"] = "move",
					["c"] = "copy",

					["y"] = "copy_to_clipboard",
					["x"] = "cut_to_clipboard",
					["p"] = "paste_from_clipboard",

					["R"] = "refresh",
					["?"] = "show_help",

					["."] = "toggle_hidden",
					["g?"] = "show_help",
				},
			},

			filesystem = {
				filtered_items = {
					visible = false,
					hide_dotfiles = false,
					hide_gitignored = false,
					hide_hidden = false,

					hide_by_name = {
						".git",
						".idea",
						".vscode",
					},

					never_show = {},
				},

				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},

				group_empty_dirs = false,
				hijack_netrw_behavior = "disabled",
				use_libuv_file_watcher = true,

				window = {
					mappings = {
						["."] = "toggle_hidden",
					},
				},
			},

			buffers = {
				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},
				group_empty_dirs = true,
				show_unloaded = true,
			},

			git_status = {
				window = {
					mappings = {
						["A"] = "git_add_all",
						["gu"] = "git_unstage_file",
						["ga"] = "git_add_file",
						["gr"] = "git_revert_file",
						["gc"] = "git_commit",
						["gp"] = "git_push",
						["gg"] = "git_commit_and_push",
					},
				},
			},
		},
	},
	-- OIL
	{
		"stevearc/oil.nvim",
		keys = {
			{
				"<leader>e",
				oil_open_column_mode,
				desc = "Oil file manager",
			},
			{
				"-",
				function()
					local current_win = vim.api.nvim_get_current_win()

					vim.t.oil_origin_win = is_oil_win(current_win) and find_main_win() or current_win
					close_oil_windows()
					require("oil").open_float(nil, nil, function()
						track_oil_column(vim.api.nvim_get_current_win())
					end)
				end,
				desc = "Oil parent directory",
			},
		},
		dependencies = {
			"nvim-mini/mini.icons",
		},
		opts = {
			default_file_explorer = false,

			columns = {
				"icon",
				"permissions",
				"size",
				"mtime",
			},

			buf_options = {
				buflisted = false,
				bufhidden = "hide",
			},

			win_options = {
				wrap = false,
				signcolumn = "no",
				cursorcolumn = false,
				foldcolumn = "0",
				spell = false,
				list = false,
				conceallevel = 3,
				concealcursor = "nvic",
			},

			delete_to_trash = true,
			skip_confirm_for_simple_edits = false,
			prompt_save_on_select_new_entry = true,
			cleanup_delay_ms = 2000,
			lsp_file_methods = {
				enabled = true,
				timeout_ms = 1000,
				autosave_changes = false,
			},

			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = {
					callback = oil_smart_select,
					desc = "Smart open",
				},
				["l"] = {
					callback = oil_smart_select,
					desc = "Smart open",
				},
				["<Right>"] = {
					callback = oil_smart_select,
					desc = "Smart open",
				},

				["h"] = {
					callback = oil_smart_back,
					desc = "Smart back",
				},
				["<Left>"] = {
					callback = oil_smart_back,
					desc = "Smart back",
				},
				["<BS>"] = {
					callback = oil_smart_back,
					desc = "Smart back",
				},
				["<C-v>"] = "actions.select_vsplit",
				["<C-s>"] = "actions.select_split",
				["<C-t>"] = "actions.select_tab",

				["<Esc>"] = "actions.close",
				["q"] = "actions.close",

				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",

				["`"] = "actions.cd",
				["~"] = "actions.tcd",

				["g."] = "actions.toggle_hidden",
				["R"] = "actions.refresh",
			},

			use_default_keymaps = true,

			view_options = {
				show_hidden = true,

				is_hidden_file = function(name)
					local hidden = {
						[".git"] = true,
						[".idea"] = true,
						[".vscode"] = true,
					}

					return hidden[name] == true
				end,

				is_always_hidden = function()
					return false
				end,

				natural_order = true,
				case_insensitive = false,
				sort = {
					{ "type", "asc" },
					{ "name", "asc" },
				},
			},

			float = {
				padding = 2,
				max_width = 0.9,
				max_height = 0.9,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
			},

			preview_win = {
				update_on_cursor_moved = true,
				preview_method = "fast_scratch",
				disable_preview = function(filename)
					return false
				end,
			},
		},
	},
}
