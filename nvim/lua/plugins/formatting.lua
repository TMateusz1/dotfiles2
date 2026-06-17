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
			{
				"<leader>uf",
				function()
					vim.g.disable_autoformat = not vim.g.disable_autoformat
					vim.notify(
						"Format on save " .. (vim.g.disable_autoformat and "disabled" or "enabled"),
						vim.log.levels.INFO,
						{ title = "conform" }
					)
				end,
				desc = "Toggle format on save",
			},
		},
		config = function(_, opts)
			require("conform").setup(opts)

			-- :FormatDisable           disable autoformat-on-save globally
			-- :FormatDisable!          disable it for the current buffer only
			vim.api.nvim_create_user_command("FormatDisable", function(args)
				if args.bang then
					vim.b.disable_autoformat = true
				else
					vim.g.disable_autoformat = true
				end
			end, { desc = "Disable autoformat-on-save", bang = true })

			vim.api.nvim_create_user_command("FormatEnable", function()
				vim.b.disable_autoformat = false
				vim.g.disable_autoformat = false
			end, { desc = "Re-enable autoformat-on-save" })
		end,
		opts = {
			formatters_by_ft = {
				go = { "goimports", "gofumpt" },
				lua = { "stylua" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				yaml = { "yamlfmt" },
				["yaml.docker-compose"] = { "yamlfmt" },
				["yaml.helm-values"] = { "yamlfmt" },
				json = { "prettier" },
				jsonc = { "prettier" },
				markdown = { "prettier" },
			},

			format_on_save = function(bufnr)
				-- Respect the <leader>uf toggle / :FormatDisable command.
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end

				return {
					timeout_ms = 1000,
					lsp_format = "fallback",
				}
			end,

			notify_on_error = true,
			notify_no_formatters = false,

		},
	},
}
