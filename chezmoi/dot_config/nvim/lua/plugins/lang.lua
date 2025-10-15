return {
	-- Language-specific (kept or updated)
	{ "kevinoid/vim-jsonc" },
	{ "Vimjas/vim-python-pep8-indent" },
	-- Modern TS/JS/GraphQL via Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		opts = {
			highlight = { enable = true },
			indent = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = { init_selection = "gnn", node_incremental = "grn", node_decremental = "grm" },
			},
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
			},
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)

			local ts_lang = vim.treesitter.language
			if ts_lang and ts_lang.register then
				ts_lang.register("tsx", "typescriptreact")
				ts_lang.register("javascript", "javascriptreact")
			end
		end,
	},
	-- Go: richer than vim-go, integrates with gopls and tooling
	{
		"ray-x/go.nvim",
		dependencies = { "ray-x/guihua.lua" },
		config = function()
			require("go").setup({})
		end,
	},

	-- Rails (kept)
	{ "tpope/vim-rails" },
	{ "tpope/vim-rake" },

	-- Terraform/HCL (kept)
	{ "hashivim/vim-terraform" },
	{ "jvirtanen/vim-hcl" },

	-- Markdown (kept)
	{ "preservim/vim-markdown" },

	-- install without yarn or npm
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
