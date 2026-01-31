local utils = require("utils")
-- plugins
vim.pack.add({
  { src = utils.gh("j-hui/fidget.nvim") },
  { src = utils.gh("knubie/vim-kitty-navigator") },
  { src = utils.gh("lewis6991/gitsigns.nvim") },
  { src = utils.gh("mikesmithgh/kitty-scrollback.nvim") },
  { src = utils.gh("nvim-mini/mini.ai") },
  { src = utils.gh("nvim-mini/mini.extra") },
  { src = utils.gh("nvim-mini/mini.hipatterns") },
  { src = utils.gh("nvim-mini/mini.icons") },
  { src = utils.gh("nvim-mini/mini.pick") },
  { src = utils.gh("nvim-mini/mini.surround") },
  {
    src = utils.gh("olimorris/codecompanion.nvim"),
    version = vim.version.range("^18.0.0")
  },
  { src = utils.gh("stevearc/conform.nvim") },
  { src = utils.gh("stevearc/oil.nvim") },
  { src = utils.gh("tpope/vim-fugitive") },
  { src = utils.gh("tpope/vim-rhubarb") },
  { src = utils.gh("nvim-lua/plenary.nvim") },
  { src = utils.gh("MeanderingProgrammer/render-markdown.nvim") },
  { src = utils.gh("vague-theme/vague.nvim") },
})

vim.cmd("packadd nvim.undotree")
vim.cmd("colorscheme vague")

require('mini.extra').setup()
local hipatterns = require("mini.hipatterns")
hipatterns.setup({
  highlighters = {
    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
    hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
    note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})
require("mini.pick").setup({
  mappings = {
    choose_marked = '<C-q>',
  },
  window = {
    config = function()
      local height = math.floor(0.618 * vim.o.lines)
      local width = math.floor(0.618 * vim.o.columns)
      return {
        anchor = 'NW',
        height = height,
        width = width,
        row = math.floor(0.5 * (vim.o.lines - height)),
        col = math.floor(0.5 * (vim.o.columns - width)),
      }
    end,
  },
})
require("mini.surround").setup()
require("oil").setup({
  delete_to_trash = true,
  keymaps = {
    ["<C-o>"] = "actions.preview",
    ["<C-p>"] = false,
  },
  view_options = {
    show_hidden = true,
  },
})

require("conform").setup({
  formatters_by_ft = {
    javascript = { "prettierd" },
    javascriptreact = { "prettierd" },
    typescript = { "prettierd" },
    typescriptreact = { "prettierd" },
    json = { "prettierd" },
    markdown = { "prettierd" },
  },
  format_on_save = function()
    return { lsp_fallback = true, timeout_ms = 2000 }
  end,
})

require('fidget').setup()

require('kitty-scrollback').setup()

require('render-markdown').setup({
  file_types = { 'markdown', 'codecompanion' },
  completions = { lsp = { enabled = true } },
})

require("opts")
require("keymaps")
require("lsp")
require("statusline")
require("completion")
require("treesitter")
require("undotree_setup")
require("obsidian_setup")
require("quickfix")
require("ai")
