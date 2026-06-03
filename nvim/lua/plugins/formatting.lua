return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>cl",
				function()
					require("conform").format({
						async = true,
						lsp_format = "fallback",
					})
				end,
				mode = { "n", "v" },
				desc = "Format file",
			},
		},
		opts = {
			formatters_by_ft = {
				go = { "goimports", "gofumpt", "golines" },
				lua = { "stylua" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				yaml = { "yamlfmt" },
				yml = { "yamlfmt" },
				["yaml.docker-compose"] = { "yamlfmt" },
				["yaml.helm-values"] = { "yamlfmt" },
				json = { "prettier" },
				jsonc = { "prettier" },
				markdown = { "prettier" },
			},

			format_on_save = {
				timeout_ms = 1000,
				lsp_format = "fallback",
			},

			notify_on_error = true,
			notify_no_formatters = false,

			formatters = {
				golines = {
					prepend_args = {
						"--max-len=120",
					},
				},
			},
		},
	},
}
