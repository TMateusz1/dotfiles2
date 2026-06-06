-- Dim inactive splits so the focused window stands out (pairs with the
-- thick lavender window separators).
return {
	{
		"levouh/tint.nvim",
		event = "VeryLazy",
		opts = {
			tint = -45,
			saturation = 0.6,
			tint_background_colors = false,
			-- Keep these readable/bright even in inactive windows
			highlight_ignore_patterns = {
				"WinSeparator",
				"WinSeparatorNC",
				"Status.*",
			},
			-- Don't dim floating windows or special buffers (oil, quickfix, etc.)
			window_ignore_function = function(winid)
				if vim.api.nvim_win_get_config(winid).relative ~= "" then
					return true
				end

				local bufid = vim.api.nvim_win_get_buf(winid)
				return vim.bo[bufid].buftype ~= ""
			end,
		},
	},
}
