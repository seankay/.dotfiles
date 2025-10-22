return {
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
		opts = function()
			return {
				highlights = require("catppuccin.special.bufferline").get_theme(),
			}
		end,
	},
}
