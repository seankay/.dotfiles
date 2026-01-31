local utils = require("utils")
vim.pack.add({
  { src = utils.gh("NickvanDyke/opencode.nvim") },
})
vim.g.opencode_opts = {
  -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition" on the type or field.
}
-- Required for `opts.events.reload`.
vim.o.autoread = true
