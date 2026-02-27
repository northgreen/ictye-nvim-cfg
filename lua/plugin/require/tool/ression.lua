--- @return LazyPluginSpec
return {
    'stevearc/resession.nvim',
    event = "VeryLazy",
    opts = {},
    keys = require("core.keymap").resession
}
