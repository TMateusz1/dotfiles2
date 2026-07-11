local M = {}

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, { title = "Go" })
end

function M.project_root(bufnr)
	return require("config.files").root(bufnr, { "go.work", "go.mod", ".git" })
end

function M.code_action(only, bufnr)
	vim.lsp.buf.code_action({
		bufnr = bufnr or 0,
		apply = true,
		context = {
			only = { only },
			diagnostics = {},
		},
	})
end

function M.organize_imports(bufnr)
	M.code_action("source.organizeImports", bufnr)
end

function M.fill_struct_literal(bufnr)
	bufnr = bufnr or 0
	if vim.bo[bufnr].filetype ~= "go" then
		notify("Fill struct is only available in Go buffers", vim.log.levels.WARN)
		return
	end

	M.code_action("refactor.rewrite.fillStruct", bufnr)
end

function M.run(args, opts)
	opts = opts or {}

	local cmd = opts.cmd or "go"
	local label = opts.label or table.concat(vim.list_extend({ cmd }, vim.deepcopy(args)), " ")

	if vim.fn.executable(cmd) ~= 1 then
		notify(cmd .. " is not executable", vim.log.levels.ERROR)
		return
	end

	vim.system(vim.list_extend({ cmd }, args), {
		cwd = opts.cwd or M.project_root(opts.bufnr),
		text = true,
	}, function(result)
		vim.schedule(function()
			local output = vim.trim(table.concat({ result.stdout or "", result.stderr or "" }, "\n"))

			if result.code == 0 then
				if vim.fn.getqflist({ title = 0 }).title == label then
					vim.fn.setqflist({}, "r", { title = label, items = {} })
					pcall(vim.cmd, "cclose")
				end
				notify(label .. " ok")
				return
			end

			if output ~= "" then
				vim.fn.setqflist({}, "r", {
					title = label,
					lines = vim.split(output, "\n", { plain = true }),
				})
				vim.cmd("copen")
			end

			notify(label .. " failed", vim.log.levels.ERROR)
		end)
	end)
end

function M.lint(bufnr)
	M.run({ "run", "./..." }, {
		bufnr = bufnr,
		cmd = "golangci-lint",
		label = "golangci-lint run ./...",
	})
end

local function gopls_client(bufnr)
	return vim.lsp.get_clients({ bufnr = bufnr, name = "gopls" })[1]
end

local function execute_gopls(bufnr, command, arguments, label, form_answers)
	local client = gopls_client(bufnr)
	if not client then
		notify("gopls is not attached", vim.log.levels.WARN)
		return false
	end

	local params = {
		command = command,
		arguments = { arguments },
	}
	if form_answers then
		params.formAnswers = form_answers
	end
	client:request("workspace/executeCommand", params, function(err)
		vim.schedule(function()
			if err then
				notify(label .. " failed: " .. (err.message or tostring(err)), vim.log.levels.ERROR)
				return
			end
			notify(label .. " ok")
		end)
	end, bufnr)
	return true
end

local function node_at_cursor(bufnr)
	local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr })
	return ok and node or nil
end

local function enclosing_struct(bufnr)
	local node = node_at_cursor(bufnr)
	while node do
		if node:type() == "type_spec" then
			local name = node:field("name")[1]
			local type_node = node:field("type")[1]
			if name and type_node and type_node:type() == "struct_type" then
				return node, vim.treesitter.get_node_text(name, bufnr)
			end
		end
		node = node:parent()
	end
end

-- Build an end-exclusive LSP range straight from a treesitter node. We can't
-- use vim.lsp.util.make_given_range_params here: that helper is meant for visual
-- selections and adds +1 to the end column (inclusive selection semantics), which
-- pushes past the end of the struct's closing `}` line and makes gopls reject the
-- request with "column is beyond end of line".
local function node_lsp_range(bufnr, node, encoding)
	local start_row, start_col, end_row, end_col = node:range()
	return {
		start = { line = start_row, character = vim.lsp.util.character_offset(bufnr, start_row, start_col, encoding) },
		["end"] = { line = end_row, character = vim.lsp.util.character_offset(bufnr, end_row, end_col, encoding) },
	}
