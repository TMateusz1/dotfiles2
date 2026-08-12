local M = {}

function M.setup()
	require("catppuccin").setup({
		flavour = "mocha",
		transparent_background = false,
		float = {
			transparent = false,
			solid = true,
		},
		term_colors = true,
		dim_inactive = {
			enabled = false,
		},
		-- Italic means exactly one thing here: "this is not code". Comments are
		-- the only italic run on screen, so the eye can use slant alone as a
		-- skip signal. Everything else separates by hue, never by font style —
		-- including `miscs`, which otherwise leaves modules and tag attributes
		-- italic by default.
		styles = {
			comments = { "italic" },
			conditionals = {},
			loops = {},
			functions = {},
			keywords = {},
			strings = {},
			variables = {},
			numbers = {},
			booleans = {},
			properties = {},
			types = {},
			operators = {},
			miscs = {},
		},
		lsp_styles = {
			inlay_hints = {
				background = false,
			},
		},
		custom_highlights = function(colors)
			return {
				-- Syntax: only the groups that intentionally differ from the
				-- flavour's defaults. Everything not listed is upstream
				-- catppuccin, so this block reads as a list of decisions.
				--
				-- Colour names things, grey carries grammar:
				--   yellow    declared types and constructors
				--   sapphire  packages and modules
				--   blue      functions and methods
				--   mauve     keywords and builtin types (int, string)
				--   teal      struct fields and properties
				--   green     strings
				--   peach     constants, numbers, booleans
				--   subtext1  operators
				--   overlay2  punctuation
				--   overlay1  comments

				-- overlay1 rather than catppuccin's overlay2. Still 4.44:1
				-- against the background, so comments stay comfortable prose,
				-- but roughly twice as far from code text in perceptual
				-- distance (dE 23 vs 10) — the eye skips them by default and
				-- finds them on purpose.
				Comment = { fg = colors.overlay1, italic = true },

				-- Packages get their own hue instead of sharing yellow with
				-- declared types and relying on italic to tell them apart.
				-- Note the scope in Go: the tree-sitter queries tag `@module`
				-- on the `package` declaration only. A qualifier inside an
				-- expression (`fmt` in `fmt.Sprintf`) is captured as
				-- `@variable` and stays body text, because gopls semantic
				-- tokens are off in config/lsp.lua. Turning them on routes it
				-- through `@lsp.type.namespace`, which lands on this colour.
				["@module"] = { fg = colors.sapphire },

				-- Fields read as their own category. Catppuccin's lavender
				-- default sits dE 9 from both plain text and function blue,
				-- which is too close to survive a dense struct literal.
				["@variable.member"] = { fg = colors.teal },
				["@property"] = { fg = colors.teal },

				-- Operators recede toward body text so the coloured tokens on a
				-- line are the ones that name something. Keeping them on sky
				-- put them dE 10.6 from the field teal they sit next to in
				-- every `c.Port == 0`.
				Operator = { fg = colors.subtext1 },
				["@operator"] = { fg = colors.subtext1 },

				-- `@type.builtin` is deliberately absent: letting it fall back
				-- to catppuccin's mauve keeps `int`/`string` from colliding
				-- with declared types like `Config`.

				-- Chrome sits below code in a deliberate ladder, so nothing in
				-- the frame outranks the text:
				--   indent guides 1.80:1 -> separators 2.46 -> line numbers
				--   3.36 -> comments 4.44 -> code 7:1 and up.
				-- The focused window is marked by the cursorline (see
				-- config/autocmds.lua), which is why the separator does not
				-- need to be an accent.
				WinSeparator = { fg = colors.surface2, bg = "NONE" },
				LineNr = { fg = colors.overlay0 },
				Whitespace = { fg = colors.overlay0 },
				CursorLine = { bg = colors.surface0 },
				CursorLineNr = { fg = colors.mauve, bold = true },
				Visual = { bg = colors.surface1 },
				MatchParen = { fg = colors.peach, bg = colors.surface1, bold = true },
				NormalFloat = { fg = colors.text, bg = colors.mantle },
				FloatBorder = { fg = colors.blue, bg = colors.mantle },
				FloatTitle = { fg = colors.blue, bg = colors.mantle, bold = true },
				PmenuSel = { fg = colors.crust, bg = colors.blue },
				Search = { fg = colors.crust, bg = colors.yellow },
				IncSearch = { fg = colors.crust, bg = colors.peach },
				CurSearch = { fg = colors.crust, bg = colors.peach },
				SnippetTabstop = { bg = "NONE", fg = "NONE" },
				LspReferenceText = { bg = colors.surface0 },
				LspReferenceRead = { bg = colors.surface0 },
				LspReferenceWrite = { bg = colors.surface1, underline = true },

				User1 = { fg = colors.crust, bg = colors.blue, bold = true },
				User2 = { fg = colors.text, bg = colors.surface0 },
				User3 = { fg = colors.text, bg = "NONE" },
				TabLine = { fg = colors.subtext0, bg = colors.base },
				TabLineSel = { fg = colors.text, bg = colors.surface0, bold = true },
				TabLineFill = { fg = colors.overlay0, bg = colors.base },

				FzfLuaNormal = { fg = colors.text, bg = colors.base },
				FzfLuaBorder = { fg = colors.blue, bg = colors.base },
				FzfLuaTitle = { fg = colors.blue, bg = colors.base, bold = true },
				FzfLuaPreviewNormal = { fg = colors.text, bg = colors.base },
				FzfLuaPreviewBorder = { fg = colors.blue, bg = colors.base },
				FzfLuaPreviewTitle = { fg = colors.blue, bg = colors.base, bold = true },
				FzfLuaCursorLine = { bg = colors.surface0 },
				FzfLuaSearch = { fg = colors.crust, bg = colors.yellow },
				FzfLuaDirPart = { fg = colors.overlay0 },
				FzfLuaFilePart = { fg = colors.text },

				IblIndent = { fg = colors.surface1 },
				IblScope = { fg = colors.mauve, bold = true },

				WhichKey = { fg = colors.blue },
				WhichKeyGroup = { fg = colors.teal },
				WhichKeyDesc = { fg = colors.text },
				WhichKeySeparator = { fg = colors.overlay0 },
				WhichKeyValue = { fg = colors.overlay0 },
			}
		end,
		integrations = {
			blink_cmp = true,
			gitsigns = true,
			mini = true,
			neotree = true,
			native_lsp = {
				enabled = true,
			},
			treesitter = true,
			which_key = true,
		},
	})

	vim.cmd.colorscheme("catppuccin")
end

return M
