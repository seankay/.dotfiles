return {
	-- make blink.cmp work with copilot.lua
	{ "fang2hou/blink-copilot", opts = {} },
	-- AI assistant
	{
		"folke/sidekick.nvim",
		opts = {
			nes = { enabled = false },
			cli = {
				mux = {
					backend = "tmux",
					enabled = true,
				},
			},
		},
	},
}
