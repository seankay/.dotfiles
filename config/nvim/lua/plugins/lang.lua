return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local parsers = {
				"bash",
				"elixir",
				"erlang",
				"go",
				"graphql",
				"hcl",
				"javascript",
				"jsdoc",
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

			local filetypes = vim.deepcopy(parsers)
			vim.list_extend(filetypes, { "javascriptreact", "typescriptreact" })

			-- keep desired parsers up to date
			require("nvim-treesitter").install(parsers, { summary = true })

			local group = vim.api.nvim_create_augroup("TreesitterFeatures", {})
			vim.api.nvim_create_autocmd("FileType", {
				group = group,
				pattern = filetypes,
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
}
