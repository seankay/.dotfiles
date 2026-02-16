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
    { "<leader>g", group = "Git" },
    { "<leader>l", group = "LSP", icon = "󰲽" },
    { "<leader>o", group = "Obsidian", icon = "" },
    { "<leader>p", group = "Pack", icon = "" },
    { "<leader>s", group = "Search", icon = "" },
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

-- esc,esc to enter normal mode in terminal
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { silent = true, noremap = true })

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
map("n", "<leader>G", ":vertical G<cr>", { desc = "Git status" })
map("n", "<leader>gd", ":vertical Gdiff<cr>", { desc = "Git Diff" })
map("n", "<leader>gl", ":vertical G log<cr>", { desc = "Git Log" })
map("n", "<leader>gb", ":G blame<cr>", { desc = "Git blame" })
map("n", "<leader>gO", function() utils.open_github(vim.api.nvim_win_get_cursor(0)[1]) end, { desc = "Git Open" })
map("x", "<leader>gO", function()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  utils.open_github(start_line, end_line)
end, { desc = "Git Open" })

-- Pickers
local fzflua = require("fzf-lua")
map("n", "<c-p>", function() fzflua.files() end)
map("n", "<leader>/", function() fzflua.live_grep() end, { desc = "Grep" })
map("n", "<leader>sw", function() fzflua.grep_cword() end, { desc = "Grep word under cursor" })
map("x", "<leader>sw", function() fzflua.grep_visual() end, { desc = "Grep selected content" })
map("n", "<leader>x", function() fzflua.diagnostics_document() end, { desc = "Document Diagnostics" })
map("n", "<leader>X", function() fzflua.diagnostics_workspace() end, { desc = "Workspace Diagnostics" })
map("n", "<leader>ls", function() fzflua.lsp_document_symbols() end, { desc = "LSP Symbols" })
map("n", "<leader>lS", function() fzflua.lsp_workspace_symbols() end, { desc = "LSP Workspace Symbols" })
map("n", "<leader>la", function() fzflua.lsp_code_actions() end, { desc = "LSP Code Actions" })
map("n", '<leader>s"', function() fzflua.registers() end, { desc = "Registers" })
map("n", '<leader>s/', function() fzflua.search_history() end, { desc = "Search History" })
map("n", "<leader>sa", function() fzflua.autocmds() end, { desc = "Autocmds" })
map("n", "<leader>sb", function() fzflua.buffers() end, { desc = "Buffer" })
map("n", "<leader>sc", function() fzflua.command_history() end, { desc = "Command History" })
map("n", "<leader>sC", function() fzflua.commands() end, { desc = "Commands" })
map("n", "<leader>sh", function() fzflua.help_tags() end, { desc = "Help Pages" })
map("n", "<leader>sj", function() fzflua.jumps() end, { desc = "Jumps" })
map("n", "<leader>sk", function() fzflua.keymaps() end, { desc = "Keymaps" })
map("n", "<leader>sl", function() fzflua.loclist() end, { desc = "Location List" })
map("n", "<leader>sm", function() fzflua.marks() end, { desc = "Marks" })
map("n", "<leader>sM", function() fzflua.manpages() end, { desc = "Man Pages" })
map("n", "<leader>su", ":FzfLua undotree fzf_opts.--keep-right=true<cr>", { desc = "Undo History" })
map("n", "<leader>sr", function() fzflua.resume() end, { desc = "Resume Fzf" })
map("n", "<leader>sg", function() fzflua.global() end, { desc = "Global picker" })
map("n", "<leader>sg", function() fzflua.tabs() end, { desc = "Tabs" })
map("n", "<leader>sq", function() fzflua.quickfix() end, { desc = "Quickfix List" })
-- LSP
map("n", "gd", function() fzflua.lsp_definitions() end, { desc = "LSP definitions" })
map("n", "gD", function() fzflua.lsp_declarations() end, { desc = "LSP declarations" })
map("n", "gr", function() fzflua.lsp_references() end, { desc = "LSP references" })
map("n", "gI", function() fzflua.lsp_implementations() end, { desc = "LSP implementations" })
map("n", "gT", function() fzflua.lsp_typedefs() end, { desc = "LSP type definitions" })
map("n", "gai", function() fzflua.lsp_incoming_calls() end, { desc = "C[a]lls Incoming" })
map("n", "gao", function() fzflua.lsp_outgoing_calls() end, { desc = "C[a]lls Outgoing" })

-- obsidian
map("n", "<leader>oo", ":split | Obsidian new TODO<cr>", { desc = "New TODO note" })
map("n", "<leader>of", "<cmd>:Obsidian quick_switch<cr>", { desc = "Quick switch note" })
map("n", "<leader>og", "<cmd>:Obsidian search<cr>", { desc = "Search notes" })
map("n", "<leader>on", "<cmd>:Obsidian new<cr>", { desc = "New note" })
