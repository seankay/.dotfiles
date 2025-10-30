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
			{
				"fredrikaverpil/neotest-golang",
				version = "*",
			},
		},
		opts = function()
			local status_icons = { running = "", passed = "", failed = "", skipped = "" }

			return {
				log_level = vim.log.levels.INFO,
				adapters = {
					require("neotest-golang")({}),
					require("neotest-rspec")({ "bundle", "exec", "rspec" }),
					require("neotest-jest")({
						jestCommand = "npm test --",
						env = { CI = true },
						jest_test_discovery = true,
					}),
				},
				quickfix = {
					open = function()
						vim.cmd("Trouble quickfix")
					end,
					enabled = true,
				},
				discovery = { enabled = true },
				output = { open_on_run = "short" },
				status = { virtual_text = false, signs = true },
				icons = status_icons,
			}
		end,
	},
}
