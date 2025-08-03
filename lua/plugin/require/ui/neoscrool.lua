--- @return LazyPluginSpec
return {
    "karb94/neoscroll.nvim",
    event = 'BufReadPre',
    enabled = not vim.g.neovide,
    opts = {
        mappings = { -- Keys to be mapped to their corresponding default scrolling animation
            '<C-u>', '<C-d>',
            '<C-b>', '<C-f>',
            '<C-y>', '<C-e>',
            'zt', 'zz', 'zb',
        },
    },
}
