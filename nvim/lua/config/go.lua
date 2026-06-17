local M = {}

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, {
		title = "Go",
	})
end

local function current_file(bufnr)
	local file = vim.api.nvim_buf_get_name(bufnr or 0)

	if file == "" then
		return vim.uv.cwd()
	end

	return vim.fs.normalize(file)
end

function M.project_root(bufnr)
	local file = current_file(bufnr)
	local root = vim.fs.root(file, {
		"go.work",
		"go.mod",
		".git",
	})

	return root or vim.uv.cwd()
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

function M.fix_all(bufnr)
	M.code_action("source.fixAll", bufnr)
end

function M.run(args, opts)
	opts = opts or {}

	local cmd = opts.cmd or "go"
	local label = opts.label or table.concat(vim.list_extend({ cmd }, vim.deepcopy(args)), " ")

	if vim.fn.executable(cmd) ~= 1 then
		notify(cmd .. " is not executable", vim.log.levels.ERROR)
		return
	end

	local root = opts.cwd or M.project_root(opts.bufnr)

	notify(label .. " started")

	vim.system(vim.list_extend({ cmd }, args), {
		cwd = root,
		text = true,
	}, function(result)
		vim.schedule(function()
			local output = vim.trim(table.concat({
				result.stdout or "",
				result.stderr or "",
			}, "\n"))

			if result.code == 0 then
				-- Clean run: if the quickfix list still shows this command's
				-- previous (failing) output, clear it and close the window so
				-- stale errors don't linger. Match on title to avoid clobbering
				-- an unrelated quickfix list.
				if vim.fn.getqflist({ title = 0 }).title == label then
					vim.fn.setqflist({}, "r", { title = label, items = {} })
					pcall(vim.cmd, "cclose")
				end

				notify(label .. " finished")
				return
			end

			if output ~= "" then
				vim.fn.setqflist({}, "r", {
					title = label,
					lines = vim.split(output, "\n", {
						plain = true,
					}),
				})
				vim.cmd("copen")
			end

			notify(label .. " failed", vim.log.levels.ERROR)
		end)
	end)
end

function M.mod_tidy(bufnr)
	M.run({ "mod", "tidy" }, {
		bufnr = bufnr,
		label = "go mod tidy",
	})
end

function M.generate(bufnr)
	M.run({ "generate", "./..." }, {
		bufnr = bufnr,
		label = "go generate ./...",
	})
end

function M.lint(bufnr)
	M.run({ "run", "./..." }, {
		bufnr = bufnr,
		cmd = "golangci-lint",
		label = "golangci-lint run ./...",
	})
end

-- ----------------------------------------------------------------------------
-- Code generation helpers (gomodifytags / impl)
-- ----------------------------------------------------------------------------

local function tool_path(name)
	local mason = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", name)

	if vim.fn.executable(mason) == 1 then
		return mason
	end

	return name
end

local function run_tool(opts)
	if vim.fn.executable(opts.cmd) ~= 1 then
		notify(opts.cmd .. " is not executable", vim.log.levels.ERROR)
		return
	end

	vim.system(vim.list_extend({ opts.cmd }, opts.args), {
		cwd = opts.cwd or M.project_root(),
		text = true,
	}, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				local output = vim.trim((result.stderr or "") .. "\n" .. (result.stdout or ""))
				notify((opts.label or opts.cmd) .. " failed\n" .. output, vim.log.levels.ERROR)
				return
			end

			if opts.on_success then
				opts.on_success(result)
			end
		end)
	end)
end

local function get_node_at_cursor(bufnr)
	local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr })

	if not ok then
		return nil
	end

	return node
end

-- Name of the nearest enclosing node whose type is in `types`.
local function enclosing_name(bufnr, types)
	local node = get_node_at_cursor(bufnr)

	while node do
		if types[node:type()] then
			local name = node:field("name")[1]

			if name then
				return vim.treesitter.get_node_text(name, bufnr)
			end
		end

		node = node:parent()
	end
end

-- The struct under the cursor: returns its name and the last line (0-based) of
-- its declaration, so generated methods can be inserted right after it.
local function enclosing_struct(bufnr)
	local node = get_node_at_cursor(bufnr)

	while node do
		if node:type() == "type_spec" then
			local name_node = node:field("name")[1]
			local type_node = node:field("type")[1]

			if name_node and type_node and type_node:type() == "struct_type" then
				local decl = node:parent()
				local target = decl and decl:type() == "type_declaration" and decl or node
				local _, _, end_row = target:range()

				return vim.treesitter.get_node_text(name_node, bufnr), end_row
			end
		end

		node = node:parent()
	end
