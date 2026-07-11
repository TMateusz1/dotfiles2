-- ~/.config/nvim/lua/plugins/tests.lua

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

local function integrated_run_args(target)
	if target == nil then
		return { strategy = "integrated" }
	end

	return { target, strategy = "integrated" }
end

local function test_quickfix_consumer(client)
	local items = {}

	local function replace_quickfix()
		vim.fn.setqflist({}, "r", {
			title = "Neotest failures",
			items = items,
		})
	end

	client.listeners.run = function()
		items = {}
	end

	client.listeners.results = function(adapter_id, results, partial)
		if partial then
			return
		end

		local tree = client:get_position(nil, { adapter = adapter_id })
		local next_items = {}
		local seen = {}

		for position_id, result in pairs(results) do
			local node = tree and tree:get_key(position_id)
			local position = node and node:data()

			if result.status == "failed" and position and (position.type == "test" or position.type == "file") then
				local range = node:closest_value_for("range") or { 0, 0 }
				local errors = result.errors or {}

				if #errors == 0 and position.type == "test" then
					errors = { { line = range[1], message = "Failed: " .. position.name } }
				end

				for _, error in ipairs(errors) do
					local item = {
						filename = position.path,
						lnum = (error.line or range[1]) + 1,
						col = range[2] + 1,
						text = error.message or ("Failed: " .. (position.name or position.id)),
						type = "E",
					}
					local key = table.concat({ item.filename, item.lnum, item.col, item.text }, ":")

					if not seen[key] then
						seen[key] = true
						next_items[#next_items + 1] = item
					end
				end
			end
		end

		table.sort(next_items, function(a, b)
			if a.filename == b.filename then
				return a.lnum < b.lnum
			end

			return a.filename < b.filename
		end)

		items = next_items
		vim.schedule(replace_quickfix)
	end

	return {
		open = function()
			replace_quickfix()

			if #items == 0 then
				pcall(vim.cmd, "cclose")
				vim.notify("No failed Neotest results", vim.log.levels.INFO, { title = "Tests" })
				return
			end

			vim.cmd("copen")
		end,
	}
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
					neotest().run.run(integrated_run_args())
				end,
				desc = "Test current function",
			},
			{
				"<leader>tF",
				function()
					neotest().run.run(integrated_run_args(current_file()))
				end,
				desc = "Test current file",
			},
			{
				"<leader>tp",
				function()
					neotest().run.run(integrated_run_args(current_package_dir()))
				end,
				desc = "Test current package",
			},
			{
				"<leader>tP",
				function()
					neotest().run.run(integrated_run_args(project_root()))
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
					neotest().watch.toggle(integrated_run_args(current_file()))
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
					test_quickfix = test_quickfix_consumer,
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
