return {
	{
		"stevearc/aerial.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			-- icons come from mini.icons via its nvim-web-devicons mock
			-- (see plugins/minis.lua).
			"nvim-mini/mini.icons",
		},
		cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
		keys = {
			{
				"<leader>F",
				"<cmd>AerialToggle!<cr>",
				desc = "Code outline (aerial)",
			},
		},
		opts = {
			-- Prefer treesitter, fall back to LSP / markdown headings / man.
			backends = { "treesitter", "lsp", "markdown", "man" },

			layout = {
				default_direction = "right",
				placement = "edge",
				min_width = 30,
				max_width = { 40, 0.25 },
				win_opts = {
					winhl = "Normal:NormalFloat,FloatBorder:FloatBorder",
					signcolumn = "no",
					statuscolumn = "",
					number = false,
					relativenumber = false,
				},
			},

			-- Keep the outline in sync with whatever window is focused.
			attach_mode = "global",
			-- Auto-close once you jump to a symbol.
			close_on_select = true,

			show_guides = true,
			guides = {
				mid_item = "├╴",
				last_item = "└╴",
				nested_top = "│ ",
				whitespace = "  ",
			},

			-- VSCode-style codicons per symbol kind (the mini.icons mock only
			-- covers files/devicons, not LSP symbol kinds). Colored by the
			-- catppuccin `aerial` integration.
			icons = {
				Array = "󰅪 ",
				Boolean = " ",
				Class = "󰠱 ",
				Constant = "󰏿 ",
				Constructor = " ",
				Enum = " ",
				EnumMember = " ",
				Event = " ",
				Field = "󰜢 ",
				File = "󰈙 ",
				Function = "󰊕 ",
				Interface = " ",
				Key = "󰌋 ",
				Method = "󰆧 ",
				Module = " ",
				Namespace = "󰦮 ",
				Null = "󰟢 ",
				Number = "󰎠 ",
				Object = " ",
				Operator = "󰪚 ",
				Package = " ",
				Property = "󰜢 ",
				String = "󰉿 ",
				Struct = "󰙅 ",
				TypeParameter = " ",
				Variable = "󰀫 ",
				Collapsed = " ",
			},

			-- Show every symbol kind (no filtering).
			filter_kind = false,

			-- Highlight the symbol under the cursor and the matching tree row.
			highlight_on_hover = true,
			autojump = true,

			keymaps = {
				["<CR>"] = "actions.jump",
				["l"] = "actions.tree_open",
				["h"] = "actions.tree_close",
				["o"] = "actions.tree_toggle",
				["{"] = "actions.prev",
				["}"] = "actions.next",
				["q"] = "actions.close",
				["<Esc>"] = "actions.close",
			},
		},
	},
}
