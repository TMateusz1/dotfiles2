local M = {}

local list_name = "marks"
local active_root

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, {
		title = "Harpoon",
	})
end

local function project_root()
	return active_root or vim.fs.normalize(require("config.files").project_root())
end

local function absolute_path(root, path)
	if vim.startswith(path, "/") then
		return vim.fs.normalize(path)
	end

	return vim.fs.normalize(vim.fs.joinpath(root, path))
end

local function loaded_buffer(path)
	path = vim.fs.normalize(path)

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(bufnr) then
			local name = vim.api.nvim_buf_get_name(bufnr)

			if name ~= "" and vim.fs.normalize(name) == path then
				return bufnr
			end
		end
	end
end

local function read_lines(path)
	local bufnr = loaded_buffer(path)

	if bufnr and vim.api.nvim_buf_is_loaded(bufnr) then
		return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	end

	if vim.fn.filereadable(path) == 1 then
		return vim.fn.readfile(path)
	end
end

local function nearest_line(lines, saved_row, predicate)
	local best
	local best_distance

	for row, line in ipairs(lines) do
		if predicate(line) then
			local distance = math.abs(row - saved_row)

			if not best_distance or distance < best_distance then
				best = row
				best_distance = distance
			end
		end
	end

	return best
end

function M.resolve_row(lines, saved_row, line_text)
	if #lines == 0 then
		return 1
	end

	saved_row = math.max(1, math.min(tonumber(saved_row) or 1, #lines))
	line_text = type(line_text) == "string" and line_text or ""

	if lines[saved_row] == line_text then
		return saved_row
	end

	local exact = nearest_line(lines, saved_row, function(line)
		return line == line_text
	end)

	if exact then
		return exact
	end

	local trimmed = vim.trim(line_text)

	if trimmed ~= "" then
		local relaxed = nearest_line(lines, saved_row, function(line)
			return vim.trim(line) == trimmed
		end)

		if relaxed then
			return relaxed
		end
	end

	return saved_row
end

local function resolve_item(item, root)
	local path = absolute_path(root, item.value)
	local lines = read_lines(path)

	if not lines then
		return nil, path
	end

	item.context = item.context or {}

	local row = M.resolve_row(lines, item.context.row, item.context.line_text)
	local line = lines[row] or ""
	local col = math.max(0, math.min(tonumber(item.context.col) or 0, #line))
	local changed = item.context.row ~= row or item.context.col ~= col or item.context.line_text ~= line

	item.context.row = row
	item.context.col = col
	item.context.line_text = line

	return {
		path = path,
		row = row,
		col = col,
		line_text = line,
		changed = changed,
	}, nil
end

local function list()
	return require("harpoon"):list(list_name)
end

local function reconcile(target_list)
	local root = target_list.config.get_root_dir()
	local changed = false

	for index = 1, target_list:length() do
		local item = target_list:get(index)

		if item then
			local resolved = resolve_item(item, root)
			changed = resolved and resolved.changed or changed
		end
	end

	if changed then
		require("harpoon"):sync()
	end
end

local function create_item(config, displayed)
	if displayed then
		local path, row, col, line_text = displayed:match("^(.-):(%d+):(%d+):%s?(.*)$")

		if not path then
			notify("Expected path:line:column: text", vim.log.levels.WARN)
			return
		end

		return {
			value = path,
			context = {
				row = tonumber(row),
				col = math.max(tonumber(col) - 1, 0),
				line_text = line_text,
			},
		}
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local path = vim.api.nvim_buf_get_name(bufnr)

	if path == "" or vim.bo[bufnr].buftype ~= "" then
		notify("Harpoon marks require a named file buffer", vim.log.levels.WARN)
		return
	end

	local root = config.get_root_dir()
	local relative = vim.fs.relpath(root, path)

	if not relative or relative == ".." or vim.startswith(relative, "../") then
		notify("The current file is outside the active Harpoon project", vim.log.levels.WARN)
		return
	end

	local cursor = vim.api.nvim_win_get_cursor(0)
	local line_text = vim.api.nvim_buf_get_lines(bufnr, cursor[1] - 1, cursor[1], false)[1] or ""

	return {
		value = relative or vim.fs.normalize(path),
		context = {
			row = cursor[1],
			col = cursor[2],
			line_text = line_text,
		},
	}
end

local function same_item(left, right)
	if not left or not right then
		return left == right
	end

	return left.value == right.value and left.context.row == right.context.row
end

local function display_item(item)
	local context = item.context or {}

	return ("%s:%d:%d: %s"):format(
		item.value,
		tonumber(context.row) or 1,
		(tonumber(context.col) or 0) + 1,
		context.line_text or ""
	)
end

local function select_item(item, target_list, options)
	if not item then
		return
	end

	local resolved, missing = resolve_item(item, target_list.config.get_root_dir())

	if not resolved then
		notify("Marked file no longer exists: " .. missing, vim.log.levels.ERROR)
		return
	end

	options = options or {}
	local escaped = vim.fn.fnameescape(resolved.path)

	if options.vsplit then
		vim.cmd("vsplit " .. escaped)
	elseif options.split then
		vim.cmd("split " .. escaped)
	elseif options.tabedit then
		vim.cmd("tabedit " .. escaped)
	else
		vim.cmd("edit " .. escaped)
	end

	vim.api.nvim_win_set_cursor(0, { resolved.row, resolved.col })
	vim.cmd("normal! zz")

	if resolved.changed then
		require("harpoon"):sync()
	end
end

function M.setup()
	active_root = vim.fs.normalize(require("config.files").project_root())

	require("harpoon"):setup({
		settings = {
			key = project_root,
			save_on_toggle = true,
			sync_on_ui_close = true,
		},
		[list_name] = {
			get_root_dir = project_root,
			create_list_item = create_item,
			equals = same_item,
			display = display_item,
			select = select_item,
			BufLeave = function() end,
		},
	})
end

function M.add()
	local target_list = list()
	local item = create_item(target_list.config)

	if not item then
		return
	end

	for index = 1, target_list:length() do
		if same_item(target_list:get(index), item) then
			notify(("Already marked: %s:%d"):format(item.value, item.context.row))
			return
		end
	end

	target_list:add(item)
	notify(("Marked: %s:%d"):format(item.value, item.context.row))
end

function M.inspect()
	local target_list = list()
	reconcile(target_list)

	require("harpoon").ui:toggle_quick_menu(target_list, {
		border = "rounded",
		title = " Harpoon marks ",
		title_pos = "center",
		height_in_lines = math.max(1, math.min(target_list:length(), 15)),
	})
end

function M.select(index)
	local target_list = list()

	if not target_list:get(index) then
		notify("No Harpoon mark in slot " .. index, vim.log.levels.WARN)
		return
	end

	target_list:select(index)
end

function M.fzf()
	local target_list = list()
	reconcile(target_list)

	local entries = {}
	local indices = {}

	for index = 1, target_list:length() do
		local item = target_list:get(index)

		if item then
			local entry = display_item(item)

			entries[#entries + 1] = entry
			indices[entry] = index
		end
	end

	if #entries == 0 then
		notify("No Harpoon marks in this project", vim.log.levels.WARN)
		return
	end

	require("fzf-lua").fzf_exec(entries, {
		cwd = target_list.config.get_root_dir(),
		prompt = "Harpoon marks > ",
		previewer = "builtin",
		actions = {
			["default"] = function(selected)
				local index = selected[1] and indices[selected[1]]

				if index then
					target_list:select(index)
				end
			end,
		},
	})
end

return M
