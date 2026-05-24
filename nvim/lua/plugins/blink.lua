return {
	{
		"saghen/blink.cmp",
		version = "1.*",
		event = "InsertEnter",
		dependencies = {
			"nvim-mini/mini.icons",
			"rafamadriz/friendly-snippets",
		},
		opts = {
			keymap = {
				preset = "default",

				["<C-space>"] = {
					function(cmp)
						pcall(function()
							require("config.kubernetes").attach_buffer_schema(0)
						end)

						return cmp.show({
							providers = { "lsp" },
						})
					end,
					"show_documentation",
					"hide_documentation",
				},
				["<C-e>"] = { "hide" },
				["<Esc>"] = {
					function(cmp)
						if cmp.is_visible() then
							cmp.hide()
							return true
						end

						if vim.snippet and vim.snippet.active() then
							pcall(vim.snippet.stop)
						end
					end,
					"fallback",
				},

				["<CR>"] = { "accept", "fallback" },

				["<Tab>"] = {
					"select_next",
					"snippet_forward",
					"fallback",
				},
				["<S-Tab>"] = {
					"select_prev",
					"snippet_backward",
					"fallback",
				},

				["<C-j>"] = { "select_next", "fallback" },
				["<C-k>"] = { "select_prev", "fallback" },

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
					},
				},

				documentation = {
					auto_show = true,
					auto_show_delay_ms = 300,
					window = {
						border = "rounded",
					},
				},

				ghost_text = {
					enabled = true,
				},

				menu = {
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
						preselect = false,
						auto_insert = false,
					},
				},
			},

			snippets = {
				preset = "default",
			},

			signature = {
				enabled = true,
				window = {
					border = "rounded",
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
					lsp = {
						fallbacks = {},
					},
					snippets = {
						opts = {
							friendly_snippets = true,
							filter_snippets = function(_, file)
								return not file:match("friendly%-snippets.*/snippets/kubernetes%.json$")
							end,
							search_paths = {
								vim.fn.stdpath("config") .. "/snippets",
							},
							use_label_description = true,
						},
					},
				},

				per_filetype = {
					lua = {
						inherit_defaults = true,
					},

					go = {
						inherit_defaults = true,
					},

					yaml = {
						inherit_defaults = true,
					},

					helm = {
						inherit_defaults = true,
					},

					["yaml.helm-values"] = {
						inherit_defaults = true,
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

					["<Tab>"] = { "show_and_insert_or_accept_single", "select_next", "fallback" },
					["<S-Tab>"] = { "show_and_insert_or_accept_single", "select_prev", "fallback" },

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
							preselect = true,
							auto_insert = true,
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
