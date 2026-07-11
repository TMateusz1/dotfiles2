local M = {}

local servers = {
	{ name = "gopls", executable = "gopls" },
	{ name = "lua_ls", executable = "lua-language-server" },
	{ name = "dockerls", executable = "docker-langserver" },
	{ name = "docker_compose_language_service", executable = "docker-compose-langserver" },
	{ name = "yamlls", executable = "yaml-language-server" },
	{ name = "helm_ls", executable = { "helm_ls", "helm-ls" } },
	{ name = "jsonls", executable = "vscode-json-language-server" },
	{ name = "bashls", executable = "bash-language-server" },
	{ name = "basedpyright", executable = "basedpyright-langserver" },
	{ name = "ruff", executable = "ruff" },
	{ name = "robotcode", executable = "robotcode" },
}

local function executable_label(executable)
	if type(executable) == "string" then
		return executable
	end

	return table.concat(executable, "/")
end

local function first_executable(executable)
	if type(executable) == "string" then
		return vim.fn.executable(executable) == 1 and executable or nil
	end

	for _, candidate in ipairs(executable) do
		if vim.fn.executable(candidate) == 1 then
			return candidate
		end
	end

	return nil
end

local function configure_servers()
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
				staticcheck = false,
				vulncheck = "Off",
				symbolStyle = "Package",
				semanticTokens = false,
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
					lostcancel = true,
					unreachable = true,
					shadow = false,
					unusedresult = false,
				},

				codelenses = {
					generate = true,
					test = true,
					tidy = true,
					gc_details = false,
					regenerate_cgo = false,
					upgrade_dependency = false,
					vendor = false,
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

	vim.lsp.config("basedpyright", {
		settings = {
			basedpyright = {
				analysis = {
					autoSearchPaths = true,
					diagnosticMode = "openFilesOnly",
				},
			},
		},
	})

	vim.lsp.config("ruff", {
		on_attach = function(client)
			-- basedpyright owns Python hover; Ruff stays focused on lint/code actions.
			client.server_capabilities.hoverProvider = false
		end,
	})

	vim.lsp.config("robotcode", {
		cmd = { "robotcode", "language-server" },
		filetypes = { "robot", "resource" },
		root_markers = { "robot.toml", "pyproject.toml", "Pipfile", ".git" },
		cmd_env = vim.env.VIRTUAL_ENV and {
			PYTHONPATH = vim.fn.glob(vim.env.VIRTUAL_ENV .. "/lib/python*/site-packages"):gsub("\n", ":"),
		} or nil,
		get_language_id = function()
			return "robotframework"
		end,
	})

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
				format = {
					enable = false,
				},
				maxItemsComputed = 10000,
				schemaStore = {
					enable = false,
					url = "",
				},
				schemas = kubernetes.yaml_schemas(),
			},
		},
	})

	vim.lsp.config("helm_ls", {
		cmd = { first_executable({ "helm_ls", "helm-ls" }) or "helm_ls", "serve" },
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
end

local function enable_servers()
	local missing = {}

	for _, server in ipairs(servers) do
		if first_executable(server.executable) then
			vim.lsp.enable(server.name)
		else
			table.insert(missing, executable_label(server.executable))
		end
	end

	if #missing > 0 then
		vim.notify_once(
			("Missing LSP tools: %s. Run `mise install`."):format(table.concat(missing, ", ")),
			vim.log.levels.WARN
		)
	end
end

local function configure_diagnostics()
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
end

local function configure_keymaps()
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
		callback = function(event)
			local bufnr = event.buf
			local client = vim.lsp.get_client_by_id(event.data.client_id)

			if client == nil then
				return
			end

			for _, lhs in ipairs({ "grn", "gra", "grx", "grr", "gri", "grt", "gO" }) do
				pcall(vim.keymap.del, "n", lhs)
			end

			local function map(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, {
					buffer = bufnr,
					desc = desc,
				})
			end

			if vim.bo[bufnr].filetype == "helm" or vim.bo[bufnr].filetype == "yaml.helm-values" then
				map("n", "gd", require("config.helm").smart_definition, "Helm value definition")
			else
				map("n", "gd", function()
					require("fzf-lua").lsp_definitions()
				end, "Go to definition")
			end
			map("n", "gD", function()
				require("fzf-lua").lsp_declarations()
			end, "Go to declaration")
			map("n", "gr", function()
				require("fzf-lua").lsp_references()
			end, "Go to references")
			map("n", "gi", function()
				require("fzf-lua").lsp_implementations()
			end, "Go to implementation")
			map("n", "gy", function()
				require("fzf-lua").lsp_typedefs()
			end, "Go to type definition")
			map("n", "K", vim.lsp.buf.hover, "Hover documentation")

			map("n", "<leader>cI", function()
				require("fzf-lua").lsp_incoming_calls()
			end, "Incoming calls")

			map({ "n", "v" }, "<leader>ca", function()
				require("fzf-lua").lsp_code_actions()
			end, "Code action")
			map("n", "<leader>cn", vim.lsp.buf.rename, "Rename symbol")

			map("n", "<leader>cx", function()
				vim.diagnostic.open_float(nil, {
					border = "rounded",
					focus = false,
					scope = "line",
					source = true,
				})
			end, "Line diagnostics")
			map("n", "<leader>cq", function()
				vim.diagnostic.setqflist({ open = false, title = "Diagnostics" })
				if vim.tbl_isempty(vim.fn.getqflist()) then
					pcall(vim.cmd, "cclose")
					vim.notify("No diagnostics", vim.log.levels.INFO, { title = "Diagnostics" })
					return
				end
				vim.cmd("copen")
			end, "Diagnostics quickfix")

			if client.name == "gopls" then
				require("config.go").attach(bufnr)
			end

			if client:supports_method("textDocument/inlayHint") then
				map("n", "<leader>uh", function()
					local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
					vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
				end, "Toggle inlay hints")
			end
		end,
	})
end

function M.setup()
	configure_servers()
	enable_servers()
	configure_diagnostics()
	configure_keymaps()
end

function M.restart_server(name)
	configure_servers()

	pcall(vim.lsp.enable, name, false)

	for _, client in ipairs(vim.lsp.get_clients({ name = name })) do
		client:stop(true)
	end

	vim.defer_fn(function()
		vim.lsp.enable(name, true)
	end, 200)
end

return M
