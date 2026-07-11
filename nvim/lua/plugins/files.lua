local function mini_files()
	return require("mini.files")
end

local function open_project_root()
	mini_files().open(require("config.files").project_root(), false)
end

local function open_current_file()
	local path = vim.api.nvim_buf_get_name(0)

	-- No real file on disk (scratch/empty buffer): fall back to the project root.
	if path == "" or vim.uv.fs_stat(path) == nil then
		open_project_root()
		return
	end

	-- Passing a file path opens its parent directory with the cursor on the file.
	mini_files().open(path, false)
end

return {
	{
		"nvim-mini/mini.files",
		version = false,
		lazy = false,
		keys = {
			{
				"<leader>e",
				open_project_root,
				desc = "Explore project root",
			},
			{
				"<leader>E",
				open_current_file,
				desc = "Explore focused on current file",
			},
		},
		config = function()
			local MiniFiles = mini_files()
			local preview_enabled = {}

			local function repeat_action(action)
				return function()
					for _ = 1, vim.v.count1 do
						action()
					end
				end
			end

			local function set_split_target(direction)
				local state = MiniFiles.get_explorer_state()

				if state == nil or not vim.api.nvim_win_is_valid(state.target_window) then
					return
				end

				local target = vim.api.nvim_win_call(state.target_window, function()
					vim.cmd(direction .. " split")
					return vim.api.nvim_get_current_win()
				end)

				MiniFiles.set_target_window(target)
			end

			local function update_directory_preview(args)
				if not vim.api.nvim_win_is_valid(args.data.win_id) then
					return
				end

				local state = MiniFiles.get_explorer_state()

				if state == nil then
					return
				end

				local focused_path = state.branch[state.depth_focus]
				local is_focused_window = false

				for _, window in ipairs(state.windows) do
					if window.win_id == args.data.win_id and window.path == focused_path then
						is_focused_window = true
						break
					end
				end

				if not is_focused_window then
					return
				end

				local cursor = vim.api.nvim_win_get_cursor(args.data.win_id)
				local entry = MiniFiles.get_fs_entry(args.data.buf_id, cursor[1])
				local should_preview = entry ~= nil and entry.fs_type == "directory"
				local tabpage = vim.api.nvim_get_current_tabpage()

				if preview_enabled[tabpage] == should_preview then
					return
				end

				preview_enabled[tabpage] = should_preview
				MiniFiles.refresh({ windows = { preview = should_preview } })

				if not should_preview then
					local branch = {}

					for depth = 1, state.depth_focus do
						branch[depth] = state.branch[depth]
					end

					MiniFiles.set_branch(branch, { depth_focus = state.depth_focus })
				end
			end

			MiniFiles.setup({
				mappings = {
					-- Backspace should go to the parent directory, not reset the explorer.
					reset = "",
				},
				-- Never auto-open on startup or when editing a directory; the
				-- explorer is opened only via <leader>e / <leader>E.
				options = {
					use_as_default_explorer = false,
				},
				windows = {
					preview = true,
				},
			})

			local group = vim.api.nvim_create_augroup("MiniFilesCustomMappings", { clear = true })

			vim.api.nvim_create_autocmd("User", {
				group = group,
				pattern = "MiniFilesBufferCreate",
				callback = function(args)
					local buffer = args.data.buf_id
					local go_in = repeat_action(function()
						MiniFiles.go_in()
					end)
					local go_in_and_close = repeat_action(function()
						MiniFiles.go_in({ close_on_file = true })
					end)
					local go_out = repeat_action(MiniFiles.go_out)

					vim.keymap.set("n", "<Right>", go_in, { buffer = buffer, desc = "Go in" })
					vim.keymap.set("n", "<Left>", go_out, { buffer = buffer, desc = "Go out" })
					vim.keymap.set("n", "<BS>", go_out, { buffer = buffer, desc = "Go out" })
					vim.keymap.set("n", "<CR>", go_in, { buffer = buffer, desc = "Go in" })
					vim.keymap.set("n", "<S-CR>", go_in_and_close, { buffer = buffer, desc = "Go in and close" })
					vim.keymap.set("n", "<C-s>", function()
						set_split_target("belowright horizontal")
					end, { buffer = buffer, desc = "Split target below" })
					vim.keymap.set("n", "<C-v>", function()
						set_split_target("belowright vertical")
					end, { buffer = buffer, desc = "Split target right" })
				end,
			})

			vim.api.nvim_create_autocmd("User", {
				group = group,
				pattern = "MiniFilesWindowUpdate",
				callback = update_directory_preview,
			})

			vim.api.nvim_create_autocmd("User", {
				group = group,
				pattern = "MiniFilesExplorerClose",
				callback = function()
					preview_enabled[vim.api.nvim_get_current_tabpage()] = nil
				end,
			})

		end,
	},
}
