local utils = require("utils")
vim.pack.add({
  { src = utils.gh("folke/snacks.nvim") }
})

require("snacks").setup({
  bigfile = { enabled = true },
  indent = { enabled = true },
  quickfile = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },
  image = { enabled = true },
  rename = { enabled = true },
  picker = {
    enabled = true,
    ignored = true,
    exclude = {
      "**/.git/*",
      "**/node_modules/*",
      "**/coverage/*",
      ".next",
      ".turbo",
    },
    sources = {
      files = {
        hidden = true,
        ignored = true,
        exclude = {
          "**/.git/*",
          "node_modules",
        },
      },
    },
  },
  terminal = { enabled = false },
  input = { enabled = true },
  dashboard = { enabled = false },
  notifier = { enabled = false },
  statuscolumn = { enabled = false },
  notify = { enabled = false },
  gh = { enable = false },
  explorer = { enabled = false },
  words = { enabled = false },
})

vim.api.nvim_create_autocmd("User", {
  pattern = "OilActionsPost",
  callback = function(event)
    if event.data.actions[1].type == "move" then
      Snacks.rename.on_rename_file(event.data.actions[1].src_url, event.data.actions[1].dest_url)
    end
  end,
})
