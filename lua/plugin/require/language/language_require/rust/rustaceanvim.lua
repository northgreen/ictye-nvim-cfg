vim.g.rustaceanvim = {
    tools = {
        Opts = {
            enable_clippy = true,
        }
    }
}


--- @return LazyPluginSpec
return {'mrcjkb/rustaceanvim', version = '^4', ft = 'rust', lazy = false}
