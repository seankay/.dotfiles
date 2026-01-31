local utils = require("utils")
vim.pack.add({
  { src = utils.gh("nickvandyke/opencode.nvim") },
})
vim.g.opencode_opts = {
  -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition" on the type or field.
  provider = {
    enabled = "kitty",
    cmd = "--copy-env --bias=30 opencode --port",
    kitty = {
      location = "vsplit"
    }
  }
}
-- Required for `opts.events.reload`.
vim.o.autoread = true
