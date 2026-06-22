return {
	{
		"nvim-mini/mini.map",
		version = false,
		keys = {
			{
				"<leader>um",
				function()
					require("mini.map").toggle()
				end,
				desc = "Toggle minimap",
			},
		},
		opts = {
			-- The map opens only through <leader>um. Keep it compact and out of
			-- the editing area while its scrollbar marks the cursor and viewport.
			window = {
				focusable = false,
				side = "right",
				width = 8,
				winblend = 15,
			},
		},
	},
}
