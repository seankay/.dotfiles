-- plugins
vim.pack.add({
  { src = "https://github.com/vague-theme/vague.nvim" },
  { src = "https://github.com/nvim-mini/mini.ai" },
  { src = "https://github.com/nvim-mini/mini.surround" },
  { src = "https://github.com/nvim-mini/mini.pick" },
  { src = "https://github.com/nvim-mini/mini.hipatterns" },
  { src = "https://github.com/nvim-mini/mini.extra" },
  { src = "https://github.com/tpope/vim-fugitive" },
  { src = "https://github.com/tpope/vim-rhubarb" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/christoomey/vim-tmux-navigator" },
  { src = "https://github.com/stevearc/oil.nvim" },
})

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
    mark = '<tab>'
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

require("opts")
require("keymaps")
require("lsp")
require("statusline")
require("completion")
require("treesitter")
require("undotree_setup")
