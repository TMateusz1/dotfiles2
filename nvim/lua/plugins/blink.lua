local function stop_active_vim_snippet()
	if not (vim.snippet and vim.snippet.active and vim.snippet.stop) then
		return
	end

	if vim.snippet.active() then
		pcall(vim.snippet.stop)
	end
end

local function is_friendly_snippet(file, relative_path)
	return file:match("friendly%-snippets.*/snippets/" .. relative_path .. "$") ~= nil
end

return {
	{
		"saghen/blink.cmp",
		version = "1.*",
		event = "InsertEnter",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"rafamadriz/friendly-snippets",
		},
		opts = {
			-- File explorer buffers are for typing file/dir names, not prose, and
			-- prompt buffers are single-line inputs; buffer-word completion in
			-- either is just noise.
			enabled = function()
				return vim.bo.filetype ~= "neo-tree" and vim.bo.buftype ~= "prompt"
			end,

			keymap = {
				preset = "default",

				["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "cancel", "fallback" },
				["<Esc>"] = { "hide", "fallback" },
				["<CR>"] = {
					function(cmp)
						if cmp.is_visible() then
							return cmp.select_and_accept()
						end

						if cmp.snippet_active({ direction = 1 }) then
							cmp.hide()
							return cmp.snippet_forward()
						end
					end,
					"fallback",
				},
				["<S-CR>"] = {
					function()
						stop_active_vim_snippet()
						return false
					end,
					"fallback",
				},

				-- Completion owns Enter when visible; otherwise Enter and Tab both
				-- advance snippet placeholders. Shift-Enter exits the snippet and
				-- inserts a regular newline through the autopairs fallback.
				["<Tab>"] = {
					function(cmp)
						if cmp.snippet_active({ direction = 1 }) then
							cmp.hide()
							return cmp.snippet_forward()
						end

						if cmp.is_visible() then
							return cmp.select_and_accept()
						end
					end,
					"fallback",
				},
				["<S-Tab>"] = {
					function(cmp)
						if cmp.snippet_active({ direction = -1 }) then
							cmp.hide()
							return cmp.snippet_backward()
						end

						if cmp.is_menu_visible() then
							return cmp.select_prev()
						end
					end,
					"fallback",
				},

				["<C-j>"] = { "select_next", "fallback" },
				["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
				["<C-n>"] = { "select_next", "fallback" },
				["<C-p>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
				["<Up>"] = { "select_prev", "fallback" },

				["<C-d>"] = { "scroll_documentation_down", "fallback" },
				["<C-u>"] = { "scroll_documentation_up", "fallback" },
			},

			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},

			completion = {
				accept = {
					auto_brackets = {
						enabled = true,
						-- Only decide brackets from the completion item kind
						-- (Function/Method). The semantic-token fallback misfires
						-- inside snippet placeholders and turns a struct like
						-- `Config` into `Config()`.
						semantic_token_resolution = {
							enabled = false,
						},
					},
				},

				trigger = {
					-- Show completion inside snippet placeholders (e.g. the
					-- receiver-type field of a `meth` snippet).
					show_in_snippet = true,
				},

				documentation = {
					auto_show = true,
					auto_show_delay_ms = 300,
					window = {
						border = "rounded",
					},
				},

				ghost_text = {
					enabled = function()
						return vim.bo.filetype ~= "grug-far"
					end,
				},

				menu = {
					-- Grug Far is an editable search form; keep completion available
					-- on demand without opening the menu after every keystroke.
					auto_show = function()
						return vim.bo.filetype ~= "grug-far"
					end,

					border = "rounded",

					draw = {
						columns = {
							{ "kind_icon" },
							{ "label", "label_description", gap = 1 },
							{ "source_name" },
						},
					},
				},

				list = {
					selection = {
						preselect = true,
						auto_insert = false,
					},
				},
			},

			snippets = {
				preset = "default",
			},

			signature = {
				enabled = true,
				trigger = {
					enabled = true,
				},
				window = {
					border = "rounded",
					show_documentation = false,
				},
			},

			sources = {
				default = {
					"lsp",
					"path",
					"snippets",
					"buffer",
				},

				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						-- Rank nvim/plugin API completions above plain lsp results.
						score_offset = 100,
					},
					lsp = {
						fallbacks = {},
						score_offset = 5,
					},
					buffer = {
						score_offset = -3,
					},
					snippets = {
						opts = {
							friendly_snippets = true,
							-- Local Kubernetes snippets replace friendly-snippets'
							-- Kubernetes set. Docker Compose snippets are isolated in
							-- their own provider below instead of leaking into every
							-- YAML buffer. friendly-snippets' Go set remains enabled.
							filter_snippets = function(_, file)
								return not is_friendly_snippet(file, "kubernetes%.json")
									and not is_friendly_snippet(file, "docker/docker%-compose%.json")
							end,
							search_paths = {
								vim.fn.stdpath("config") .. "/snippets",
							},
							use_label_description = true,
						},
					},
					docker_snippets = {
						name = "Docker Compose",
						module = "blink.cmp.sources.snippets",
						score_offset = -1,
						opts = {
							friendly_snippets = true,
							global_snippets = {},
							get_filetype = function()
								return "yaml"
							end,
							filter_snippets = function(_, file)
								return is_friendly_snippet(file, "docker/docker%-compose%.json")
							end,
							use_label_description = true,
						},
					},
				},

				per_filetype = {
					lua = {
						inherit_defaults = true,
						"lazydev",
					},

					yaml = {
						inherit_defaults = true,
					},

					helm = {
						inherit_defaults = true,
					},

					-- Blink splits dotted filetypes before applying this table, so
					-- these keys match yaml.helm-values and yaml.docker-compose.
					["helm-values"] = {
						inherit_defaults = true,
					},

					["docker-compose"] = {
						inherit_defaults = true,
						"docker_snippets",
					},
				},
			},

			cmdline = {
				enabled = true,

				keymap = {
					preset = "cmdline",

					["<Up>"] = { "select_prev", "fallback" },
					["<Down>"] = { "select_next", "fallback" },

					["<C-k>"] = { "select_prev", "fallback" },
					["<C-j>"] = { "select_next", "fallback" },

					["<Tab>"] = { "select_next", "fallback" },
					["<S-Tab>"] = { "select_prev", "fallback" },

					["<CR>"] = { "accept_and_enter", "fallback" },
					["<C-space>"] = { "show", "fallback" },
					["<C-e>"] = {
						function(cmp)
							if cmp.is_visible() then
								return cmp.cancel()
							end

							return cmp.show()
						end,
						"fallback",
					},
				},

				completion = {
					ghost_text = {
						enabled = true,
					},
					list = {
						selection = {
							preselect = false,
							auto_insert = false,
						},
					},
					menu = {
						auto_show = function()
							return vim.fn.getcmdtype() == ":"
						end,
					},
				},
			},
		},
		opts_extend = {
			"sources.default",
		},
	},
}
