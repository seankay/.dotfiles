-- =====================================================================
-- Options
-- =====================================================================
vim.g.mapleader = "," -- leader
vim.opt.hidden = true
vim.opt.encoding = "utf-8"
vim.opt.showcmd = true
vim.opt.number = true
vim.opt.guicursor = {
	"n-v-c:block", -- Normal/Visual/Command: block cursor
	"i-ci-ve:ver25", -- Insert/Command-line Insert/Visual-ex: vertical bar (beam)
	"r-cr:hor20", -- Replace/Command-line Replace: horizontal underline
	"o:hor50", -- Operator-pending: half-height block
	"sm:block-blinkwait175-blinkoff150-blinkon175", -- showmatch
}

-- Whitespace / indent
vim.opt.wrap = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.backspace = "indent,eol,start"
vim.opt.autoindent = true
vim.opt.smartindent = true

-- Backups
vim.opt.backup = false
vim.opt.writebackup = false

-- UI / perf
vim.opt.cmdheight = 0
vim.opt.updatetime = 300
vim.opt.shortmess:append("c")

-- Search
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Clipboard
vim.opt.clipboard = "unnamedplus" -- (use 'unnamedplus' if you prefer the system clipboard explicitly)

if vim.fn.executable("wl-copy") == 1 then
	vim.g.clipboard = {
		name = "wl-clipboard",
		copy = { ["+"] = "wl-copy --type text/plain", ["*"] = "wl-copy  --type text/plain" },
		paste = { ["+"] = "wl-paste --no-newline", ["*"] = "wl-paste --no-newline" },
	}
elseif vim.loop.os_uname().sysname == "Darwin" then
	vim.g.clipboard = {
		name = "pbcopy",
		copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
		paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
	}
end

-- Scrolling
vim.opt.scrolloff = 1
vim.opt.sidescrolloff = 5
vim.opt.display:append("lastline")

-- History / tabs
vim.opt.history = 1000
vim.opt.tabpagemax = 50

-- Colors / truecolor
if vim.fn.has("termguicolors") == 1 then
	vim.opt.termguicolors = true
end

-- Statusline
vim.opt.laststatus = 2
vim.opt.showmode = false

-- Signcolumn
vim.signcolumn = "yes"

-- Disable all bells (no beep, no screen flash)
vim.opt.errorbells = false
vim.opt.visualbell = false
vim.opt.belloff = "all"

-- relative numbers / absolute for cursor line
vim.wo.number = true
vim.wo.relativenumber = true

-- enable folding
vim.opt.foldenable = true
