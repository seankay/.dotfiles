return {
	-- LINTING
	{
		"mfussenegger/nvim-lint",
		opts = {
			events = { "BufWritePost", "BufReadPost", "InsertLeave" },
			linters_by_ft = {
				ruby = { "rubocop" },
				javascript = { "eslint_d" },
				typescript = { "eslint_d" },
				javascriptreact = { "eslint_d" }, -- fixed spelling
				typescriptreact = { "eslint_d" },
				go = { "golangcilint" },
			},
		},
		config = function(_, opts)
			local lint = require("lint")
			-- apply opts
			lint.linters_by_ft = opts.linters_by_ft or {}

			-- run on desired events
			local group = vim.api.nvim_create_augroup("nvim-lint-autocmds", { clear = true })
			vim.api.nvim_create_autocmd(opts.events or { "BufWritePost" }, {
				group = group,
				callback = function()
					-- try filetype linters first, then fallback to any available linters
					lint.try_lint()
				end,
			})
		end,
	},

	-- FORMATTING
	{
		"stevearc/conform.nvim",
		opts = {
			format_on_save = {
				timeout_ms = 1500,
				lsp_format = "fallback",
			},
			formatters_by_ft = {
				css = { "prettierd" },
				go = { "gofmt", "goimports" },
				html = { "prettierd" },
				javascript = { "prettierd" },
				javascriptreact = { "prettierd" },
				json = { "prettierd" },
				lua = { "stylua" },
				markdown = { "prettierd" },
				python = { "black" },
				ruby = { "rubocop" },
				scss = { "prettierd" },
				typescript = { "prettierd" },
				typescriptreact = { "prettierd" },
				yaml = { "prettierd" },
			},
		},
		config = function(_, opts)
			opts.log_level = vim.log.levels.DEBUG
			require("conform").setup(opts)
			-- optional, but recommended so motions use Conform when formatting:
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
	},
}
