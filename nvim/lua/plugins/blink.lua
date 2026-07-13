local function stop_active_vim_snippet()
	if not (vim.snippet and vim.snippet.active and vim.snippet.stop) then
		return
	end

	if vim.snippet.active() then
		pcall(vim.snippet.stop)
	end
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
			-- mini.files buffers are for typing file/dir names, not prose, and
			-- prompt buffers (snacks input, etc.) are single-line inputs; buffer-word
			-- completion in either is just noise.
			enabled = function()
				return vim.bo.filetype ~= "minifiles" and vim.bo.buftype ~= "prompt"
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

				-- Snippet placeholders own Tab. Enter accepts completion items.
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
				["<C-k>"] = { "select_prev", "fallback" },
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
					enabled = false,
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
							-- Only Kubernetes is filtered (local snippets take
							-- precedence there). friendly-snippets' Go set stays:
							-- it provides the general-purpose snippets (tys, for,
							-- forr, meth, ...) while local go.json adds the
							-- specialized ones with non-colliding prefixes.
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
						"lazydev",
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
