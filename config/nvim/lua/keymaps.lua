local utils = require("utils")
vim.pack.add({
  { src = utils.gh("folke/which-key.nvim") }
})

require("which-key").setup({
  preset = "helix", -- vertical menu on the right
  win = {
    border = "rounded",
    no_overlap = true,
    col = math.huge,
    row = math.huge,
  },
  layout = {
    width = { min = 20, max = 50 },
    spacing = 1,
    align = "left",
  },
  spec = {
    { "<leader>a", group = "AI", icon = "󱚡" },
    { "<leader>g", group = "Git" },
    { "<leader>gh", group = "Hunk" },
    { "<leader>l", group = "LSP", icon = "󰲽" },
    { "<leader>o", group = "Obsidian", icon = "" },
    { "<leader>p", group = "Pack", icon = "" },
    { "<leader>s", group = "Search", icon = "" },
    { "<leader>t", group = "Tests", icon = "󰙨" },
    { "<leader>x", group = "Diagnostics" },
    { "<leader>e", group = "Explore", icon = "" },
    { "<leader>/", group = "Grep", icon = "" },
    { "<leader>\\", group = "Split Vertically", icon = "󰮾" },
    { "<leader>-", group = "Split Horizontally", icon = "󰮸" },
    { "<leader>w", group = "Write", icon = "" },
    { "<leader>W", group = "Write All", icon = "" },
    { "<leader>q", group = "Quit", icon = "󰈆" },
    { "<leader>Q", group = "Quit All", icon = "󰈆" },
    { "<leader>r", group = "Replace Word", icon = "" },
  }
})

-- Keymaps
vim.g.mapleader = " " -- init before mappings
local map = vim.keymap.set

-- pack
map("n", "<leader>pc", utils.pack_clean, { desc = "Clean" })
map("n", "<leader>pu", function()
  vim.pack.update()
end, { desc = "Update" })

