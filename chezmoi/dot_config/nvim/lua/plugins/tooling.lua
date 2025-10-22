return {
	-- Mason core
	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = {
				"gofumpt",
				"goimports",
				"golangci-lint",
				"gomodifytags",
				"impl",
			},
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},
	-- Mason tools (formatters/linters, etc.)
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				"black",
				"eslint_d",
				"golangci-lint",
				"prettierd",
				"rubocop",
				"stylua",
			},
		},
	},
}
