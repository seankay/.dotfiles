--diagnostics
vim.diagnostic.config({
  virtual_text = {
    spacing = 4,
    prefix = "●",
    format = function(diagnostic)
      local message = diagnostic.message
      local max_width = 80
      if #message > max_width then
        return message:sub(1, max_width - 1) .. "…"
      end

      return message
    end,
  }
})
