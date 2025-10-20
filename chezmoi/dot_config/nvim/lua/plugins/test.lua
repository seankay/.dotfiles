local globals = require("config.globals")

return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-neotest/nvim-nio",
			"nvim-treesitter/nvim-treesitter",
			"olimorris/neotest-rspec",
			"haydenmeade/neotest-jest",
			{
				"fredrikaverpil/neotest-golang",
				version = "*",
				build = function()
					vim.system({ "go", "install", "gotest.tools/gotestsum@latest" }):wait() -- Optional, but recommended
				end,
			},
		},
		opts = function()
			local status_icons = { running = "", passed = "", failed = "", skipped = "" }

			return {
				log_level = vim.log.levels.INFO,
				adapters = {
					require("neotest-golang")({ runner = "gotestsum" }),
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
	},
}
