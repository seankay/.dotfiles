return {
	{ "tpope/vim-endwise" },
	{ "nvim-mini/mini.comment", version = "*", opts = {} },
	{ "nvim-mini/mini.pairs", version = "*", opts = {} },
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
}
