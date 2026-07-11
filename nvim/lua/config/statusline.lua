local M = {}

local modes = {
	n = "N",
	no = "O",
	nov = "O",
	noV = "O",
	["no\22"] = "O",
	niI = "N",
	niR = "N",
	niV = "N",
	nt = "N",
	v = "V",
	vs = "V",
	V = "V-L",
	Vs = "V-L",
	["\22"] = "V-B",
	["\22s"] = "V-B",
	s = "S",
	S = "S-L",
	["\19"] = "S-B",
	i = "I",
	ic = "I",
	ix = "I",
	R = "R",
	Rc = "R",
	Rx = "R",
	Rv = "V-R",
	Rvc = "V-R",
	Rvx = "V-R",
	c = "C",
	cv = "EX",
	ce = "EX",
	r = "P",
	rm = "M",
	["r?"] = "?",
	["!"] = "!",
	t = "T",
}

local function hl(name)
	return "%#" .. name .. "#"
end

local function macro_recording()
	local register = vim.fn.reg_recording()

	return register == "" and "" or ("  󰑊 @" .. register)
end

local function git_branch()
	local branch = vim.b.gitsigns_head

	return branch and branch ~= "" and ("  " .. branch) or ""
end

local function diagnostics()
	local counts = vim.diagnostic.count(0)
	local parts = {}
	local labels = {
		{ vim.diagnostic.severity.ERROR, "E" },
		{ vim.diagnostic.severity.WARN, "W" },
		{ vim.diagnostic.severity.INFO, "I" },
		{ vim.diagnostic.severity.HINT, "H" },
	}

	for _, item in ipairs(labels) do
		local count = counts[item[1]]
		if count and count > 0 then
			parts[#parts + 1] = item[2] .. count
		end
	end

	return #parts > 0 and ("  " .. table.concat(parts, " ")) or ""
end

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

local function filetype()
	local ft = vim.bo.filetype

	if ft == "" then
		return ""
	end

	local ok, devicons = pcall(require, "nvim-web-devicons")
	local icon = ok and devicons.get_icon_by_filetype(ft, { default = true }) or ""
	icon = icon ~= "" and (icon .. " ") or ""

	return "  " .. icon .. ft
end

local function search_count()
	if vim.v.hlsearch == 0 then
		return ""
	end

	local ok, count = pcall(vim.fn.searchcount, { recompute = true, maxcount = 999 })
	if not ok or type(count.current) ~= "number" or type(count.total) ~= "number" or count.total == 0 then
		return ""
	end

	return ("  %d/%d"):format(count.current, count.total)
end

function M.render()
	local mode = modes[vim.fn.mode(1)] or vim.fn.mode(1)

	return table.concat({
		hl("User1"),
		" ",
		mode,
		" ",
		hl("User2"),
		git_branch(),
		diagnostics(),
		" ",
		"%<",
		hl("User3"),
		" %t%m%r ",
		"%=",
		hl("User2"),
		lsp_servers(),
		filetype(),
		hl("User1"),
		macro_recording(),
		search_count(),
		" %l:%v ",
		hl("StatusLine"),
	})
end

function M.setup()
	vim.opt.statusline = "%!v:lua.require'config.statusline'.render()"

	vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
		group = vim.api.nvim_create_augroup("user_statusline_macro", { clear = true }),
		callback = function()
			vim.schedule(function()
				vim.cmd("redrawstatus")
			end)
		end,
		desc = "Refresh statusline for the macro indicator",
	})
end

return M
