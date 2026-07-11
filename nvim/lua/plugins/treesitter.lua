-- ~/.config/nvim/lua/plugins/treesitter.lua

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		opts = {
			install_dir = vim.fn.stdpath("data") .. "/site",
		},
		config = function(_, opts)
			local treesitter = require("nvim-treesitter")

			treesitter.setup(opts)

			local parsers = {
				"bash",
				"c",
				"css",
				"dockerfile",
				"go",
				"gomod",
				"gosum",
				"gowork",
				"helm",
				"html",
				"javascript",
				"json",
				"lua",
				"make",
				"markdown",
				"markdown_inline",
				"python",
				"query",
				"regex",
				"robot",
				"sql",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
			}

			if vim.fn.executable("tree-sitter") == 1 then
				treesitter.install(parsers)
			else
				vim.notify_once(
					"tree-sitter CLI missing; run `mise install` to enable parser installs",
					vim.log.levels.WARN
				)
			end

			vim.treesitter.language.register("json", "jsonc")
			vim.treesitter.language.register("robot", "resource")

			local filetypes = vim.list_extend(vim.deepcopy(parsers), { "jsonc", "resource" })
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
				pattern = filetypes,
				callback = function()
					pcall(vim.treesitter.start)
				end,
				desc = "Enable Treesitter highlighting",
			})
		end,
	},
}
