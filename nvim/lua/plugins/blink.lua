local go_doc_request_id = 0

local function current_project_root()
	local file = vim.api.nvim_buf_get_name(0)

	if file ~= "" then
		local root = vim.fs.root(file, {
			"go.work",
			"go.mod",
			".git",
		})

		if root then
			return root
		end
	end

	return vim.uv.cwd()
end

local function go_doc_query(item)
	if vim.bo.filetype ~= "go" or vim.fn.executable("go") ~= 1 then
		return nil
	end

	if item.documentation ~= nil or type(item.detail) ~= "string" then
		return nil
	end

	local package = item.detail:match('%(from "([^"]+)"%)')
	local symbol = type(item.label) == "string" and item.label:match("^[_%a][_%w]*")

	if not package or not symbol then
		return nil
	end

	return package .. "." .. symbol
end

local function draw_completion_documentation(opts)
	go_doc_request_id = go_doc_request_id + 1
	local request_id = go_doc_request_id

	opts.default_implementation()

	local query = go_doc_query(opts.item)

	if not query then
		return
	end

	vim.system({
		"go",
		"doc",
		query,
	}, {
		cwd = current_project_root(),
		text = true,
	}, function(result)
		if result.code ~= 0 or not result.stdout or vim.trim(result.stdout) == "" then
			return
		end

		vim.schedule(function()
			if request_id ~= go_doc_request_id or not opts.window:is_open() then
				return
			end

			local bufnr = opts.window:get_buf()

			if not vim.api.nvim_buf_is_valid(bufnr) then
				return
			end

			local lines = vim.split(vim.trim(result.stdout), "\n", {
				plain = true,
			})
			local docs = require("blink.cmp.lib.window.docs")
			local highlight_ns = require("blink.cmp.config").appearance.highlight_ns

			vim.api.nvim_set_option_value("modifiable", true, {
				buf = bufnr,
			})
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
			vim.api.nvim_set_option_value("modifiable", false, {
				buf = bufnr,
			})
			vim.api.nvim_buf_clear_namespace(bufnr, highlight_ns, 0, -1)
			if opts.config.treesitter_highlighting then
				docs.highlight_with_treesitter(bufnr, "go", 0, #lines)
			end
			opts.window:update_size()
		end)
	end)
end

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

						local providers = vim.bo.filetype == "go" and { "go_struct_tags", "lsp" } or { "lsp" }

						return cmp.show({
							providers = providers,
						})
					end,
					"show_documentation",
					"hide_documentation",
				},
				["<C-e>"] = { "cancel", "fallback" },
				["<Esc>"] = {
					function()
						stop_active_vim_snippet()
						return false
					end,
					"fallback",
				},
				["<CR>"] = {
					function(cmp)
						if cmp.is_visible() then
							return cmp.accept()
						end

						stop_active_vim_snippet()
						return false
					end,
					"fallback",
				},

				-- Smart Tab: default to jumping snippet placeholders, but once
				-- the completion menu is actually being navigated (an item is
				-- highlighted) keep cycling it instead. Outside a snippet, Tab
				-- drives the menu. <CR> accepts; <C-j>/<C-k> also cycle.
				["<Tab>"] = {
					function(cmp)
						if cmp.is_menu_visible() and cmp.get_selected_item() then
							return cmp.select_next()
						end

						if cmp.snippet_active({ direction = 1 }) then
							return cmp.snippet_forward()
						end

						if cmp.is_menu_visible() then
							return cmp.select_next()
						end
					end,
					"fallback",
				},
				["<S-Tab>"] = {
					function(cmp)
						if cmp.is_menu_visible() and cmp.get_selected_item() then
							return cmp.select_prev()
						end

						if cmp.snippet_active({ direction = -1 }) then
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
					draw = draw_completion_documentation,
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
					go_struct_tags = {
						name = "Go tags",
						module = "config.blink_go_struct_tags",
						score_offset = 20,
					},
					lsp = {
						fallbacks = {},
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
					},

					go = {
						inherit_defaults = true,
						"go_struct_tags",
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