end

local function save_if_modified(bufnr)
	if vim.bo[bufnr].modified then
		vim.api.nvim_buf_call(bufnr, function()
			vim.cmd("silent write")
		end)
	end
end

local function reload_buffer(bufnr)
	vim.schedule(function()
		if vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_call(bufnr, function()
				vim.cmd("silent! checktime")
			end)
		end
	end)
end

local function modify_tags(bufnr, tag, action, opts)
	bufnr = bufnr or 0
	opts = opts or {}

	local name = enclosing_name(bufnr, { type_spec = true })

	if not name then
		notify(("Place the cursor inside a struct to %s %s tags"):format(action, tag), vim.log.levels.WARN)
		return
	end

	local file = current_file(bufnr)
	save_if_modified(bufnr)

	local args = {
		"-file",
		file,
		"-struct",
		name,
		action == "add" and "-add-tags" or "-remove-tags",
		tag,
	}

	if action == "add" then
		if opts.options then
			vim.list_extend(args, { "-add-options", tag .. "=" .. opts.options })
		end

		vim.list_extend(args, { "-transform", opts.transform or "camelcase" })
	end

	vim.list_extend(args, { "-quiet", "-w" })

	run_tool({
		cmd = tool_path("gomodifytags"),
		cwd = vim.fs.dirname(file),
		args = args,
		label = ("gomodifytags %s %s"):format(action, tag),
		on_success = function()
			reload_buffer(bufnr)
			notify(("%s %s tags on %s"):format(action == "add" and "Added" or "Removed", tag, name))
		end,
	})
end

function M.add_json_tags(bufnr)
	modify_tags(bufnr, "json", "add", {
		options = "omitempty",
	})
end

function M.remove_json_tags(bufnr)
	modify_tags(bufnr, "json", "remove")
end

function M.add_yaml_tags(bufnr)
	modify_tags(bufnr, "yaml", "add")
end

function M.remove_yaml_tags(bufnr)
	modify_tags(bufnr, "yaml", "remove")
end

function M.add_env_tags(bufnr)
	modify_tags(bufnr, "env", "add", {
		transform = "snakecase",
	})
end

function M.remove_env_tags(bufnr)
	modify_tags(bufnr, "env", "remove")
end

-- Render `go doc` output in a scrollable, syntax-highlighted floating window.
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
	vim.wo[win].cursorline = true

	for _, key in ipairs({ "q", "<Esc>" }) do
		vim.keymap.set("n", key, "<cmd>close<CR>", {
			buffer = buf,
			silent = true,
			desc = "Close go doc",
		})
	end

	pcall(vim.treesitter.start, buf, "go")
end

-- Show `go doc` for the symbol under the cursor. Uses <cexpr> so selectors
-- like `strings.Split` or `http.Client` resolve, and runs in the file's
-- package directory so bare local symbols resolve against the package too.
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

	notify("go doc " .. query)

	vim.system({ "go", "doc", query }, {
		cwd = vim.fs.dirname(current_file(bufnr)),
		text = true,
	}, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				local err = vim.trim((result.stderr or "") .. "\n" .. (result.stdout or ""))
				notify("go doc failed: " .. (err ~= "" and err or query), vim.log.levels.ERROR)
				return
			end

			local output = vim.trim(result.stdout or "")

			if output == "" then
				notify("No documentation for " .. query, vim.log.levels.WARN)
				return
			end

			open_doc_window(query, vim.split(output, "\n", { plain = true }))
		end)
	end)
end

