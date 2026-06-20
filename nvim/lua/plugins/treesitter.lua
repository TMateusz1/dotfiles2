-- ~/.config/nvim/lua/plugins/treesitter.lua

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		opts = {
			install_dir = vim.fn.stdpath("data") .. "/site",
		},
		config = function(_, opts)
			require("nvim-treesitter").setup(opts)

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
				"rust",
				"sql",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
			}

			require("nvim-treesitter").install(parsers)
			vim.treesitter.language.register("json", "jsonc")

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
				pattern = {
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
					"jsonc",
					"lua",
					"make",
					"markdown",
					"python",
					"query",
					"rust",
					"sql",
					"tsx",
					"typescript",
					"vim",
					"vimdoc",
					"yaml",
				},
				callback = function()
					pcall(vim.treesitter.start)
				end,
				desc = "Enable Treesitter highlighting",
			})
		end,
	},
}
