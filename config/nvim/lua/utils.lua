local M = {}

function M.gh(repo)
  return 'https://github.com/' .. repo
end

function M.pack_clean()
  local active_plugins = {}
  local unused_plugins = {}

  for _, plugin in ipairs(vim.pack.get()) do
    active_plugins[plugin.spec.name] = plugin.active
  end

  for _, plugin in ipairs(vim.pack.get()) do
    if not active_plugins[plugin.spec.name] then
      table.insert(unused_plugins, plugin.spec.name)
    end
  end

  if #unused_plugins == 0 then
    print("No unused plugins.")
    return
  end

  local choice = vim.fn.confirm("Remove unused plugins?", "&Yes\n&No", 2)
  if choice == 1 then
    vim.pack.del(unused_plugins)
  end
end

local function github_repo_from_url(url)
  url = url:gsub("%.git$", "")
  if url:match("^git@github.com:") then
    return url:match("^git@github.com:([^/]+/[^/]+)$")
  end
  local https = url:match("^https?://github.com/(.+)$")
      or url:match("^ssh://git@github.com/(.+)$")
      or url:match("^git://github.com/(.+)$")
  return https and https:gsub("%.git$", "") or nil
end

local function get_git_root()
  local root = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return root[1]
end

local function get_git_ref()
  local branch = vim.fn.systemlist({ "git", "rev-parse", "--abbrev-ref", "HEAD" })
  if vim.v.shell_error ~= 0 then
    return nil
  end
  if branch[1] ~= "HEAD" then
    return branch[1]
  end
  local sha = vim.fn.systemlist({ "git", "rev-parse", "HEAD" })
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return sha[1]
end

function M.open_github(range_start, range_end)
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("No file path for current buffer", vim.log.levels.WARN)
    return
  end

  local root = get_git_root()
  if not root then
    vim.notify("Not inside a git repository", vim.log.levels.WARN)
    return
  end

  local rel = file:sub(#root + 2)
  if rel == "" or rel == file then
    vim.notify("File is not inside the git root", vim.log.levels.WARN)
    return
  end

  local remote = vim.fn.systemlist({ "git", "remote", "get-url", "origin" })
  if vim.v.shell_error ~= 0 or not remote[1] then
    vim.notify("Could not read git remote 'origin'", vim.log.levels.WARN)
    return
  end

  local repo = github_repo_from_url(remote[1])
  if not repo then
    vim.notify("Remote is not a GitHub URL", vim.log.levels.WARN)
    return
  end

  local ref = get_git_ref()
  if not ref then
    vim.notify("Could not resolve git ref", vim.log.levels.WARN)
    return
  end

  local line_suffix = ""
  if range_start and range_end then
    if range_start > range_end then
      range_start, range_end = range_end, range_start
    end
    line_suffix = string.format("#L%s-L%s", range_start, range_end)
  elseif range_start then
    line_suffix = string.format("#L%s", range_start)
  end

  local url = string.format("https://github.com/%s/blob/%s/%s%s", repo, ref, rel, line_suffix)
  vim.ui.open(url)
end

return M
