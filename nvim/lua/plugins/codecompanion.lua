-- ~/.config/nvim/lua/plugins/codecompanion.lua

return {
	{
		"olimorris/codecompanion.nvim",
		cmd = {
			"CodeCompanion",
			"CodeCompanionActions",
			"CodeCompanionChat",
			"CodeCompanionCLI",
			"CodeCompanionCmd",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			adapters = {
				acp = {
					codex = function()
						return require("codecompanion.adapters").extend("codex", {
							commands = {
								default = {
									"npx",
									"-y",
									"@zed-industries/codex-acp",
								},
							},
							defaults = {
								auth_method = "chatgpt",
								timeout = 60000,
							},
						})
					end,
				},
			},
			interactions = {
				chat = {
					adapter = "codex",
				},
				cli = {
					agent = "codex",
					agents = {
						codex = {
							cmd = "codex",
							args = {},
							description = "OpenAI Codex CLI",
							provider = "terminal",
						},
					},
				},
			},
			display = {
				action_palette = {
					provider = "snacks",
				},
				chat = {
					window = {
						layout = "vertical",
						width = 0.4,
					},
				},
			},
		},
		keys = {
			{
				"<leader>aa",
				"<cmd>CodeCompanionActions<cr>",
				mode = { "n", "v" },
				desc = "AI actions",
			},
			{
				"<leader>ac",
				"<cmd>CodeCompanionChat Toggle<cr>",
				desc = "AI Codex chat",
			},
			{
				"<leader>ad",
				"<cmd>CodeCompanionChat Add<cr>",
				mode = "v",
				desc = "AI add selection to chat",
			},
			{
				"<leader>an",
				"<cmd>CodeCompanionChat<cr>",
				desc = "AI new Codex chat",
			},
			{
				"<leader>at",
				"<cmd>CodeCompanionCLI<cr>",
				desc = "AI Codex terminal",
			},
		},
	},
}
