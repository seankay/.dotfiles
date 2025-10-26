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
-- LOAD LAST:
--  * make cursor white
--  * put this *after* you load material.nvim
-- =====================================================================
local function set_cursor_white()
	vim.api.nvim_set_hl(0, "Cursor", { fg = "#1b1e2b", bg = "#ffffff" })
	vim.api.nvim_set_hl(0, "iCursor", { fg = "#1b1e2b", bg = "#eeeeee" })
end

set_cursor_white()
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = set_cursor_white,
})
