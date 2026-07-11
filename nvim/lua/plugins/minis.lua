return {
	{
		"nvim-mini/mini.ai",
		version = false,
		event = "VeryLazy",
		dependencies = {
			-- Ships the textobjects.scm queries the treesitter specs below
			-- read, plus the ]f / [f function motions.
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
				branch = "main",
				keys = {
					{
						"]f",
						function()
							require("nvim-treesitter-textobjects.move").goto_next_start(
								"@function.outer",
								"textobjects"
							)
						end,
						mode = { "n", "x", "o" },
						desc = "Next function start",
					},
					{
						"[f",
						function()
							require("nvim-treesitter-textobjects.move").goto_previous_start(
								"@function.outer",
								"textobjects"
							)
						end,
						mode = { "n", "x", "o" },
						desc = "Previous function start",
					},
				},
				opts = {
					move = {
						-- Record motions in the jumplist so <C-o> goes back.
						set_jumps = true,
					},
				},
			},
		},
		opts = function()
			local ai = require("mini.ai")

			return {
				n_lines = 500,
				custom_textobjects = {
					-- f: function/method definition (default f = call moves to F)
					f = ai.gen_spec.treesitter({
						a = "@function.outer",
						i = "@function.inner",
					}),
					F = ai.gen_spec.function_call(),
					-- o: surrounding block / conditional / loop
					o = ai.gen_spec.treesitter({
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}),
					-- c: type declaration (struct/interface in Go, class elsewhere)
					c = ai.gen_spec.treesitter({
						a = "@class.outer",
						i = "@class.inner",
					}),
				},
			}
		end,
	},
	{
		"nvim-mini/mini.surround",
		version = false,
		event = "VeryLazy",
		opts = {
			mappings = {
				add = "sa",
				delete = "sd",
				find = "sf",
				find_left = "sF",
				highlight = "sh",
				replace = "sr",
				update_n_lines = "sn",
			},
		},
	},
}
