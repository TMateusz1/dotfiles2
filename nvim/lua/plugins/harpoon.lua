local harpoon_entry_separator = "\t"

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

local function clean_label(label)
	if type(label) ~= "string" then
		return nil
	end

	label = vim.trim(label:gsub("[%c]", " "))

	return label ~= "" and label or nil
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
	local existing = existing_mark(list, item)

	item.context = item.context or {}
	item.context.marked_row = row
	item.context.marked_col = col
	item.context.label = clean_label(existing and existing.context and existing.context.label)

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

local function select_slot(index)
	local list = current_list()
	local item = list:get(index)

	if not item then
		return
	end

	list:select(index)
	set_cursor_to_item(item)
end

local function item_label(item)
	return clean_label(item and item.context and item.context.label)
end

local function harpoon_location(item)
	local row = item_position(item)

	return ("%s:%d"):format(item.value, row)
end

local function harpoon_display(item)
	local location = harpoon_location(item)
	local label = item_label(item)

	if label then
		return ("%s  %s"):format(label, location)
	end

	return location
end

local function harpoon_entry(index, item)
	local row, col = item_position(item)

	return table.concat({
		("%d  %s"):format(index, harpoon_display(item)),
		tostring(index),
		item.value,
		tostring(row),
		tostring(col),
	}, harpoon_entry_separator)
end

local function harpoon_entries()
	local list = current_list()
	local entries = {}

	for index = 1, list:length() do
		local item = list:get(index)

		if item then
			table.insert(entries, harpoon_entry(index, item))
		end
	end

	return entries
end

local function parse_harpoon_entry(line)
	if not line then
		return nil
	end

	return tonumber(line:match("\t(%d+)\t"))
end

local function selected_harpoon_index(selected)
	return parse_harpoon_entry(selected and selected[1])
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
end

local function move_harpoon_action(offset)
	return {
		fn = function(selected)
			local index = selected_harpoon_index(selected)

			if index then
				move_harpoon_mark(index, offset)
			end
		end,
		reload = true,
	}
end

local function rename_harpoon_mark(selected)
	local index = selected_harpoon_index(selected)

	if not index then
		return
	end

	local harpoon = require("harpoon")
	local list = harpoon:list()
	local item = list:get(index)

	if not item then
		return
	end

	local name = require("fzf-lua.utils").input(
		("Harpoon name (%s): "):format(harpoon_location(item)),
		item_label(item) or ""
	)

	if name then
		name = vim.trim(name:gsub("[%c]", " "))
		item.context = item.context or {}
		item.context.label = name ~= "" and name or nil
		harpoon:sync()
	end
end

local function harpoon_preview_command()
	return table.concat({
		"line={4};",
		"if [ -z \"$line\" ]; then line=1; fi;",
		"if [ \"$line\" -gt 8 ]; then start=$((line - 8)); else start=1; fi;",
		"end=$((line + 8));",
		"if [ -f {3} ]; then",
		"(command -v bat >/dev/null && bat --color=always --style=numbers --line-range=${start}:${end} --highlight-line=${line} {3}) ||",
		"sed -n \"${start},${end}p\" {3};",
		"else",
		"printf '%s\\n' 'File not found: {3}';",
		"fi",
	}, " ")
end

local function open_harpoon_files()
	local entries = harpoon_entries()

	if #entries == 0 then
		notify("No Harpoon files marked yet")
		return
	end

	local list = current_list()

	require("fzf-lua").fzf_exec(function(cb)
		for _, entry in ipairs(harpoon_entries()) do
			cb(entry)
		end

		cb(nil)
	end, {
		cwd = list.config.get_root_dir(),
		prompt = "Harpoon> ",
		winopts = {
			title = " Harpoon Files ",
			height = 0.85,
			width = 0.85,
			preview = {
				layout = "flex",
				vertical = "down:45%",
				horizontal = "right:55%",
			},
		},
		actions = {
			["enter"] = function(selected)
				local index = selected_harpoon_index(selected)

				if index then
					select_slot(index)
				end
			end,
			["ctrl-x"] = {
				fn = function(selected)
					local index = selected_harpoon_index(selected)

					if not index then
						return
					end

					local harpoon = require("harpoon")

					harpoon:list():remove_at(index)
					harpoon:sync()
				end,
				reload = true,
			},
			["ctrl-r"] = {
				fn = rename_harpoon_mark,
				reload = true,
			},
			["ctrl-k"] = move_harpoon_action(-1),
			["ctrl-up"] = move_harpoon_action(-1),
			["ctrl-j"] = move_harpoon_action(1),
			["ctrl-down"] = move_harpoon_action(1),
		},
		fzf_opts = {
			["--delimiter"] = harpoon_entry_separator,
			["--with-nth"] = "1",
			["--header"] = "Enter open | Ctrl-r rename | Ctrl-x remove | Ctrl-k/Ctrl-Up move up | Ctrl-j/Ctrl-Down move down",
			["--id-nth"] = "3..4",
			["--info"] = "inline-right",
			["--no-sort"] = true,
			["--preview"] = harpoon_preview_command(),
			["--track"] = true,
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
