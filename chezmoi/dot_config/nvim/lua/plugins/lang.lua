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
