local M = {}
local files = require("config.files")
local go_root_markers = { "go.work", "go.mod", ".git" }

local function current_file()
	return files.current_file(0, vim.uv.cwd())
end

local function current_package_dir()
	return files.current_dir(0, vim.uv.cwd())
end

local function project_root()
	return files.root(0, go_root_markers, vim.uv.cwd())
end

local function integrated_run_args(target)
	if target == nil then
		return { strategy = "integrated" }
	end

	return { target, strategy = "integrated" }
end

local function quickfix_consumer(client)
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

M.current_file = current_file
M.current_package_dir = current_package_dir
M.project_root = project_root
M.integrated_run_args = integrated_run_args
M.quickfix_consumer = quickfix_consumer

return M
