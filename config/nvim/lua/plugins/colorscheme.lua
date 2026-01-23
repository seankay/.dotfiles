return {
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = false,
		priority = 1000,
		opts = function()
			local palette = require("rose-pine.palette")
			return {
				variant = "main",
				dark_variant = "main",
				styles = {
					bold = true,
					italic = false,
					transparency = true,
				},
			}
		end,
		config = function(_, opts)
			require("rose-pine").setup(opts)
			vim.cmd.colorscheme("rose-pine")
		end,
	},
}
