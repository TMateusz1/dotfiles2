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

local function close_all_oil_columns()
	local target_win = find_main_win()

	close_oil_windows()

	if target_win and vim.api.nvim_win_is_valid(target_win) then
		vim.api.nvim_set_current_win(target_win)
	end
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

local minifiles_git_cache = {}
local minifiles_ns = vim.api.nvim_create_namespace("user_minifiles")

local function path_exists(path)
	return path ~= nil and vim.uv.fs_stat(path) ~= nil
end

local function path_type(path)
	local stat = path and vim.uv.fs_stat(path) or nil

	return stat and stat.type or nil
end

local function path_dir(path)
	if path == nil or path == "" then
		return vim.uv.cwd()
	end

	path = vim.fs.normalize(path)

	if path_type(path) == "directory" then
		return path
	end

	return vim.fs.dirname(path)
end

local function git_root_for(path)
	local dir = path_dir(path)

	if not path_exists(dir) then
		return nil
	end

	local git_path = vim.fs.find(".git", {
		path = dir,
		upward = true,
	})[1]

	return git_path and vim.fs.dirname(git_path) or nil
end

local function is_path_inside(root, path)
	root = vim.fs.normalize(root)
	path = vim.fs.normalize(path)

	return path == root or vim.startswith(path, root .. "/")
end

local function branch_from_root(root, target)
	if root == nil or target == nil or not is_path_inside(root, target) then
		return nil, nil
	end

	root = vim.fs.normalize(root)
	target = vim.fs.normalize(target)

	local target_dir = path_type(target) == "file" and vim.fs.dirname(target) or target
	local dirs = {}
	local current = target_dir

	while current ~= nil and current ~= root and is_path_inside(root, current) do
		table.insert(dirs, 1, current)
		current = vim.fs.dirname(current)
	end

	local branch = { root }

	for _, dir in ipairs(dirs) do
		table.insert(branch, dir)
	end

	local depth_focus = #branch

	return branch, depth_focus
end

local function focus_minifiles_path(minifiles, path)
	local state = minifiles.get_explorer_state()

	if state == nil or path == nil then
		return
	end

	path = vim.fs.normalize(path)

	for _, win in ipairs(state.windows) do
		if vim.api.nvim_win_is_valid(win.win_id) then
			local buf = vim.api.nvim_win_get_buf(win.win_id)
			local line_count = vim.api.nvim_buf_line_count(buf)

			for line = 1, line_count do
				local ok, entry = pcall(minifiles.get_fs_entry, buf, line)

				if ok and entry and vim.fs.normalize(entry.path) == path then
					vim.api.nvim_set_current_win(win.win_id)
					vim.api.nvim_win_set_cursor(win.win_id, { line, 0 })
					return
				end
			end
		end
	end
end

local function open_minifiles()
	local minifiles = require("mini.files")
	local path = vim.api.nvim_buf_get_name(0)

	if path == "" then
		minifiles.open(vim.uv.cwd(), false)
		return
	end

	path = vim.fs.normalize(path)

	if path_type(path) ~= "file" then
		minifiles.open(path, false)
		return
	end

	local root = git_root_for(path)
	local branch, depth_focus = branch_from_root(root, path)

	if branch == nil then
		minifiles.open(path, false)
		return
	end

	minifiles.open(root, false)
	minifiles.set_branch(branch, {
		depth_focus = depth_focus,
	})
	focus_minifiles_path(minifiles, path)
end

local function set_minifiles_target_split(minifiles, direction)
	local state = minifiles.get_explorer_state()

	if state == nil or not vim.api.nvim_win_is_valid(state.target_window) then
		return false
	end

	local new_target = vim.api.nvim_win_call(state.target_window, function()
		vim.cmd(direction)
		return vim.api.nvim_get_current_win()
	end)

	minifiles.set_target_window(new_target)
	return true
end

local function minifiles_open_in_split(minifiles, direction)
	return function()
		local entry = minifiles.get_fs_entry()

		if entry == nil or entry.fs_type == "directory" then
			minifiles.go_in({
				close_on_file = true,
			})
			return
		end

		if set_minifiles_target_split(minifiles, direction) then
			minifiles.go_in({
				close_on_file = true,
			})
		end
	end
end

local function get_git_status_for_root(root)
	if root == nil or vim.fn.executable("git") ~= 1 then
		return {}
	end

	local now = vim.uv.now()
	local cached = minifiles_git_cache[root]

	if cached and now - cached.time < 1500 then
		return cached.status
	end

	local result = vim.system({
		"git",
		"-C",
		root,
		"status",
		"--porcelain=v1",
		"--ignored=matching",
	}, {
		text = true,
	}):wait()

	local status = {}

	if result.code == 0 then
		for line in result.stdout:gmatch("[^\r\n]+") do
			local code = line:sub(1, 2)
			local relpath = line:sub(4)

			if relpath:find(" %-> ") then
				relpath = relpath:match(".* %-> (.*)")
			end

			relpath = relpath:gsub('^"', ""):gsub('"$', "")
			local marker = code:find("%?") and "?"
				or code:find("!") and "!"
				or code:find("D") and "D"
				or code:find("R") and "R"
				or code:find("A") and "A"
				or code:find("M") and "M"
				or nil

			if marker then
				status[vim.fs.normalize(root .. "/" .. relpath)] = marker
			end
		end
	end

	minifiles_git_cache[root] = {
		status = status,
		time = now,
	}

	return status
end

