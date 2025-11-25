--- @return LazyPluginSpec
return {
    'williamboman/mason.nvim',
    opts = {
        ui = { border = 'single' },
        registries = {
            "github:mason-org/mason-registry",
            "github:Crashdummyy/mason-registry",
        },
    },
    cmd = { 'Mason' }
}
