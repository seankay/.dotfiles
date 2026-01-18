return {
	{
		"dgox16/oldworld.nvim",
		lazy = false,
		priority = 1000,
		config = function(_, opts)
			require("oldworld").setup(opts)
			vim.cmd.colorscheme("oldworld")
		end,
	},
}
