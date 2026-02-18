local utils = require("utils")
vim.pack.add({
  {
    src = utils.gh("saghen/blink.cmp"),
    version = vim.version.range("^1.8.0")
  },
  { src = utils.gh("rafamadriz/friendly-snippets") },
})
require('blink.cmp').setup({
  appearance = {
    nerd_font_variant = 'mono'
  },
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500,
    },
    menu = {
      draw = {
        columns = {
          { "label",     "label_description", gap = 1 },
          { "kind_icon", "kind" },
        },
      },
    },
  },
  signature = { enabled = true },

  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },

  fuzzy = { implementation = "prefer_rust_with_warning" },
})
