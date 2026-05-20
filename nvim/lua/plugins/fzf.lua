-- ~/.config/nvim/lua/plugins/fzf.lua

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
					require("fzf-lua").files()
				end,
				desc = "Find files",
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
