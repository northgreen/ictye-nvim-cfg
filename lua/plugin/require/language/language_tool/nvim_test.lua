--- @return LazyPluginSpec
return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    -- "antoinemadec/FixCursorHold.nvim",
    "nsidorenco/neotest-vstest"
  },
  enable = false,
  config = function(_, _)
    require('neotest').setup({
      adapters = {
        require('rustaceanvim.neotest'),
        require("neotest-vstest")
      },
      consumers = {
        overseer = require("neotest.consumers.overseer"),
      },
    })
  end,
  event = "VeryLazy"
}
