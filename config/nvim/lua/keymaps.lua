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

map("n", "<leader>u", function()
  Snacks.picker.undo()
end)
-- Git
map("n", "<leader>gs", function()
  Snacks.picker.git_status()
end)
map("n", "<leader>gb", ":Gitsigns blame<cr>")
map("n", "<leader>gd", function()
  Snacks.picker.git_diff()
end)
map("n", "<leader>gl", function()
  Snacks.picker.git_log()
end)
map({ "n", "x" }, "<leader>go", function()
  Snacks.gitbrowse()
end)

--quickfix
map("n", "<M-j>", "<cmd>cnext<cr>")
map("n", "<M-k>", "<cmd>cprev<cr>")

-- Pickers
map("n", "<c-p>", function()
  Snacks.picker.smart()
end)

map("n", "<leader>/", function()
  Snacks.picker.grep()
end)
map("n", "<leader>h", function()
  Snacks.picker.help()
end)
map("n", "<leader>b", function()
  Snacks.picker.buffers()
end)
map("n", "<leader>x", function()
  Snacks.picker.diagnostics()
end)
map("n", "gd", function()
  Snacks.picker.lsp_definitions()
end)
map("n", "gD", function()
  Snacks.picker.lsp_declarations()
end)
map("n", "gr", function()
  Snacks.picker.lsp_references()
end)
map("n", "gI", function()
  Snacks.picker.lsp_implementations()
end)
map("n", "gt", function()
  Snacks.picker.lsp_type_definitions()
end)

-- obsidian
map("n", "<leader>oo", ":split | Obsidian new TODO<cr>")
map("n", "<leader>of", "<cmd>:Obsidian quick_switch<cr>")
map("n", "<leader>og", "<cmd>:Obsidian search<cr>")
map("n", "<leader>on", "<cmd>:Obsidian new<cr>")

-- AI
map({ "n", "x" }, "<leader>aa", function() require("opencode").ask("@this: ", { submit = true }) end,
  { desc = "Ask opencode…" })
map({ "n", "x" }, "<leader>as", function() require("opencode").select() end, { desc = "Execute opencode action…" })
map({ "n", "t" }, "<leader>at", function() require("opencode").toggle() end, { desc = "Toggle opencode" })

map({ "n", "x" }, "go", function() return require("opencode").operator("@this ") end,
  { desc = "Add range to opencode", expr = true })
map("n", "goo", function() return require("opencode").operator("@this ") .. "_" end,
  { desc = "Add line to opencode", expr = true })

map("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end,
  { desc = "Scroll opencode up" })
map("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end,
  { desc = "Scroll opencode down" })

-- Tests (neotest)
map("n", "<leader>tt", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "Test file" })
map("n", "<leader>tr", function() require("neotest").run.run() end, { desc = "Test nearest" })
map("n", "<leader>tl", function() require("neotest").run.run_last() end, { desc = "Test last" })
map("n", "<leader>ta",
  function()
    local neotest = require("neotest")
    neotest.run.run({ suite = true })
    neotest.summary.open()
  end, { desc = "Test suite" })
map("n", "<leader>tp", function() require("neotest").output_panel.toggle() end, { desc = "Toggle output panel" })
map("n", "<leader>to", function()
    require("neotest").output.open({
      short = true,
      auto_close = true,
    })
  end,
  { desc = "Output window" })
map("n", "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, { desc = "Watch file" })
map("n", "<leader>tx", function() require("neotest").run.stop() end, { desc = "Stop" })
map("n", "<leader>ts", function() require("neotest").summary.toggle() end, { desc = "Summary" })
