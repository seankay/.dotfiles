-- =====================================================================
-- Bootstrap: lazy.nvim
-- =====================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("config.options")
-- =====================================================================
-- Plugins (lazy.nvim)
-- =====================================================================
require("lazy").setup({
	-- automatically check for plugin updates
	checker = { enabled = true },
	install = { colorscheme = { "catppuccin-mocha" } },
	spec = {
		-- import your plugins
		{ import = "plugins" },
	},
})

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
