return {
	-- AI assistant
	{
		"folke/sidekick.nvim",
		opts = {
			nes = { enabled = true },
			cli = {
				mux = {
					backend = "tmux",
					enabled = true,
				},
			},
		},
	},
}
