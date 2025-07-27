return {
    'folke/lazydev.nvim',
    ft = 'lua', -- only load on lua files
    opts = {
        library = {{path = 'lua_docs/luvit-meta/library', words = {'vim%.uv'}}}
    }
}
