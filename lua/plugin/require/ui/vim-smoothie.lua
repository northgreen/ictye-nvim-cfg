--- @return LazyPluginSpec
return {
    'psliwka/vim-smoothie',
    enabled = not vim.g.neovide,
    -- enabled = false,
    opt = {},
    event = 'VeryLazy'
}
