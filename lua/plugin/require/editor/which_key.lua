--- @return LazyPluginSpec
return {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    keys = require("core.keymap").which_key
}
