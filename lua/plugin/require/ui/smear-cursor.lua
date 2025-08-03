--- @return LazyPluginSpec
return {
    "sphamba/smear-cursor.nvim",
    opts = {},
    config = function()
        _G.smear_cursor = require("smear_cursor")
        smear_cursor.setup()
    end,
    event = 'VeryLazy'
}
