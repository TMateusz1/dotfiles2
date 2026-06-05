local function file_preview_without_markdown_render(ctx)
	local path = Snacks.picker.util.path(ctx.item)
	local ft = path and vim.filetype.match({ filename = path }) or nil

	if ft ~= "markdown" then
		return Snacks.picker.preview.file(ctx)
	end

	local file = ctx.picker.opts.previewers.file
	local previous_ft = file.ft
	file.ft = "text"
	local ok, result = pcall(Snacks.picker.preview.file, ctx)
	file.ft = previous_ft

	if not ok then
		error(result)
	end

	return result
end

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
		dashboard = {
			enabled = true,
			preset = {
				keys = {
					{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
					{ icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
					{ icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
					{
						icon = " ",
						key = "c",
						desc = "Config",
						action = ":lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })",
					},
					{ icon = " ", key = "s", desc = "Search Sessions", action = ":lua require('persistence').select()" },
					{ icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy" },
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1, padding = 1 },
				{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
				{ section = "startup" },
			},
		},
		dim = {
			enabled = true,
		},
		gitbrowse = {
			enabled = true,
		},
		indent = {
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
		scroll = {
			enabled = true,
		},
		statuscolumn = {
			enabled = true,
		},
		terminal = {
			enabled = true,
		},
		toggle = {
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
			replace_netrw = false,
			trash = true,
		},

		-- Snacks explorer is picker-backed.
		picker = {
			enabled = true,
			sources = {
				files = {
					hidden = true,
					follow = true,
					preview = file_preview_without_markdown_render,
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
			"<leader>gB",
			function()
				Snacks.gitbrowse()
			end,
			desc = "Git browse (open in browser)",
			mode = { "n", "v" },
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
			"<leader>ud",
			function()
				Snacks.toggle.dim():toggle()
			end,
			desc = "Toggle code dimming",
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
				Snacks.toggle.words():toggle()
			end,
			desc = "Toggle word references",
		},
	},
}
