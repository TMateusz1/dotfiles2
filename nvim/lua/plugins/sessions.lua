-- Git toplevel of the current working directory, falling back to the cwd when
-- not inside a git repo.
local function project_root()
	local cwd = vim.fn.getcwd()
	local out = vim.fn.systemlist({ "git", "-C", cwd, "rev-parse", "--show-toplevel" })

	if vim.v.shell_error == 0 and out[1] and out[1] ~= "" then
		return out[1]
	end

	return cwd
end

-- Pick a saved session via vim.ui.select and delete its file.
local function session_delete()
	local persistence = require("persistence")
	local dir = require("persistence.config").options.dir

	local items = {}
	for _, session in ipairs(persistence.list()) do
		-- Decode the session filename back to its project directory, mirroring
		-- persistence's own decoding (handles legacy "%%branch" suffixes too).
		local raw = session:sub(#dir + 1, -5)
		local proj = vim.split(raw, "%%", { plain = true })[1]:gsub("%%", "/")

		items[#items + 1] = {
			file = session,
			label = vim.fn.fnamemodify(proj, ":p:~"),
		}
	end

	if vim.tbl_isempty(items) then
		vim.notify("No saved sessions", vim.log.levels.INFO, { title = "Sessions" })
		return
	end

	vim.ui.select(items, {
		prompt = "Delete session: ",
		format_item = function(item)
			return item.label
		end,
	}, function(item)
		if item then
			vim.fn.delete(item.file)
			vim.notify("Deleted session: " .. item.label, vim.log.levels.INFO, {
				title = "Sessions",
			})
		end
	end)
end

return {
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		-- One session per project (keyed by git root, see config) and not split
		-- per branch.
		opts = {
			branch = false,
		},
		config = function(_, opts)
			local persistence = require("persistence")
			persistence.setup(opts)

			-- Pin sessions to the git root instead of the launch cwd, so opening
			-- nvim from any subdirectory of a project restores the same session
			-- (falls back to cwd outside a git repo). The name encoding matches
			-- upstream so require("persistence").select() still decodes paths.
			local config = require("persistence.config")
			persistence.current = function()
				local name = project_root():gsub("[\\/:]+", "%%")
				return config.options.dir .. name .. ".vim"
			end
		end,
		keys = {
			{
				"<leader>ss",
				function()
					require("persistence").select()
				end,
				desc = "Select session",
			},
			{
				"<leader>sc",
				function()
					require("persistence").load()
				end,
				desc = "Restore session (project root)",
			},
			{
				"<leader>sl",
				function()
					require("persistence").load({ last = true })
				end,
				desc = "Restore last session",
			},
			{
				"<leader>sd",
				function()
					session_delete()
				end,
				desc = "Delete session",
			},
			{
				"<leader>sx",
				function()
					require("persistence").stop()
				end,
				desc = "Don't save session",
			},
		},
	},
}
