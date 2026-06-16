-- mini.statusline. Colours come from catppuccin's `mini` integration
-- (the MiniStatusline* highlight groups), so no explicit theme table is
-- needed the way lualine required one.

local function macro_recording()
	local register = vim.fn.reg_recording()

	if register == "" then
		return ""
	end

	return "󰑊 @" .. register
end

-- Names of the LSP servers attached to the current buffer (e.g. "gopls,
-- lua_ls"). mini's own section_lsp only shows a generic attached/not icon.
local function lsp_servers()
	local clients = vim.lsp.get_clients({ bufnr = 0 })

	if #clients == 0 then
		return ""
	end

	local names = {}

	for _, client in ipairs(clients) do
		names[#names + 1] = client.name
	end

	table.sort(names)
	return "  " .. table.concat(names, ", ")
end

-- Filetype with its mini.icons glyph, in place of mini's verbose
-- section_fileinfo (which also tacks on encoding, format and file size).
local function filetype()
	local ft = vim.bo.filetype

	if ft == "" then
		return ""
	end

	local ok, icons = pcall(require, "mini.icons")
	local icon = ok and (icons.get("filetype", ft) .. " ") or ""

	return icon .. ft
end

return {
	{
		"nvim-mini/mini.statusline",
		version = false,
		dependencies = {
			"nvim-mini/mini.icons",
		},
		event = "VeryLazy",
		opts = function()
			local statusline = require("mini.statusline")

			return {
				use_icons = true,
				-- options.lua already sets laststatus=3 (global) + showmode=false;
				-- don't let mini reset laststatus back to 2.
				set_vim_settings = false,
				content = {
					active = function()
						-- trunc_width=999 keeps the mode abbreviated (N/I/V) at any
						-- realistic window width instead of spelling it out.
						local mode, mode_hl = statusline.section_mode({ trunc_width = 999 })
						local git = statusline.section_git({ trunc_width = 40 })
						local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
						local search = statusline.section_searchcount({ trunc_width = 75 })

						return statusline.combine_groups({
							{ hl = mode_hl, strings = { mode } },
							{ hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
							"%<", -- Truncate from here when the window is narrow
							-- %t = file name only (no path); %m modified, %r readonly.
							{ hl = "MiniStatuslineFilename", strings = { "%t%m%r" } },
							"%=", -- Right-align everything after this
							{ hl = "MiniStatuslineFileinfo", strings = { lsp_servers(), filetype() } },
							{ hl = mode_hl, strings = { macro_recording(), search, "%l:%v" } },
						})
					end,
				},
			}
		end,
		config = function(_, opts)
			require("mini.statusline").setup(opts)

			-- The statusline doesn't redraw when recording starts/stops, so the
			-- macro indicator would lag until the next cursor move.
			vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
				group = vim.api.nvim_create_augroup("user_statusline_macro", { clear = true }),
				callback = function()
					-- Scheduled: during RecordingLeave reg_recording() still returns
					-- the register, so an immediate redraw would keep the indicator.
					vim.schedule(function()
						vim.cmd("redrawstatus")
					end)
				end,
				desc = "Refresh statusline for the macro indicator",
			})
		end,
	},
}
