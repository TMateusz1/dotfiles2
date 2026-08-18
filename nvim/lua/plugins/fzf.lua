local exclude = {
	".git",
	".vscode",
	"node_modules",
	"dist",
	"build",
	"target",
	".idea",
}

local function excluded_args()
	local args = {}

	for _, item in ipairs(exclude) do
		vim.list_extend(args, { "--exclude", vim.fn.shellescape(item) })
	end

	return args
end

local function find_files(cwd)
	require("fzf-lua").files({
		cwd = cwd or vim.fn.getcwd(-1, -1),
		hidden = true,
		follow = true,
		fd_opts = table.concat(
			vim.list_extend({
				"--color=never",
				"--type",
				"f",
				"--type",
				"l",
				"--hidden",
				"--follow",
			}, excluded_args()),
			" "
		),
	})
end

local function live_grep(cwd)
	require("fzf-lua").live_grep({
		cwd = cwd,
		rg_opts = table.concat(
			vim.list_extend(
				{
					"--column",
					"--line-number",
					"--no-heading",
					"--color=always",
					"--smart-case",
					"--hidden",
					"--follow",
				},
				vim.tbl_map(function(item)
					return ("--glob=!%s"):format(item)
				end, exclude)
			),
			" "
		),
	})
end

local function action(method)
	return function()
		require("fzf-lua")[method]()
	end
end

return {
	{
		"ibhagwan/fzf-lua",
		cmd = "FzfLua",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			winopts = {
				border = "rounded",
				height = 0.86,
				width = 0.88,
				row = 0.45,
				preview = {
					border = "rounded",
					layout = "flex",
					vertical = "down:45%",
					horizontal = "right:56%",
					wrap = false,
				},
			},
			fzf_colors = true,
			files = {
				formatter = "path.filename_first",
			},
			grep = {
				formatter = "path.filename_first",
			},
		},
		keys = {
			{
				"<leader>ff",
				find_files,
				desc = "Find files",
			},
			{
				"<leader>fg",
				live_grep,
				desc = "Live grep",
			},
			{
				"<leader>/",
				action("blines"),
				desc = "Search buffer lines",
			},
			{
				"<leader>fG",
				action("git_status"),
				desc = "Git changed files",
			},
			{
				"<leader>fb",
				action("buffers"),
				desc = "Find buffers",
			},
			{
				"<leader>fs",
				action("lsp_document_symbols"),
				desc = "Document symbols",
			},
			{
				"<leader>fS",
				action("lsp_live_workspace_symbols"),
				desc = "Live workspace symbols",
			},
			{
				"<leader>fd",
				action("diagnostics_document"),
				desc = "Document diagnostics",
			},
			{
				"<leader>fD",
				action("diagnostics_workspace"),
				desc = "Workspace diagnostics",
			},
			{
				"<leader>fq",
				action("quickfix"),
				desc = "Quickfix list",
			},
			{
				"<leader>fc",
				action("commands"),
				desc = "Commands",
			},
		},
	},
}
