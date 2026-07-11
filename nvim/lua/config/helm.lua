local M = {}

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, {
		title = "Helm",
	})
end

function M.chart_root(bufnr)
	local file = vim.api.nvim_buf_get_name(bufnr or 0)

	if file == "" then
		return nil
	end

	local chart = vim.fs.find("Chart.yaml", {
		path = vim.fs.dirname(file),
		upward = true,
		limit = 1,
	})[1]

	return chart and vim.fs.dirname(chart) or nil
end

local function values_files(root)
	local files = {}

	for _, glob in ipairs({ "/values*.yaml", "/values*.yml" }) do
		vim.list_extend(files, vim.fn.glob(root .. glob, true, true))
	end

	table.sort(files)
	return files
end

local function rel(root, file)
	return vim.fs.relpath(root, file) or file
end

local function open_location(item)
	if not item then
		return
	end

	vim.cmd.edit(vim.fn.fnameescape(item.file))
	vim.api.nvim_win_set_cursor(0, { item.line, math.max((item.col or 1) - 1, 0) })
	vim.cmd("normal! zz")
end

local function picker(title, items, root)
	if #items == 0 then
		notify("No " .. title:lower() .. " found", vim.log.levels.WARN)
		return
	end

	local entries = {}
	local lookup = {}

	for _, item in ipairs(items) do
		local entry = ("%s:%d:%d:%s"):format(rel(root, item.file), item.line, item.col or 1, item.label)

		entries[#entries + 1] = entry
		lookup[entry] = item
	end

	require("fzf-lua").fzf_exec(entries, {
		cwd = root,
		prompt = title .. " > ",
		previewer = "builtin",
		actions = {
			["default"] = function(selected)
				open_location(lookup[selected[1]])
			end,
		},
	})
end

local function parse_values_file(file, root)
	local items = {}
	local stack = {}

	for line_number, line in ipairs(vim.fn.readfile(file)) do
		if not line:match("^%s*#") then
			local indent, key = line:match("^(%s*)([%w_.-]+)%s*:")

			if key then
				local level = math.floor(#indent / 2) + 1
				stack[level] = key

				for index = level + 1, #stack do
					stack[index] = nil
				end

				local path = table.concat(stack, ".", 1, level)
				items[#items + 1] = {
					label = path,
					path = path,
					file = file,
					line = line_number,
					col = #indent + 1,
				}
			end
		end
	end

	return items
end

local function values_items(root)
	local items = {}

	for _, file in ipairs(values_files(root)) do
		vim.list_extend(items, parse_values_file(file, root))
	end

	table.sort(items, function(a, b)
		return a.path < b.path
	end)

	return items
end

local function match_under_cursor(pattern)
	local line = vim.api.nvim_get_current_line()
	local cursor = vim.api.nvim_win_get_cursor(0)[2] + 1
	local start = 1

	while start <= #line do
		local from, to, match = line:find(pattern, start)
		if not from then
			return nil
		end

		if from <= cursor and cursor <= to then
			return match
		end

		start = to + 1
	end
end

function M.values_path_under_cursor()
	local match = match_under_cursor("(%$?%.Values[%w_%.%-]*)")

	if not match then
		return nil
	end

	local path = match:gsub("^%$?%.Values%.?", ""):gsub("%.$", "")
	return path ~= "" and path or nil
end

function M.pick_values()
	local root = M.chart_root(0)

	if not root then
		notify("No Helm chart found", vim.log.levels.WARN)
		return
	end

	picker("Helm values", values_items(root), root)
end

function M.find_value_under_cursor()
	local root = M.chart_root(0)
	local path = M.values_path_under_cursor()

	if not root then
		notify("No Helm chart found", vim.log.levels.WARN)
		return false
	end

	if not path then
		notify("No .Values path under cursor", vim.log.levels.WARN)
		return false
	end

	for _, item in ipairs(values_items(root)) do
		if item.path == path then
			open_location(item)
			return true
		end
	end

	require("fzf-lua").grep({
		cwd = root,
		search = path:match("[^.]+$") or path,
		glob = { "values*.yaml", "values*.yml" },
	})
	return true
end

function M.smart_definition()
	if M.values_path_under_cursor() and M.find_value_under_cursor() then
		return
	end

	require("fzf-lua").lsp_definitions()
end

function M.setup()
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("user_helm_navigation", { clear = true }),
		pattern = {
			"helm",
			"yaml.helm-values",
		},
		callback = function(event)
			vim.keymap.set("n", "gd", M.smart_definition, {
				buffer = event.buf,
				desc = "Helm value definition",
			})
			vim.keymap.set("n", "<leader>hv", M.pick_values, {
				buffer = event.buf,
				desc = "Pick Helm value",
			})
			vim.keymap.set("n", "<leader>hgv", M.find_value_under_cursor, {
				buffer = event.buf,
				desc = "Go to Helm value",
			})
		end,
		desc = "Helm values navigation keymaps",
	})
end

return M
