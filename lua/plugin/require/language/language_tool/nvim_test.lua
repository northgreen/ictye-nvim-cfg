--- @return LazyPluginSpec
return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio", "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim", "nvim-treesitter/nvim-treesitter"
    },
    config = function(_, _)
        require('neotest').setup({
            adapters = {
                require('rustaceanvim.neotest')
            },
            consumers = {
                overseer = require("neotest.consumers.overseer"),
            },
        })
    end,
    event = "VeryLazy"
}
