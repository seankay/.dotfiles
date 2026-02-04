--diagnostics
local current_cursor_lnum = nil

local diagnostic_virtual_text = {
  spacing = 4,
  prefix = "●",
  format = function(diagnostic)
    if diagnostic.lnum == current_cursor_lnum then
      return nil
    end

    local message = diagnostic.message
    local max_width = 80
    if #message > max_width then
      return message:sub(1, max_width - 1) .. "…"
    end

    return message
  end,
}

local diagnostic_virtual_lines = {
  prefix = "●",
}

local namespace = vim.api.nvim_create_namespace("diagnostic_current_line_virtuals")

vim.diagnostic.config({
  virtual_text = diagnostic_virtual_text,
  virtual_lines = false,
})

local function update_diagnostic_virtuals()
  local current_buf = vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(current_buf) then
    return
  end

  local win = vim.fn.bufwinid(current_buf)
  if win == -1 then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(win)
  local lnum = cursor[1] - 1

  current_cursor_lnum = lnum

  vim.diagnostic.hide(namespace, current_buf)

  local diagnostics = vim.diagnostic.get(current_buf, {
    lnum = lnum,
  })

  if not diagnostics or vim.tbl_isempty(diagnostics) then
    return
  end

  vim.diagnostic.show(namespace, current_buf, diagnostics, {
    virtual_text = false,
    signs = false,
    underline = false,
    virtual_lines = diagnostic_virtual_lines,
  })
end

update_diagnostic_virtuals()

local group = vim.api.nvim_create_augroup("diagnostic_virtuals", { clear = true })

local function schedule_update(event)
  local target_buf = event and event.buf or vim.api.nvim_get_current_buf()

  vim.defer_fn(function()
    if target_buf ~= vim.api.nvim_get_current_buf() then
      return
    end
    update_diagnostic_virtuals()
  end, 20)
end

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI", "DiagnosticChanged" }, {
  group = group,
  callback = schedule_update,
})

vim.api.nvim_create_autocmd("BufLeave", {
  group = group,
  callback = function(event)
    vim.diagnostic.hide(namespace, event.buf)
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = schedule_update,
})
