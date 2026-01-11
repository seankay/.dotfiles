return { -- which-key: discoverable keymaps for your current setup
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "helix", -- vertical menu on the right
			win = {
				border = "rounded",
				no_overlap = true,
				col = math.huge,
				row = math.huge,
			},
			layout = {
				width = { min = 20, max = 50 },
				spacing = 1,
				align = "left",
			},
			spec = {
				{ "<leader>g", group = "Git" },
				{ "<leader>t", group = "Tests", icon = "󰙨" },
				{ "<leader>f", group = "Find" },
				{ "<leader>x", group = "Diagnostics" },
				{ "<leader>r", group = "Tasks" },
				{ "<leader>b", group = "Buffer" },
				{ "<leader>a", group = "AI" },
				{ "<leader>l", group = "LSP", icon = "󰲽" },
				{ "<leader>o", group = "Obsidian", icon = "" },
				{ "<leader>d", group = "Debugger" },
				{
					"<leader>e",
					function()
						Snacks.explorer()
					end,
					icon = "󰥨",
					desc = "Explore",
				},
				{
					"<leader>/",
					function()
						Snacks.picker.grep()
					end,
					icon = "󱎸",
					desc = "Grep",
				},
			},
		},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)

			-- === ZoomToggle helper ===
			local zoom = { zoomed = false, winrestcmd = nil }
			function _G.ZoomToggle()
				if zoom.zoomed and zoom.winrestcmd then
					vim.cmd(zoom.winrestcmd)
					zoom.zoomed = false
				else
					zoom.winrestcmd = vim.fn.winrestcmd()
					vim.cmd("resize")
					vim.cmd("vertical resize")
					zoom.zoomed = true
				end
			end

			vim.api.nvim_create_user_command("ZoomToggle", ZoomToggle, {})

			-- === TrimWhitespace autocmds ===
			local function trim_ws()
				local view = vim.fn.winsaveview()
				vim.cmd([[%s/\s\+$//e]])
				vim.fn.winrestview(view)
			end
			vim.api.nvim_create_autocmd(
				{ "FileWritePre", "FileAppendPre", "FilterWritePre", "BufWritePre" },
				{ callback = trim_ws }
			)
		end,
		keys = {
			--ai
			{
				"<tab>",
				function()
					-- if there is a next edit, jump to it, otherwise apply it if any
					if not require("sidekick").nes_jump_or_apply() then
						return "<Tab>" -- fallback to normal tab
					end
				end,
				expr = true,
				desc = "Goto/Apply Next Edit Suggestion",
			},
			{
				"<c-.>",
				function()
					require("sidekick.cli").focus()
				end,
				mode = { "n", "x", "i", "t" },
				desc = "Sidekick Switch Focus",
			},
			{
				"<leader>aa",
				function()
					require("sidekick.cli").toggle({ name = "opencode", focus = true })
				end,
				desc = "Sidekick Toggle CLI",
				mode = { "n", "v" },
			},
			{
				"<leader>ac",
				function()
					require("sidekick.nes").clear()
				end,
				desc = "Sidekick Clear NES",
				mode = { "n", "v" },
			},
			{
				"<leader>an",
				function()
					require("sidekick.nes").toggle()
				end,
				desc = "Sidekick Toggle NES",
			},
			{
				"<leader>at",
				function()
					require("sidekick.cli").send({ msg = "{this}" })
				end,
				mode = { "x", "n" },
				desc = "Send This",
			},
			{
				"<leader>af",
				function()
					require("sidekick.cli").send({ msg = "{file}" })
				end,
				desc = "Send File",
			},
			{
				"<leader>av",
				function()
					require("sidekick.cli").send({ msg = "{selection}" })
				end,
				mode = { "x" },
				desc = "Send Visual Selection",
			},
			{
				"<leader>ap",
				function()
					require("sidekick.cli").prompt()
				end,
				mode = { "n", "x" },
				desc = "Sidekick Select Prompt",
			},
			-- buffers
			{
				"H",
				"<cmd>BufferLineCyclePrev<cr>",
				desc = "Previous buffer",
				mode = "n",
			},
			{
				"L",
				"<cmd>BufferLineCycleNext<cr>",
				desc = "Next buffer",
				mode = "n",
			},
			--Windows
			-- Split windows
			{
				"<leader>-",
				"<C-w>s",
				desc = "Split window horizontally",
				mode = "n",
			},
			{
				"<leader>\\",
				"<C-w>v",
				desc = "Split window vertically",
				mode = "n",
			},

			-- Buffer operations
			{
				"<leader>bb",
				"<cmd>buffer #<cr>",
				desc = "Switch to alternate buffer",
				mode = "n",
			},
			{
				"<leader>bd",
				"<cmd>bdelete<cr>",
				desc = "Delete current buffer",
				mode = "n",
			},
			{
				"<leader>bo",
				"<cmd>%bdelete|edit#|bdelete#<cr>",
				desc = "Delete other buffers",
				mode = "n",
			},
			{
				"<leader>ba",
				"<cmd>bufdo bdelete<cr>",
				desc = "Delete all buffers",
				mode = "n",
			},

			{
				"<leader>bn",
				"<cmd>bnext<cr>",
				desc = "Next buffer",
				mode = "n",
			},
			{
				"<leader>bp",
				"<cmd>bprevious<cr>",
				desc = "Previous buffer",
				mode = "n",
			},

			-- If using bufferline.nvim
			{
				"<leader>bl",
				"<cmd>BufferLinePick<cr>",
				desc = "Pick buffer",
				mode = "n",
			},
			{
				"<leader>bp",
				"<cmd>BufferLineTogglePin<cr>",
				desc = "Toggle pin",
				mode = "n",
			},
			{
				"<leader>bP",
				"<cmd>BufferLineGroupClose ungrouped<cr>",
				desc = "Close unpinned",
				mode = "n",
			},
			{
				"<leader>bN",
				"<cmd>new<cr>",
				desc = "New buffer",
				mode = "n",
			},

			-- files / nav
			{
				"<leader><leader>",
				"<C-^>",
				desc = "Last file",
			},

			-- LSP
			{
				"gd",
				function()
					Snacks.picker.lsp_definitions()
				end,
				desc = "Goto Definition",
			},
			{
				"gD",
				function()
					Snacks.picker.lsp_declarations()
				end,
				desc = "Goto Declaration",
			},
			{
				"gr",
				function()
					Snacks.picker.lsp_references()
				end,
				nowait = true,
				desc = "References",
			},
			{
				"gI",
				function()
					Snacks.picker.lsp_implementations()
				end,
				desc = "Goto Implementation",
			},
			{
				"gy",
				function()
					Snacks.picker.lsp_type_definitions()
				end,
				desc = "Goto T[y]pe Definition",
			},
			{
				"<leader>ls",
				function()
					Snacks.picker.lsp_symbols()
				end,
				desc = "LSP Symbols",
			},
			{
				"<leader>lS",
				function()
					Snacks.picker.lsp_workspace_symbols()
				end,
				desc = "LSP Workspace Symbols",
			},

			-- Find: Snacks.picker / ctrl-p
			{
				"<C-p>",
				function()
					Snacks.picker.smart()
				end,
				desc = "Smart Find files",
			},
			{
				"<leader>fb",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Find Buffers",
			},
			{
				"<leader>ff",
				function()
					Snacks.picker.files()
				end,
				desc = "Find Files",
			},
			{
				"<leader>fw",
				function()
					Snacks.picker.grep_word()
				end,
				desc = "Find Word",
				mode = { "n", "x" },
			},
			{
				"<leader>fu",
				function()
					Snacks.picker.undo()
				end,
				desc = "Undo History",
			},
			{
				"<leader>fk",
				function()
					Snacks.picker.keymaps()
				end,
				desc = "Find Keymap",
				mode = { "n", "x" },
			},

			-- diagnostics
			{
				"<leader>xn",
				function()
					vim.diagnostic.jump({ count = 1, float = true })
				end,
				desc = "Next diagnostic",
			},
			{
				"<leader>xp",
				function()
					vim.diagnostic.jump({ count = -1, float = true })
				end,
				desc = "Prev diagnostic",
			},
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>xcl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},

			-- Git
			-- vim-fugitive
			{
				"<leader>gs",
				"<cmd>Git<cr>",
				desc = "Git status (Fugitive)",
			},
			{
				"<leader>gb",
				"<cmd>Git blame<cr>",
				desc = "Git blame (Fugitive)",
			},
			{
				"<leader>gd",
				"<cmd>Gvdiffsplit<cr>",
				desc = "Git diff (Fugitive)",
			},
			{ "<leader>gP", "<cmd>Git push<cr>", desc = "Git push" },
			{ "<leader>gF", "<cmd>Git pull<cr>", desc = "Git pull" },
			{ "<leader>gl", "<cmd>Git log<cr>", desc = "Git log" },

			{
				"<leader>go",
				"<cmd>GBrowse<cr>",
				desc = "Open in GitHub (GBrowse)",
				mode = "n",
			},
			{
				"<leader>go",
				":GBrowse<cr>",
				desc = "Open in GitHub (GBrowse)",
				mode = "x",
			},

			-- gitsigns.nvim
			{
				"<leader>g[",
				function()
					require("gitsigns").nav_hunk("prev")
				end,
				desc = "Next Git hunk",
			},
			{
				"<leader>g]",
				function()
					require("gitsigns").nav_hunk("next")
				end,
				desc = "Prev Git hunk",
			},
			{
				"<leader>gp",
				function()
					require("gitsigns").preview_hunk()
				end,
				desc = "Preview hunk",
			},
			{
				"<leader>gr",
				function()
					require("gitsigns").reset_hunk()
				end,
				desc = "Reset hunk",
			},
			{
				"<leader>gR",
				function()
					require("gitsigns").reset_buffer()
				end,
				desc = "Reset buffer",
			},
			{
				"<leader>gs",
				function()
					require("gitsigns").stage_hunk()
				end,
				desc = "[Un]stage hunk",
			},
			{
				"<leader>gS",
				function()
					require("gitsigns").stage_buffer()
				end,
				desc = "Stage buffer",
			},
			{
				"<leader>gd",
				function()
					require("gitsigns").diffthis()
				end,
				desc = "Git diff against index",
			},

			-- Tests (neotest)
			{
				"<leader>tt",
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				desc = "Test file",
			},
			{
				"<leader>tr",
				function()
					require("neotest").run.run()
				end,
				desc = "Test nearest",
			},
			{
				"<leader>tl",
				function()
					require("neotest").run.run_last()
				end,
				desc = "Test last",
			},
			{
				"<leader>ta",
				function()
					local neotest = require("neotest")
					neotest.run.run({ suite = true })
					neotest.summary.open()
				end,
				desc = "Test suite",
			},
			{
				"<leader>to",
				function()
					require("neotest").output_panel.toggle()
				end,
				desc = "Toggle output panel",
			},
			{
				"<leader>tw",
				function()
					require("neotest").watch.toggle(vim.fn.expand("%"))
				end,
				desc = "Watch file",
			},
			{
				"<leader>tx",
				function()
					require("neotest").run.stop()
				end,
				desc = "Stop",
			},
			{
				"<leader>ts",
				function()
					require("neotest").summary.toggle()
				end,
				desc = "Summary",
			},

			-- Obsidian
			{
				"<leader>oo",
				":split | Obsidian new TODO<cr>",
				desc = "Open TODO",
			},
			{
				"<leader>of",
				"<cmd>:Obsidian quick_switch<cr>",
				desc = "Find File",
			},
			{
				"<leader>og",
				"<cmd>:Obsidian search<cr>",
				desc = "Grep",
			},
			{
				"<leader>on",
				"<cmd>:Obsidian new<cr>",
				desc = "New File",
			},

			-- zoom
			{
				"<C-w>z",
				"<cmd>ZoomToggle<cr>",
				desc = "Toggle Zoom",
			},
		},
	},
}
