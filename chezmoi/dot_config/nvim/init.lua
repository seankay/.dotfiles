vim.g.path_dotfiles = vim.env.HOME .. "/.dotfiles"
vim.g.path_config = vim.env.HOME .. "/.config"
vim.g.path_dev = vim.env.HOME .. "/c"

require("config.pre-lazy-opts")
require("config.lazy")
require("config.post-lazy-opts")
require("config.winbar").setup()
