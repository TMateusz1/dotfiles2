local M = {}

local tmux_clipboard_timeout_ms = 150
local tmux_clipboard_poll_ms = 15

local function tmux_save_buffer()
	return vim.system({ "tmux", "save-buffer", "-" }, {
		text = true,
	}):wait()
end

local function tmux_copy()
	return function(lines)
		local result = vim.system({ "tmux", "load-buffer", "-w", "-" }, {
			stdin = table.concat(lines, "\n"),
			text = true,
		}):wait()

		if result.code ~= 0 then
			vim.notify_once("tmux clipboard copy failed", vim.log.levels.WARN, { title = "Clipboard" })
		end
	end
end

local function tmux_paste()
	return function()
		local before = tmux_save_buffer()
		local refresh = vim.system({ "tmux", "refresh-client", "-l" }, {
			text = true,
		}):wait()

		if refresh.code ~= 0 then
			vim.notify_once("tmux clipboard paste failed", vim.log.levels.WARN, { title = "Clipboard" })
			return { "" }
		end

		local contents = before.stdout or ""
		local previous = contents

		vim.wait(tmux_clipboard_timeout_ms, function()
			local current = tmux_save_buffer()

			if current.code ~= 0 then
				return false
			end

			contents = current.stdout or ""
			return contents ~= previous
		end, tmux_clipboard_poll_ms)

		return vim.split(contents, "\n")
	end
end

local function osc52_sequence(clipboard, contents)
	if vim.env.TMUX then
		return string.format("\027Ptmux;\027\027]52;%s;%s\007\027\\", clipboard, contents)
	end

	return string.format("\027]52;%s;%s\007", clipboard, contents)
end

local function copy(reg)
	local clipboard = reg == "+" and "c" or "p"

	return function(lines)
		vim.api.nvim_ui_send(osc52_sequence(clipboard, vim.base64.encode(table.concat(lines, "\n"))))
	end
end

local function paste(reg)
	local clipboard = reg == "+" and "c" or "p"

	return function()
		local contents = nil
		local id = vim.api.nvim_create_autocmd("TermResponse", {
			callback = function(event)
				local encoded = event.data.sequence:match("\027%]52;%w?;([A-Za-z0-9+/=]*)")

				if encoded then
					contents = vim.base64.decode(encoded)
					return true
				end
			end,
		})

		vim.api.nvim_ui_send(osc52_sequence(clipboard, "?"))

		local ok = vim.wait(800, function()
			return contents ~= nil
		end)

		pcall(vim.api.nvim_del_autocmd, id)

		if not ok then
			vim.notify_once("OSC52 paste timed out", vim.log.levels.WARN, { title = "Clipboard" })
			return { "" }
		end

		return vim.split(contents, "\n")
	end
end

function M.setup()
	if not (vim.env.SSH_TTY or vim.env.SSH_CONNECTION) then
		return
	end

	if vim.env.TMUX then
		vim.g.clipboard = {
			name = "OSC52/tmux",
			copy = {
				["+"] = tmux_copy(),
				["*"] = tmux_copy(),
			},
			paste = {
				["+"] = tmux_paste(),
				["*"] = tmux_paste(),
			},
		}

		vim.opt.clipboard = "unnamedplus"
		return
	end

	vim.g.clipboard = {
		name = "OSC52",
		copy = {
			["+"] = copy("+"),
			["*"] = copy("*"),
		},
		paste = {
			["+"] = paste("+"),
			["*"] = paste("*"),
		},
	}

	vim.opt.clipboard = "unnamedplus"
end

return M
