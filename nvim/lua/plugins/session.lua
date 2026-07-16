local function close_minifiles()
	local ok, MiniFiles = pcall(require, "mini.files")

	if ok then
		pcall(MiniFiles.close)
	end
end

local function close_neotree()
	if package.loaded["neo-tree"] then
		pcall(require("neo-tree.command").execute, { action = "close" })
	end
end

local function close_file_explorers()
	close_minifiles()
	close_neotree()
end

return {
	{
		"rmagatti/auto-session",
		lazy = false,
		opts = {
			auto_restore_last_session = false,
			close_unsupported_windows = true,
			close_filetypes_on_save = {
				"checkhealth",
				"minifiles",
				"neo-tree",
			},
			cwd_change_handling = false,
			git_use_branch_name = false,
			args_allow_single_directory = true,
			args_allow_files_auto_save = false,
			legacy_cmds = false,
			pre_save_cmds = {
				close_file_explorers,
			},
			post_restore_cmds = {
				close_file_explorers,
			},
			suppressed_dirs = {
				"~/",
				"~/Downloads",
				"/",
			},
			session_lens = {
				load_on_setup = false,
			},
			log_level = "error",
		},
	},
}
