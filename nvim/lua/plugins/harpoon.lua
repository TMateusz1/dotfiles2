local keys = {
	{
		"<leader>aa",
		function()
			require("config.harpoon").add()
		end,
		desc = "Add Harpoon mark",
	},
	{
		"<leader>A",
		function()
			require("config.harpoon").inspect()
		end,
		desc = "Inspect Harpoon marks",
	},
	{
		"<leader>fa",
		function()
			require("config.harpoon").fzf()
		end,
		desc = "Find Harpoon marks",
	},
}

for index = 1, 5 do
	local slot = index

	keys[#keys + 1] = {
		("<leader>a%d"):format(slot),
		function()
			require("config.harpoon").select(slot)
		end,
		desc = ("Go to Harpoon mark %d"):format(slot),
	}
end

return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = keys,
		config = function()
			require("config.harpoon").setup()
		end,
	},
}
