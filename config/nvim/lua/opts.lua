vim.o.hidden = true
vim.o.encoding = "utf-8"
vim.o.showcmd = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.foldenable = true
vim.o.backup = false
vim.o.writebackup = false
vim.o.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.o.undofile = true
vim.o.wrap = false
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true
vim.o.backspace = "indent,eol,start"
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.hlsearch = false
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.clipboard = "unnamedplus"
vim.o.history = 1000
vim.o.tabpagemax = 50
vim.o.laststatus = 2
vim.o.showmode = false
vim.signcolumn = "yes"
vim.o.conceallevel = 2
vim.o.errorbells = false
vim.o.visualbell = false
vim.o.belloff = "all"
vim.o.winborder = "rounded"
vim.o.cmdheight = 1
vim.opt.shortmess:append("c", "I")

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

--diagnostics
vim.o.updatetime = 250 -- Adjust this value to control the delay
-- vim.cmd([[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])
vim.diagnostic.config({
  virtual_text = {
    severity = { min = vim.diagnostic.severity.WARN },
    spacing = 4,
    prefix = "●",
  },
})

-- ignore fugitive buffers for lsp
local old_start = vim.lsp.start
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
