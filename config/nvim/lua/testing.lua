local utils = require("utils")
vim.pack.add({
  { src = utils.gh("nvim-neotest/neotest") },
  { src = utils.gh("nvim-neotest/nvim-nio") },
  { src = utils.gh("antoinemadec/FixCursorHold.nvim") },
  { src = utils.gh("olimorris/neotest-rspec") },
  { src = utils.gh("haydenmeade/neotest-jest") },
  { src = utils.gh("marilari88/neotest-vitest") },
  { src = utils.gh("nvim-neotest/neotest-python") },
  {
    src = utils.gh("fredrikaverpil/neotest-golang"),
    version = vim.version.range("*"),
  },
})

require("neotest").setup({
  log_level = vim.log.levels.INFO,
  icons = {
    expanded = "",
    child_prefix = "",
    child_indent = "",
    final_child_prefix = "",
    non_collapsible = "",
    collapsed = "",

    passed = "",
    running = "",
    failed = "",
    unknown = ""
  },
  adapters = {
    require("neotest-python")({}),
    require("neotest-golang")({}),
    require("neotest-rspec")({ "bundle", "exec", "rspec" }),
    require("neotest-vitest")({
      filter_dir = function(name)
        return name ~= "node_modules"
      end,
    }),
    require("neotest-jest")({
      jestCommand = "npm test --",
      env = { CI = true },
      jest_test_discovery = true,
    }),
  },
})
