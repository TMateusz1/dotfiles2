return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			-- icons come from mini.icons via its nvim-web-devicons mock
			-- (see plugins/minis.lua).
			"nvim-mini/mini.icons",
		},
		cmd = "Neotree",
		-- Load eagerly when Neovim is started on a directory (e.g. `nvim .`)
		-- so neo-tree's netrw hijack can take over that buffer.
		init = function()
			if vim.fn.argc(-1) == 1 then
				local stat = vim.uv.fs_stat(vim.fn.argv(0))
				if stat and stat.type == "directory" then
					require("neo-tree")
				end
			end
		end,
		keys = {
			{
				"<leader>e",
				function()
					-- Only reveal when the current buffer is a real, on-disk file;
					-- otherwise (dashboard, scratch, ...) reveal would prompt to
					-- change cwd for a bogus path.
					local reveal = false
					if vim.bo.buftype == "" then
						local name = vim.api.nvim_buf_get_name(0)
						reveal = name ~= "" and vim.uv.fs_stat(name) ~= nil
					end

					require("neo-tree.command").execute({
						toggle = true,
						source = "filesystem",
						position = "left",
						reveal = reveal,
					})
				end,
				desc = "File explorer (neo-tree)",
			},
		},
		opts = {
			close_if_last_window = true,
			popup_border_style = "rounded",
			enable_git_status = true,
			enable_diagnostics = true,
			sort_case_insensitive = true,

			-- Close the tree as soon as a file is opened from it.
			event_handlers = {
				{
					event = "file_opened",
					handler = function()
						require("neo-tree.command").execute({ action = "close" })
					end,
				},
			},

			default_component_configs = {
				indent = {
					with_markers = true,
					indent_marker = "│",
					last_indent_marker = "└",
					with_expanders = true,
					expander_collapsed = "",
					expander_expanded = "",
					expander_highlight = "NeoTreeExpander",
				},
				icon = {
					folder_closed = "",
					folder_open = "",
					folder_empty = "󰜌",
					default = "",
				},
				modified = {
					symbol = "●",
				},
				git_status = {
					symbols = {
						added = "",
						modified = "",
						deleted = "",
						renamed = "󰁕",
						untracked = "",
						ignored = "",
						unstaged = "󰄱",
						staged = "",
						conflict = "",
					},
				},
				diagnostics = {
					symbols = {
						hint = "󰌶",
						info = "",
						warn = "",
						error = "",
					},
				},
			},

			source_selector = {
				winbar = true,
				statusline = false,
				content_layout = "center",
				sources = {
					{ source = "filesystem", display_name = "  Files " },
					{ source = "buffers", display_name = "  Buffers " },
					{ source = "git_status", display_name = "  Git " },
				},
			},

			window = {
				position = "left",
				width = 32,
				mappings = {
					["l"] = "open",
					["h"] = "close_node",
					["<CR>"] = "open",
					["<Esc>"] = "cancel",
					["s"] = "open_split",
					["v"] = "open_vsplit",
					["<C-s>"] = "open_split",
					["<C-v>"] = "open_vsplit",
					-- `-`/`=` are reserved for window splits globally; keep them
					-- inert inside the tree.
					["-"] = "noop",
					["="] = "noop",
				},
			},

			filesystem = {
				bind_to_cwd = false,
				-- Take over directory buffers (`nvim .`) in the same window.
				hijack_netrw_behavior = "open_current",
				follow_current_file = {
					enabled = true,
				},
				use_libuv_file_watcher = true,
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
					hide_gitignored = false,
					hide_by_name = {
						".git",
						".idea",
						".vscode",
					},
				},
			},
		},
	},
}