end

local function struct_range(bufnr, node, encoding)
	return node_lsp_range(bufnr, node, encoding)
end

local function struct_name_range(bufnr, node, encoding)
	local name = node:field("name")[1]
	if not name then
		return nil
	end

	return node_lsp_range(bufnr, name, encoding)
end

local function modify_tags(bufnr, operation, tag, opts)
	bufnr = bufnr or 0
	opts = opts or {}
	local node, name = enclosing_struct(bufnr)
	if not node then
		notify(("Place the cursor inside a struct to %s %s tags"):format(operation, tag), vim.log.levels.WARN)
		return
	end

	local client = gopls_client(bufnr)
	if not client then
		notify("gopls is not attached", vim.log.levels.WARN)
		return
	end

	local args = {
		Modification = operation,
		URI = vim.uri_from_bufnr(bufnr),
		Range = struct_range(bufnr, node, client.offset_encoding),
	}
	if operation == "add" then
		args.Add = tag
		args.AddOptions = opts.options
		args.Transform = opts.transform or "camelcase"
	else
		args.Remove = tag
	end

	execute_gopls(bufnr, "gopls.modify_tags", args, ("%s %s tags on %s"):format(operation, tag, name))
end

function M.add_json_tags(bufnr)
	modify_tags(bufnr, "add", "json", { options = "json=omitempty" })
end

function M.remove_json_tags(bufnr)
	modify_tags(bufnr, "remove", "json")
end

function M.add_yaml_tags(bufnr)
	modify_tags(bufnr, "add", "yaml")
end

function M.remove_yaml_tags(bufnr)
	modify_tags(bufnr, "remove", "yaml")
end

function M.add_env_tags(bufnr)
	modify_tags(bufnr, "add", "env", { transform = "snakecase" })
end

function M.remove_env_tags(bufnr)
	modify_tags(bufnr, "remove", "env")
end

local function open_doc_window(title, lines)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.bo[buf].bufhidden = "wipe"

	local width = math.min(90, math.max(40, math.floor(vim.o.columns * 0.8)))
	local height = math.min(math.max(#lines, 3), math.floor(vim.o.lines * 0.7))
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
		title = " go doc: " .. title .. " ",
		title_pos = "center",
	})
	vim.wo[win].wrap = true
	vim.wo[win].linebreak = true
	for _, key in ipairs({ "q", "<Esc>" }) do
		vim.keymap.set("n", key, "<cmd>close<CR>", { buffer = buf, silent = true })
	end
	pcall(vim.treesitter.start, buf, "go")
end

function M.doc(bufnr)
	bufnr = bufnr or 0
	if vim.fn.executable("go") ~= 1 then
		notify("go executable not found", vim.log.levels.ERROR)
		return
	end

	local query = vim.fn.expand("<cexpr>")
	if query == "" then
		query = vim.fn.expand("<cword>")
	end
	if query == "" then
		notify("No symbol under the cursor", vim.log.levels.WARN)
		return
	end

	vim.system({ "go", "doc", query }, { cwd = M.project_root(bufnr), text = true }, function(result)
		vim.schedule(function()
			local output = vim.trim(result.stdout or "")
			if result.code ~= 0 or output == "" then
				local detail = vim.trim(table.concat({ result.stdout or "", result.stderr or "" }, "\n"))
				notify("go doc failed: " .. (detail ~= "" and detail or query), vim.log.levels.ERROR)
				return
			end
			open_doc_window(query, vim.split(output, "\n", { plain = true }))
		end)
	end)
end

local function canonical_path(path)
	return vim.uv.fs_realpath(path) or vim.fs.normalize(path)
end

local function selected_interface_symbol(symbols, entry)
	local file = canonical_path(entry.path)
	local matches = {}
	for _, symbol in ipairs(symbols or {}) do
		if vim.lsp.protocol.SymbolKind[symbol.kind] == "Interface" and symbol.location then
			local location = symbol.location
			if
				canonical_path(vim.uri_to_fname(location.uri)) == file
				and location.range.start.line + 1 == entry.line
			then
				table.insert(matches, symbol)
			end
		end
	end

	if #matches == 1 then
		return matches[1]
	end

	for _, symbol in ipairs(matches) do
		if symbol.location.range.start.character + 1 == entry.col then
			return symbol
		end
	end
