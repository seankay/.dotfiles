vim.o.hidden = true -- allow switching buffers with unsaved changes
vim.o.encoding = "utf-8" -- default string encoding
vim.o.showcmd = true -- show partial command in the last line
vim.o.number = true -- show absolute line numbers
vim.o.relativenumber = true -- show relative line numbers
vim.o.foldenable = true -- enable code folding
vim.o.backup = false -- disable backup file creation
vim.o.writebackup = false -- disable backup before overwriting
vim.o.undodir = os.getenv("HOME") .. "/.vim/undodir" -- persistent undo directory
vim.o.undofile = true -- enable persistent undo
vim.o.wrap = false -- do not wrap long lines
vim.o.tabstop = 2 -- number of spaces per tab
vim.o.shiftwidth = 2 -- indentation width for >> and <<
vim.o.softtabstop = 2 -- spaces per Tab in insert mode
vim.o.expandtab = true -- use spaces instead of tabs
vim.o.backspace = "indent,eol,start" -- allow backspace over indent/eol/start
vim.o.autoindent = true -- copy indent from current line
vim.o.smartindent = true -- smarter auto indentation
vim.o.hlsearch = true -- highlight search matches
vim.o.incsearch = true -- show matches while typing search
vim.o.ignorecase = true -- ignore case in search patterns
vim.o.smartcase = true -- override ignorecase if uppercase present
vim.o.clipboard = "unnamedplus" -- use system clipboard
vim.o.history = 1000 -- command/history length
vim.o.tabpagemax = 50 -- maximum number of tab pages
vim.o.laststatus = 2 -- always show statusline
vim.o.showmode = false -- do not show mode in command line
vim.signcolumn = "yes" -- always show the sign column
vim.o.conceallevel = 2 -- conceal text with syntax conceal
vim.o.errorbells = false -- disable error bells
vim.o.visualbell = false -- disable visual bell
vim.o.belloff = "all" -- disable all bell events
vim.o.winborder = "rounded" -- rounded borders for floating windows
vim.o.cmdheight = 1 -- command line height
vim.opt.shortmess:append("c", "I") -- shorten messages; no intro screen
vim.opt.fillchars = {
  fold = ' ', -- blank fold filler
  diff = '╱', -- diff filler
  wbr = '─', -- word break symbol
  msgsep = '─', -- message separator
  horiz = '─', -- horizontal window separator
  horizup = '│', -- up-facing horizontal separator
  horizdown = '│', -- down-facing horizontal separator
  vertright = '│', -- right-facing vertical separator
  vertleft = '│', -- left-facing vertical separator
  verthoriz = '│', -- vertical/horizontal junction
}

-- Colors / truecolor
if vim.fn.has("termguicolors") == 1 then
  vim.opt.termguicolors = true
end

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

-- highlight yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  pattern = "*",
  desc = "highlight selection on yank",
  callback = function()
    vim.highlight.on_yank({ timeout = 200, visual = true })
  end,
})

-- auto resize splits when the terminal's window is resized
vim.api.nvim_create_autocmd("VimResized", {
  command = "wincmd =",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  desc = "enable wrapping in quickfix buffers",
  callback = function()
    vim.opt_local.wrap = true
  end,
})
