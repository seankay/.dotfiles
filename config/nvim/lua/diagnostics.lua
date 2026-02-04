--diagnostics
local diagnostic_virtual_text = {
  severity = { min = vim.diagnostic.severity.INFO },
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

local diagnostic_virtual_lines = {
  severity = { min = vim.diagnostic.severity.INFO },
  prefix = "●",
  only_current_line = true,
}

local function update_diagnostic_virtuals()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local lnum = cursor[1] - 1
  local has_diagnostics = #vim.diagnostic.get(0, { lnum = lnum }) > 0

  if has_diagnostics then
    vim.diagnostic.config({
      virtual_text = false,
      virtual_lines = diagnostic_virtual_lines,
    })
  else
    vim.diagnostic.config({
      virtual_text = diagnostic_virtual_text,
      virtual_lines = false,
    })
  end
end

update_diagnostic_virtuals()

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "DiagnosticChanged" }, {
  group = vim.api.nvim_create_augroup("diagnostic_virtuals", { clear = true }),
  callback = update_diagnostic_virtuals,
})
