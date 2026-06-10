-- Sticky context: keeps the enclosing function/type signature pinned at the
-- top of the window while scrolling through long bodies. On trial — toggle
-- with <leader>uC; delete this file to drop the experiment.
return {
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			enable = true,
			-- Never eat more than a few lines of the viewport.
			max_lines = 3,
			-- Show only the first line of each context node (no full signatures
			-- spanning multiple lines).
			multiline_threshold = 1,
			trim_scope = "outer",
			mode = "cursor",
		},
		config = function(_, opts)
			require("treesitter-context").setup(opts)

			Snacks.toggle({
				name = "Sticky Context",
				get = function()
					return require("treesitter-context").enabled()
				end,
				set = function(state)
					if state then
						require("treesitter-context").enable()
					else
						require("treesitter-context").disable()
					end
				end,
			}):map("<leader>uC")
		end,
	},
}
