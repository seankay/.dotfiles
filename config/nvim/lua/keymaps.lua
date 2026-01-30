-- Keymaps
vim.g.mapleader = " " -- init before mappings
local map = vim.keymap.set

map("i", "jj", "<Esc>")
map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")
map("n", "<leader>e", ":Oil<CR>")
map("n", "<leader>W", "<cmd>wall<cr>")
map("n", "<leader>Q", "<cmd>qall<cr>")
-- visual move
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")
-- cursor stays in place while running commands in normal mode
map("n", "J", "mzJ`z")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
-- keep yanked work when pasting
map("x", "<leader>p", '"_dP')
-- replace word under cursor
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
-- switch to previous file
map("n", "<leader><leader>", "<C-^>")
-- %% -> expand current dir in cmdline
map("c", "%%", function()
  return vim.fn.expand("%:h") .. "/"
end, { expr = true })
-- Split windows
map("n", "<leader>-", "<C-w>s")
map("n", "<leader>\\", "<C-w>v")

-- Typos (command-line abbreviations)
vim.cmd([[cabbrev W w]])
vim.cmd([[cabbrev Wall wall]])
vim.cmd([[cabbrev W! w!]])
vim.cmd([[cabbrev Q q]])
vim.cmd([[cabbrev Qall qall]])
vim.cmd([[cabbrev Q! q!]])
vim.cmd([[cabbrev Qall! qall!]])
vim.cmd([[cabbrev Wq wq]])
vim.cmd([[cabbrev WQ wq]])

map("n", "<leader>u", ":Undotree<cr>")
-- Git
map("n", "<leader>gs", ":Git<cr>")
map("n", "<leader>gb", ":Git blame<cr>")
map("n", "<leader>gd", ":Gvdiffsplit<cr>")
map("n", "<leader>gl", ":Git log<cr>")
map("n", "<leader>go", ":GBrowse<cr>")
map("x", "<leader>go", ":GBrowse<cr>")
map("n", "<leader>gx", function()
  require("gitsigns").setqflist("all")
end)
map("n", "<leader>ghn", ":Gitsigns next_hunk next<cr>")
map("n", "<leader>ghp", ":Gitsigns next_hunk prev<cr>")
map("n", "<leader>gsh", ":Gitsigns stage_hunk<cr>")

--quickfix
map("n", "<M-j>", "<cmd>cnext<cr>")
map("n", "<M-k>", "<cmd>cprev<cr>")

-- Pickers
map("n", "<c-p>", ":Pick files<cr>")
map("n", "<leader>/", ":Pick grep_live<cr>")
map("n", "<leader>h", ":Pick help<cr>")
map("n", "<leader>b", ":Pick buffers<cr>")
map("n", "<leader>x", function()
  MiniExtra.pickers.diagnostic()
end)
map("n", "gd", function()
  MiniExtra.pickers.lsp({
    scope = "definition"
  })
end)
map("n", "gD", function()
  MiniExtra.pickers.lsp({
    scope = "declaration"
  })
end)
map("n", "gr", function()
  MiniExtra.pickers.lsp({
    scope = "references"
  })
end)
map("n", "gI", function()
  MiniExtra.pickers.lsp({
    scope = "implementation"
  })
end)
map("n", "gt", function()
  MiniExtra.pickers.lsp({
    scope = "type_definition"
  })
end)

-- obsidian
map("n", "<leader>oo", ":split | Obsidian new TODO<cr>")
map("n", "<leader>of", "<cmd>:Obsidian quick_switch<cr>")
map("n", "<leader>og", "<cmd>:Obsidian search<cr>")
map("n", "<leader>on", "<cmd>:Obsidian new<cr>")
