-- ~/.config/nvim/lua/plugins/lsp.lua

return {
	{
		"b0o/schemastore.nvim",
		lazy = true,
	},

	{
		"qvalentin/helm-ls.nvim",
		ft = "helm",
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
				"delve",
				"staticcheck",

				-- Docker yaml helm
				"stylua",
				"shfmt",
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

			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			vim.lsp.config("gopls", {
				settings = {
					gopls = {
						gofumpt = true,
						usePlaceholders = true,
						completeUnimported = true,
						staticcheck = true,
						semanticTokens = true,

						analyses = {
							unusedparams = true,
							unusedwrite = true,
							nilness = true,
							shadow = true,
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

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						runtime = {
							version = "LuaJIT",
						},

						diagnostics = {
							globals = {
								"vim",
							},
						},

						workspace = {
							checkThirdParty = false,
							library = {
								vim.env.VIMRUNTIME,
								vim.fn.stdpath("config"),
								"${3rd}/luv/library",
							},
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

			vim.lsp.config("yamlls", {
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

						schemaStore = {
							enable = false,
							url = "",
						},

						schemas = require("schemastore").yaml.schemas({
							extra = {
								{
									name = "Kubernetes",
									description = "Kubernetes resources",
									fileMatch = {
										"k8s/**/*.yaml",
										"k8s/**/*.yml",
										"kubernetes/**/*.yaml",
										"kubernetes/**/*.yml",
										"manifests/**/*.yaml",
										"manifests/**/*.yml",
										"deploy/**/*.yaml",
										"deploy/**/*.yml",
										"*.k8s.yaml",
										"*.k8s.yml",
									},
									url = "kubernetes",
								},
							},
						}),
					},
				},
			})

			vim.lsp.config("helm_ls", {
				settings = {
					["helm-ls"] = {
						yamlls = {
							path = "yaml-language-server",
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

					local function map(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, {
							buffer = bufnr,
							desc = desc,
						})
					end

					-- Navigation
					map("n", "gd", vim.lsp.buf.definition, "Go to definition")
					map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")

					map("n", "gr", function()
						require("fzf-lua").lsp_references()
					end, "Go to references")

					map("n", "gi", function()
						require("fzf-lua").lsp_implementations()
					end, "Go to implementation")
					map("n", "K", vim.lsp.buf.hover, "Hover documentation")

					-- Code actions
					map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
					map("n", "<leader>cr", vim.lsp.buf.rename, "Rename symbol")

					map("n", "<leader>cs", function()
						require("fzf-lua").lsp_document_symbols()
					end, "Document symbols")

					map("n", "<leader>cS", function()
						require("fzf-lua").lsp_workspace_symbols()
					end, "Workspace symbols")

					-- Diagnostics
					map("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
					map("n", "<leader>cq", vim.diagnostic.setqflist, "Diagnostics quickfix")

					map("n", "]d", function()
						vim.diagnostic.jump({ count = 1, float = true })
					end, "Next diagnostic")

					map("n", "[d", function()
						vim.diagnostic.jump({ count = -1, float = true })
					end, "Previous diagnostic")

					-- Inlay hints
					if client:supports_method("textDocument/inlayHint") then
						vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

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
