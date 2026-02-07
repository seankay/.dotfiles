vim.o.laststatus = 3

local M = {}

function M.git_branch()
  local dict = vim.b.gitsigns_status_dict
  if not dict or not dict.head or dict.head == "" then
    return ""
  end
  local added = dict.added or 0
  local changed = dict.changed or 0
  local removed = dict.removed or 0
  local dirty = added + changed + removed > 0
  local group = dirty and "StatusLineGitDirty" or "StatusLineGitClean"

  local function segment(count, hl, prefix)
    if count == 0 then
      return ""
    end
    return string.format("%%#%s#%s%d%%*", hl, prefix, count)
  end

  local segments = {}
  for _, seg in ipairs({
    segment(added, "StatusLineGitAdd", "+"),
    segment(changed, "StatusLineGitChange", "~"),
    segment(removed, "StatusLineGitRemove", "-"),
  }) do
    if seg ~= "" then
      table.insert(segments, seg)
    end
  end

  local counts = table.concat(segments, " ")

  if counts ~= "" then
    counts = " " .. counts
  end

  return string.format("%%#%s# %s%%*%s", group, dict.head, counts)
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

function M.mode()
  local modes = {
    ["n"] = "N",
    ["no"] = "N",
    ["v"] = "V",
    ["V"] = "V",
    [""] = "V",
    ["s"] = "S",
    ["S"] = "S",
    [""] = "S",
    ["i"] = "I",
    ["ic"] = "I",
    ["R"] = "I",
    ["Rv"] = "V",
    ["c"] = "!",
    ["cv"] = "!",
    ["ce"] = "!",
    ["r"] = "?",
    ["rm"] = "?",
    ["r?"] = "?",
    ["!"] = "!",
    ["t"] = "T",
  }
  return string.format("%s", modes[vim.api.nvim_get_mode().mode])
end

function M.file_icon()
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    return ""
  end
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    return ""
  end
  local icon, hl = devicons.get_icon(name, nil, { default = false })
  if not icon then
    return ""
  end
  if hl and hl ~= "" then
    return string.format("%%#%s#%s%%* ", hl, icon)
  end
  return icon .. " "
end

function M.statusline()
  return table.concat({
    "   ",
    M.file_icon(),
    " ",
    " %#StatusLineFile#%f%*", -- file
    "%m%r",                   -- modified/readonly
    " %= ",
    M.diag_counts(),
    " ",
    string.format(" %%#StatusLineLsp#%s%%*", M.lsp_status()),
    " ",
    " " .. M.git_branch(),
    " ",
    " "
  })
end

local function set_git_hl()
  local palette = require("vague").get_palette()
  vim.api.nvim_set_hl(0, "StatusLineGit", { fg = palette.plus, bg = palette.bg })
  vim.api.nvim_set_hl(0, "StatusLineGitClean", { fg = palette.plus, bg = palette.bg })
  vim.api.nvim_set_hl(0, "StatusLineGitDirty", { fg = palette.delta, bg = palette.bg })
  vim.api.nvim_set_hl(0, "StatusLineGitAdd", { fg = palette.plus, bg = palette.bg })
  vim.api.nvim_set_hl(0, "StatusLineGitChange", { fg = palette.delta, bg = palette.bg })
  vim.api.nvim_set_hl(0, "StatusLineGitRemove", { fg = palette.error, bg = palette.bg })
end

local function set_status_hl()
  local palette = require("vague").get_palette()
  vim.api.nvim_set_hl(0, "StatusLine", { fg = palette.fg, bg = palette.bg })
  vim.api.nvim_set_hl(0, "StatusLineNC", { fg = palette.comment, bg = palette.bg })
  vim.api.nvim_set_hl(0, "StatusLineFile", { fg = palette.comment, bg = palette.bg })
  vim.api.nvim_set_hl(0, "StatusLineLsp", { fg = palette.comment, bg = palette.bg })
end

set_git_hl()
set_status_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_git_hl })
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_status_hl })

vim.o.statusline = "%!v:lua.require'statusline'.statusline()"

return M
