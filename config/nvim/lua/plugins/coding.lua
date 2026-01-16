return {
	{ "tpope/vim-endwise" },
	{ "nvim-mini/mini.comment", version = "*", opts = {} },
	{
		"nvim-mini/mini.surround",
		version = "*",
		opts = {
			mappings = {
				add = "ys",
				delete = "ds",
				replace = "cs",

				find = "",
				find_left = "",
				highlight = "",
				update_n_lines = "",
				suffix_last = "l",
				suffix_next = "n",
			},
		},
		config = function(_, opts)
			require("mini.surround").setup(opts)

			vim.keymap.set("n", "yss", function()
				vim.cmd.normal({ args = { "0v$h" }, bang = true })
				vim.cmd.normal({ args = { "S" }, bang = true })
			end, { desc = "Surround line" })

			vim.keymap.set("x", "gS", "S", { remap = true, desc = "Surround (block-style alias)" })
		end,
	},
	{
		"saghen/blink.cmp",
		-- optional: provides snippets for the snippet source
		dependencies = { "rafamadriz/friendly-snippets" },

		version = "1.*",
		opts = {
			keymap = { preset = "super-tab" },

			appearance = {
				nerd_font_variant = "mono",
			},

			completion = { documentation = { auto_show = false } },

			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						-- make lazydev completions top priority (see `:h blink.cmp`)
						score_offset = 100,
					},
				},
			},

			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
		opts_extend = { "sources.default" },
	},
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
	{
		"mfussenegger/nvim-lint",
		opts = {
			events = { "BufWritePost", "BufReadPost", "InsertLeave" },
			linters_by_ft = {
				ruby = { "rubocop" },
				javascript = { "eslint_d" },
				typescript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				typescriptreact = { "eslint_d" },
				go = { "golangcilint" },
			},
		},
		config = function(_, opts)
			local lint = require("lint")
			lint.linters_by_ft = opts.linters_by_ft or {}

			-- Force eslint_d to run with CI=true and strip noisy prefix lines before JSON parse
			if lint.linters.eslint_d then
				local eslint_parser = lint.linters.eslint.parser
				local eslint_d = lint.linters.eslint_d
				if type(eslint_d) == "function" then
					eslint_d = eslint_d()
				end
				lint.linters.eslint_d = vim.tbl_extend("force", eslint_d, {
					env = { CI = "true" },
					parser = function(output, bufnr, linter_cwd)
						-- Remove any "Processing ..." log lines that eslint_d may emit to stdout
						local cleaned = output:match("[%[{].*") or ""
						return eslint_parser(cleaned, bufnr, linter_cwd)
					end,
				})
			end

			local group = vim.api.nvim_create_augroup("nvim-lint-autocmds", { clear = true })

			vim.api.nvim_create_autocmd(opts.events or { "BufWritePost" }, {
				group = group,
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},

	{
		"stevearc/conform.nvim",
		opts = {
			format_on_save = {
				timeout_ms = 1500,
				lsp_format = "fallback",
			},
			formatters_by_ft = {
				css = { "prettierd" },
				go = { "gofumpt", "golines", "goimports" },
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
