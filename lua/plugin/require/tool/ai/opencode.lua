return {
  "NickvanDyke/opencode.nvim",
  -- enabled = false,
  keys = require("core.keymap").opencode,
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    -- Required for `snacks` provider.
    ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      server = {
        start = function()
          -- 这里使用kitty开启垂直分屏并且运行opencode_cmd
          vim.fn.system {
            "kitty", "@", "launch",
            "--location=vsplit",
            "--keep-focus",
            "--cwd", vim.fn.getcwd(),
            "opencode","--port",
          }
        end,
      },
    }

    -- Required for `opts.events.reload`.
    vim.o.autoread = true
  end,
}
