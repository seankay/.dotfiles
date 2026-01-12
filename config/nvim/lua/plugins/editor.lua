return {
	{ "folke/trouble.nvim", opts = {}, cmd = "Trouble" },
	{
		"nvim-pack/nvim-spectre",
		opts = {},
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			bigfile = { enabled = true },
			indent = { enabled = true },
			quickfile = { enabled = true },
			scope = { enabled = true },
			scroll = { enabled = true },
			words = { enabled = true },
			explorer = { enabled = true },
			picker = {
				enabled = true,
				ignored = true,
				exclude = {
					"**/.git/*",
					"node_modules",
					".next",
					".turbo",
				},
				sources = {
					files = {
						exclude = {
							"**/.git/*",
							"node_modules",
						},
					},
					explorer = {
						exclude = {
							"**/.git/*",
							"node_modules",
						},

						win = {
							list = {
								keys = {
									["<c-p>"] = "toggle_focus",
								},
							},
						},
					},
				},
			},
			dashboard = {
				enabled = true,
				sections = {
					{ section = "keys", gap = 1, padding = 1 },
					{
						icon = " ",
						desc = "Browse Repo",
						padding = 1,
						key = "b",
						action = function()
							Snacks.gitbrowse()
						end,
					},
					function()
						local in_git = Snacks.git.get_root() ~= nil
						local cmds = {
							{
								icon = " ",
								title = "Git Status",
								cmd = "git --no-pager diff --stat -B -M -C",
								height = 6,
							},
						}
						return vim.tbl_map(function(cmd)
							return vim.tbl_extend("force", {
								section = "terminal",
								enabled = in_git,
								padding = 1,
								ttl = 5 * 60,
								indent = 3,
							}, cmd)
						end, cmds)
					end,
					{ section = "startup" },
				},
			},
		},

		image = { enabled = false },
		statuscolumn = { enabled = false },
		notifier = { enabled = false },
		terminal = { enabled = false },
		notify = { enabled = false },
		input = { enabled = false },
		gh = { enable = false },
	},
}
