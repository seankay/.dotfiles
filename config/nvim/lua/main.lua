local utils = require("utils")
-- plugins
vim.pack.add({
  { src = utils.gh("knubie/vim-kitty-navigator") },
  { src = utils.gh("tpope/vim-fugitive") },
  { src = utils.gh("lewis6991/gitsigns.nvim") },
  { src = utils.gh("mikesmithgh/kitty-scrollback.nvim") },
  { src = utils.gh("nvim-mini/mini.ai") },
  { src = utils.gh("nvim-mini/mini.hipatterns") },
  { src = utils.gh("nvim-mini/mini.surround") },
  { src = utils.gh("stevearc/conform.nvim") },
  { src = utils.gh("stevearc/oil.nvim") },
  { src = utils.gh("nvim-lua/plenary.nvim") },
  { src = utils.gh("MeanderingProgrammer/render-markdown.nvim") },
  { src = utils.gh("vague-theme/vague.nvim") },
  { src = utils.gh("sindrets/diffview.nvim") },
  { src = utils.gh("nvim-tree/nvim-web-devicons") },

})

vim.cmd("colorscheme vague")

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
    python = { "ruff" }
  },
  format_on_save = function()
    return { lsp_fallback = true, timeout_ms = 2000 }
  end,
})

require('kitty-scrollback').setup({})

require('render-markdown').setup({
  file_types = { 'markdown', 'codecompanion' },
  completions = { lsp = { enabled = true } },
})

require("diffview").setup({
  keymaps = {
    file_panel = {
      {
        "n", "cc",
        "<Cmd>Git commit <bar> wincmd J<CR>",
        { desc = "Commit staged changes" },
      },
      {
        "n", "ca",
        "<Cmd>Git commit --amend <bar> wincmd J<CR>",
        { desc = "Amend the last commit" },
      },
      {
        "n", "c<space>",
        ":Git commit ",
        { desc = "Populate command line with \":Git commit \"" },
      },
    },
  },
  file_panel = {
    listing_style = "list",
    win_config = {
      position = "bottom",
      height = 10,
    },
  }
})

require("opts")
require("ai")
require("completion")
require("diagnostics")
require("lsp")
require("snacks_setup")
require("obsidian_setup")
require("quickfix")
require("statusline")
require("treesitter")
require("testing")
require("keymaps")
require("colorscheme")
