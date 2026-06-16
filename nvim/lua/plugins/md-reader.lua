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
}
