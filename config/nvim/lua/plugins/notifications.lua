return {
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = function(_, opts)
			-- needed to allow for neovim transparency without warning
			require("notify").setup(vim.tbl_extend("keep", {
				background_colour = "#000000",
			}, opts))

			local function map_noice_scroll(lhs, delta)
				vim.keymap.set({ "n", "i", "s" }, lhs, function()
					local ok, lsp = pcall(require, "noice.lsp")
					if ok and lsp.scroll(delta) then
						return ""
					end
					return lhs
				end, { silent = true, expr = true, desc = "Scroll Noice floating window" })
			end

			map_noice_scroll("<C-f>", 4)
			map_noice_scroll("<C-b>", -4)

			return {
				lsp = {
					-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
					},
					progress = {
						enabled = true,
					},
					message = {
						enabled = true,
					},
					hover = {
						enabled = true,
					},
					signature = {
						enabled = true,
					},
				},
				routes = {
					{
						filter = {
							event = "msg_show",
							kind = "",
							find = "test",
						},
						opts = { skip = false }, -- allow test messages to be shown
					},
				},
				presets = {
					bottom_search = true, -- use a classic bottom cmdline for search
					command_palette = true, -- position the cmdline and popupmenu together
					long_message_to_split = true, -- long messages will be sent to a split
					inc_rename = false, -- enables an input dialog for inc-rename.nvim
					lsp_doc_border = false, -- add a border to hover docs and signature help
				},
			}
		end,
	},
}
