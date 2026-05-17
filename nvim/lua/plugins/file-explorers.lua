return {
	-- {
	-- 	"nvim-neo-tree/neo-tree.nvim",
	-- 	branch = "v3.x",
	-- 	cmd = "Neotree",
	-- 	keys = {
	-- 		{
	-- 			"<leader>e",
	-- 			"<cmd>Neotree toggle filesystem reveal left<CR>",
	-- 			desc = "Explorer",
	-- 		},
	-- 		{
	-- 			"<leader>ge",
	-- 			"<cmd>Neotree toggle git_status left<CR>",
	-- 			desc = "Git status tree",
	-- 		},
	-- 		{
	-- 			"<leader>be",
	-- 			"<cmd>Neotree toggle buffers left<CR>",
	-- 			desc = "Buffers tree",
	-- 		},
	-- 	},
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		"MunifTanjim/nui.nvim",
	-- 		"nvim-mini/mini.icons",
	-- 	},
	-- 	opts = {
	-- 		close_if_last_window = false,
	-- 		popup_border_style = "rounded",
	-- 		enable_git_status = true,
	-- 		enable_diagnostics = true,
	--
	-- 		sources = {
	-- 			"filesystem",
	-- 			"buffers",
	-- 			"git_status",
	-- 		},
	--
	-- 		source_selector = {
	-- 			winbar = true,
	-- 			statusline = false,
	-- 			sources = {
	-- 				{
	-- 					source = "filesystem",
	-- 					display_name = " 󰉓 Files ",
	-- 				},
	-- 				{
	-- 					source = "buffers",
	-- 					display_name = " 󰈙 Buffers ",
	-- 				},
	-- 				{
	-- 					source = "git_status",
	-- 					display_name = " 󰊢 Git ",
	-- 				},
	-- 			},
	-- 		},
	--
	-- 		default_component_configs = {
	-- 			indent = {
	-- 				with_expanders = true,
	-- 				expander_collapsed = "",
	-- 				expander_expanded = "",
	-- 			},
	-- 			icon = {
	-- 				folder_closed = "",
	-- 				folder_open = "",
	-- 				folder_empty = "󰜌",
	-- 				default = "󰈙",
	-- 			},
	-- 			git_status = {
	-- 				symbols = {
	-- 					added = "A",
	-- 					modified = "M",
	-- 					deleted = "D",
	-- 					renamed = "R",
	-- 					untracked = "X",
	-- 					ignored = "I",
	-- 					unstaged = "U",
	-- 					staged = "S",
	-- 					conflict = "C",
	-- 				},
	-- 			},
	-- 		},
	--
	-- 		window = {
	-- 			position = "left",
	-- 			width = 35,
	-- 			mappings = {
	-- 				["<space>"] = "none",
	--
	-- 				["<CR>"] = "open",
	-- 				["l"] = "open",
	-- 				["h"] = "close_node",
	--
	-- 				["o"] = "add",
	-- 				["O"] = "add_directory",
	-- 				["r"] = "rename",
	-- 				["d"] = "delete",
	-- 				["m"] = "move",
	-- 				["c"] = "copy",
	--
	-- 				["y"] = "copy_to_clipboard",
	-- 				["x"] = "cut_to_clipboard",
	-- 				["p"] = "paste_from_clipboard",
	--
	-- 				["R"] = "refresh",
	-- 				["?"] = "show_help",
	--
	-- 				["."] = "toggle_hidden",
	-- 				["g?"] = "show_help",
	-- 			},
	-- 		},
	--
	-- 		filesystem = {
	-- 			filtered_items = {
	-- 				visible = false,
	-- 				hide_dotfiles = false,
	-- 				hide_gitignored = false,
	-- 				hide_hidden = false,
	--
	-- 				hide_by_name = {
	-- 					".git",
	-- 					".idea",
	-- 					".vscode",
	-- 				},
	--
	-- 				never_show = {},
	-- 			},
	--
	-- 			follow_current_file = {
	-- 				enabled = true,
	-- 				leave_dirs_open = false,
	-- 			},
	--
	-- 			group_empty_dirs = false,
	-- 			hijack_netrw_behavior = "disabled",
	-- 			use_libuv_file_watcher = true,
	--
	-- 			window = {
	-- 				mappings = {
	-- 					["."] = "toggle_hidden",
	-- 				},
	-- 			},
	-- 		},
	--
	-- 		buffers = {
	-- 			follow_current_file = {
	-- 				enabled = true,
	-- 				leave_dirs_open = false,
	-- 			},
	-- 			group_empty_dirs = true,
	-- 			show_unloaded = true,
	-- 		},
	--
	-- 		git_status = {
	-- 			window = {
	-- 				mappings = {
	-- 					["A"] = "git_add_all",
	-- 					["gu"] = "git_unstage_file",
	-- 					["ga"] = "git_add_file",
	-- 					["gr"] = "git_revert_file",
	-- 					["gc"] = "git_commit",
	-- 					["gp"] = "git_push",
	-- 					["gg"] = "git_commit_and_push",
	-- 				},
	-- 			},
	-- 		},
	-- 	},
	-- },
	-- OIL
	{
		"stevearc/oil.nvim",
		keys = {
			{
				"<leader>E",
				"<cmd>Oil --float<CR>",
				desc = "Oil file manager",
			},
			{
				"-",
				"<cmd>Oil --float<CR>",
				desc = "Oil parent directory",
			},
		},
		dependencies = {
			"nvim-mini/mini.icons",
		},
		opts = {
			default_file_explorer = false,

			columns = {
				"icon",
				"permissions",
				"size",
				"mtime",
			},

			buf_options = {
				buflisted = false,
				bufhidden = "hide",
			},

			win_options = {
				wrap = false,
				signcolumn = "no",
				cursorcolumn = false,
				foldcolumn = "0",
				spell = false,
				list = false,
				conceallevel = 3,
				concealcursor = "nvic",
			},

			delete_to_trash = true,
			skip_confirm_for_simple_edits = false,
			prompt_save_on_select_new_entry = true,
			cleanup_delay_ms = 2000,
			lsp_file_methods = {
				enabled = true,
				timeout_ms = 1000,
				autosave_changes = false,
			},

			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["<C-v>"] = "actions.select_vsplit",
				["<C-s>"] = "actions.select_split",
				["<C-t>"] = "actions.select_tab",

				["<Esc>"] = "actions.close",
				["q"] = "actions.close",

				["<BS>"] = "actions.parent",
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",

				["`"] = "actions.cd",
				["~"] = "actions.tcd",

				["g."] = "actions.toggle_hidden",
				["R"] = "actions.refresh",
			},

			use_default_keymaps = true,

			view_options = {
				show_hidden = true,

				is_hidden_file = function(name)
					local hidden = {
						[".git"] = true,
						[".idea"] = true,
						[".vscode"] = true,
					}

					return hidden[name] == true
				end,

				is_always_hidden = function()
					return false
				end,

				natural_order = true,
				case_insensitive = false,
				sort = {
					{ "type", "asc" },
					{ "name", "asc" },
				},
			},

			float = {
				padding = 2,
				max_width = 0.9,
				max_height = 0.9,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
			},

			preview_win = {
				update_on_cursor_moved = true,
				preview_method = "fast_scratch",
				disable_preview = function(filename)
					return false
				end,
			},
		},
	},
}
