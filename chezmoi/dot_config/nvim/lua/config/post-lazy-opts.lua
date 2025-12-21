-- =====================================================================
-- Non which-key Keymaps. Load after Lazy
-- =====================================================================
local map = vim.keymap.set

-- exit insert with jj
map("i", "jj", "<Esc>")

-- %% -> expand current dir in cmdline
vim.keymap.set("c", "%%", function()
	return vim.fn.expand("%:h") .. "/"
end, { expr = true })

-- Typos
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Q", "q", {})
vim.api.nvim_create_user_command("Wq", "wq", {})
vim.api.nvim_create_user_command("WQ", "wq", {})

-- =====================================================================
-- options
-- =====================================================================
vim.o.conceallevel = 2

local old_start = vim.lsp.start
-- ignore fugitive buffers for lsp
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.start = function(...)
	local _, opt = unpack({ ... })
	if opt and opt.bufnr then
		if vim.b[opt.bufnr].fugitive_type then
			return
		end
	end
	old_start(...)
end

-- =====================================================================
-- Misc Autocommands
-- =====================================================================
-- highlight yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	pattern = "*",
	desc = "highlight selection on yank",
	callback = function()
		vim.highlight.on_yank({ timeout = 200, visual = true })
	end,
})

-- restore cursor to file position in previous editing session
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(args)
		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(args.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			vim.api.nvim_win_set_cursor(0, mark)
			-- defer centering slightly so it's applied after render
			vim.schedule(function()
				vim.cmd("normal! zz")
			end)
		end
	end,
})

-- open help in vertical split
vim.api.nvim_create_autocmd("FileType", {
	pattern = "help",
	command = "wincmd L",
})

-- auto resize splits when the terminal's window is resized
vim.api.nvim_create_autocmd("VimResized", {
	command = "wincmd =",
})

-- no auto continue comments on new line
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("no_auto_comment", {}),
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- show cursorline only in active window enable
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
	group = vim.api.nvim_create_augroup("active_cursorline", { clear = true }),
	callback = function()
		vim.opt_local.cursorline = true
	end,
})

-- show cursorline only in active window disable
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
	group = "active_cursorline",
	callback = function()
		vim.opt_local.cursorline = false
	end,
})
-- =====================================================================
-- LOAD LAST:
--  * make cursor white
--  * put this *after* you load colorscheme
-- =====================================================================
local function set_cursor_white()
	vim.api.nvim_set_hl(0, "Cursor", { fg = "#1b1e2b", bg = "#ffffff" })
	vim.api.nvim_set_hl(0, "iCursor", { fg = "#1b1e2b", bg = "#eeeeee" })
end

set_cursor_white()
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = set_cursor_white,
})
