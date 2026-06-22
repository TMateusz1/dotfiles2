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
				{ "<leader>ck", group = "Kubernetes" },
				{ "<leader>d", group = "Debug" },
				{ "<leader>M", group = "Markdown" },
				{ "<leader>t", group = "Tests" },
				{ "<leader>u", group = "UI / Toggles" },

				-- Harpoon
				{ "<leader>a", desc = "Harpoon add file" },
				{ "<leader>A", desc = "Harpoon edit list" },
				{ "<leader>1", desc = "Harpoon file 1" },
				{ "<leader>2", desc = "Harpoon file 2" },
				{ "<leader>3", desc = "Harpoon file 3" },
				{ "<leader>4", desc = "Harpoon file 4" },

				-- Direct leader mappings
				{ "<leader>e", desc = "File explorer (mini.files)" },
				{ "<leader>w", desc = "Save file" },
				{ "<leader>W", desc = "Save and close buffer" },
				{ "<leader>k", desc = "Close window (keep buffer)" },
				{ "<leader>q", desc = "Smart close" },
				{ "<leader>Q", desc = "Quit all (confirm save)" },
				{ "<leader>=", desc = "Split window right (vsplit)" },
				{ "<leader>-", desc = "Split window below (split)" },
				{ "<leader>/", desc = "Search buffer lines" },

				-- Buffers
				{ "[b", desc = "Previous buffer" },
				{ "]b", desc = "Next buffer" },
				{ "<leader>bx", desc = "Delete buffer" },
				{ "<leader>bp", desc = "Pick buffer" },
				{ "<leader>bX", desc = "Delete other buffers" },
				{ "<leader>bL", desc = "Delete buffers to the right" },
				{ "<leader>bH", desc = "Delete buffers to the left" },

				-- Git
				{ "<leader>gg", desc = "LazyGit" },
				{ "<leader>gl", desc = "Git line commits" },
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

				-- FZF picker
				{ "<leader>ff", desc = "Find files" },
				{ "<leader>fG", desc = "Git changed files" },
				{ "<leader>fg", desc = "Live grep" },
				{ "<leader>fr", desc = "Recent files" },
				{ "<leader>fw", desc = "Grep word under cursor" },
				{ "<leader>fs", desc = "Document symbols (all kinds)" },
				{ "<leader>fS", desc = "Workspace symbols" },
				{ "<leader>fd", desc = "Document diagnostics" },
				{ "<leader>fD", desc = "Workspace diagnostics" },
				{ "<leader>fq", desc = "Quickfix list" },
				{ "<leader>ft", desc = "Todo/Fix/Fixme/Bug" },

				-- LSP / Code — bare keys (fast)
				{ "gd", desc = "Go to definition" },
				{ "gD", desc = "Go to declaration" },
				{ "gi", desc = "Go to implementation" },
				{ "gr", desc = "Go to references" },
				{ "gy", desc = "Go to type definition" },
				{ "K", desc = "Hover documentation" },

				-- <leader>c — navigation
				{ "<leader>cI", desc = "Incoming calls" },

				-- <leader>c — actions
				{ "<leader>ca", desc = "Code action" },
				{ "<leader>cn", desc = "Rename symbol" },
				{ "<leader>cgo", desc = "Organize imports" },
				{ "<leader>cl", desc = "Format file" },

				-- <leader>c — diagnostics & LSP management
				{ "<leader>x", group = "Buffers / Lists" },
				{ "<leader>xx", desc = "Close current buffer" },
				{ "<leader>xX", desc = "Close other buffers" },
				{ "<leader>xn", desc = "New scratch buffer" },
				{ "<leader>xq", desc = "Toggle quickfix" },
				{ "<leader>cx", desc = "Line diagnostics" },
				{ "<leader>cq", desc = "Diagnostics quickfix" },

				-- <leader>ck — Kubernetes
				{ "<leader>cks", desc = "Generate CRD schemas from cluster" },
				{ "<leader>ckl", desc = "Generate CRD schemas from local files" },
				{ "<leader>cka", desc = "Attach Kubernetes schema to buffer" },

				-- <leader>cg — Go tools
				{ "<leader>cgl", desc = "Go lint" },
				{ "<leader>cgd", desc = "Go doc" },
				{ "<leader>cgi", desc = "Implement interface" },
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
				{ "]f", desc = "Next function start" },
				{ "[f", desc = "Previous function start" },

				-- Markdown
				{ "<leader>Md", desc = "Toggle rendered Markdown view" },
				{ "<leader>MD", desc = "Preview in side window" },

				-- Line movement
				{ "<A-j>", desc = "Move line down", mode = { "n", "v" } },
				{ "<A-k>", desc = "Move line up", mode = { "n", "v" } },

				-- UI / toggles
				{ "<leader>uz", desc = "Toggle zen mode" },
				{ "<leader>ud", desc = "Toggle dim (twilight)" },
				{ "<leader>uc", desc = "Toggle VSCode code colors" },
				{ "<leader>un", desc = "Dismiss notifications" },
				{ "<leader>uf", desc = "Toggle format on save" },
				{ "<leader>uh", desc = "Toggle inlay hints" },
				{ "<leader>um", desc = "Toggle minimap" },
				{ "<leader>uv", desc = "Toggle virtual-line diagnostics" },
			},
		},
	},
}
