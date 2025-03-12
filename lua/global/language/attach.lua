local M = {}

function M.attach(client, buffer)
    if options.ui.bread_nav == options.ui.types.bread_nav_options.navic then
        require("nvim-navic").attach(client, buffer)
    end

    require("lsp_signature").on_attach({
        bind = true,
        use_lspsaga = false,
        floating_window = true,
        fix_pos = true,
        hint_enable = true,
        hi_parameter = "Search",
        handler_opts = {"double"}
    })
end

return M
