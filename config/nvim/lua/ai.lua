local utils = require("utils")
vim.pack.add({
  { src = utils.gh("nickvandyke/opencode.nvim") },
})
vim.g.opencode_opts = {
  provider = {
    enabled = "kitty",
    cmd = "--copy-env --bias=30 opencode --port --continue",
    kitty = {
      location = "vsplit"
    }
  }
}
vim.o.autoread = true -- re-render buffer if edited by opencode
