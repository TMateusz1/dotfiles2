return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-mini/mini.icons",
		},
		opts = {
			file_types = { "markdown" },
			render_modes = { "n", "c", "t" },
			completions = {
				lsp = {
					enabled = true,
				},
			},
		},
		keys = {
			{
				"<leader>Md",
				"<cmd>RenderMarkdown toggle<cr>",
				desc = "Markdown: toggle rendered view",
			},
			{
				"<leader>MD",
				"<cmd>RenderMarkdown preview<cr>",
				desc = "Markdown: preview in side window",
			},
		},
	},

	{
		"iamcco/markdown-preview.nvim",
		cmd = {
			"MarkdownPreviewToggle",
			"MarkdownPreview",
			"MarkdownPreviewStop",
		},
		ft = { "markdown" },
		build = function()
			require("lazy").load({ plugins = { "markdown-preview.nvim" } })
			vim.fn["mkdp#util#install"]()
		end,
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
			vim.g.mkdp_auto_start = 0
			vim.g.mkdp_auto_close = 0
			vim.g.mkdp_refresh_slow = 0
		end,
		keys = {
			{
				"<leader>Me",
				"<cmd>MarkdownPreviewToggle<cr>",
				ft = "markdown",
				desc = "Markdown: browser preview",
			},
		},
	},
}
