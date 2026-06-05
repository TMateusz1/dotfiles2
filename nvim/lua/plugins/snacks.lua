return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		bigfile = {
			enabled = true,
		},
		bufdelete = {
			enabled = true,
		},
		input = {
			enabled = true,
		},
		lazygit = {
			enabled = true,
		},
		quickfile = {
			enabled = true,
		},
		scratch = {
			enabled = true,
		},
		terminal = {
			enabled = true,
		},
		words = {
			enabled = true,
		},
		zen = {
			enabled = true,
		},
		explorer = {
			enabled = true,
			replace_netrw = true,
			trash = true,
		},

		-- Snacks explorer is picker-backed.
		picker = {
			enabled = true,
			sources = {
				files = {
					hidden = true,
					follow = true,
					exclude = {
						".git",
						".vscode",
						"node_modules",
						"dist",
						"build",
						"target",
						".idea",
					},
				},
				grep = {
					hidden = true,
					follow = true,
					exclude = {
						".git",
						".vscode",
						"node_modules",
						"dist",
						"build",
						"target",
						".idea",
					},
				},
			},
		},
		notifier = {
			enabled = true,
			timeout = 3000,
			style = "fancy", -- "compact" | "minimal" | "fancy"
			width = { min = 40, max = 0.4 },
			height = { min = 1, max = 0.6 },
			margin = { top = 0, right = 1, bottom = 0 },
			padding = true,
			sort = { "level", "added" },
			icons = {
				error = " ",
				warn = " ",
				info = " ",
				debug = " ",
				trace = " ",
			},
		},
	},
	keys = {
		{
			"]r",
			function()
				Snacks.words.jump(vim.v.count1, true)
			end,
			desc = "Next reference",
		},
		{
			"[r",
			function()
				Snacks.words.jump(-vim.v.count1, true)
			end,
			desc = "Previous reference",
		},
		{
			"<leader>e",
			function()
				Snacks.explorer.reveal()
			end,
			desc = "Snacks explorer",
		},
		{
			"<leader>se",
			function()
				Snacks.explorer()
			end,
			desc = "Snacks explorer cwd",
		},
		{
			"<leader>fe",
			function()
				Snacks.explorer()
			end,
			desc = "File explorer",
		},
		{
			"<leader>ff",
			function()
				Snacks.picker.files({
					cwd = vim.fn.getcwd(-1, -1),
				})
			end,
			desc = "Find files",
		},
		{
			"<leader>fg",
			function()
				Snacks.picker.grep()
			end,
			desc = "Live grep",
		},
		{
			"<leader>fG",
			function()
				Snacks.picker.git_status()
			end,
			desc = "Git changed files",
		},
		{
			"<leader>fb",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Find buffers",
		},
		{
			"<leader>fr",
			function()
				Snacks.picker.recent()
			end,
			desc = "Recent files",
		},
		{
			"<leader>fc",
			function()
				Snacks.picker.files({
					cwd = vim.fn.stdpath("config"),
					title = "Config files",
				})
			end,
			desc = "Find config files",
		},
		{
			"<leader>fw",
			function()
				Snacks.picker.grep_word()
			end,
			desc = "Grep word under cursor",
		},
		{
			"<leader>fW",
			function()
				Snacks.picker.grep({
					search = vim.fn.expand("<cWORD>"),
					live = false,
					regex = false,
				})
			end,
			desc = "Grep WORD under cursor",
		},
		{
			"<leader>fh",
			function()
				Snacks.picker.help()
			end,
			desc = "Help tags",
		},
		{
			"<leader>fk",
			function()
				Snacks.picker.keymaps()
			end,
			desc = "Keymaps",
		},
		{
			"<leader>f:",
			function()
				Snacks.picker.commands()
			end,
			desc = "Commands",
		},
		{
			"<leader>fj",
			function()
				Snacks.picker.jumps()
			end,
			desc = "Jump list",
		},
		{
			"<leader>f;",
			function()
				Snacks.picker.command_history()
			end,
			desc = "Command history",
		},
		{
			"<leader>f/",
			function()
				Snacks.picker.search_history()
			end,
			desc = "Search history",
		},
		{
			"<leader>fd",
			function()
				Snacks.picker.diagnostics_buffer()
			end,
			desc = "Document diagnostics",
		},
		{
			"<leader>fD",
			function()
				Snacks.picker.diagnostics()
			end,
			desc = "Workspace diagnostics",
		},
		{
			"<leader>fq",
			function()
				Snacks.picker.qflist()
			end,
			desc = "Quickfix list",
		},
		{
			"<leader>fl",
			function()
				Snacks.picker.loclist()
			end,
			desc = "Location list",
		},
		{
			"<leader>fR",
			function()
				Snacks.picker.resume()
			end,
			desc = "Resume picker",
		},
		{
			"<leader>fn",
			function()
				Snacks.picker.notifications()
			end,
			desc = "Notification history",
		},
		{
			"<leader>f.",
			function()
				Snacks.scratch.select()
			end,
			desc = "Scratch buffers",
		},
		{
			"<leader>gc",
			function()
				Snacks.picker.git_log()
			end,
			desc = "Git commits",
		},
		{
			"<leader>gb",
			function()
				Snacks.picker.git_branches()
			end,
			desc = "Git branches",
		},
		{
			"<leader>gC",
			function()
				Snacks.picker.git_log_file()
			end,
			desc = "Git buffer commits",
		},
		{
			"<leader>gd",
			function()
				Snacks.picker.git_diff()
			end,
			desc = "Git diff hunks",
		},
		{
			"<leader>gl",
			function()
				Snacks.picker.git_log_line()
			end,
			desc = "Git line commits",
		},
		{
			"<leader>gs",
			function()
				Snacks.picker.git_stash()
			end,
			desc = "Git stash",
		},
		{
			"<leader>gg",
			function()
				Snacks.lazygit()
			end,
			desc = "LazyGit",
		},
		{
			"<leader>gG",
			function()
				Snacks.lazygit.log_file()
			end,
			desc = "LazyGit current file",
		},
		{
			"<leader>.",
			function()
				Snacks.scratch()
			end,
			desc = "Toggle scratch buffer",
		},
		{
			"<leader>un",
			function()
				Snacks.picker.notifications()
			end,
			desc = "Notification history",
		},
		{
			"<leader>ut",
			function()
				Snacks.terminal(vim.o.shell)
			end,
			desc = "Toggle terminal",
		},
		{
			"<leader>uz",
			function()
				Snacks.zen()
			end,
			desc = "Toggle zen mode",
		},
		{
			"<leader>uZ",
			function()
				Snacks.zen.zoom()
			end,
			desc = "Toggle zoom",
		},
		{
			"<leader>uw",
			function()
				if Snacks.words.is_enabled() then
					Snacks.words.disable()
				else
					Snacks.words.enable()
				end
			end,
			desc = "Toggle word references",
		},
	},
}
