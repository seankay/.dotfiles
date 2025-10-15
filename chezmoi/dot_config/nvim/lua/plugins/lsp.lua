return {
	-- Mason core
	{ "mason-org/mason.nvim", config = true },
	-- Mason <-> LSP bridge (auto-enables servers)
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"ts_ls",
				"gopls",
				"pyright",
				"ruby_lsp",
				"graphql",
				"terraformls",
				"lua_ls",
				"copilot",
				"nil_ls",
			},
		},
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
	},
}
