require("codecompanion").setup({
  adapters = {
    acp = {
      opencode = function()
        return require("codecompanion.adapters").extend("opencode", {
          defaults = {
            model = "openai/gpt-5.2-codex"
          }
        })
      end,
    },
  },
  interactions = {
    chat = {
      adapter = {
        name = "opencode",
      },
      send = {
        callback = function(chat)
          vim.cmd("stopinsert")
          chat:submit()
          chat:add_buf_message({ role = "llm", content = "" })
        end,
        index = 1,
        description = "Send",
      },
    },
    inline = {
      adapter = {
        name = "openai",
        model = "gpt-5-codex",
      },
    },
    cmd = {
      adapter = {
        name = "openai",
        model = "gpt-5-codex",
      },
    },
    background = {
      adapter = {
        name = "openai",
        model = "gpt-5-codex",
      },
    },
  },
})

require("ai.fidget_spinner"):init()
require("ai.in_chat_spinner"):init()
