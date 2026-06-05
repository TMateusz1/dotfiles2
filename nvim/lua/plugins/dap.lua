-- ~/.config/nvim/lua/plugins/dap.lua

local function dap()
	return require("dap")
end

local function dapui()
	return require("dapui")
end

local function dap_go()
	return require("dap-go")
end

local function delve_path()
	local mason_dlv = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", "dlv")

	if vim.fn.executable(mason_dlv) == 1 then
		return mason_dlv
	end

	return "dlv"
end

local function float_size(width_ratio, height_ratio)
	return {
		width = math.floor(vim.o.columns * width_ratio),
		height = math.floor(vim.o.lines * height_ratio),
	}
end

return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			{
				"leoluz/nvim-dap-go",
				config = function()
					require("dap-go").setup({
						delve = {
							path = delve_path(),
						},
					})
				end,
			},
			{
				"rcarriga/nvim-dap-ui",
				dependencies = {
					"nvim-neotest/nvim-nio",
				},
				opts = {
					controls = {
						enabled = true,
					},
					expand_lines = true,
					floating = {
						border = "rounded",
						max_height = 0.85,
						max_width = 0.95,
					},
					layouts = {
						{
							elements = {
								{
									id = "scopes",
									size = 0.65,
								},
								{
									id = "watches",
									size = 0.15,
								},
								{
									id = "stacks",
									size = 0.20,
								},
							},
							position = "right",
							size = 64,
						},
						{
							elements = {
								{
									id = "repl",
									size = 0.6,
								},
								{
									id = "console",
									size = 0.4,
								},
							},
							position = "bottom",
							size = 12,
						},
					},
					render = {
						indent = 2,
						max_type_length = 80,
						max_value_lines = 20,
					},
				},
			},
			{
				"theHamsta/nvim-dap-virtual-text",
				opts = {},
			},
		},
		keys = {
			{
				"<leader>db",
				function()
					dap().toggle_breakpoint()
				end,
				desc = "Debug toggle breakpoint",
			},
			{
				"<leader>dB",
				function()
					dap().set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				desc = "Debug conditional breakpoint",
			},
			{
				"<leader>dp",
				function()
					dap().set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
				end,
				desc = "Debug log point",
			},
			{
				"<leader>dc",
				function()
					dap().continue()
				end,
				desc = "Debug continue",
			},
			{
				"<leader>dC",
				function()
					dap().run_to_cursor()
				end,
				desc = "Debug run to cursor",
			},
			{
				"<leader>di",
				function()
					dap().step_into()
				end,
				desc = "Debug step into",
			},
			{
				"<leader>do",
				function()
					dap().step_over()
				end,
				desc = "Debug step over",
			},
			{
				"<leader>dO",
				function()
					dap().step_out()
				end,
				desc = "Debug step out",
			},
			{
				"<leader>dr",
				function()
					dap().restart()
				end,
				desc = "Debug restart",
			},
			{
				"<leader>dl",
				function()
					dap().run_last()
				end,
				desc = "Debug run last",
			},
			{
				"<leader>dt",
				function()
					dap().terminate()
				end,
				desc = "Debug terminate",
			},
			{
				"<leader>du",
				function()
					dapui().toggle()
				end,
				desc = "Debug UI",
			},
			{
				"<leader>de",
				function()
					dapui().eval()
				end,
				desc = "Debug eval",
				mode = { "n", "v" },
			},
			{
				"<leader>df",
				function()
					dapui().float_element("frames", {
						enter = true,
					})
				end,
				desc = "Debug frames",
			},
			{
				"<leader>ds",
				function()
					dapui().float_element("scopes", {
						enter = true,
					})
				end,
				desc = "Debug scopes",
			},
			{
				"<leader>dS",
				function()
					dapui().float_element(
						"scopes",
						vim.tbl_extend("force", float_size(0.92, 0.82), {
							enter = true,
						})
					)
				end,
				desc = "Debug scopes wide",
			},
			{
				"<leader>dg",
				function()
					dap_go().debug_test()
				end,
				desc = "Debug Go test",
			},
			{
				"<leader>dG",
				function()
					dap_go().debug_last_test()
				end,
				desc = "Debug last Go test",
			},
		},
		config = function()
			local icons = {
				breakpoint = "●",
				breakpoint_condition = "◆",
				log_point = "◆",
				stopped = "▶",
			}

			vim.fn.sign_define("DapBreakpoint", {
				text = icons.breakpoint,
				texthl = "DiagnosticSignError",
			})
			vim.fn.sign_define("DapBreakpointCondition", {
				text = icons.breakpoint_condition,
				texthl = "DiagnosticSignWarn",
			})
			vim.fn.sign_define("DapLogPoint", {
				text = icons.log_point,
				texthl = "DiagnosticSignInfo",
			})
			vim.fn.sign_define("DapStopped", {
				text = icons.stopped,
				texthl = "DiagnosticSignHint",
				linehl = "Visual",
			})

			local debug = dap()
			local ui = dapui()

			debug.listeners.before.attach.dapui_config = function()
				ui.open()
			end
			debug.listeners.before.launch.dapui_config = function()
				ui.open()
			end
			debug.listeners.before.event_terminated.dapui_config = function()
				ui.close()
			end
			debug.listeners.before.event_exited.dapui_config = function()
				ui.close()
			end
		end,
	},
}
