-- ~/.config/nvim/lua/plugins/fzf.lua

local explorer_entry_separator = "\t"

local open_file_explorer

local function explorer_icon(kind, name)
	local ok, mini_icons = pcall(require, "mini.icons")

	if ok then
		local icon = mini_icons.get(kind == "dir" and "directory" or "file", name)

		if icon then
			return icon
		end
	end

	return kind == "dir" and "" or "󰈙"
end

local function explorer_entry(label, path, kind)
	return table.concat({
		label,
		path,
		kind,
	}, explorer_entry_separator)
end

local function parse_explorer_entry(line)
	if not line then
		return nil
	end

	local path, kind = line:match("\t([^\t]+)\t([^\t]+)$")

	if not path or not kind then
		return nil
	end

	return {
		path = path,
		kind = kind,
	}
end

local function explorer_entries(cwd)
	local entries = {}
	local dirs = {}
	local files = {}
	local parent = vim.fs.dirname(cwd)
	local skip_names = {
		[".git"] = true,
		[".idea"] = true,
		[".vscode"] = true,
		["build"] = true,
		["dist"] = true,
		["node_modules"] = true,
		["target"] = true,
	}

	if parent and parent ~= cwd then
		table.insert(entries, explorer_entry("󰉖 ../", parent, "dir"))
	end

	local scan = vim.uv.fs_scandir(cwd)

	if not scan then
		return entries
	end

	while true do
		local name, kind = vim.uv.fs_scandir_next(scan)

		if not name then
			break
		end

		if not skip_names[name] then
			local path = vim.fs.joinpath(cwd, name)

			if kind == "directory" then
				table.insert(dirs, {
					label = ("%s %s/"):format(explorer_icon("dir", name), name),
					path = path,
				})
			else
				table.insert(files, {
					label = ("%s %s"):format(explorer_icon("file", name), name),
					path = path,
				})
			end
		end
	end

	local function sort_by_label(left, right)
		return left.label:lower() < right.label:lower()
	end

	table.sort(dirs, sort_by_label)
	table.sort(files, sort_by_label)

	for _, dir in ipairs(dirs) do
		table.insert(entries, explorer_entry(dir.label, dir.path, "dir"))
	end

	for _, file in ipairs(files) do
		table.insert(entries, explorer_entry(file.label, file.path, "file"))
	end

	return entries
end

local function open_file(path, command)
	vim.cmd[command](vim.fn.fnameescape(path))
end

local function explorer_preview_command()
	return table.concat({
		"if [ -d {2} ]; then",
		"(command -v eza >/dev/null && eza -la --color=always --icons --group-directories-first {2}) ||",
		"(command -v lsd >/dev/null && lsd -la --color=always --icon=always --group-directories-first {2}) ||",
		"ls -la {2};",
		"else",
		"(command -v bat >/dev/null && bat --color=always --style=numbers --line-range=:200 {2}) ||",
		"sed -n '1,200p' {2};",
		"fi",
	}, " ")
end

local function select_explorer_entry(selected, command)
	local entry = parse_explorer_entry(selected and selected[1])

	if not entry then
		return
	end

	if entry.kind == "dir" then
		open_file_explorer(entry.path)
		return
	end

	open_file(entry.path, command)
end

open_file_explorer = function(cwd)
	cwd = vim.fs.normalize(cwd or vim.fn.getcwd(-1, -1))

	local function open_parent()
		local parent = vim.fs.dirname(cwd)

		if parent and parent ~= cwd then
			open_file_explorer(parent)
		end
	end

	require("fzf-lua").fzf_exec(explorer_entries(cwd), {
		cwd = cwd,
		prompt = "Explorer> ",
		cwd_prompt = true,
		winopts = {
			title = " File Explorer ",
			height = 0.90,
			width = 0.92,
			preview = {
				layout = "flex",
				vertical = "down:50%",
				horizontal = "right:60%",
			},
		},
		actions = {
			["enter"] = function(selected)
				select_explorer_entry(selected, "edit")
			end,
			["ctrl-v"] = function(selected)
				select_explorer_entry(selected, "vsplit")
			end,
			["ctrl-s"] = function(selected)
				select_explorer_entry(selected, "split")
			end,
			["ctrl-t"] = function(selected)
				select_explorer_entry(selected, "tabedit")
			end,
			["ctrl-o"] = open_parent,
			["ctrl-h"] = open_parent,
			["ctrl-r"] = function()
				open_file_explorer(cwd)
			end,
		},
		fzf_opts = {
			["--delimiter"] = explorer_entry_separator,
			["--with-nth"] = "1",
			["--header"] = "Enter open/descend | Ctrl-o parent | Ctrl-r refresh | Ctrl-v vertical | Ctrl-s split | Ctrl-t tab",
			["--info"] = "inline-right",
			["--preview"] = explorer_preview_command(),
		},
	})
end

