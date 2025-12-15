return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = function(_, opts)
			local auto = require("lualine.themes.auto")
			local colors = require("catppuccin.palettes").get_palette()
			local bg = require("catppuccin.utils.colors").darken(colors.surface0, 0.25, colors.base)

			local function separator()
				return {
					function()
						return "│"
					end,
					color = { fg = colors.surface0, bg = bg, gui = "bold" },
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
					auto[mode].c.bg = bg
				end
			end

			opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
				theme = auto,
				component_separators = "",
				section_separators = "",
				globalstatus = true,
				disabled_filetypes = { statusline = {} },
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
								return { fg = "none", bg = colors.blue, gui = "bold" }
							elseif mode == "V" then
								return { fg = colors.blue, bg = bg, gui = "underline,bold" }
							else
								return { fg = colors.blue, bg = bg, gui = "bold" }
							end
						end,
						padding = { left = 1, right = 1 },
					},
					{
						require("noice").api.status.command.get,
						color = { fg = colors.blue, bg = bg },
					},
					{
						function()
							local mode = "[" .. require("noice").api.status.mode.get() .. "]"
							return mode
						end,
						cond = require("noice").api.status.mode.has,
						color = { fg = colors.yellow, bg = bg },
					},
					{
						require("noice").api.status.search.get,
						cond = require("noice").api.status.search.has,
						color = { fg = colors.yellow, bg = bg },
					},
				},
				lualine_b = {
					separator(),
					{
						custom_branch,
						color = { fg = colors.green, bg = bg, gui = "bold" },
						padding = { left = 0, right = 0 },
					},
					{
						"diff",
						colored = true,
						diff_color = {
							added = { fg = colors.teal, bg = bg, gui = "bold" },
							modified = { fg = colors.yellow, bg = bg, gui = "bold" },
							removed = { fg = colors.red, bg = bg, gui = "bold" },
						},
						symbols = { added = "+", modified = "~", removed = "-" },
						source = nil,
						padding = { left = 1, right = 0 },
					},
				},
				lualine_c = {
					separator(),
					{
						function()
							local msg = " No Active Lsp"
							local text_clients = ""

							local clients = vim.lsp.get_clients({ bufnr = 0 })
							if next(clients) == nil then
								return msg
							end
							for _, client in ipairs(clients) do
								if client.name ~= "copilot" then
									text_clients = text_clients .. client.name .. ", "
								end
							end
							if text_clients ~= "" then
								return text_clients:sub(1, -3)
							end
							return msg
						end,
						icons_enabled = true,
						icon = "",
						color = { fg = colors.blue },
						padding = { left = 1 },
					},
					separator(),
					{
						"filename",
						file_status = true,
						path = 1,
					},
					separator(),
					{
						function()
							return require("dap").status()
						end,
						icon = { "", color = { fg = colors.red } },
						cond = function()
							if not package.loaded.dap then
								return false
							end
							local session = require("dap").session()
							return session ~= nil
						end,
					},
				},
				lualine_x = {
					{
						function()
							local status = require("sidekick.status").get()
							local nes_enabled = require("sidekick.nes").enabled
							if not status then
								return ""
							elseif status.kind == "Error" then
								return ""
							elseif not nes_enabled then
								return ""
							elseif status.busy then
								return ""
							else
								return ""
							end
						end,
						color = function()
							local status = require("sidekick.status").get()
							local nes_edits = require("sidekick.nes").have()
							local nes_enabled = require("sidekick.nes").enabled

							if status then
								if not status.kind == "Error" then
									return { fg = colors.red }
								end

								if status.busy then
									return { fg = colors.yellow }
								end
							end

							if not nes_enabled then
								return { fg = colors.text }
							end

							if nes_edits then
								return { fg = colors.yellow }
							end

							return { fg = colors.blue }
						end,
						cond = function()
							local status = require("sidekick.status")
							return status.get() ~= nil
						end,
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
								return { fg = (count == 0) and colors.green or colors.red, bg = bg, gui = "bold" }
							end,
							warn = function()
								local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
								return { fg = (count == 0) and colors.green or colors.yellow, bg = bg, gui = "bold" }
							end,
							info = function()
								local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
								return { fg = (count == 0) and colors.green or colors.blue, bg = bg, gui = "bold" }
							end,
							hint = function()
								local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
								return { fg = (count == 0) and colors.green or colors.teal, bg = bg, gui = "bold" }
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
						color = { fg = colors.blue, bg = bg, gui = "bold" },
						padding = { left = 0, right = 0 },
					},
					{
						"location",
						color = { fg = colors.blue, bg = bg, gui = "bold" },
						padding = { left = 1, right = 1 },
					},
					{
						require("lazy.status").updates,
						cond = require("lazy.status").has_updates,
						padding = { left = 1, right = 1 },
						color = { fg = colors.yellow, bg = bg },
					},
				},
			}
		end,
	},
}
