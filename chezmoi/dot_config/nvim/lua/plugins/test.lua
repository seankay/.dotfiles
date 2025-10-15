local globals = require("config.globals")

return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-neotest/nvim-nio",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"olimorris/neotest-rspec",
			"haydenmeade/neotest-jest",
		},
		opts = function()
			local status_icons = { running = "", passed = "", failed = "", skipped = "" }

			return {
				log_level = vim.log.levels.INFO,
				adapters = {
					require("neotest-rspec")({ "bundle", "exec", "rspec" }),
					require("neotest-jest")({
						jestCommand = "npm test --",
						env = { CI = true },
						jest_test_discovery = true,
					}),
				},
				quickfix = { enabled = false },
				discovery = { enabled = true },
				output = { open_on_run = "short" },
				status = { virtual_text = true, signs = true },
				icons = status_icons,
			}
		end,
		config = function(_, opts)
			require("neotest").setup(opts)
		end,
	},
}
