local utils = require("utils")

vim.pack.add({
  { src = utils.gh("vague-theme/vague.nvim") },
})

vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#252530", bg = "NONE" })
vim.api.nvim_set_hl(0, "VertSplit", { fg = "#252530", bg = "NONE" })
vim.api.nvim_set_hl(0, "WinSeparatorNC", { fg = "#252530", bg = "NONE" })
