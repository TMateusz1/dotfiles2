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

local function set_cursor_to_item(item)
	local row, col = item_position(item)
	local line_count = vim.api.nvim_buf_line_count(0)

	row = math.min(math.max(row, 1), line_count)

	local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""

	col = math.min(math.max(col, 0), #line)

	vim.api.nvim_win_set_cursor(0, { row, col })
end

local function mark_slot(index)
	local harpoon = require("harpoon")
	local list = harpoon:list()
	local item = list.config.create_list_item(list.config)
	local row, col = item_position(item)

	item.context.marked_row = row
	item.context.marked_col = col

	list:replace_at(index, item)
	harpoon:sync()
	notify(("Marked current line as Harpoon %d"):format(index))
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

local function harpoon_display(item)
	local row = item_position(item)

	return ("%s:%d"):format(item.value, row)
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
		},
		fzf_opts = {
			["--delimiter"] = harpoon_entry_separator,
			["--with-nth"] = "1",
			["--header"] = "Enter open | Ctrl-x remove",
			["--info"] = "inline-right",
			["--preview"] = harpoon_preview_command(),
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
}

for index = 1, 5 do
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
			require("harpoon"):setup()
		end,
	},
}
