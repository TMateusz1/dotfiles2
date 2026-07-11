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

local function existing_path_or_cwd(path)
	if path ~= "" then
		return path
	end

	return vim.fn.getcwd()
end

function M.root(bufnr, markers)
	bufnr = bufnr or 0
	markers = markers or root_markers
	local buffer = bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr
	local path = existing_path_or_cwd(vim.api.nvim_buf_get_name(buffer))
	local stat = vim.uv.fs_stat(path)
	local start = stat and stat.type == "directory" and path or vim.fs.dirname(path)
	local marker = vim.fs.find(markers, { path = start, upward = true })[1]

	return marker and vim.fs.dirname(marker) or vim.fn.getcwd()
end

function M.project_root(bufnr)
	return M.root(bufnr, root_markers)
end

return M
