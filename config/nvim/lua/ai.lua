local utils = require("utils")
vim.pack.add({
  { src = utils.gh("folke/sidekick.nvim") },
})

require("sidekick").setup({
  nes = { enabled = false },
  cli = {
    win = {
      keys = {
        prompt = { "<leader>ap", "prompt", mode = "t", desc = "insert prompt or context" },
      }
    },
    tools = {
      opencode_resume = {
        cmd = { "opencode", "--continue" }
      }
    }
  }
})
