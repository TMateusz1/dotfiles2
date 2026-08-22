local M = {}

local root_markers = {
	".git",
	"go.mod",
	"package.json",
	"Cargo.toml",
	"pyproject.toml",
	"flake.nix",
	"Makefile",
}

local function resolve_bufnr(bufnr)
	if bufnr == nil or bufnr == 0 then
		return vim.api.nvim_get_current_buf()
	end

	return bufnr
end

function M.current_file(bufnr, fallback)
	local path = vim.api.nvim_buf_get_name(resolve_bufnr(bufnr))

	return path ~= "" and vim.fs.normalize(path) or fallback or vim.fn.getcwd()
end

function M.current_dir(bufnr, fallback)
	local path = M.current_file(bufnr, fallback)
	local stat = vim.uv.fs_stat(path)

	if stat and stat.type == "directory" then
		return path
	end

	return vim.fs.dirname(path) or fallback or vim.fn.getcwd()
end

function M.root(bufnr, markers, fallback)
	markers = markers or root_markers
	fallback = fallback or vim.fn.getcwd()
	local path = M.current_file(bufnr, fallback)
	local stat = vim.uv.fs_stat(path)
	local start = stat and stat.type == "directory" and path or vim.fs.dirname(path)
	local marker = vim.fs.find(markers, { path = start, upward = true })[1]

	return marker and vim.fs.dirname(marker) or fallback
end

function M.project_root(bufnr)
	return M.root(bufnr, root_markers)
end

return M
