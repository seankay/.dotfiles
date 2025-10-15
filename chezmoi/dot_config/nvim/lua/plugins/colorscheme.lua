return {
	-- Theme: material for Neovim (Lua version)
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			default_integrations = true,
			flavour = "auto", -- latte, frappe, macchiato, mocha
			background = { -- :h background
				light = "latte",
				dark = "macchiato",
			},
			transparent_background = true,
			term_colors = true,
			custom_highlights = function(colors)
				return {
					Normal = { bg = "NONE" },
					NormalNC = { bg = "NONE" },
					NormalFloat = { bg = "NONE" },
					ColorColumn = { bg = colors.surface0, blend = 97 },
					CursorColumn = { bg = colors.surface1, blend = 92 },
					FloatBorder = { fg = colors.surface2, bg = "NONE" },
					FloatTitle = { fg = colors.text, bg = "NONE" },
					SignColumn = { bg = "NONE" },
					GitSignsAdd = { bg = "NONE" },
					GitSignsChange = { bg = "NONE" },
					GitSignsDelete = { bg = "NONE" },
					DiagnosticVirtualTextError = { bg = "NONE" },
					DiagnosticVirtualTextWarn = { bg = "NONE" },
					DiagnosticVirtualTextInfo = { bg = "NONE" },
					DiagnosticVirtualTextHint = { bg = "NONE" },
					TelescopeNormal = { bg = "NONE" },
					TelescopeBorder = { fg = colors.surface2, bg = "NONE" },
					TelescopePromptNormal = { bg = "NONE" },
					TelescopePromptBorder = { fg = colors.surface2, bg = "NONE" },
					TelescopeResultsNormal = { bg = "NONE" },
					TelescopeResultsBorder = { fg = colors.surface2, bg = "NONE" },
					TelescopePreviewNormal = { bg = "NONE" },
					TelescopePreviewBorder = { fg = colors.surface2, bg = "NONE" },
					Pmenu = { bg = colors.none or "NONE" },
					PmenuSel = { bg = colors.surface1, fg = colors.text },
					WinSeparator = { fg = colors.surface2, bg = "NONE" },
					VertSplit = { fg = colors.surface2, bg = "NONE" },
					StatusLine = { bg = "NONE" },
					StatusLineNC = { bg = "NONE" },
				}
			end,
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin-mocha")
		end,
	},
}
