local languages = require("config.languages")

local formatters_by_ft = {
	go = { "goimports", "gofumpt" },
	lua = { "stylua" },
	python = { "ruff_format" },
	sh = { "shfmt" },
	bash = { "shfmt" },
	helm = { "helm_template_spacing" },
	json = { "prettier" },
	jsonc = { "prettier" },
	markdown = { "prettier" },
}

for _, filetype in ipairs(languages.robot) do
	formatters_by_ft[filetype] = { "robocop_format" }
end

for _, filetype in ipairs(languages.yaml) do
	formatters_by_ft[filetype] = { "yamlfmt" }
end

return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo", "FormatDisable", "FormatEnable" },
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
			formatters = {
				helm_template_spacing = {
					-- Keep Helm formatting dependency-free and preserve template comments.
					format = function(_, _, lines, callback)
						local text = table.concat(lines, "\n")
						local formatted = text:gsub("{{(%-?)(.-)(%-?)}}", function(left, body, right)
							local trimmed = vim.trim(body)

							if trimmed:match("^/%*") then
								return "{{" .. left .. body .. right .. "}}"
							end

							return "{{" .. left .. " " .. trimmed .. " " .. right .. "}}"
						end)

						callback(nil, vim.split(formatted, "\n", { plain = true }))
					end,
				},

				shfmt = {
					prepend_args = function(_, ctx)
						local file = vim.api.nvim_buf_get_name(ctx.buf)
						local start = file ~= "" and vim.fs.dirname(file) or vim.uv.cwd()
						local editorconfig = vim.fs.find(".editorconfig", {
							path = start,
							upward = true,
							limit = 1,
						})[1]

						if editorconfig then
							return { "-ci" }
						end

						return { "-i", "4", "-ci" }
					end,
				},

				-- Keep intentional whitespace between logical YAML sections, such as
				-- Taskfile tasks and test-plan cases.
				yamlfmt = {
					prepend_args = { "-formatter", "retain_line_breaks=true" },
				},

				robocop_format = {
					command = "robocop",
					args = { "format", "$FILENAME" },
					stdin = false,
				},
			},
			formatters_by_ft = formatters_by_ft,

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