end

function M.implement_interface(bufnr)
	bufnr = bufnr or 0
	if not enclosing_struct(bufnr) then
		notify("Place the cursor inside a struct to implement an interface", vim.log.levels.WARN)
		return
	end

	local function execute_for_interface(symbol)
		local import_path = vim.trim(symbol.containerName or "")
		local name = vim.trim((symbol.name or ""):match("([^.]+)$") or "")
		if import_path == "" or name == "" then
			notify("Selected interface has no package or name", vim.log.levels.ERROR)
			return
		end

		local node, struct = enclosing_struct(bufnr)
		if not node then
			notify("Place the cursor inside a struct to implement an interface", vim.log.levels.WARN)
			return
		end
		local client = gopls_client(bufnr)
		if not client then
			notify("gopls is not attached", vim.log.levels.WARN)
			return
		end
		local range = struct_name_range(bufnr, node, client.offset_encoding)
		if not range then
			notify("Could not determine the target struct", vim.log.levels.ERROR)
			return
		end
		local iface = import_path .. "." .. name
		execute_gopls(bufnr, "gopls.implement_interface", {
			Location = { uri = vim.uri_from_bufnr(bufnr), range = range },
			Interface = iface,
		}, "implement " .. iface .. " on " .. struct, { iface })
	end

	local fzf = require("fzf-lua")
	local fzf_path = require("fzf-lua.path")
	fzf.lsp_live_workspace_symbols({
		prompt = "Implement interface > ",
		lsp_query = "",
		no_resume = true,
		regex_filter = function(item)
			return item.kind == "Interface"
		end,
		symbol_style = 3,
		path_shorten = 2,
		actions = {
			default = function(selected, opts)
				if not selected[1] then
					return
				end
				local entry = fzf_path.entry_to_file(selected[1], opts)
				local query = opts.last_query or ""
				if not entry.path or entry.path == "" or query == "" then
					notify("Could not read the selected interface", vim.log.levels.ERROR)
					return
				end
				local client = gopls_client(bufnr)
				if not client then
					notify("gopls is not attached", vim.log.levels.WARN)
					return
				end
				client:request("workspace/symbol", { query = query }, function(err, symbols)
					vim.schedule(function()
						if err then
							notify("Interface search failed: " .. (err.message or tostring(err)), vim.log.levels.ERROR)
							return
						end
						local symbol = selected_interface_symbol(symbols, entry)
						if not symbol then
							notify("Could not resolve the selected interface", vim.log.levels.ERROR)
							return
						end
						execute_for_interface(symbol)
					end)
				end, bufnr)
			end,
		},
	})
end

function M.attach(bufnr)
	local function map(lhs, rhs, desc)
		vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
	end
	map("<leader>cgl", function()
		M.lint(bufnr)
	end, "Go lint")
	map("<leader>cgo", function()
		M.organize_imports(bufnr)
	end, "Organize imports")
	map("<leader>cgd", function()
		M.doc(bufnr)
	end, "Go doc")
	map("<leader>cgj", function()
		M.add_json_tags(bufnr)
	end, "Add json tags")
	map("<leader>cgJ", function()
		M.remove_json_tags(bufnr)
	end, "Remove json tags")
	map("<leader>cgy", function()
		M.add_yaml_tags(bufnr)
	end, "Add yaml tags")
	map("<leader>cgY", function()
		M.remove_yaml_tags(bufnr)
	end, "Remove yaml tags")
	map("<leader>cge", function()
		M.add_env_tags(bufnr)
	end, "Add env tags")
	map("<leader>cgE", function()
		M.remove_env_tags(bufnr)
	end, "Remove env tags")
	map("<leader>cgi", function()
		M.implement_interface(bufnr)
	end, "Implement interface")
	map("<leader>cgs", function()
		M.fill_struct_literal(bufnr)
	end, "Fill struct literal")
end

return M
