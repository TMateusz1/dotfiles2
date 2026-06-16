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

-- Reset (discard) the working-tree hunk(s) under the cursor/selection in the
-- git_diff picker. Each item carries a full unified-diff patch for one hunk
-- (item.diff), so we reverse-apply it to the working tree, then reload any
-- open buffers and refresh the picker list.
local function git_diff_reset_hunk(picker)
	local items = picker:selected({ fallback = true })
	local first = items[1]

	if not first or not first.diff then
		Snacks.notify.warn("No hunk to reset here", { title = "Snacks Picker" })
		return
	end

	local files = vim.tbl_map(function(item)
		return Snacks.picker.util.path(item)
	end, items)
	local msg = #items == 1 and ("Discard hunk in `%s`?"):format(files[1])
		or ("Discard %d hunks?"):format(#items)

	Snacks.picker.util.confirm(msg, function()
		local done = 0
		for _, item in ipairs(items) do
			Snacks.picker.util.cmd({ "git", "apply", "--reverse", "-" }, function()
				done = done + 1
				if done == #items then
					vim.schedule(function()
						-- Reload buffers that changed on disk, then refresh.
						vim.cmd("checktime")
						picker:refresh()
					end)
				end
			end, { cwd = item.cwd, input = item.diff })
		end
	end)
end

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
		notifier = {
			-- Renders vim.notify as stacked top-right cards (replaces the
			-- noice → nvim-notify path). noice keeps the cmdline + messages.
			enabled = true,
			top_down = true,
			timeout = 3000,
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
			-- Snacks' own "fancy" diff renderer (borders, gutter line numbers,
			-- treesitter-highlighted code). Theme-integrated with catppuccin.
			previewers = {
				diff = {
					style = "fancy",
					wo = {
						number = false,
						relativenumber = false,
						signcolumn = "no",
						foldcolumn = "0",
						cursorline = false,
						wrap = false,
					},
				},
			},
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
				Snacks.notifier.show_history()
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
				Snacks.picker.git_diff({
					-- Big, preview-dominant layout so the fancy diff has room.
					layout = {
						preview = true,
						layout = {
							box = "horizontal",
							width = 0.92,
							height = 0.92,
							border = "rounded",
							{
								box = "vertical",
								width = 0.32,
								{
									win = "input",
									height = 1,
									border = "rounded",
									title = "{title} {live} {flags}",
									title_pos = "center",
								},
								{ win = "list", border = "rounded" },
							},
							{ win = "preview", title = "{preview}", border = "rounded" },
						},
					},
					-- C-x discards the hunk under the cursor (like gitsigns reset).
					actions = {
						git_diff_reset_hunk = git_diff_reset_hunk,
					},
					win = {
						input = {
							keys = {
								["<c-x>"] = { "git_diff_reset_hunk", mode = { "n", "i" }, desc = "Reset hunk" },
							},
						},
						list = {
							keys = {
								["<c-x>"] = { "git_diff_reset_hunk", desc = "Reset hunk" },
							},
						},
					},
				})
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
