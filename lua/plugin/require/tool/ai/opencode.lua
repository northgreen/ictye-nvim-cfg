return {
  "NickvanDyke/opencode.nvim",
  -- enabled = false,
  keys = require("core.keymap").opencode,
  dependencies = {
    ---@module 'snacks'
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      server = {
        start = function()
          if vim.env.TERM == "xterm-kitty" then
            vim.fn.system {
              "kitty", "@", "launch",
              "--location=vsplit",
              "--keep-focus",
              "--cwd", vim.fn.getcwd(),
              "opencode", "--port",
            }
          else
            local opencode_cmd = 'opencode --port'
            ---@type snacks.terminal.Opts
            local snacks_terminal_opts = {
              win = {
                position = 'right',
                enter = false,
              },
            }
            require('snacks.terminal').open(opencode_cmd, snacks_terminal_opts)
          end
        end,
      },
    }
    -- Required for `opts.events.reload`.
    vim.o.autoread = true
  end,
}
