return {
	{
		"rmagatti/auto-session",
		lazy = false,
		opts = {
			auto_restore_last_session = false,
			cwd_change_handling = false,
			git_use_branch_name = false,
			args_allow_single_directory = true,
			args_allow_files_auto_save = false,
			legacy_cmds = false,
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
