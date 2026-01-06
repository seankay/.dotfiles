return {
	{ "tpope/vim-endwise" },
	{ "nvim-mini/mini.comment", version = "*", opts = {} },
	{
		"nvim-mini/mini.surround",
		version = "*",
		opts = {
			-- Remap core actions to vim-surround keys
			mappings = {
				add = "ys", -- add surroundings:  ys{motion}{char}
				delete = "ds", -- delete surroundings: ds{char}
				replace = "cs", -- change surroundings: cs{old}{new}

				-- Disable extras you don't use / to avoid conflicts
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

			-- yss : surround current line (like vim-surround)
			-- Select the line then reuse visual 'S' from mini.surround
			vim.keymap.set("n", "yss", function()
				-- From first nonblank to end-of-line (minus trailing newline)
				vim.cmd.normal({ args = { "0v$h" }, bang = true })
				vim.cmd.normal({ args = { "S" }, bang = true })
			end, { desc = "Surround line" })

			-- Visual mode: keep 'S' to surround selection (matches vim-surround)
			-- mini.surround already maps 'S' in Visual by default.
			-- For 'gS' (block-style in vim-surround), just alias to S (closest behavior).
			vim.keymap.set("x", "gS", "S", { remap = true, desc = "Surround (block-style alias)" })
		end,
	},
	{
		"saghen/blink.cmp",
		-- optional: provides snippets for the snippet source
		dependencies = { "rafamadriz/friendly-snippets" },

		-- use a release tag to download pre-built binaries
		version = "1.*",
		-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
		-- build = 'cargo build --release',
		opts = {
			-- See :h blink-cmp-config-keymap for defining your own keymap
			keymap = { preset = "super-tab" },

			appearance = {
				nerd_font_variant = "mono",
			},

			-- (Default) Only show the documentation popup when manually triggered
			completion = { documentation = { auto_show = false } },

			-- Default list of enabled providers defined so that you can extend it
			-- elsewhere in your config, without redefining it, due to `opts_extend`
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

			-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
			-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
			-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
			--
			-- See the fuzzy documentation for more information
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
				lint.linters.eslint_d = vim.tbl_extend("force", lint.linters.eslint_d, {
					env = { CI = "true" },
					parser = function(output, bufnr)
						-- Remove any "Processing ..." log lines that eslint_d may emit to stdout
						local cleaned = output:match("[%[{].*") or ""
						return eslint_parser(cleaned, bufnr)
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

	{
		"neovim/nvim-lspconfig",
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
}
