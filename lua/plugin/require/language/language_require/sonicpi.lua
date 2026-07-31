--- @return LazyPluginSpec
return {
    'magicmonty/sonicpi.nvim',
    opts = {
        server_dir = "C:\\Program Files\\Sonic Pi\\app\\server"
    },
    -- lazy = false,
    event = "VeryLazy",
    requires = {
        'hrsh7th/nvim-cmp',
        'kyazdani42/nvim-web-devicons',
    }
}