-- Implement an interface on the struct under the cursor. The interface is
-- chosen from a live gopls workspace-symbol picker (type e.g. "fmt.Str" to
-- find fmt.Stringer); impl's generated stubs are inserted after the struct.
function M.implement_interface(bufnr)
	bufnr = bufnr or 0

	local struct, end_row = enclosing_struct(bufnr)

	if not struct then
		notify("Place the cursor inside a struct to implement an interface", vim.log.levels.WARN)
		return
	end

	local struct_dir = vim.fs.dirname(current_file(bufnr))
	local receiver = struct:sub(1, 1):lower() .. " *" .. struct

	local function run_impl(iface_arg, display)
		run_tool({
			cmd = tool_path("impl"),
			cwd = struct_dir,
			args = {
				"-dir",
				struct_dir,
				receiver,
				iface_arg,
			},
			label = "impl " .. struct,
			on_success = function(result)
				local output = vim.trim(result.stdout or "")

				if output == "" then
					notify("impl produced no output for " .. display, vim.log.levels.WARN)
					return
				end

				local lines = vim.split(output, "\n", { plain = true })
				table.insert(lines, 1, "")
				vim.api.nvim_buf_set_lines(bufnr, end_row + 1, end_row + 1, false, lines)
				notify(("Implemented %s on %s"):format(display, struct))
			end,
		})
	end

	-- Resolve the chosen symbol's fully-qualified import path so impl can find
	-- it whether it lives in the stdlib, a dependency, or the workspace.
	local function implement_symbol(item)
		-- gopls may return the symbol bare ("Writer") or package-qualified
		-- ("io.Writer"); take the final component so combining it with the import
		-- path below never doubles the package prefix (e.g. "io.io.Writer").
		local name = item.name:match("[^.]+$") or item.name
		local iface_dir = item.file and vim.fs.dirname(item.file) or struct_dir

		vim.system({
			"go",
			"list",
			"-f",
			"{{.ImportPath}}",
			iface_dir,
		}, {
			cwd = iface_dir,
			text = true,
		}, function(result)
			vim.schedule(function()
				local import_path = result.code == 0 and vim.trim(result.stdout or "") or ""
				local container = item.item and item.item.containerName
				local iface_arg

				if import_path ~= "" then
					iface_arg = import_path .. "." .. name
				elseif container and container ~= "" then
					iface_arg = container .. "." .. name
				else
					iface_arg = name
				end

				run_impl(iface_arg, item.display or name)
			end)
		end)
	end

	local ok = pcall(function()
		local items_by_entry = {}

		local function short_package(container)
			if not container or container == "" then
				return nil
			end

			local pkg = container:match("([^/]+)$") or container

			if pkg:match("^v%d+$") then
				pkg = container:match("([^/]+)/[^/]+$") or pkg
			end

			return pkg
		end

		local function symbol_item(symbol)
			if vim.lsp.protocol.SymbolKind[symbol.kind] ~= "Interface" or not symbol.location then
				return nil
			end

			local file = vim.uri_to_fname(symbol.location.uri)
			local range = symbol.location.range
			local bare = (symbol.name or ""):match("[^.]+$") or symbol.name
			local pkg = short_package(symbol.containerName)
			local display = pkg and (pkg .. "." .. bare) or bare
			local lnum = range.start.line + 1
			local col = range.start.character + 1
			local rel = vim.fs.relpath(M.project_root(bufnr), file) or file

			return {
				name = symbol.name,
				display = display,
				file = file,
				line = lnum,
				col = col,
				item = symbol,
				entry = table.concat({
					display,
					("%s:%d:%d"):format(rel, lnum, col),
					symbol.containerName or "",
				}, "\t"),
			}
		end

		local function interface_entries(query)
			if query == "" then
				items_by_entry = {}
				return {}
			end

			local responses = vim.lsp.buf_request_sync(bufnr, "workspace/symbol", {
				query = query,
			}, 5000) or {}
			local entries = {}
			local next_items = {}

			for _, response in pairs(responses) do
				for _, symbol in ipairs(response.result or {}) do
					local item = symbol_item(symbol)

					if item then
						table.insert(entries, item.entry)
						next_items[item.entry] = item
					end
				end
			end

			table.sort(entries)
			items_by_entry = next_items

			return entries
		end

		require("fzf-lua").fzf_live(function(args)
			return interface_entries(args[1] or "")
		end, {
			prompt = "Implement interface on " .. struct .. "> ",
			fzf_opts = {
				["--delimiter"] = "\t",
				["--with-nth"] = "1,2",
				["--nth"] = "1",
			},
			preview = {
				fn = function(selected)
					local item = selected and items_by_entry[selected[1]]

					if not item then
						return ""
					end

					return table.concat({
						item.display,
						("%s:%d:%d"):format(item.file, item.line, item.col),
						item.item.containerName or "",
					}, "\n")
				end,
			},
			actions = {
				["default"] = function(selected)
					local item = selected and items_by_entry[selected[1]]

					if item then
						implement_symbol(item)
					end
				end,
			},
		})
	end)

	if ok then
		return
	end

	-- Fallback: type the interface manually if the picker is unavailable.
	vim.ui.input({
		prompt = "Interface to implement (e.g. fmt.Stringer): ",
	}, function(iface)
		if iface and vim.trim(iface) ~= "" then
			run_impl(vim.trim(iface), vim.trim(iface))
		end
	end)
end

return M
