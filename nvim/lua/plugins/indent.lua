-- Static indent guides on every level. Plain line, no animation, no scope
-- highlighting — kept deliberately minimal. Colours come from catppuccin's
-- indent_blankline integration (enabled in colorscheme.lua).
return {
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			-- tab_char must be set explicitly: it otherwise defaults to the
			-- `listchars` tab (set to blank in options.lua), so tab-indented
			-- files (Lua, Go) would draw an invisible space instead of a line.
			indent = { char = "│", tab_char = "│" },
			-- ibl's own scope is treesitter-based: on a block's opening/closing
			-- line it snaps to the outer syntactic scope, not the block you're
			-- visually in. The active scope is handled by mini.indentscope
			-- (indentation-based) instead — see minis.lua.
			scope = { enabled = false },
		},
	},
}
