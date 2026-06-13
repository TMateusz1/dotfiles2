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
				{ "<leader>a", group = "AI (CodeCompanion)" },
				{ "<leader>b", group = "Buffers" },
				{ "<leader>f", group = "Find" },
				{ "<leader>g", group = "Git" },
				{ "<leader>c", group = "Code" },
				{ "<leader>cg", group = "Go" },
				{ "<leader>d", group = "Debug" },
				{ "<leader>m", group = "Marks (Harpoon)" },
				{ "<leader>M", group = "Markdown" },
				{ "<leader>t", group = "Tests" },
				{ "<leader>u", group = "UI / Toggles" },
				{ "<leader>x", group = "Lists (quickfix)" },

				-- Direct leader mappings
				{ "<leader>e", desc = "File explorer (neo-tree toggle)" },
				{ "<leader>E", desc = "Oil multi-file edit" },
				{ "<leader>F", desc = "Code outline (aerial)" },
				{ "<leader>w", desc = "Save file" },
				{ "<leader>W", desc = "Save and close buffer" },
				{ "<leader>k", desc = "Close window (keep buffer)" },
				{ "<leader>q", desc = "Smart close" },
				{ "<leader>Q", desc = "Quit window + delete buffer" },
				{ "<leader>X", desc = "Quit all (confirm save)" },
				{ "<leader>=", desc = "Split window right (vsplit)" },
				{ "<leader>-", desc = "Split window below (split)" },
				{ "<leader>.", desc = "Toggle scratch buffer" },
				{ "<leader>/", desc = "Search buffer lines" },

				-- Buffers
				{ "[b", desc = "Previous buffer" },
				{ "]b", desc = "Next buffer" },
				{ "<leader>bx", desc = "Delete buffer" },
				{ "<leader>bp", desc = "Pick buffer" },
				{ "<leader>bX", desc = "Delete other buffers" },
				{ "<leader>bL", desc = "Delete buffers to the right" },
				{ "<leader>bH", desc = "Delete buffers to the left" },

				-- AI
				{ "<leader>aa", desc = "AI actions", mode = { "n", "v" } },
				{ "<leader>ac", desc = "AI Codex chat" },
				{ "<leader>ad", desc = "AI add selection to chat", mode = "v" },
				{ "<leader>an", desc = "AI new Codex chat" },
				{ "<leader>at", desc = "AI Codex terminal" },

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
				{ "<leader>ghu", desc = "Undo stage hunk (toggle)" },

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
				{ "<leader>fs", desc = "Document symbols (all kinds)" },
				{ "<leader>fS", desc = "Workspace symbols" },
				{ "<leader>fd", desc = "Document diagnostics" },
				{ "<leader>fD", desc = "Workspace diagnostics" },
				{ "<leader>fq", desc = "Quickfix list" },
				{ "<leader>fl", desc = "Location list" },
				{ "<leader>fR", desc = "Resume picker" },
				{ "<leader>fu", desc = "Undo history" },
				{ "<leader>fn", desc = "Notification history" },
				{ "<leader>f.", desc = "Scratch buffers" },
				{ "<leader>ft", desc = "Todo comments" },
				{ "<leader>fT", desc = "Todo/Fix/Fixme only" },

				-- LSP / Code — bare keys (fast)
				{ "gd", desc = "Go to definition" },
				{ "gD", desc = "Go to declaration" },
				{ "gi", desc = "Go to implementation" },
				{ "gr", desc = "Go to references" },
				{ "gy", desc = "Go to type definition" },
				{ "K", desc = "Hover documentation" },

				-- <leader>c — navigation (all use picker)
				{ "<leader>cd", desc = "Go to definition" },
				{ "<leader>cD", desc = "Go to declaration" },
				{ "<leader>ci", desc = "Implement interface (Go)" },
				{ "<leader>cy", desc = "Go to type definition" },
				{ "<leader>cu", desc = "Find usages" },
				{ "<leader>cF", desc = "LSP finder (all)" },
				{ "<leader>cI", desc = "Incoming calls" },
				{ "<leader>cO", desc = "Outgoing calls" },

				-- <leader>c — actions
				{ "<leader>ca", desc = "Code action" },
				{ "<leader>cr", desc = "References" },
				{ "<leader>cn", desc = "Rename symbol" },
				{ "<leader>co", desc = "Organize imports" },
				{ "<leader>cf", desc = "Fix all" },
				{ "<leader>cl", desc = "Format file" },
				{ "<leader>cc", desc = "Run code lens" },
				{ "<leader>cC", desc = "Refresh code lens" },

				-- <leader>c — diagnostics & LSP management
				{ "<leader>cx", desc = "Line diagnostics" },
				{ "<leader>cq", desc = "Diagnostics quickfix" },
				{ "<leader>cL", desc = "LSP info" },
				{ "<leader>cR", desc = "Restart LSP" },

				-- <leader>cg — Go tools
				{ "<leader>cgg", desc = "Go generate" },
				{ "<leader>cgm", desc = "Go mod tidy" },
				{ "<leader>cgl", desc = "Go lint" },
				{ "<leader>cgd", desc = "Go doc" },
				{ "<leader>cgj", desc = "Add json tags" },
				{ "<leader>cgJ", desc = "Remove json tags" },
				{ "<leader>cgy", desc = "Add yaml tags" },
				{ "<leader>cgY", desc = "Remove yaml tags" },
				{ "<leader>cge", desc = "Add env tags" },
				{ "<leader>cgE", desc = "Remove env tags" },

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
				{ "<leader>tq", desc = "Test failures quickfix" },
				{ "<leader>tw", desc = "Test watch file" },
				{ "<leader>tx", desc = "Test stop" },

				-- Diagnostics
				{ "]d", desc = "Next diagnostic" },
				{ "[d", desc = "Previous diagnostic" },
				{ "]q", desc = "Next quickfix item" },
				{ "[q", desc = "Previous quickfix item" },
				{ "<leader>xq", desc = "Toggle quickfix window" },
				{ "<leader>xl", desc = "Toggle location list" },
				{ "<leader>xx", desc = "Problems panel (workspace)" },
				{ "<leader>xX", desc = "Problems panel (buffer)" },
				{ "<leader>xs", desc = "Symbols outline" },
				{ "<leader>xt", desc = "Todo comments (Trouble)" },
				{ "]t", desc = "Next todo comment" },
				{ "[t", desc = "Previous todo comment" },
				{ "]f", desc = "Next function start" },
				{ "[f", desc = "Previous function start" },

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
				{ "<leader>uc", desc = "Toggle VSCode code colors" },
				{ "<leader>ud", desc = "Toggle code dimming" },
				{ "<leader>uf", desc = "Toggle format on save" },
				{ "<leader>uh", desc = "Toggle inlay hints" },
				{ "<leader>uC", desc = "Toggle sticky context" },
				{ "<leader>uv", desc = "Toggle virtual-line diagnostics" },
				{ "<leader>ut", desc = "Toggle terminal" },
				{ "<leader>uz", desc = "Toggle zen mode" },
				{ "<leader>uZ", desc = "Toggle zoom" },
			},
		},
	},
}
