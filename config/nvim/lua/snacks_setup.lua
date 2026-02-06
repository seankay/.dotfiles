local utils = require("utils")
vim.pack.add({
  { src = utils.gh("folke/snacks.nvim") }
})

local function split_grep_query(query)
  local term, scope = query:match("^(.-)%s%s+(.+)$")
  if not term then
    return nil
  end
  term = vim.trim(term)
  scope = vim.trim(scope)
  if term == "" or scope == "" then
    return nil
  end
  return term, scope
end

local function is_glob(value)
  return value:find("[*?[]") ~= nil
end

require("snacks").setup({
  bigfile = { enabled = true },
  quickfile = { enabled = true },
  scope = { enabled = true },
  image = { enabled = true },
  rename = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = true },
  picker = {
    enabled = true,
    ignored = true,
    exclude = {
      "**/.git/**",
      "**/node_modules/**",
      "**/coverage/**",
      "**/.next/**",
      "**/.turbo/**",
    },
    sources = {
      files = {
        hidden = true,
        ignored = true,
      },
      grep = {
        hidden = true,
        ignored = true,
        filter = {
          transform = function(picker, filter)
            local term, scope = split_grep_query(filter.search)
            if term then
              if is_glob(scope) then
                local next_glob = scope
                local glob_changed = picker.opts.glob ~= next_glob
                local dirs_changed = picker.opts.dirs ~= nil
                picker.opts.glob = next_glob
                picker.opts.dirs = nil
                if filter.search ~= term then
                  filter.search = term
                  return true
                end
                return glob_changed or dirs_changed
              end

              local next_dirs = { scope }
              local dirs_changed = not vim.deep_equal(picker.opts.dirs, next_dirs)
              local glob_changed = picker.opts.glob ~= nil
              picker.opts.dirs = next_dirs
              picker.opts.glob = nil
              if filter.search ~= term then
                filter.search = term
                return true
              end
              return dirs_changed or glob_changed
            end

            if picker.opts.dirs ~= nil or picker.opts.glob ~= nil then
              picker.opts.dirs = nil
              picker.opts.glob = nil
              return true
            end
          end,
        },
      },
    },
  },
})

vim.api.nvim_create_autocmd("User", {
  pattern = "OilActionsPost",
  callback = function(event)
    if event.data.actions[1].type == "move" then
      Snacks.rename.on_rename_file(event.data.actions[1].src_url, event.data.actions[1].dest_url)
    end
  end,
})
