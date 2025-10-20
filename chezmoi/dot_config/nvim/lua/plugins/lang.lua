return {
	-- Modern TS/JS/GraphQL via Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		branch = "main",
		lazy = false,
		opts = {
			highlight = { enable = true },
			indent = { enable = true },
			ensure_installed = {
				"bash",
				"go",
				"graphql",
				"hcl",
				"javascript",
				"json",
				"jsonc",
				"lua",
				"markdown",
				"markdown_inline",
				"python",
				"regex",
				"ruby",
				"terraform",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"elixir",
				"erlang",
			},
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
	{ "fatih/vim-go", ft = "go" },
	-- Rails (kept)
	{ "tpope/vim-rails" },
	{ "tpope/vim-rake" },

	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},
}
