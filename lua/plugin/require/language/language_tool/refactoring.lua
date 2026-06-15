--- @return LazyPluginSpec
return {
  'ThePrimeagen/refactoring.nvim',
  dependencies = {
    "lewis6991/async.nvim"
  },
  keys = require("core.keymap").refactoring,
  -- event = 'BufRead',
  config = function()
    require('refactoring').setup({})
  end
}
