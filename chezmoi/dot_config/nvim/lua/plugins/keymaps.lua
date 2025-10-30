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
				{ "<leader>t", group = "Tests" },
				{ "<leader>f", group = "Find" },
				{ "<leader>x", group = "Diagnostics" },
				{ "<leader>r", group = "Tasks" },
				{ "<leader>b", group = "Buffer" },
				{ "<leader>a", group = "AI" },
				{ "<leader>s", group = "Spectre" },
				{ "<leader>l", group = "LSP" },
				{ "<leader>o", group = "Obsidian" },
				{ "<leader>d", group = "Debugger" },
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
					require("sidekick.cli").toggle({ name = "codex", focus = true })
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
				"<leader>at",
				function()
					require("sidekick.nes").toggle()
				end,
				desc = "Sidekick Toggle NES",
			},
			-- debugger
			{
				"<leader>dB",
				function()
					require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				desc = "Breakpoint Condition",
			},
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle Breakpoint",
			},
			{
				"<leader>dc",
				function()
					require("dap").continue()
				end,
				desc = "Run/Continue",
			},
			{
				"<leader>da",
				function()
					require("dap").continue({ before = get_args })
				end,
				desc = "Run with Args",
			},
			{
				"<leader>dC",
				function()
					require("dap").run_to_cursor()
				end,
				desc = "Run to Cursor",
			},
			{
				"<leader>dg",
				function()
					require("dap").goto_()
				end,
				desc = "Go to Line (No Execute)",
			},
			{
				"<leader>di",
				function()
					require("dap").step_into()
				end,
				desc = "Step Into",
			},
			{
				"<leader>dj",
				function()
					require("dap").down()
				end,
				desc = "Down",
			},
			{
				"<leader>dk",
				function()
					require("dap").up()
				end,
				desc = "Up",
			},
			{
				"<leader>dl",
				function()
					require("dap").run_last()
				end,
				desc = "Run Last",
			},
			{
				"<leader>do",
				function()
					require("dap").step_out()
				end,
				desc = "Step Out",
			},
			{
				"<leader>dO",
				function()
					require("dap").step_over()
				end,
				desc = "Step Over",
			},
			{
				"<leader>dP",
				function()
					require("dap").pause()
				end,
				desc = "Pause",
			},
			{
				"<leader>dr",
				function()
					require("dap").repl.toggle()
				end,
				desc = "Toggle REPL",
			},
			{
				"<leader>ds",
				function()
					require("dap").session()
				end,
				desc = "Session",
			},
			{
				"<leader>dt",
				function()
					require("dap").terminate()
				end,
				desc = "Terminate",
			},
			{
				"<leader>dw",
				function()
					require("dap.ui.widgets").hover()
				end,
				desc = "Widgets",
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

			-- files / nav
			{
				"<leader><leader>",
				"<C-^>",
				desc = "Last file",
			},
			{
				"<leader>e",
				function()
					Snacks.picker.explorer()
				end,
				desc = "Explorer",
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
				"<leader>/",
				function()
					Snacks.picker.grep()
				end,
				desc = "Grep",
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

			-- Replace: spectre
			{ "<leader>st", '<cmd>lua require("spectre").toggle()<CR>', desc = "Toggle Spectre" },
			{
				"<leader>sw",
				'<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
				desc = "Search current word",
			},
			{
				"<leader>sp",
				'<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
				desc = "Search current word in file",
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

			-- vim-rhubarb
			{
				"<leader>go",
				"<cmd>GBrowse<cr>",
				desc = "Open in GitHub (GBrowse)",
			},
			{
				"<leader>gO",
				"<cmd>GBrowse!<cr>",
				desc = "Open selection in GitHub (GBrowse!)",
				mode = { "n", "v" },
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
					neotest.summary.open()
					neotest.run.run(vim.fn.getcwd())
				end,
				desc = "Test suite)",
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
				"<cmd>:Obsidian search<cr>",
				desc = "Find File",
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
