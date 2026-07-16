local M = {}
local collapse_on_render = false

local function project_root()
	return require("config.files").project_root()
end

function M.collapse_focused(state)
	local tree = state.tree
	local node = tree and tree:get_node()

	if not node then
		return
	end

	local target = node.type == "directory" and node or tree:get_node(node:get_parent_id())
	local root = tree:get_nodes()[1]

	if not target or target == root then
		return
	end

	target:collapse()
	if state.explicitly_opened_nodes then
		state.explicitly_opened_nodes[target:get_id()] = false
	end

	local renderer = require("neo-tree.ui.renderer")
	renderer.redraw(state)
	renderer.focus_node(state, target:get_id())
end

function M.open_and_close(state)
	local node = state.tree and state.tree:get_node()

	if not node then
		return
	end

	require("neo-tree.sources.filesystem.commands").open(state)

	if node.type == "file" then
		require("neo-tree.command").execute({ action = "close" })
	end
end

function M.collapse_and_focus_root(state)
	state = state or require("neo-tree.sources.manager").get_state("filesystem")

	if not state or not state.tree then
		return
	end

	require("neo-tree.sources.filesystem.commands").close_all_nodes(state)

	local root = state.tree:get_nodes()[1]
	if root then
		require("neo-tree.ui.renderer").focus_node(state, root:get_id())
	end
end

function M.open_current_file()
	local path = vim.api.nvim_buf_get_name(0)

	if path == "" or vim.uv.fs_stat(path) == nil then
		M.open_root()
		return
	end

	require("neo-tree.command").execute({
		action = "focus",
		source = "filesystem",
		position = "left",
		dir = project_root(),
		reveal_file = path,
		reveal_force_cwd = true,
	})
end

function M.open_root()
	collapse_on_render = true

	require("neo-tree.command").execute({
		action = "focus",
		source = "filesystem",
		position = "left",
		dir = project_root(),
		reveal = false,
	})

	local state = require("neo-tree.sources.manager").get_state("filesystem")
	if state and state.tree then
		collapse_on_render = false
		M.collapse_and_focus_root(state)
	end
end

function M.setup()
	require("neo-tree").setup({
		close_if_last_window = false,
		enable_diagnostics = true,
		enable_git_status = true,
		popup_border_style = "rounded",
		default_component_configs = {
			indent = {
				with_markers = true,
				indent_marker = "│",
				last_indent_marker = "└",
				expander_collapsed = "",
				expander_expanded = "",
			},
			icon = {
				folder_closed = "",
				folder_open = "",
				folder_empty = "󰉖",
				folder_empty_open = "󰷏",
				default = "󰈔",
			},
			git_status = {
				symbols = {
					added = "✚",
					deleted = "✖",
					modified = "",
					renamed = "󰁕",
					untracked = "",
					ignored = "",
					unstaged = "󰄱",
					staged = "",
					conflict = "",
				},
			},
		},
		event_handlers = {
			{
				event = "after_render",
				handler = function(state)
					if collapse_on_render and state.name == "filesystem" then
						collapse_on_render = false
						M.collapse_and_focus_root(state)
					end
				end,
			},
		},
		filesystem = {
			bind_to_cwd = false,
			follow_current_file = {
				enabled = false,
				leave_dirs_open = false,
			},
			filtered_items = {
				hide_dotfiles = false,
				hide_gitignored = false,
				hide_by_name = { ".git", ".DS_Store" },
			},
			group_empty_dirs = false,
			hijack_netrw_behavior = "disabled",
			use_libuv_file_watcher = true,
		},
		window = {
			position = "left",
			width = 38,
			mappings = {
				["="] = M.collapse_focused,
				["+"] = M.collapse_and_focus_root,
				["<S-CR>"] = M.open_and_close,
			},
		},
	})
end

return M
