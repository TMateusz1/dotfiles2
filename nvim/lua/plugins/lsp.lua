-- ~/.config/nvim/lua/plugins/lsp.lua

return {
	{
		"b0o/schemastore.nvim",
		lazy = true,
	},

	{
		-- Lazily feeds lua_ls type definitions for the nvim API and only the
		-- plugins actually require()d, instead of the static workspace.library
		-- listing below. Faster lua_ls and real completions for plugin APIs.
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				{ path = "fzf-lua", words = { "FzfLua" } },
			},
		},
	},

	{
		"qvalentin/helm-ls.nvim",
		ft = {
			"helm",
			"yaml.helm-values",
		},
		opts = {
			conceal_templates = {
				enabled = true,
			},
			indent_hints = {
				enabled = true,
				only_for_current_line = true,
			},
			action_highlight = {
				enabled = true,
			},
		},
	},
	{
		"mason-org/mason.nvim",
		cmd = "Mason",
		opts = {
			ui = {
				border = "rounded",
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = {
			"mason-org/mason.nvim",
		},
		opts = {
			ensure_installed = {
				-- Go
				"goimports",
				"gofumpt",
				"golines",
				"delve",
				"gotestsum",
				"gomodifytags",
				"impl",
				"golangci-lint",

				-- Docker yaml helm shell
				"stylua",
				"shfmt",
				"shellcheck",
				"prettier",
				"yamlfmt",
				"yamllint",
				"hadolint",
			},
			auto_update = false,
			run_on_start = true,
			start_delay = 3000,
		},
	},

	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
			"saghen/blink.cmp",
		},
		config = function()
			-- ------------------------------------------------------------
			-- LSP server configs
			--
			-- Important:
			-- Define vim.lsp.config(...) BEFORE mason-lspconfig setup,
			-- because mason-lspconfig with automatic_enable=true will
			-- enable installed servers automatically.
			-- ------------------------------------------------------------

			local capabilities = require("blink.cmp").get_lsp_capabilities()
			local kubernetes = require("config.kubernetes")

			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			vim.lsp.config("gopls", {
				settings = {
					gopls = {
						gofumpt = true,
						usePlaceholders = false,
						completeUnimported = true,
						staticcheck = true,
						-- govulncheck diagnostics on go.mod requires whose
						-- vulnerable code is actually reachable from this module.
						vulncheck = "Imports",
						semanticTokens = true,
						experimentalPostfixCompletions = true,
						directoryFilters = {
							"-**/.git",
							"-**/.direnv",
							"-**/node_modules",
							"-**/tmp",
						},

						analyses = {
							unusedparams = true,
							unusedwrite = true,
							nilness = true,
							shadow = true,
							lostcancel = true,
							unusedresult = true,
							unreachable = true,
						},

						codelenses = {
							generate = true,
							gc_details = true,
							regenerate_cgo = true,
							test = true,
							tidy = true,
							upgrade_dependency = true,
							vendor = true,
						},

						hints = {
							assignVariableTypes = true,
							compositeLiteralFields = true,
							compositeLiteralTypes = true,
							constantValues = true,
							functionTypeParameters = true,
							parameterNames = true,
							rangeVariableTypes = true,
						},
					},
				},
			})

			-- Workspace libraries (nvim runtime, plugin types) are injected
			-- per-require by lazydev.nvim; no static library list needed.
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						runtime = {
							version = "LuaJIT",
						},

						workspace = {
							checkThirdParty = false,
						},

						telemetry = {
							enable = false,
						},

						hint = {
							enable = true,
							arrayIndex = "Disable",
							await = true,
							paramName = "All",
							paramType = true,
							semicolon = "Disable",
							setType = true,
						},

						completion = {
							callSnippet = "Replace",
						},
					},
				},
			})

			vim.lsp.config("dockerls", {})

			vim.lsp.config("docker_compose_language_service", {})

			vim.lsp.config("jsonls", {
				settings = {
					json = {
						schemas = require("schemastore").json.schemas(),
						validate = {
							enable = true,
						},
					},
				},
			})

			-- bash-language-server runs shellcheck itself when the binary is on
			-- PATH (Mason's bin dir is prepended by mason.nvim).
			vim.lsp.config("bashls", {})

			vim.lsp.config("yamlls", {
				filetypes = {
					"yaml",
					"yaml.docker-compose",
					"yaml.helm-values",
				},
				settings = {
					redhat = {
						telemetry = {
							enabled = false,
						},
					},
					yaml = {
						validate = true,
						completion = true,
						hover = true,
						-- Formatting is owned by conform (yamlfmt); keep yamlls out of it.
						format = {
							enable = false,
						},
						maxItemsComputed = 10000,
						kubernetesCRDStore = kubernetes.crd_store_settings(),

						schemaStore = {
							enable = false,
							url = "",
						},

						schemas = kubernetes.yaml_schemas(),
					},
				},
			})

			vim.lsp.config("helm_ls", {
				settings = {
					["helm-ls"] = {
						yamlls = {
							path = "yaml-language-server",
						},
						valuesFiles = {
							mainValuesFile = "values.yaml",
							lintOverlayValuesFile = "values.lint.yaml",
							additionalValuesFilesGlobPattern = "values*.yaml",
						},
					},
				},
			})

			-- ------------------------------------------------------------
			-- Mason LSP setup
			--
			-- automatic_enable=true:
			-- - installed servers are enabled automatically
			-- - if we defined vim.lsp.config("server", ...), that config
			--   is used/merged before the server starts
			-- ------------------------------------------------------------

			require("mason-lspconfig").setup({
				ensure_installed = {
					"gopls",
					"lua_ls",
					"dockerls",
					"docker_compose_language_service",
					"yamlls",
					"helm_ls",
					"jsonls",
					"bashls",
				},

				automatic_enable = true,
			})
		end,
	},

	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			-- ------------------------------------------------------------
			-- Diagnostics UI
			-- ------------------------------------------------------------

			vim.diagnostic.config({
				virtual_text = false,
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "",
						[vim.diagnostic.severity.WARN] = "",
						[vim.diagnostic.severity.INFO] = "",
						[vim.diagnostic.severity.HINT] = "󰌵",
					},
				},
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				float = {
					border = "rounded",
					source = true,
				},
			})

			-- ------------------------------------------------------------
			-- LSP keymaps
			-- ------------------------------------------------------------

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
				callback = function(event)
					local bufnr = event.buf
					local client = vim.lsp.get_client_by_id(event.data.client_id)

					if client == nil then
						return
					end

					-- Remove Neovim 0.12 default LSP maps that shadow our snappy `gr`.
					-- `gr` is a prefix of grr/gri/grn/gra/grt/grx, so without this it
					-- waits timeoutlen before firing. These are global; deleting once
					-- is enough and pcall guards repeated LspAttach events.
					for _, lhs in ipairs({ "grn", "gra", "grx", "grr", "gri", "grt", "gO" }) do
						pcall(vim.keymap.del, "n", lhs)
					end

					local function map(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, {
							buffer = bufnr,
							desc = desc,
						})
					end

					local function fzf_lsp()
						return require("fzf-lua")
					end

					-- Quick navigation (bare keys — fast access)
					map("n", "gd", function()
						fzf_lsp().lsp_definitions()
					end, "Go to definition")
					map("n", "gD", function()
						fzf_lsp().lsp_declarations()
					end, "Go to declaration")
					map("n", "gr", function()
						fzf_lsp().lsp_references()
					end, "Go to references")
					map("n", "gi", function()
						fzf_lsp().lsp_implementations()
					end, "Go to implementation")
					map("n", "gy", function()
						fzf_lsp().lsp_typedefs()
					end, "Go to type definition")
					map("n", "K", vim.lsp.buf.hover, "Hover documentation")

					-- Navigation (discoverable via <leader>c)
					map("n", "<leader>cd", function()
						fzf_lsp().lsp_definitions()
					end, "Go to definition")
					map("n", "<leader>cD", function()
						fzf_lsp().lsp_declarations()
					end, "Go to declaration")
					map("n", "<leader>cy", function()
						fzf_lsp().lsp_typedefs()
					end, "Go to type definition")
					map("n", "<leader>cu", function()
						fzf_lsp().lsp_references({ includeDeclaration = false })
					end, "Find usages")

					-- Browse / search
					map("n", "<leader>fS", function()
						fzf_lsp().lsp_live_workspace_symbols()
					end, "Workspace symbols")
					map("n", "<leader>cF", function()
						fzf_lsp().lsp_finder()
					end, "LSP finder (all)")
					map("n", "<leader>cI", function()
						fzf_lsp().lsp_incoming_calls()
					end, "Incoming calls")
					map("n", "<leader>cO", function()
						fzf_lsp().lsp_outgoing_calls()
					end, "Outgoing calls")

					-- Actions
					map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
					map("n", "<leader>cr", function()
						fzf_lsp().lsp_references()
					end, "References")
					map("n", "<leader>cn", vim.lsp.buf.rename, "Rename symbol")
					map("n", "<leader>co", function()
						require("config.go").organize_imports(bufnr)
					end, "Organize imports")
					map("n", "<leader>cf", function()
						require("config.go").fix_all(bufnr)
					end, "Fix all")

					if client:supports_method("textDocument/codeLens") then
						map("n", "<leader>cc", vim.lsp.codelens.run, "Run code lens")
						map("n", "<leader>cC", function()
							pcall(vim.lsp.codelens.enable, true, { bufnr = bufnr })
						end, "Refresh code lens")
					end

					-- Diagnostics
					map("n", "<leader>cx", vim.diagnostic.open_float, "Line diagnostics")
					map("n", "<leader>cq", function()
						-- Populate without auto-opening. With no diagnostics, close any
						-- stale list instead of showing an empty one; otherwise render
						-- the quickfix list in Trouble (matching <leader>xq).
						vim.diagnostic.setqflist({ open = false, title = "Diagnostics" })
						if vim.tbl_isempty(vim.fn.getqflist()) then
							pcall(vim.cmd, "Trouble qflist close")
							vim.notify("No diagnostics", vim.log.levels.INFO, { title = "Diagnostics" })
							return
						end
						vim.cmd("Trouble qflist open")
					end, "Diagnostics quickfix")
					-- ]d / [d / <leader>uv are global (config/keymaps.lua) so they also
					-- work with nvim-lint diagnostics in buffers without an LSP client.

					-- LSP management
					map("n", "<leader>cL", "<cmd>LspInfo<CR>", "LSP info")
					map("n", "<leader>cR", "<cmd>LspRestart<CR>", "Restart LSP")

					-- Go tools (gopls)
					if client.name == "gopls" then
						map("n", "<leader>cgm", function()
							require("config.go").mod_tidy(bufnr)
						end, "Go mod tidy")
						map("n", "<leader>cgg", function()
							require("config.go").generate(bufnr)
						end, "Go generate")
						map("n", "<leader>cgl", function()
							require("config.go").lint(bufnr)
						end, "Go lint")
						map("n", "<leader>cgd", function()
							require("config.go").doc(bufnr)
						end, "Go doc")

						-- Code generation (gomodifytags / impl)
						map("n", "<leader>cgj", function()
							require("config.go").add_json_tags(bufnr)
						end, "Add json tags")
						map("n", "<leader>cgJ", function()
							require("config.go").remove_json_tags(bufnr)
						end, "Remove json tags")
						map("n", "<leader>cgy", function()
							require("config.go").add_yaml_tags(bufnr)
						end, "Add yaml tags")
						map("n", "<leader>cgY", function()
							require("config.go").remove_yaml_tags(bufnr)
						end, "Remove yaml tags")
						map("n", "<leader>cge", function()
							require("config.go").add_env_tags(bufnr)
						end, "Add env tags")
						map("n", "<leader>cgE", function()
							require("config.go").remove_env_tags(bufnr)
						end, "Remove env tags")
						map("n", "<leader>ci", function()
							require("config.go").implement_interface(bufnr)
						end, "Implement interface")
					end

					-- Inlay hints
					if client:supports_method("textDocument/inlayHint") then
						map("n", "<leader>uh", function()
							local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
							vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
						end, "Toggle inlay hints")
					end
				end,
			})
		end,
	},
}
