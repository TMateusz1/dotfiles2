local terminals = {}

local function term(id, opts)
	local key = ("%s:%s"):format(id, opts.dir or "")
	local terminal = terminals[key]

	if terminal then
		return terminal
	end

	local Terminal = require("toggleterm.terminal").Terminal

	terminal = Terminal:new(vim.tbl_extend("force", {
		hidden = true,
		on_open = function()
			vim.cmd("startinsert!")
		end,
	}, opts))

	terminals[key] = terminal
	return terminal
end

local function toggle_shell(direction)
	term("shell_" .. direction, {
		dir = require("config.files").project_root(),
		direction = direction,
		size = direction == "horizontal" and math.floor(vim.o.lines * 0.35) or nil,
		float_opts = {
			border = "rounded",
		},
	}):toggle()
end

local function toggle_lazygit()
	term("lazygit", {
		cmd = "lazygit",
		dir = require("config.files").project_root(),
		direction = "float",
		float_opts = {
			border = "rounded",
			width = math.floor(vim.o.columns * 0.92),
			height = math.floor(vim.o.lines * 0.88),
		},
	}):toggle()
end

return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		keys = {
			{
				"<leader>`",
				function()
					toggle_shell("horizontal")
				end,
				desc = "Toggle terminal",
			},
			{
				"<leader>Tf",
				function()
					toggle_shell("float")
				end,
				desc = "Toggle floating terminal",
			},
			{
				"<leader>gg",
				toggle_lazygit,
				desc = "LazyGit",
			},
		},
		opts = {
			direction = "horizontal",
			size = 18,
			shade_terminals = false,
			float_opts = {
				border = "rounded",
			},
		},
	},
}
