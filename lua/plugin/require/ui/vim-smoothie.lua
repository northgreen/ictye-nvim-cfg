--- @return LazyPluginSpec
return {
    'psliwka/vim-smoothie',
    enabled = not vim.g.neovide,
    opt = {},
    event = 'VeryLazy'
}
