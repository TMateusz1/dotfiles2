-- Shared by the files and grep picker sources.
local picker_exclude = {
	".git",
	".vscode",
	"node_modules",
	"dist",
	"build",
	"target",
	".idea",
}

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		bigfile = {
			enabled = true,
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
		terminal = {
			enabled = true,
		},
		toggle = {
			enabled = true,
		},
		zen = {
			enabled = true,
		},

		picker = {
			enabled = true,
			sources = {
				files = {
					hidden = true,
					follow = true,
					exclude = picker_exclude,
				},
				grep = {
					hidden = true,
					follow = true,
					exclude = picker_exclude,
				},
			},
		},
	},
	config = function(_, opts)
		require("snacks").setup(opts)

		-- Picker markdown previews: syntax-highlight only, never run Snacks'
		-- heavy markdown pass (image scanning via Snacks.image.doc.attach +
		-- a full synchronous render-markdown decoration). That pass froze the
		-- preview on large .md files. Treesitter highlighting is kept.
		require("snacks.picker.util.markdown").render = function(buf)
			if not pcall(vim.treesitter.start, buf, "markdown") then
				vim.bo[buf].syntax = "markdown"
			end
		end
	end,
	keys = {
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
			"<leader>/",
			function()
				Snacks.picker.lines()
			end,
			desc = "Search buffer lines",
		},
		{
			"<leader>fu",
			function()
				Snacks.picker.undo()
			end,
			desc = "Undo history",
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
			"<leader>fs",
			function()
				Snacks.picker.lsp_symbols()
			end,
			desc = "Document symbols",
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
				require("mini.notify").show_history()
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
	},
}
