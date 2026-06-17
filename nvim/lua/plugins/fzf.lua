local picker_exclude = {
	".git",
	".vscode",
	"node_modules",
	"dist",
	"build",
	"target",
	".idea",
}

local function fd_opts()
	local opts = {
		"--color=never",
		"--type",
		"f",
		"--type",
		"l",
		"--hidden",
		"-L",
	}

	for _, pattern in ipairs(picker_exclude) do
		vim.list_extend(opts, { "--exclude", pattern })
	end

	return table.concat(opts, " ")
end

local function rg_opts()
	local opts = {
		"--column",
		"--line-number",
		"--no-heading",
		"--color=always",
		"--smart-case",
		"--hidden",
		"-L",
		"--max-columns=4096",
	}

	for _, pattern in ipairs(picker_exclude) do
		table.insert(opts, "--glob=!" .. pattern)
		table.insert(opts, "--glob=!**/" .. pattern .. "/**")
	end

	table.insert(opts, "-e")
	return table.concat(opts, " ")
end

local function fzf()
	return require("fzf-lua")
end

local function git_line_commits()
	local line = vim.api.nvim_win_get_cursor(0)[1]
	local git_log = table.concat({
		[[git log --color --pretty=format:"%C(yellow)%h%Creset ]],
		[[%Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset"]],
		(" -L %d,%d:{file} --no-patch"):format(line, line),
	})

	fzf().git_bcommits({
		cmd = git_log,
		preview = "git show --color {1} -- {file}",
	})
end

return {
	{
		"ibhagwan/fzf-lua",
		lazy = false,
		dependencies = {
			"nvim-mini/mini.icons",
		},
		opts = {
			ui_select = true,
			winopts = {
				width = 0.92,
				height = 0.92,
				row = 0.5,
				col = 0.5,
				border = "rounded",
				preview = {
					border = "rounded",
					layout = "flex",
					horizontal = "right:60%",
					vertical = "down:45%",
					flip_columns = 120,
					wrap = false,
					winopts = {
						number = false,
						relativenumber = false,
						signcolumn = "no",
						foldcolumn = "0",
						cursorline = false,
					},
				},
			},
			defaults = {
				git_icons = false,
				color_icons = true,
				formatter = "path.filename_first",
			},
			files = {
				fd_opts = fd_opts(),
				hidden = true,
				cwd_prompt = false,
				line_query = true,
			},
			grep = {
				rg_opts = rg_opts(),
				rg_glob = true,
			},
			oldfiles = {
				include_current_session = true,
			},
			lsp = {
				jump1 = true,
				finder = {
					no_autoclose = true,
				},
				workspace_symbols = {
					jump1 = false,
				},
			},
		},
		config = function(_, opts)
			local actions = require("fzf-lua.actions")
			opts.actions = {
				files = {
					["default"] = actions.file_edit_or_qf,
					["ctrl-s"]  = actions.file_split,
					["ctrl-v"]  = actions.file_vsplit,
					["ctrl-t"]  = actions.file_tabedit,
					["ctrl-q"]  = actions.file_sel_to_qf,
				},
			}
			require("fzf-lua").setup(opts)
		end,
		keys = {
			{
				"<leader>ff",
				function()
					fzf().files({
						cwd = vim.fn.getcwd(-1, -1),
					})
				end,
				desc = "Find files",
			},
			{
				"<leader>fg",
				function()
					fzf().live_grep()
				end,
				desc = "Live grep",
			},
			{
				"<leader>/",
				function()
					fzf().blines()
				end,
				desc = "Search buffer lines",
			},
			{
				"<leader>fu",
				function()
					fzf().undotree()
				end,
				desc = "Undo history",
			},
			{
				"<leader>fG",
				function()
					fzf().git_status()
				end,
				desc = "Git changed files",
			},
			{
				"<leader>fr",
				function()
					fzf().oldfiles()
				end,
				desc = "Recent files",
			},
			{
				"<leader>fw",
				function()
					fzf().grep_cword()
				end,
				desc = "Grep word under cursor",
			},
			{
				"<leader>fs",
				function()
					fzf().lsp_document_symbols()
				end,
				desc = "Document symbols",
			},
			{
				"<leader>fd",
				function()
					fzf().diagnostics_document()
				end,
				desc = "Document diagnostics",
			},
			{
				"<leader>fD",
				function()
					fzf().diagnostics_workspace()
				end,
				desc = "Workspace diagnostics",
			},
			{
				"<leader>fq",
				function()
					fzf().quickfix()
				end,
				desc = "Quickfix list",
			},
			{
				"<leader>gc",
				function()
					fzf().git_commits()
				end,
				desc = "Git commits",
			},
			{
				"<leader>gb",
				function()
					fzf().git_branches()
				end,
				desc = "Git branches",
			},
			{
				"<leader>gC",
				function()
					fzf().git_bcommits()
				end,
				desc = "Git buffer commits",
			},
			{
				"<leader>gl",
				function()
					git_line_commits()
				end,
				desc = "Git line commits",
			},
			{
				"<leader>gs",
				function()
					fzf().git_stash()
				end,
				desc = "Git stash",
			},
		},
	},
}
