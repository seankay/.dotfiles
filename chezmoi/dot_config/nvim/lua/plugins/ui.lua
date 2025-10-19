return {
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
		opts = function()
			return {
				highlights = require("catppuccin.special.bufferline").get_theme(),
			}
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = function(_, opts)
			local auto = require("lualine.themes.auto")
			local colors = require("catppuccin.palettes").get_palette()

			local function separator()
				return {
					function()
						return "│"
					end,
					color = { fg = colors.surface0, bg = "NONE", gui = "bold" },
					padding = { left = 1, right = 1 },
				}
			end

			local function custom_branch()
				local gitsigns = vim.b.gitsigns_head
				local fugitive = vim.fn.exists("*FugitiveHead") == 1 and vim.fn.FugitiveHead() or ""
				local branch = gitsigns or fugitive
				if branch == nil or branch == "" then
					return ""
				else
					return " " .. branch
				end
			end

			local modes = { "normal", "insert", "visual", "replace", "command", "inactive", "terminal" }
			for _, mode in ipairs(modes) do
				if auto[mode] and auto[mode].c then
					auto[mode].c.bg = "NONE"
				end
			end

			opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
				theme = auto,
				component_separators = "",
				section_separators = "",
				globalstatus = true,
				disabled_filetypes = { statusline = {}, winbar = {} },
			})

			opts.sections = {
				lualine_a = {
					{
						"mode",
						fmt = function(str)
							return str:sub(1, 1)
						end,
						color = function()
							local mode = vim.fn.mode()
							if mode == "\22" then
								return { fg = "none", bg = colors.red, gui = "bold" }
							elseif mode == "V" then
								return { fg = colors.red, bg = "none", gui = "underline,bold" }
							else
								return { fg = colors.red, bg = "none", gui = "bold" }
							end
						end,
						padding = { left = 0, right = 0 },
					},
				},
				lualine_b = {
					separator(),
					{
						custom_branch,
						color = { fg = colors.green, bg = "none", gui = "bold" },
						padding = { left = 0, right = 0 },
					},
					{
						"diff",
						colored = true,
						diff_color = {
							added = { fg = colors.teal, bg = "none", gui = "bold" },
							modified = { fg = colors.yellow, bg = "none", gui = "bold" },
							removed = { fg = colors.red, bg = "none", gui = "bold" },
						},
						symbols = { added = "+", modified = "~", removed = "-" },
						source = nil,
						padding = { left = 1, right = 0 },
					},
				},
				lualine_c = {
					separator(),
					{
						"filetype",
						icon_only = true,
						colored = false,
						color = { fg = colors.blue, bg = "none", gui = "bold" },
						padding = { left = 0, right = 1 },
					},
					{
						"filename",
						file_status = true,
						path = 0,
						shorting_target = 20,
						symbols = {
							modified = "[+]",
							readonly = "[-]",
							unnamed = "[?]",
							newfile = "[!]",
						},
						color = { fg = colors.blue, bg = "none", gui = "bold" },
						padding = { left = 0, right = 0 },
					},
					separator(),
					{
						function()
							local bufnr_list = vim.fn.getbufinfo({ buflisted = 1 })
							local total = #bufnr_list
							local current_bufnr = vim.api.nvim_get_current_buf()
							local current_index = 0

							for i, buf in ipairs(bufnr_list) do
								if buf.bufnr == current_bufnr then
									current_index = i
									break
								end
							end

							return string.format(" %d/%d", current_index, total)
						end,
						color = { fg = colors.yellow, bg = "none", gui = "bold" },
						padding = { left = 0, right = 0 },
					},
				},
				lualine_x = {
					{
						"fileformat",
						color = { fg = colors.yellow, bg = "none", gui = "bold" },
						symbols = {
							unix = "",
							dos = "",
							mac = "",
						},
						padding = { left = 0, right = 0 },
					},
					{
						"encoding",
						color = { fg = colors.yellow, bg = "none", gui = "bold" },
						padding = { left = 1, right = 0 },
					},
					separator(),
					{
						function()
							local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
							if size < 0 then
								return "-"
							else
								if size < 1024 then
									return size .. "B"
								elseif size < 1024 * 1024 then
									return string.format("%.1fK", size / 1024)
								elseif size < 1024 * 1024 * 1024 then
									return string.format("%.1fM", size / (1024 * 1024))
								else
									return string.format("%.1fG", size / (1024 * 1024 * 1024))
								end
							end
						end,
						color = { fg = colors.blue, bg = "none", gui = "bold" },
						padding = { left = 0, right = 0 },
					},
				},
				lualine_y = {
					separator(),
					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						sections = { "error", "warn", "info", "hint" },
						diagnostics_color = {
							error = function()
								local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
								return { fg = (count == 0) and colors.green or colors.red, bg = "none", gui = "bold" }
							end,
							warn = function()
								local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
								return { fg = (count == 0) and colors.green or colors.yellow, bg = "none", gui = "bold" }
							end,
							info = function()
								local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
								return { fg = (count == 0) and colors.green or colors.blue, bg = "none", gui = "bold" }
							end,
							hint = function()
								local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
								return { fg = (count == 0) and colors.green or colors.teal, bg = "none", gui = "bold" }
							end,
						},
						symbols = {
							error = "󰅚 ",
							warn = "󰀪 ",
							info = "󰋽 ",
							hint = "󰌶 ",
						},
						colored = true,
						update_in_insert = false,
						always_visible = true,
						padding = { left = 0, right = 0 },
					},
				},
				lualine_z = {
					separator(),
					{
						"progress",
						color = { fg = colors.red, bg = "none", gui = "bold" },
						padding = { left = 0, right = 0 },
					},
					{
						"location",
						color = { fg = colors.red, bg = "none", gui = "bold" },
						padding = { left = 1, right = 0 },
					},
				},
			}
		end,
	},
	-- notifications
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
				top_down = false, -- show notification at the bottom
			}, opts))

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
