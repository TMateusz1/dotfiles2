-- ~/.config/nvim/lua/plugins/which-key.lua

return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "modern",

			delay = function(ctx)
				-- Show faster after leader, slower for other mappings
				return ctx.plugin and 0 or 300
			end,

			icons = {
				mappings = true,
				keys = {
					Space = "SPC",
					CR = "RET",
					Esc = "ESC",
				},
			},

			win = {
				border = "rounded",
				padding = { 1, 2 },
			},

			layout = {
				width = { min = 20 },
				spacing = 3,
			},

			spec = {
				-- Top-level leader groups
				{ "<leader>b", group = "Buffers" },
				{ "<leader>f", group = "Find" },
				{ "<leader>g", group = "Git" },
				{ "<leader>c", group = "Code" },
				{ "<leader>cg", group = "Go" },
				{ "<leader>d", group = "Debug" },
				{ "<leader>m", group = "Marks (Harpoon)" },
				{ "<leader>M", group = "Markdown" },
				{ "<leader>s", group = "Sessions" },
				{ "<leader>t", group = "Tests" },
				{ "<leader>u", group = "UI / Toggles" },

				-- Direct leader mappings
				{ "<leader>e", desc = "Snacks explorer (reveal current file)" },
				{ "<leader>E", desc = "Oil multi-file edit" },
				{ "<leader>w", desc = "Save file" },
				{ "<leader>W", desc = "Save and close buffer" },
				{ "<leader>q", desc = "Smart close" },
				{ "<leader>Q", desc = "Quit window" },
				{ "<leader>C", desc = "Quit all force" },
				{ "<leader>.", desc = "Toggle scratch buffer" },

				-- Buffers
				{ "[b", desc = "Previous buffer" },
				{ "]b", desc = "Next buffer" },
				{ "<leader>bx", desc = "Delete buffer" },
				{ "<leader>bp", desc = "Pick buffer" },
				{ "<leader>bX", desc = "Delete other buffers" },
				{ "<leader>bL", desc = "Delete buffers to the right" },
				{ "<leader>bH", desc = "Delete buffers to the left" },

				-- Git
				{ "<leader>gB", desc = "Git browse (open in browser)", mode = { "n", "v" } },
				{ "<leader>gg", desc = "LazyGit" },
				{ "<leader>gG", desc = "LazyGit current file" },
				{ "<leader>gc", desc = "Git commits" },
				{ "<leader>gC", desc = "Git buffer commits" },
				{ "<leader>gb", desc = "Git branches" },
				{ "<leader>gd", desc = "Git diff hunks" },
				{ "<leader>gl", desc = "Git line commits" },
				{ "<leader>gs", desc = "Git stash" },
				{ "<leader>gh", group = "Git Hunks" },

				{ "]h", desc = "Next git hunk" },
				{ "[h", desc = "Previous git hunk" },

				{ "<leader>ghp", desc = "Preview hunk" },
				{ "<leader>ghs", desc = "Stage hunk" },
				{ "<leader>ghr", desc = "Reset hunk" },
				{ "<leader>ghu", desc = "Undo stage hunk" },

				{ "<leader>ghb", desc = "Blame line" },
				{ "<leader>ghB", desc = "Full blame line" },
				{ "<leader>ghl", desc = "Toggle inline blame" },

				{ "<leader>ghd", desc = "Diff this file" },
				{ "<leader>ghD", desc = "Diff against previous commit" },

				{ "<leader>ght", desc = "Toggle deleted lines" },
				{ "<leader>ghw", desc = "Toggle word diff" },

				-- Snacks picker
				{ "<leader>ff", desc = "Find files" },
				{ "<leader>fG", desc = "Git changed files" },
				{ "<leader>fg", desc = "Live grep" },
				{ "<leader>fb", desc = "Find buffers" },
				{ "<leader>fr", desc = "Recent files" },
				{ "<leader>fc", desc = "Find config files" },
				{ "<leader>fw", desc = "Grep word under cursor" },
				{ "<leader>fW", desc = "Grep WORD under cursor" },
				{ "<leader>fh", desc = "Help tags" },
				{ "<leader>fk", desc = "Keymaps" },
				{ "<leader>f:", desc = "Commands" },
				{ "<leader>fj", desc = "Jump list" },
				{ "<leader>fm", desc = "Harpoon files" },
				{ "<leader>f;", desc = "Command history" },
				{ "<leader>f/", desc = "Search history" },
				{ "<leader>fd", desc = "Document diagnostics" },
				{ "<leader>fD", desc = "Workspace diagnostics" },
				{ "<leader>fq", desc = "Quickfix list" },
				{ "<leader>fl", desc = "Location list" },
				{ "<leader>fR", desc = "Resume picker" },
				{ "<leader>fn", desc = "Notification history" },
				{ "<leader>f.", desc = "Scratch buffers" },
				{ "<leader>ft", desc = "Todo comments" },
				{ "<leader>fT", desc = "Todo/Fix/Fixme only" },

				-- LSP / Code
				{ "gd", desc = "Go to definition" },
				{ "gD", desc = "Go to declaration" },
				{ "gi", desc = "Go to implementation" },
				{ "gr", desc = "Go to references" },
				{ "gy", desc = "Go to type definition" },
				{ "K", desc = "Hover documentation" },
				{ "<leader>ca", desc = "Code action" },
				{ "<leader>cc", desc = "Run code lens" },
				{ "<leader>cC", desc = "Refresh code lens" },
				{ "<leader>cf", desc = "Fix all" },
				{ "<leader>cF", desc = "LSP finder" },
				{ "<leader>cI", desc = "Incoming calls" },
				{ "<leader>cO", desc = "Outgoing calls" },
				{ "<leader>co", desc = "Organize imports" },
				{ "<leader>cr", desc = "Rename symbol" },
				{ "<leader>cu", desc = "Find usages" },
				{ "<leader>cd", desc = "Line diagnostics" },
				{ "<leader>ci", desc = "LSP info" },
				{ "<leader>cq", desc = "Diagnostics quickfix" },
				{ "<leader>cl", desc = "Format file" },
				{ "<leader>cs", desc = "Document symbols" },
				{ "<leader>cS", desc = "Live workspace symbols" },
				{ "<leader>cR", desc = "Restart LSP" },
				{ "<leader>cgg", desc = "Go generate" },
				{ "<leader>cgm", desc = "Go mod tidy" },
				{ "<leader>cgv", desc = "Go vulncheck" },

				-- Debug
				{ "<leader>db", desc = "Debug toggle breakpoint" },
				{ "<leader>dB", desc = "Debug conditional breakpoint" },
				{ "<leader>dp", desc = "Debug log point" },
				{ "<leader>dc", desc = "Debug continue" },
				{ "<leader>dC", desc = "Debug run to cursor" },
				{ "<leader>di", desc = "Debug step into" },
				{ "<leader>do", desc = "Debug step over" },
				{ "<leader>dO", desc = "Debug step out" },
				{ "<leader>dr", desc = "Debug restart" },
				{ "<leader>dl", desc = "Debug run last" },
				{ "<leader>dt", desc = "Debug terminate" },
				{ "<leader>du", desc = "Debug UI" },
				{ "<leader>de", desc = "Debug eval", mode = { "n", "v" } },
				{ "<leader>df", desc = "Debug frames" },
				{ "<leader>ds", desc = "Debug scopes" },
				{ "<leader>dS", desc = "Debug scopes wide" },
				{ "<leader>dg", desc = "Debug Go test" },
				{ "<leader>dG", desc = "Debug last Go test" },

				-- Tests
				{ "<leader>tf", desc = "Test current function" },
				{ "<leader>tF", desc = "Test current file" },
				{ "<leader>tp", desc = "Test current package" },
				{ "<leader>tP", desc = "Test entire project" },
				{ "<leader>tr", desc = "Test rerun last" },
				{ "<leader>ts", desc = "Test summary" },
				{ "<leader>to", desc = "Test output" },
				{ "<leader>tO", desc = "Test output panel" },
				{ "<leader>tq", desc = "Next failed test" },
				{ "<leader>tQ", desc = "Previous failed test" },
				{ "<leader>tw", desc = "Test watch file" },
				{ "<leader>tx", desc = "Test stop" },

				-- Sessions
				{ "<leader>ss", desc = "Restore session (cwd)" },
				{ "<leader>sl", desc = "Restore last session" },
				{ "<leader>sS", desc = "Select session" },
				{ "<leader>sd", desc = "Don't save session" },

				-- Diagnostics
				{ "]d", desc = "Next diagnostic" },
				{ "[d", desc = "Previous diagnostic" },
				{ "]q", desc = "Next quickfix item" },
				{ "[q", desc = "Previous quickfix item" },
				{ "]r", desc = "Next reference" },
				{ "[r", desc = "Previous reference" },
				{ "]t", desc = "Next todo comment" },
				{ "[t", desc = "Previous todo comment" },

				-- Harpoon marks
				{ "<leader>mm", desc = "Mark newest Harpoon file" },
				{ "<leader>m1", desc = "Mark Harpoon slot 1" },
				{ "<leader>m2", desc = "Mark Harpoon slot 2" },
				{ "<leader>m3", desc = "Mark Harpoon slot 3" },
				{ "<leader>1", desc = "Go to Harpoon slot 1" },
				{ "<leader>2", desc = "Go to Harpoon slot 2" },
				{ "<leader>3", desc = "Go to Harpoon slot 3" },

				-- Markdown
				{ "<leader>Md", desc = "Toggle rendered Markdown view" },
				{ "<leader>MD", desc = "Preview in side window" },
				{ "<leader>Me", desc = "Browser preview (markdown only)" },

				-- Line movement
				{ "<A-j>", desc = "Move line down", mode = { "n", "v" } },
				{ "<A-k>", desc = "Move line up", mode = { "n", "v" } },

				-- UI / toggles
				{ "<leader>ud", desc = "Toggle code dimming" },
				{ "<leader>uh", desc = "Toggle inlay hints" },
				{ "<leader>ut", desc = "Toggle terminal" },
				{ "<leader>uz", desc = "Toggle zen mode" },
				{ "<leader>uZ", desc = "Toggle zoom" },
				{ "<leader>uw", desc = "Toggle word references" },
			},
		},
	},
}
