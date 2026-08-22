-- ~/.config/nvim/lua/plugins/tests.lua

local neotest_config = require("config.neotest")

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
			},
		},

		keys = {
			{
				"<leader>tf",
				function()
					neotest().run.run(neotest_config.integrated_run_args())
				end,
				desc = "Test current function",
			},
			{
				"<leader>tF",
				function()
					neotest().run.run(neotest_config.integrated_run_args(neotest_config.current_file()))
				end,
				desc = "Test current file",
			},
			{
				"<leader>tp",
				function()
					neotest().run.run(neotest_config.integrated_run_args(neotest_config.current_package_dir()))
				end,
				desc = "Test current package",
			},
			{
				"<leader>tP",
				function()
					neotest().run.run(neotest_config.integrated_run_args(neotest_config.project_root()))
				end,
				desc = "Test entire project",
			},
			{
				"<leader>tr",
				function()
					neotest().run.run_last({ strategy = "integrated" })
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
					neotest().test_quickfix.open()
				end,
				desc = "Test failures quickfix",
			},
			{
				"<leader>tw",
				function()
					neotest().watch.toggle(neotest_config.integrated_run_args(neotest_config.current_file()))
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
				default_strategy = "integrated",
				consumers = {
					test_quickfix = neotest_config.quickfix_consumer,
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
					mappings = {
						debug = {},
						debug_marked = {},
					},
				},
			})
		end,
	},
}
