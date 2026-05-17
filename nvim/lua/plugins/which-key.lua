-- ~/.config/nvim/lua/plugins/which-key.lua

return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "modern",

			delay = function(ctx)
				-- Show faster after leader, slower for other mappings
				return ctx.plugin and 0 or 300
			end,

			icons = {
				mappings = true,
				keys = {
					Space = "SPC",
					CR = "RET",
					Esc = "ESC",
				},
			},

			win = {
				border = "rounded",
				padding = { 1, 2 },
			},

			layout = {
				width = { min = 20 },
				spacing = 3,
			},

			spec = {
				-- Top-level leader groups
				{ "<leader>b", group = "Buffers" },
				{ "<leader>f", group = "Find" },
				{ "<leader>g", group = "Git" },
				{ "<leader>c", group = "Code" },
				{ "<leader>u", group = "UI / Toggles" },

				-- Direct leader mappings
				{ "<leader>e", desc = "Explorer" },
				{ "<leader>E", desc = "Oil Explorer" },
				{ "<leader>x", desc = "Delete buffer" },
				{ "<leader>w", desc = "Save file" },
				{ "<leader>q", desc = "Quit" },

				-- Buffers
				{ "[[", desc = "Previous buffer" },
				{ "]]", desc = "Next buffer" },
				{ "<leader>be", desc = "Buffers tree" },
				{ "<leader>bx", desc = "Delete buffer" },
				{ "<leader>bp", desc = "Pick buffer" },
				{ "<leader>bX", desc = "Delete other buffers" },
				{ "<leader>bL", desc = "Delete buffers to the right" },
				{ "<leader>bH", desc = "Delete buffers to the left" },

				-- Git
				{ "<leader>ge", desc = "Git status tree" },
				{ "<leader>gh", group = "Git Hunks" },

				{ "]h", desc = "Next git hunk" },
				{ "[h", desc = "Previous git hunk" },

				{ "<leader>ghp", desc = "Preview hunk" },
				{ "<leader>ghs", desc = "Stage hunk" },
				{ "<leader>ghr", desc = "Reset hunk" },
				{ "<leader>ghu", desc = "Undo stage hunk" },

				{ "<leader>ghb", desc = "Blame line" },
				{ "<leader>ghB", desc = "Full blame line" },
				{ "<leader>ghl", desc = "Toggle inline blame" },

				{ "<leader>ghd", desc = "Diff this file" },
				{ "<leader>ghD", desc = "Diff against previous commit" },

				{ "<leader>ght", desc = "Toggle deleted lines" },
				{ "<leader>ghw", desc = "Toggle word diff" },

				-- FZF
				{ "<leader>ff", desc = "Find files" },
				{ "<leader>fg", desc = "Live grep" },
				{ "<leader>fb", desc = "Find buffers" },
				{ "<leader>fr", desc = "Recent files" },
				{ "<leader>fc", desc = "Find config files" },
				{ "<leader>fw", desc = "Grep word under cursor" },
				{ "<leader>fW", desc = "Grep WORD under cursor" },
				{ "<leader>fh", desc = "Help tags" },
				{ "<leader>fk", desc = "Keymaps" },
				{ "<leader>f:", desc = "Commands" },

				-- LSP / Code
				{ "gd", desc = "Go to definition" },
				{ "gD", desc = "Go to declaration" },
				{ "gi", desc = "Go to implementation" },
				{ "gr", desc = "Go to references" },
				{ "K", desc = "Hover documentation" },
				{ "<leader>ca", desc = "Code action" },
				{ "<leader>cr", desc = "Rename symbol" },
				{ "<leader>cd", desc = "Line diagnostics" },
				{ "<leader>cq", desc = "Diagnostics quickfix" },
				{ "<leader>cl", desc = "Format file" },

				-- Diagnostics
				{ "]d", desc = "Next diagnostic" },
				{ "[d", desc = "Previous diagnostic" },

				-- UI / toggles
				{ "<leader>uh", desc = "Toggle inlay hints" },
			},
		},
	},
}
