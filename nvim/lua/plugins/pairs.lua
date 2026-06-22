return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {
			-- Keep pairing syntax-agnostic: delimiters behave the same in prose,
			-- comments, and source code. The plugin's built-in rules also include
			-- multi-character Markdown fences.
			check_ts = false,
			enable_moveright = true,
			map_bs = true,
			map_cr = true,
		},
	},
}