return {
	{
		"ibhagwan/fzf-lua",
		cmd = "FzfLua",
		dependencies = {
			"nvim-mini/mini.icons",
		},
		keys = {
			{
				"<leader>ff",
				function()
					require("fzf-lua").files({
						cwd = vim.fn.getcwd(-1, -1),
					})
				end,
				desc = "Find files",
			},
			{
				"<leader>fe",
				open_file_explorer,
				desc = "File explorer",
			},
			{
				"<leader>fg",
				function()
					require("fzf-lua").live_grep()
				end,
				desc = "Live grep",
			},
			{
				"<leader>fG",
				function()
					require("fzf-lua").git_status()
				end,
				desc = "Git changed files",
			},
			{
				"<leader>fb",
				function()
					require("fzf-lua").buffers()
				end,
				desc = "Find buffers",
			},
			{
				"<leader>fr",
				function()
					require("fzf-lua").oldfiles()
				end,
				desc = "Recent files",
			},
			{
				"<leader>fc",
				function()
					require("fzf-lua").files({
						cwd = vim.fn.stdpath("config"),
						prompt = "Config files> ",
					})
				end,
				desc = "Find config files",
			},
			{
				"<leader>fw",
				function()
					require("fzf-lua").grep_cword()
				end,
				desc = "Grep word under cursor",
			},
			{
				"<leader>fW",
				function()
					require("fzf-lua").grep_cWORD()
				end,
				desc = "Grep WORD under cursor",
			},
			{
				"<leader>fh",
				function()
					require("fzf-lua").help_tags()
				end,
				desc = "Help tags",
			},
			{
				"<leader>fk",
				function()
					require("fzf-lua").keymaps()
				end,
				desc = "Keymaps",
			},
			{
				"<leader>f:",
				function()
					require("fzf-lua").commands()
				end,
				desc = "Commands",
			},
			{
				"<leader>fj",
				function()
					require("fzf-lua").jumps()
				end,
				desc = "Jump list",
			},
			{
				"<leader>f;",
				function()
					require("fzf-lua").command_history()
				end,
				desc = "Command history",
			},
			{
				"<leader>f/",
				function()
					require("fzf-lua").search_history()
				end,
				desc = "Search history",
			},
			{
				"<leader>gc",
				function()
					require("fzf-lua").git_commits()
				end,
				desc = "Git commits",
			},
			{
				"<leader>gb",
				function()
					require("fzf-lua").git_branches()
				end,
				desc = "Git branches",
			},
			{
				"<leader>gC",
				function()
					require("fzf-lua").git_bcommits()
				end,
				desc = "Git buffer commits",
			},
			{
				"<leader>fd",
				function()
					require("fzf-lua").diagnostics_document()
				end,
				desc = "Document diagnostics",
			},
			{
				"<leader>fD",
				function()
					require("fzf-lua").diagnostics_workspace()
				end,
				desc = "Workspace diagnostics",
			},
			{
				"<leader>fq",
				function()
					require("fzf-lua").quickfix()
				end,
				desc = "Quickfix list",
			},
			{
				"<leader>fl",
				function()
					require("fzf-lua").loclist()
				end,
				desc = "Location list",
			},
		},
		opts = {
			"default-title",

			winopts = {
				height = 0.85,
				width = 0.85,
				row = 0.50,
				col = 0.50,
				border = "rounded",
				preview = {
					border = "rounded",
					layout = "flex",
					vertical = "down:45%",
					horizontal = "right:55%",
					scrollbar = "float",
				},
			},

			keymap = {
				builtin = {
					["<Esc>"] = "hide",
					["<C-d>"] = "preview-page-down",
					["<C-u>"] = "preview-page-up",
				},
				fzf = {
					["ctrl-d"] = "preview-page-down",
					["ctrl-u"] = "preview-page-up",
					["ctrl-q"] = "select-all+accept",
				},
			},

			files = {
				prompt = "Files> ",

				-- fd:
				-- --hidden      include dotfiles like .env, .github, .vscode
				-- --follow      follow symlinks
				-- --exclude     explicitly hide noisy directories
				--
				-- fd respects .gitignore by default, so ignored build artifacts
				-- and vendor folders usually disappear automatically.
				fd_opts = table.concat({
					"--color=never",
					"--type f",
					"--hidden",
					"--follow",
					"--exclude .git",
					"--exclude .vscode",
					"--exclude node_modules",
					"--exclude dist",
					"--exclude build",
					"--exclude target",
					"--exclude .idea",
				}, " "),

				-- rg fallback for file listing
				rg_opts = table.concat({
					"--color=never",
					"--files",
					"--hidden",
					"--follow",
					"-g '!.git'",
					"-g '!.vscode'",
					"-g '!node_modules'",
					"-g '!dist'",
					"-g '!build'",
					"-g '!target'",
					"-g '!.idea'",
				}, " "),
			},

			grep = {
				prompt = "Grep> ",

				-- live_grep uses ripgrep.
				-- By default ripgrep respects .gitignore.
				-- --hidden makes it search hidden files/folders too,
				-- then we explicitly exclude noisy directories.
				rg_opts = table.concat({
					"--column",
					"--line-number",
					"--no-heading",
					"--color=always",
					"--smart-case",
					"--hidden",
					"--follow",
					"-g '!.git'",
					"-g '!.vscode'",
					"-g '!node_modules'",
					"-g '!dist'",
					"-g '!build'",
					"-g '!target'",
					"-g '!.idea'",
				}, " "),
			},

			oldfiles = {
				prompt = "Recent> ",
				include_current_session = true,
			},

			buffers = {
				prompt = "Buffers> ",
				sort_lastused = true,
			},
		},
		config = function(_, opts)
			require("fzf-lua").setup(opts)
		end,
	},
}
