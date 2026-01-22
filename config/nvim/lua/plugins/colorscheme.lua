return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = function()
			local util = require("tokyonight.util")
			return {
				transparent = true,
				diagnostics = {
					darker = false,
					undercurl = true,
					background = false,
				},
				on_highlights = function(hl, colors)
					local cursorline_bg = util.darken(colors.bg_highlight, 0.6, colors.bg)
					hl.CursorLine = { bg = cursorline_bg }
					hl.CursorLineNr = { fg = colors.blue, bold = true }
					hl.LspReferenceText = { fg = colors.fg, bg = colors.none, underline = true }
					hl.LspReferenceRead = { fg = colors.fg, bg = colors.none, underline = true }
					hl.LspReferenceWrite = { fg = colors.fg, bg = colors.none, underline = true, bold = true }
					hl.DiagnosticUnnecessary = { fg = colors.comment, italic = true }
					hl.DiagnosticVirtualTextError = { fg = colors.error, bg = colors.none }
					hl.DiagnosticVirtualTextWarn = { fg = colors.warning, bg = colors.none }
					hl.DiagnosticVirtualTextInfo = { fg = colors.info, bg = colors.none }
					hl.DiagnosticVirtualTextHint = { fg = colors.hint, bg = colors.none }
				end,
			}
		end,
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd.colorscheme("tokyonight-night")
		end,
	},
}
