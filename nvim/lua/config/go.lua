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
				vim.cmd("cwindow")
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

-- ----------------------------------------------------------------------------
-- Code generation helpers (gomodifytags / gotests / impl)
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

-- Add json+yaml tags (camelCase, omitempty) to the struct under the cursor.
function M.add_tags(bufnr)
	bufnr = bufnr or 0

	local name = enclosing_name(bufnr, { type_spec = true })

	if not name then
		notify("Place the cursor inside a struct to add tags", vim.log.levels.WARN)
		return
	end

	local file = current_file(bufnr)
	save_if_modified(bufnr)

	run_tool({
		cmd = tool_path("gomodifytags"),
		cwd = vim.fs.dirname(file),
		args = {
			"-file",
			file,
			"-struct",
			name,
			"-add-tags",
			"json,yaml",
			"-add-options",
			"json=omitempty",
			"-transform",
			"camelcase",
			"-quiet",
			"-w",
		},
		label = "gomodifytags add",
		on_success = function()
			reload_buffer(bufnr)
			notify("Added json+yaml tags to " .. name)
		end,
	})
end

-- Remove all field tags from the struct under the cursor.
function M.remove_tags(bufnr)
	bufnr = bufnr or 0

	local name = enclosing_name(bufnr, { type_spec = true })

	if not name then
		notify("Place the cursor inside a struct to remove tags", vim.log.levels.WARN)
		return
	end

	local file = current_file(bufnr)
	save_if_modified(bufnr)

	run_tool({
		cmd = tool_path("gomodifytags"),
		cwd = vim.fs.dirname(file),
		args = {
			"-file",
			file,
			"-struct",
			name,
			"-clear-tags",
			"-quiet",
			"-w",
		},
		label = "gomodifytags clear",
		on_success = function()
			reload_buffer(bufnr)
			notify("Removed tags from " .. name)
		end,
	})
end

-- Scaffold table tests for the function/method under the cursor (gotests).
function M.generate_tests(bufnr)
	bufnr = bufnr or 0

	local name = enclosing_name(bufnr, {
		function_declaration = true,
		method_declaration = true,
	})

	if not name then
		notify("Place the cursor inside a function or method", vim.log.levels.WARN)
		return
	end

	local file = current_file(bufnr)
	save_if_modified(bufnr)

	run_tool({
		cmd = tool_path("gotests"),
		cwd = vim.fs.dirname(file),
		args = {
			"-only",
			"^" .. name .. "$",
			"-parallel",
			"-w",
			file,
		},
		label = "gotests",
		on_success = function()
			reload_buffer(bufnr)
			notify("Generated tests for " .. name)
		end,
	})
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
		local name = item.name
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

				run_impl(iface_arg, name)
			end)
		end)
	end

	local ok = pcall(function()
		Snacks.picker.lsp_workspace_symbols({
			title = "Implement interface on " .. struct,
			-- gopls workspace/symbol is queried live as you type; restrict the
			-- results to interfaces.
			filter = {
				["go"] = { "Interface" },
			},
			confirm = function(picker, item)
				picker:close()

				if item then
					implement_symbol(item)
				end
			end,
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

function M.vulncheck(bufnr)
	if vim.fn.executable("govulncheck") == 1 then
		M.run({ "./..." }, {
			bufnr = bufnr,
			cmd = "govulncheck",
			label = "govulncheck ./...",
		})
		return
	end

	M.run({
		"run",
		"golang.org/x/vuln/cmd/govulncheck@latest",
		"./...",
	}, {
		bufnr = bufnr,
		label = "go run govulncheck ./...",
	})
end

return M
