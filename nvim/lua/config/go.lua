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
