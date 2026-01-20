return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local langs = {
				"bash",
				"elixir",
				"erlang",
				"go",
				"graphql",
				"hcl",
				"javascript",
				"json",
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
			}

			-- keep desired parsers up to date
			require("nvim-treesitter").install(langs, { summary = true })

			local group = vim.api.nvim_create_augroup("TreesitterFeatures", {})
			vim.api.nvim_create_autocmd("FileType", {
				group = group,
				pattern = langs,
				callback = function(ev)
					vim.treesitter.start(ev.buf) -- syntax highlighting (built into Neovim)
					vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},

	{
		"neovim/nvim-lspconfig",
		dependencies = { "saghen/blink.cmp" },
		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()
			local inlay_group = vim.api.nvim_create_augroup("LspInlayHints", { clear = true })
			vim.api.nvim_create_autocmd("FileType", {
				group = inlay_group,
				pattern = { "go", "gomod" },
				callback = function(ev)
					vim.lsp.inlay_hint.enable(false, { bufnr = ev.buf })
				end,
			})
			local servers = {
				"copilot",
				"gopls",
				"graphql",
				"lua_ls",
				"pyright",
				"ruby_lsp",
				"terraformls",
				"ts_ls",
				"eslint",
			}

			for _, server in ipairs(servers) do
				vim.lsp.config(server, { capabilities = capabilities })
				vim.lsp.enable(server)
			end
		end,
	},
	-- Mason <-> LSP bridge (auto-enables servers)
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"copilot",
				"gopls",
				"graphql",
				"lua_ls",
				"pyright",
				"ruby_lsp",
				"terraformls",
				"ts_ls",
				"eslint",
			},
		},
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
	},
	{
		"ray-x/go.nvim",
		dependencies = { -- optional packages
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			-- lsp_keymaps = false,
			-- other options
		},
		config = function(_, opts)
			require("go").setup(opts)
			local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*.go",
				callback = function()
					require("go.format").goimports()
				end,
				group = format_sync_grp,
			})
		end,
		ft = { "go", "gomod" },
		build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
	},
}
