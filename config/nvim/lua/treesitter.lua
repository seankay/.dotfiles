vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" }
})
local ts_runtime = vim.fn.stdpath("data") .. "/site/pack/core/opt/nvim-treesitter/runtime"
if vim.uv.fs_stat(ts_runtime) then
  vim.opt.rtp:append(ts_runtime)
end
local parsers = {
  "bash",
  "elixir",
  "erlang",
  "go",
  "graphql",
  "hcl",
  "javascript",
  "jsdoc",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "regex",
  "ruby",
  "terraform",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
}

local filetypes = vim.deepcopy(parsers)
vim.list_extend(filetypes, { "javascriptreact", "jsonc", "typescriptreact" })
local filetype_lookup = {}
for _, filetype in ipairs(filetypes) do
  filetype_lookup[filetype] = true
end

local language = vim.treesitter.language
if language and language.register then
  language.register("javascript", "javascriptreact")
  language.register("json", "jsonc")
  language.register("tsx", "typescriptreact")
end

local function ensure_treesitter(buf)
  local filetype = vim.bo[buf].filetype
  if filetype == "" or not filetype_lookup[filetype] then
    return
  end
  if not vim.treesitter.highlighter.active[buf] then
    vim.treesitter.start(buf)
  end
  vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

local group = vim.api.nvim_create_augroup("TreesitterFeatures", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = filetypes,
  callback = function(ev)
    ensure_treesitter(ev.buf)
  end,
})

-- keep desired parsers up to date
require("nvim-treesitter").install(parsers, { summary = true })