map("i", "jj", "<Esc>", { desc = "Escape insert" })
map("n", "<leader>w", ":w<CR>", { desc = "Write" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
map("n", "<leader>W", "<cmd>wall<cr>", { desc = "Write all" })
map("n", "<leader>Q", "<cmd>qall<cr>", { desc = "Quit all" })
map("n", "<leader>e", ":Oil<CR>", { desc = "Oil" })
-- visual move
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
-- cursor stays in place while running commands in normal mode
map("n", "J", "mzJ`z", { desc = "Join lines keep cursor" })
map("n", "<C-d>", "<C-d>zz", { desc = "Page down keep centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Page up keep centered" })
map("n", "n", "nzzzv", { desc = "Next search result centered" })
map("n", "N", "Nzzzv", { desc = "Prev search result centered" })
map("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })
-- switch to previous file
map("n", "<leader><leader>", "<C-^>", { desc = "Previous file" })
-- %% -> expand current dir in cmdline
map("c", "%%", function()
  return vim.fn.expand("%:h") .. "/"
end, { expr = true, desc = "Expand current dir" })
-- Split windows
map("n", "<leader>-", "<C-w>s", { desc = "Split horizontally" })
map("n", "<leader>\\", "<C-w>v", { desc = "Split vertically" })

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

-- Git
local gitsigns = require("gitsigns")
map("n", "<leader>G", "<cmd>Git<cr>", { desc = "Git status" })
map("n", "<leader>gB", ":Gitsigns blame<cr>", { desc = "Git blame" })
map("n", "<leader>gb", ":Gitsigns blame_line<cr>", { desc = "Git blame line" })
map('n', '<leader>ghs', gitsigns.stage_hunk, { desc = "Stage hunk" })
map('v', '<leader>ghs', function()
  gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
end, { desc = "Stage hunk" })
map('n', '<leader>ghr', gitsigns.reset_hunk, { desc = "Reset hunk" })
map('v', '<leader>ghr', function()
  gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
end, { desc = "Reset hunk" })
map({ 'o', 'x' }, 'gih', gitsigns.select_hunk, { desc = "Select hunk" })
map('n', '<leader>ghp', gitsigns.preview_hunk, { desc = "Preview hunk" })
map('n', '<leader>ghi', gitsigns.preview_hunk_inline, { desc = "Preview hunk inline" })
map('n', ']h', function()
  if vim.wo.diff then
    vim.cmd.normal({ ']c', bang = true })
  else
    gitsigns.nav_hunk('next')
  end
end, { desc = "Next hunk" })

map('n', '[h', function()
  if vim.wo.diff then
    vim.cmd.normal({ '[c', bang = true })
  else
    gitsigns.nav_hunk('prev')
  end
end, { desc = "Prev hunk" })
map("n", "<leader>gd", function()
  local lib = require('diffview.lib')
  if lib.get_current_view() then
    vim.cmd("DiffviewClose")
  else
    vim.cmd("DiffviewOpen")
  end
end
, { desc = "Diff tool" })
map("n", "<leader>gl", function()
  local lib = require("diffview.lib")
  if lib.get_current_view() then
    vim.cmd("DiffviewClose")
  else
    vim.cmd("DiffviewFileHistory")
  end
end, { desc = "Git log" })
map({ "n", "x" }, "<leader>go", function() Snacks.gitbrowse() end, { desc = "Git browse" })

-- Pickers
map("n", "<c-p>", function()
  Snacks.picker.files()
end, { desc = "File picker" })
map("n", "<leader>/", function()
  Snacks.picker.grep()
end, { desc = "Grep" })
map("n", "<leader>sw", function()
  Snacks.picker.grep({ search = vim.fn.expand("<cword>") })
end, { desc = "Grep word under cursor" })
map("n", "<leader>b", function()
  Snacks.picker.buffers()
end, { desc = "Buffers" })
map("n", "<leader>x", function()
  Snacks.picker.diagnostics()
end, { desc = "Diagnostics" })
map("n", "gd", function()
  Snacks.picker.lsp_definitions()
end, { desc = "LSP definitions" })
map("n", "gD", function()
  Snacks.picker.lsp_declarations()
end, { desc = "LSP declarations" })
map("n", "gr", function()
  Snacks.picker.lsp_references()
end, { desc = "LSP references" })
map("n", "gI", function()
  Snacks.picker.lsp_implementations()
end, { desc = "LSP implementations" })
map("n", "gT", function()
  Snacks.picker.lsp_type_definitions()
end, { desc = "LSP type definitions" })
map("n", "gai", function() Snacks.picker.lsp_incoming_calls() end, { desc = "C[a]lls Incoming" })
map("n", "gao", function() Snacks.picker.lsp_outgoing_calls() end, { desc = "C[a]lls Outgoing" })
map("n", "<leader>ls", function() Snacks.picker.lsp_symbols() end, { desc = "LSP Symbols" })
map("n", "<leader>lS", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "LSP Workspace Symbols" })
map("n", '<leader>s"', function() Snacks.picker.registers() end, { desc = "Registers" })
map("n", '<leader>s/', function() Snacks.picker.search_history() end, { desc = "Search History" })
map("n", "<leader>sa", function() Snacks.picker.autocmds() end, { desc = "Autocmds" })
map("n", "<leader>sb", function() Snacks.picker.lines() end, { desc = "Buffer Lines" })
map("n", "<leader>sc", function() Snacks.picker.command_history() end, { desc = "Command History" })
map("n", "<leader>sC", function() Snacks.picker.commands() end, { desc = "Commands" })
map("n", "<leader>sd", function() Snacks.picker.diagnostics() end, { desc = "Diagnostics" })
map("n", "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, { desc = "Buffer Diagnostics" })
map("n", "<leader>sh", function() Snacks.picker.help() end, { desc = "Help Pages" })
map("n", "<leader>si", function() Snacks.picker.icons() end, { desc = "Icons" })
map("n", "<leader>sj", function() Snacks.picker.jumps() end, { desc = "Jumps" })
map("n", "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
map("n", "<leader>sl", function() Snacks.picker.loclist() end, { desc = "Location List" })
map("n", "<leader>sm", function() Snacks.picker.marks() end, { desc = "Marks" })
map("n", "<leader>sM", function() Snacks.picker.man() end, { desc = "Man Pages" })
map("n", "<leader>su", function() Snacks.picker.undo() end, { desc = "Undo History" })


-- obsidian
map("n", "<leader>oo", ":split | Obsidian new TODO<cr>", { desc = "New TODO note" })
map("n", "<leader>of", "<cmd>:Obsidian quick_switch<cr>", { desc = "Quick switch note" })
map("n", "<leader>og", "<cmd>:Obsidian search<cr>", { desc = "Search notes" })
map("n", "<leader>on", "<cmd>:Obsidian new<cr>", { desc = "New note" })

-- AI
map({ "n", "x" }, "<leader>aa", function() require("opencode").ask("@this: ", { submit = true }) end,
  { desc = "Ask opencode…" })
map({ "n", "x" }, "<leader>as", function() require("opencode").select() end, { desc = "Execute opencode action…" })
map({ "n", "t" }, "<leader>at", function() require("opencode").toggle() end, { desc = "Toggle opencode" })

map({ "n", "x" }, "go", function() return require("opencode").operator("@this ") end,
  { desc = "Add range to opencode", expr = true })
map("n", "goo", function() return require("opencode").operator("@this ") .. "_" end,
  { desc = "Add line to opencode", expr = true })

map("n", "<leader>au", function() require("opencode").command("session.half.page.up") end,
  { desc = "Scroll opencode up" })
map("n", "<leader>ad", function() require("opencode").command("session.half.page.down") end,
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
