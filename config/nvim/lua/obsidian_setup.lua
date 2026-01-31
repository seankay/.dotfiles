vim.pack.add({
  {
    src = "https://github.com/obsidian-nvim/obsidian.nvim",
    version = vim.version.range("*")
  }
})

-- set OBSIDIAN_VAULT_PATH=/path/to/your/vault if needed
local file_exists = function(filename)
  if vim.fn.isdirectory(filename) ~= 1 then
    vim.notify(
      "Vault not found. Set OBSIDIAN_VAULT_PATH env var if needed.",
      vim.log.levels.ERROR,
      { title = "Obsidian" }
    )
    return false
  end
  return true
end

local home = os.getenv("HOME")
local default_path = home .. "/main-vault"
local obsidian_path = os.getenv("OBSIDIAN_VAULT_PATH") or default_path

if not file_exists(obsidian_path) then
  return
end

require("obsidian").setup({
  legacy_commands = false,
  -- disable and let render-markdown render content
  ui = { enable = false },
  templates = {
    folder = "Templates",
  },
  frontmatter = {
    enabled = false,
  },
  daily_notes = {
    folder = "Timestamps",
    date_format = "%Y/%m-%B/%Y-%m-%d-%A",
    default_tags = { "daily_note" },
    template = "Daily.md",
  },
  note_id_func = function(title)
    return title
  end,
  workspaces = {
    {
      name = "main",
      path = obsidian_path,
    },
  },
})
