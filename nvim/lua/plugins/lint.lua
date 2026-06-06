return {
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		config = function()
			local lint = require("lint")

			-- helm templates are filetype "helm" (not "yaml"), so yamllint never
			-- runs on `{{ }}` files. Plain manifests and values files still get it.
			lint.linters_by_ft = {
				yaml = { "yamllint" },
				["yaml.docker-compose"] = { "yamllint" },
				["yaml.helm-values"] = { "yamllint" },
				dockerfile = { "hadolint" },
			}

			-- "relaxed" drops the noisy warnings (line length, comment spacing,
			-- document-start) that fire constantly on Kubernetes manifests, while
			-- keeping real errors like duplicate keys and bad indentation.
			lint.linters.yamllint.args = {
				"-d",
				"relaxed",
				"-f",
				"parsable",
				"-",
			}

			local function try_lint()
				if vim.bo.buftype ~= "" then
					return
				end

				if lint.linters_by_ft[vim.bo.filetype] then
					lint.try_lint()
				end
			end

			vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
				group = vim.api.nvim_create_augroup("user_nvim_lint", { clear = true }),
				callback = try_lint,
				desc = "Run nvim-lint linters",
			})

			try_lint()
		end,
	},
}
