-- ~/.config/nvim/lua/plugins/testing.lua

local function current_file()
	local file = vim.api.nvim_buf_get_name(0)

	if file == "" then
		return vim.uv.cwd()
	end

	return vim.fs.normalize(file)
end

local function current_package_dir()
	local file = current_file()

	if vim.fn.filereadable(file) == 1 then
		return vim.fs.dirname(file)
	end

	return vim.uv.cwd()
end

local function project_root()
	local file = current_file()

	local root = vim.fs.root(file, {
		"go.work",
		"go.mod",
		".git",
	})

	return root or vim.uv.cwd()
end

local function neotest()
	return require("neotest")
end

return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",

			{
				"fredrikaverpil/neotest-golang",
				version = "*",
				build = function()
					if vim.fn.executable("gotestsum") == 1 then
						return
					end

					vim.system({
						"go",
						"install",
						"gotest.tools/gotestsum@latest",
					}):wait()
				end,
			},
		},

		keys = {
			{
				"<leader>tf",
				function()
					neotest().run.run()
				end,
				desc = "Test current function",
			},
			{
				"<leader>tF",
				function()
					neotest().run.run(current_file())
				end,
				desc = "Test current file",
			},
			{
				"<leader>tp",
				function()
					neotest().run.run(current_package_dir())
				end,
				desc = "Test current package",
			},
			{
				"<leader>tP",
				function()
					neotest().run.run(project_root())
				end,
				desc = "Test entire project",
			},
			{
				"<leader>tr",
				function()
					neotest().run.run_last()
				end,
				desc = "Test rerun last",
			},
			{
				"<leader>ts",
				function()
					neotest().summary.toggle()
				end,
				desc = "Test summary",
			},
			{
				"<leader>to",
				function()
					neotest().output.open({
						enter = true,
						auto_close = true,
					})
				end,
				desc = "Test output",
			},
			{
				"<leader>tO",
				function()
					neotest().output_panel.toggle()
				end,
				desc = "Test output panel",
			},
			{
				"<leader>tq",
				function()
					neotest().jump.next({
						status = "failed",
					})
				end,
				desc = "Next failed test",
			},
			{
				"<leader>tQ",
				function()
					neotest().jump.prev({
						status = "failed",
					})
				end,
				desc = "Previous failed test",
			},
			{
				"<leader>tw",
				function()
					neotest().watch.toggle(current_file())
				end,
				desc = "Test watch file",
			},
			{
				"<leader>tx",
				function()
					neotest().run.stop()
				end,
				desc = "Test stop",
			},
		},

		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-golang")({
						runner = "gotestsum",
					}),
				},

				diagnostic = {
					enabled = true,
				},

				floating = {
					border = "rounded",
					max_height = 0.7,
					max_width = 0.8,
				},

				icons = {
					expanded = "▾",
					child_prefix = "",
					child_indent = "  ",
					final_child_prefix = "",
					non_collapsible = "",
					passed = "✓",
					failed = "✗",
					running = "●",
					skipped = "○",
					unknown = "?",
				},

				output = {
					enabled = true,
					open_on_run = "short",
				},

				output_panel = {
					enabled = true,
					open = "botright split | resize 15",
				},

				quickfix = {
					enabled = true,
					open = false,
				},

				status = {
					enabled = true,
					signs = true,
					virtual_text = false,
				},

				summary = {
					enabled = true,
					expand_errors = true,
					follow = true,
				},
			})
		end,
	},
}
