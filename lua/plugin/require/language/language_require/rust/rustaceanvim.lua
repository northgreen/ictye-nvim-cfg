vim.g.rustaceanvim = {
    tools = {
        enable_clippy = true,
    },
}


--- @return LazyPluginSpec
return {'mrcjkb/rustaceanvim', version = '^6',ft = "rust", lazy = false}
