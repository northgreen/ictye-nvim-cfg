return {
    'SmiteshP/nvim-navic',
    depedencies = {'neovim/nvim-lspconfig'},
    lazy = true,
    opts = {
        icons = options.ui.symbal_map,
        lsp = {auto_attach = false, preference = nil},
        -- highlight = true,
        separator = options.ui.nav_option.sparator,
        depth_limit = 8,
        depth_limit_indicator = "..",
        safe_output = true,
        lazy_update_context = false,
        click = false,
        format_text = function(text) return text end
    }
}
