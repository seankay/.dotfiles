local utils = require("utils")
vim.pack.add({
  { src = utils.gh("folke/sidekick.nvim") },
})

require("sidekick").setup({
  nes = { enabled = false },
  cli = {
    tools = {
      opencode_resume = {
        cmd = { "opencode", "--continue" }
      }
    }
  }
})
