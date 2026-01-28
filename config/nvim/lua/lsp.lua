vim.pack.add({
  { src = 'https://github.com/neovim/nvim-lspconfig' },
})

-- format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    if vim.lsp.get_clients({ bufnr = 0 })[1] then
      vim.lsp.buf.format({ bufnr = 0, timeout_ms = 2000 })
    end
  end,
})

-- load nvim runtime so `vim` and other globals are recognized
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true)
      }
    }
  }
})

vim.lsp.config.bashls = {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'bash', 'sh', 'zsh' }
}

vim.lsp.enable({
  "lua_ls",
  "jsonls",
  "pyright",
  "terraformls",
  "ts_ls",
  "eslint",
  "gopls",
  "bashls"
})
