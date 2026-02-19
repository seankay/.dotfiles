local utils = require("utils")
-- plugins
vim.pack.add({
  { src = utils.gh("knubie/vim-kitty-navigator") },
  { src = utils.gh("mikesmithgh/kitty-scrollback.nvim") },
  { src = utils.gh("tpope/vim-fugitive") },
  { src = utils.gh("stevearc/oil.nvim") },
  { src = utils.gh("MeanderingProgrammer/render-markdown.nvim") },
  { src = utils.gh("nvim-mini/mini.ai") },
  { src = utils.gh("nvim-mini/mini.hipatterns") },
  { src = utils.gh("nvim-mini/mini.surround") },
  { src = utils.gh("nvim-mini/mini.icons"), },
  { src = utils.gh("nvim-mini/mini.notify"), },
  { src = utils.gh("stevearc/conform.nvim") },
  { src = utils.gh("nvim-tree/nvim-web-devicons") },
  { src = utils.gh("ibhagwan/fzf-lua") },
  { src = utils.gh("neovim/nvim-lspconfig") },
  { src = utils.gh("vague-theme/vague.nvim") },
  { src = utils.gh("kevinhwang91/nvim-bqf") }
})

-- Colorscheme
vim.cmd("colorscheme vague")
vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#252530", bg = "NONE" })
vim.api.nvim_set_hl(0, "VertSplit", { fg = "#252530", bg = "NONE" })
vim.api.nvim_set_hl(0, "WinSeparatorNC", { fg = "#252530", bg = "NONE" })
local palette = require("vague").get_palette()
vim.api.nvim_set_hl(0, "Pmenu", { fg = palette.fg })
vim.api.nvim_set_hl(0, "PmenuSel", { fg = palette.constant, bg = palette.line })
vim.api.nvim_set_hl(0, "PmenuSbar", { bg = palette.line })
vim.api.nvim_set_hl(0, "PmenuThumb", { bg = palette.comment })

--Diagnostics
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
-- Quickfix
local fn = vim.fn
---@diagnostic disable-next-line: duplicate-set-field
function _G.qftf(info)
  local items
  local ret = {}
  -- The name of item in list is based on the directory of quickfix window.
  -- Change the directory for quickfix window make the name of item shorter.
  -- It's a good opportunity to change current directory in quickfixtextfunc :)
  --
  -- local alterBufnr = fn.bufname('#') -- alternative buffer is the buffer before enter qf window
  -- local root = getRootByAlterBufnr(alterBufnr)
  -- vim.cmd(('noa lcd %s'):format(fn.fnameescape(root)))
  --
  if info.quickfix == 1 then
    items = fn.getqflist({ id = info.id, items = 0 }).items
  else
    items = fn.getloclist(info.winid, { id = info.id, items = 0 }).items
  end
  local limit = 31
  local fnameFmt1, fnameFmt2 = '%-' .. limit .. 's', '…%.' .. (limit - 1) .. 's'
  local validFmt = '%s │%5d:%-3d│%s %s'
  for i = info.start_idx, info.end_idx do
    local e = items[i]
    local fname = ''
    local str
    if e.valid == 1 then
      if e.bufnr > 0 then
        fname = fn.bufname(e.bufnr)
        if fname == '' then
          fname = '[No Name]'
        else
          fname = fname:gsub('^' .. vim.env.HOME, '~')
        end
        -- char in fname may occur more than 1 width, ignore this issue in order to keep performance
        if #fname <= limit then
          fname = fnameFmt1:format(fname)
        else
          fname = fnameFmt2:format(fname:sub(1 - limit))
        end
      end
      local lnum = e.lnum > 99999 and -1 or e.lnum
      local col = e.col > 999 and -1 or e.col
      local qtype = e.type == '' and '' or ' ' .. e.type:sub(1, 1):upper()
      str = validFmt:format(fname, lnum, col, qtype, e.text)
    else
      str = e.text
    end
    table.insert(ret, str)
  end
  return ret
end

vim.o.qftf = '{info -> v:lua._G.qftf(info)}'

require('kitty-scrollback').setup()

require('render-markdown').setup({
  file_types = { 'markdown', 'codecompanion' },
  completions = { lsp = { enabled = true } },
})

-- mini
require("mini.notify").setup()
require("mini.ai").setup({ n_lines = 200 })
require("mini.surround").setup()
local hipatterns = require("mini.hipatterns")
hipatterns.setup({
  highlighters = {
    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
    hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
    note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})

require("oil").setup({
  delete_to_trash = true,
  keymaps = {
    ["<C-o>"] = "actions.preview",
    ["<C-p>"] = false,
  },
  view_options = {
    show_hidden = true,
  },
})

require("conform").setup({
  formatters_by_ft = {
    javascript = { "prettierd" },
    javascriptreact = { "prettierd" },
    typescript = { "prettierd" },
    typescriptreact = { "prettierd" },
    json = { "prettierd" },
    markdown = { "prettierd" },
    python = { "ruff" }
  },
  format_on_save = function()
    return { lsp_fallback = true, timeout_ms = 2000 }
  end,
})

require("fzf-lua").setup({
  grep = {
    rg_glob = true,
    glob_flag = "--iglob",
    glob_separator = "%s%s",
  },
  keymap = {
    builtin = {
      true,
      ["<C-f>"] = "preview-page-down",
      ["<C-b>"] = "preview-page-up",
    },
    fzf = {
      true,
      ["ctrl-a"] = "toggle-all",
    }
  },
  actions = {
    files = {
      true,
      ["ctrl-q"] = FzfLua.actions.file_sel_to_qf,
      ["ctrl-g"] = FzfLua.actions.toggle_ignore,
      ["ctrl-h"] = FzfLua.actions.toggle_hidden,
    }
  }
})

-- LSP
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

-- AI
vim.pack.add({
  { src = utils.gh("nickvandyke/opencode.nvim") },
})
vim.g.opencode_opts = {
  provider = {
    enabled = "kitty",
    cmd = "--copy-env --bias=30 opencode --port --continue",
    kitty = {
      location = "vsplit"
    }
  }
}
vim.o.autoread = true -- re-render buffer if edited by opencode

require("opts")
require("obsidian_setup")
require("completion")
require("statusline")
require("treesitter")
require("keymaps")
