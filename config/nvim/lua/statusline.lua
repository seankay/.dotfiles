vim.o.laststatus = 3

local M = {}

M.git = {
  branch = "",
  dirty = false,
  root = nil,
}

function M.update_git()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  local dir = name ~= "" and vim.fn.fnamemodify(name, ":h") or vim.fn.getcwd()

  vim.system({ "git", "-C", dir, "rev-parse", "--show-toplevel" }, { text = true }, function(root_result)
    if root_result.code ~= 0 then
      M.git.root = nil
      M.git.branch = ""
      M.git.dirty = false
      vim.schedule(function()
        vim.cmd("redrawstatus")
      end)
      return
    end

    local root = vim.trim(root_result.stdout or "")
    M.git.root = root

    vim.system({ "git", "-C", root, "rev-parse", "--abbrev-ref", "HEAD" }, { text = true }, function(head_result)
      if head_result.code == 0 then
        M.git.branch = vim.trim(head_result.stdout or "")
      else
        M.git.branch = ""
      end

      vim.system({ "git", "-C", root, "status", "--porcelain" }, { text = true }, function(status_result)
        if status_result.code == 0 then
          M.git.dirty = status_result.stdout ~= ""
        else
          M.git.dirty = false
        end

        vim.schedule(function()
          vim.cmd("redrawstatus")
        end)
      end)
    end)
  end)
end

function M.git_branch()
  if M.git.branch == "" then
    return ""
  end

  local dirty_mark = M.git.dirty and " ●" or ""
  local group = M.git.dirty and "StatusLineGitDirty" or "StatusLineGitClean"
  return string.format("%%#%s# %s%s%%*", group, M.git.branch, dirty_mark)
end

function M.diag_counts()
  local severities = vim.diagnostic.severity
  local err = #vim.diagnostic.get(0, { severity = severities.ERROR })
  local warn = #vim.diagnostic.get(0, { severity = severities.WARN })
  local info = #vim.diagnostic.get(0, { severity = severities.INFO })
  local hint = #vim.diagnostic.get(0, { severity = severities.HINT })

  local function segment(count, group, icon)
    if count == 0 then
      return ""
    end
    return string.format("%%#%s#%s %d%%* ", group, icon, count)
  end

  return table.concat({
    segment(err, "DiagnosticError", "󰅚"),
    segment(warn, "DiagnosticWarn", "󰀪"),
    segment(info, "DiagnosticInfo", "󰋽"),
    segment(hint, "DiagnosticHint", "󰌶"),
  })
end

function M.lsp_status()
  local names = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    if client.name ~= "copilot" then
      table.insert(names, client.name)
    end
  end

  if #names == 0 then
    return "No LSP"
  end

  local progress = vim.lsp.status()
  local label = table.concat(names, ", ")
  if progress ~= "" then
    return label .. " (loading)"
  end
  return label
end

function M.statusline()
  return table.concat({
    " " .. M.git_branch(),
    " ",
    " %f",  -- file
    "%m%r", -- modified/readonly
    " %= ",
    " " .. M.lsp_status(),
    " ",
    " " .. M.diag_counts(),
    " %l:%c %p%% ",
  })
end

local function set_git_hl()
  local clean = vim.api.nvim_get_hl(0, { name = "DiffAdd", link = false })
  local dirty = vim.api.nvim_get_hl(0, { name = "DiffChange", link = false })
  vim.api.nvim_set_hl(0, "StatusLineGitClean", { fg = clean.fg })
  vim.api.nvim_set_hl(0, "StatusLineGitDirty", { fg = dirty.fg })
end

set_git_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_git_hl })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusGained", "DirChanged" }, {
  callback = function()
    M.update_git()
  end,
})

vim.o.statusline = "%!v:lua.require'statusline'.statusline()"

return M