local function get_diagnostic_markers()
	local markers = {}
	local severity_marker = {
		[vim.diagnostic.severity.ERROR] = "E",
		[vim.diagnostic.severity.WARN] = "W",
		[vim.diagnostic.severity.INFO] = "I",
		[vim.diagnostic.severity.HINT] = "H",
	}

	for _, diagnostic in ipairs(vim.diagnostic.get(nil)) do
		local name = vim.api.nvim_buf_is_valid(diagnostic.bufnr) and vim.api.nvim_buf_get_name(diagnostic.bufnr) or nil

		if name and name ~= "" then
			local path = vim.fs.normalize(name)
			local current = markers[path]

			if current == nil or diagnostic.severity < current.severity then
				markers[path] = {
					marker = severity_marker[diagnostic.severity],
					severity = diagnostic.severity,
				}
			end
		end
	end

	return markers
end

local function marker_highlight(marker)
	if marker == "E" or marker == "D" then
		return "DiagnosticVirtualTextError"
	end

	if marker == "W" or marker == "M" then
		return "DiagnosticVirtualTextWarn"
	end

	if marker == "?" or marker == "!" then
		return "DiagnosticVirtualTextHint"
	end

	return "DiagnosticVirtualTextInfo"
end

local function update_minifiles_marks(minifiles, buf_id)
	if not vim.api.nvim_buf_is_valid(buf_id) then
		return
	end

	vim.api.nvim_buf_clear_namespace(buf_id, minifiles_ns, 0, -1)

	local line_count = vim.api.nvim_buf_line_count(buf_id)
	local diagnostics = get_diagnostic_markers()
	local root

	for line = 1, line_count do
		local ok, entry = pcall(minifiles.get_fs_entry, buf_id, line)

		if ok and entry and root == nil then
			root = git_root_for(entry.path)
			break
		end
	end

	local git_status = get_git_status_for_root(root)

	for line = 1, line_count do
		local ok, entry = pcall(minifiles.get_fs_entry, buf_id, line)

		if ok and entry then
			local path = vim.fs.normalize(entry.path)
			local text = {}
			local git_marker = git_status[path]
			local diagnostic = diagnostics[path]

			if git_marker then
				table.insert(text, { " " .. git_marker, marker_highlight(git_marker) })
			end

			if diagnostic then
				table.insert(text, { " " .. diagnostic.marker, marker_highlight(diagnostic.marker) })
			end

			if #text > 0 then
				vim.api.nvim_buf_set_extmark(buf_id, minifiles_ns, line - 1, 0, {
					virt_text = text,
					virt_text_pos = "right_align",
				})
			end
		end
	end
end

local function clear_minifiles_git_cache()
	minifiles_git_cache = {}
end

return {
	{
		"nvim-mini/mini.files",
		version = false,
		keys = {
			{
				"<leader>e",
				open_minifiles,
				desc = "Mini.files",
			},
		},
		dependencies = {
			"nvim-mini/mini.icons",
		},
		opts = {
			mappings = {
				close = "q",
				go_in = "",
				go_in_plus = "",
				go_out = "",
				go_out_plus = "",
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
			},
			windows = {
				max_number = 4,
				preview = false,
				width_focus = 44,
				width_nofocus = 24,
				width_preview = 44,
			},
		},
		config = function(_, opts)
			local minifiles = require("mini.files")

			minifiles.setup(opts)

			vim.api.nvim_create_autocmd("User", {
				pattern = "MiniFilesBufferCreate",
				callback = function(args)
					local buf_id = args.data.buf_id
					local map = function(lhs, rhs, desc)
						vim.keymap.set("n", lhs, rhs, {
							buffer = buf_id,
							desc = desc,
							silent = true,
						})
					end

					local go_in = function()
						minifiles.go_in({
							close_on_file = true,
						})
					end

					map("<CR>", go_in, "Open entry")
					map("l", go_in, "Open entry")
					map("<Right>", go_in, "Open entry")

					map("<BS>", minifiles.go_out, "Go to parent directory")
					map("h", minifiles.go_out, "Go to parent directory")
					map("<Left>", minifiles.go_out, "Go to parent directory")

					map(
						"<C-v>",
						minifiles_open_in_split(minifiles, "belowright vertical split"),
						"Open in vertical split"
					)
					map(
						"<C-s>",
						minifiles_open_in_split(minifiles, "belowright split"),
						"Open in horizontal split"
					)
					map("<C-t>", minifiles_open_in_split(minifiles, "tab split"), "Open in tab")

					map("<Esc>", minifiles.close, "Close explorer")
				end,
			})

			vim.api.nvim_create_autocmd("User", {
				pattern = "MiniFilesBufferUpdate",
				callback = function(args)
					update_minifiles_marks(minifiles, args.data.buf_id)
				end,
			})

			vim.api.nvim_create_autocmd("User", {
				pattern = {
					"MiniFilesActionCreate",
					"MiniFilesActionDelete",
					"MiniFilesActionRename",
					"MiniFilesActionCopy",
					"MiniFilesActionMove",
				},
				callback = clear_minifiles_git_cache,
			})
		end,
	},
	-- OIL
	{
		"stevearc/oil.nvim",
		keys = {
			{
				"<leader>E",
				oil_open_column_mode,
				desc = "Oil multi-file edit",
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

				["<Esc>"] = {
					callback = close_all_oil_columns,
					desc = "Close all Oil columns",
				},
				["q"] = {
					callback = close_all_oil_columns,
					desc = "Close all Oil columns",
				},

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
