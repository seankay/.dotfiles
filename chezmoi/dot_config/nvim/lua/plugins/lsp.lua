return {
	{
		"neovim/nvim-lspconfig",
	},
	-- Mason <-> LSP bridge (auto-enables servers)
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"copilot",
				"expert",
				"gopls",
				"graphql",
				"lua_ls",
				"pyright",
				"ruby_lsp",
				"terraformls",
				"ts_ls",
			},
		},
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
	},
}
