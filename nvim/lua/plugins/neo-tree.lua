return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		cmd = "Neotree",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-mini/mini.icons",
		},
		keys = {
			{
				"<leader>e",
				"<cmd>Neotree toggle right reveal<CR>",
				desc = "Toggle file explorer",
			},
		},
		opts = {
			close_if_last_window = true,
			enable_diagnostics = true,
			enable_git_status = true,
			enable_modified_markers = true,
			popup_border_style = "rounded",

			-- A compact, readable sidebar: folders, files, Git state, and
			-- diagnostics stay visible without taking over the editor.
			default_component_configs = {
				container = {
					enable_character_fade = true,
				},
				indent = {
					indent_size = 2,
					padding = 1,
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
				},
				modified = {
					symbol = "●",
				},
				git_status = {
					symbols = {
						added = "✚",
						modified = "",
						deleted = "✖",
						renamed = "󰁕",
						untracked = "★",
						ignored = "◌",
						unstaged = "󰄱",
						staged = "",
						conflict = "",
					},
				},
			},

			window = {
				position = "right",
				width = 38,
				mappings = {
					["<CR>"] = "open",
					["l"] = "open",
					["h"] = "close_node",
					["q"] = "close_window",
				},
			},

			filesystem = {
				follow_current_file = {
					enabled = true,
					leave_dirs_open = true,
				},
				filtered_items = {
					hide_dotfiles = false,
					hide_gitignored = false,
					never_show = { ".DS_Store", "thumbs.db" },
				},
				use_libuv_file_watcher = true,
			},
		},
	},
}
