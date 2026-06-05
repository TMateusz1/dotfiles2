local function current_list()
	return require("harpoon"):list()
end

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, {
		title = "Harpoon",
	})
end

local function item_position(item)
	local context = item and item.context or {}
	local row = tonumber(context.marked_row or context.row) or 1
	local col = tonumber(context.marked_col or context.col) or 0

	return row, col
end

local function same_mark(a, b)
	if a == nil and b == nil then
		return true
	elseif a == nil or b == nil then
		return false
	end

	local a_row = item_position(a)
	local b_row = item_position(b)

	return a.value == b.value and a_row == b_row
end

local function existing_mark(list, item)
	for index = 1, list:length() do
		local existing = list:get(index)

		if same_mark(existing, item) then
			return existing, index
		end
	end
end

local function set_cursor_to_item(item)
	local row, col = item_position(item)
	local line_count = vim.api.nvim_buf_line_count(0)

	row = math.min(math.max(row, 1), line_count)

	local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""

	col = math.min(math.max(col, 0), #line)

	vim.api.nvim_win_set_cursor(0, { row, col })
end

local function current_mark_item(list)
	local item = list.config.create_list_item(list.config)
	local row, col = item_position(item)

	item.context = item.context or {}
	item.context.marked_row = row
	item.context.marked_col = col

	return item
end

local function mark_slot(index)
	local harpoon = require("harpoon")
	local list = harpoon:list()

	list:replace_at(index, current_mark_item(list))
	harpoon:sync()
	notify(("Marked current line as Harpoon %d"):format(index))
end

local function mark_newest()
	local harpoon = require("harpoon")
	local list = harpoon:list()
	local item = current_mark_item(list)
	local _, existing_index = existing_mark(list, item)

	if existing_index then
		notify(("Harpoon mark already exists at %d"):format(existing_index))
		return
	end

	list:remove(item)
	list:replace_at(list:length() + 1, item)
	harpoon:sync()
	notify(("Marked current line as Harpoon %d"):format(list:length()))
end

local function select_slot(index, command)
	local list = current_list()
	local item = list:get(index)

	if not item then
		return
	end

	if command then
		vim.cmd[command]()
	end

	list:select(index)
	set_cursor_to_item(item)
end

local function harpoon_location(item)
	local row = item_position(item)

	return ("%s:%d"):format(item.value, row)
end

local function harpoon_picker_item(index, item)
	local row, col = item_position(item)

	return {
		text = harpoon_location(item),
		label = ("[%d]"):format(index),
		file = item.value,
		pos = { row, col },
		harpoon_index = index,
	}
end

local function harpoon_entry_sort_key(record)
	return record.index
end

local function harpoon_entry_records()
	local list = current_list()
	local records = {}

	for index = 1, list:length() do
		local item = list:get(index)

		if item then
			table.insert(records, {
				index = index,
				item = item,
				entry = harpoon_picker_item(index, item),
			})
		end
	end

	table.sort(records, function(a, b)
		local a_key = harpoon_entry_sort_key(a)
		local b_key = harpoon_entry_sort_key(b)

		if a_key == b_key then
			return a.index < b.index
		end

		return a_key < b_key
	end)

	return records
end

local function harpoon_picker_items()
	local records = harpoon_entry_records()
	local entries = {}

	for _, record in ipairs(records) do
		table.insert(entries, record.entry)
	end

	return entries
end

local function current_buffer_focus_position(list, records)
	local current = list.config.create_list_item(list.config)

	if not current or current.value == "" then
		return 1
	end

	local current_row = item_position(current)
	local same_file_position

	for position, record in ipairs(records) do
		if record.item.value == current.value then
			same_file_position = same_file_position or position

			if item_position(record.item) == current_row then
				return position
			end
		end
	end

	return same_file_position or 1
end

local function reset_list_length(list)
	local length = 0

	for index, item in pairs(list.items) do
		if type(index) == "number" and item and index > length then
			length = index
		end
	end

	list._length = length
end

local open_harpoon_files

local function move_harpoon_mark(index, offset)
	local harpoon = require("harpoon")
	local list = harpoon:list()
	local target = index + offset

	if not list:get(index) or target < 1 or target > list:length() then
		return
	end

	list.items[index], list.items[target] = list.items[target], list.items[index]
	reset_list_length(list)
	harpoon:sync()
	return target
end

local function move_harpoon_action(offset)
	return function(picker, item)
		local index = item and item.harpoon_index

		if index then
			local target = move_harpoon_mark(index, offset)

			if target then
				picker:close()
				vim.schedule(function()
					open_harpoon_files(target)
				end)
			end
		end
	end
end

open_harpoon_files = function(focus_index)
	local records = harpoon_entry_records()

	if #records == 0 then
		notify("No Harpoon files marked yet")
		return
	end

	local list = current_list()
	local focus_position = focus_index or current_buffer_focus_position(list, records)

	focus_position = math.min(math.max(focus_position, 1), #records)

	Snacks.picker({
		source = "harpoon",
		title = "Harpoon Files",
		cwd = list.config.get_root_dir(),
		items = harpoon_picker_items(),
		format = "file",
		preview = "file",
		sort = {
			fields = { "idx" },
		},
		jump = {
			close = true,
			reuse_win = true,
		},
		on_show = function(picker)
			picker.list:view(focus_position)
		end,
		actions = {
			confirm = function(picker, item)
				local index = item and item.harpoon_index

				if index then
					picker:close()
					select_slot(index)
				end
			end,
			harpoon_vsplit = function(picker, item)
				local index = item and item.harpoon_index

				if index then
					picker:close()
					select_slot(index, "vsplit")
				end
			end,
			harpoon_remove = function(picker, item)
				local index = item and item.harpoon_index

				if not index then
					return
				end

				local harpoon = require("harpoon")

				harpoon:list():remove_at(index)
				harpoon:sync()
				picker:close()
				vim.schedule(function()
					open_harpoon_files(index)
				end)
			end,
			harpoon_move_up = move_harpoon_action(-1),
			harpoon_move_down = move_harpoon_action(1),
		},
		win = {
			input = {
				keys = {
					["<c-v>"] = { "harpoon_vsplit", mode = { "n", "i" } },
					["<c-x>"] = { "harpoon_remove", mode = { "n", "i" } },
					["<c-k>"] = { "harpoon_move_up", mode = { "n", "i" } },
					["<c-up>"] = { "harpoon_move_up", mode = { "n", "i" } },
					["<c-j>"] = { "harpoon_move_down", mode = { "n", "i" } },
					["<c-down>"] = { "harpoon_move_down", mode = { "n", "i" } },
				},
			},
			list = {
				keys = {
					["<c-v>"] = "harpoon_vsplit",
					["<c-x>"] = "harpoon_remove",
					["<c-k>"] = "harpoon_move_up",
					["<c-up>"] = "harpoon_move_up",
					["<c-j>"] = "harpoon_move_down",
					["<c-down>"] = "harpoon_move_down",
				},
			},
		},
	})
end

local function mark_key(index)
	return {
		("<leader>m%d"):format(index),
		function()
			mark_slot(index)
		end,
		desc = ("Mark Harpoon file %d"):format(index),
	}
end

local function select_key(index)
	return {
		("<leader>%d"):format(index),
		function()
			select_slot(index)
		end,
		desc = ("Go to Harpoon file %d"):format(index),
	}
end

local keys = {
	{
		"<leader>fm",
		open_harpoon_files,
		desc = "Harpoon files",
	},
	{
		"<leader>mm",
		mark_newest,
		desc = "Mark newest Harpoon file",
	},
}

for index = 1, 3 do
	table.insert(keys, mark_key(index))
	table.insert(keys, select_key(index))
end

return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = {
			"folke/snacks.nvim",
			"nvim-lua/plenary.nvim",
		},
		keys = keys,
		config = function()
			require("harpoon"):setup({
				default = {
					equals = same_mark,
				},
			})
		end,
	},
}
