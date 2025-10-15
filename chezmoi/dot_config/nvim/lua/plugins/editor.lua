return {
	{ "folke/trouble.nvim", opts = {}, cmd = "Trouble" },
	{ "lewis6991/gitsigns.nvim" },
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
			image = { enabled = true },
			picker = {
				enabled = true,
				exclude = {
					"**/.git/*",
				},
				sources = {
					files = {
						hidden = true,
						exclude = {
							"**/.git/*",
						},
					},
					explorer = {
						hidden = true,
						exclude = {
							"**/.git/*",
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
					{
						section = "terminal",
						cmd = "colorscripts-squares",
						height = 5,
						padding = 1,
					},
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
							{
								title = "Notifications",
								cmd = "gh notify -s -a -n5",
								action = function()
									vim.ui.open("https://github.com/notifications")
								end,
								key = "n",
								icon = " ",
								height = 5,
								enabled = true,
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

		input = { enabled = false },
		statuscolumn = { enabled = false },
		notifier = { enabled = false },
		terminal = { enabled = false },
		notify = { enabled = false },
	},
}
