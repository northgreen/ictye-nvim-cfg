--- @enum BreadNavOption
return {
    trouble = function()
        local trouble = require("trouble")
        local symbols = trouble.statusline({
            mode = "lsp_document_symbols",
            groups = {},
            title = false,
            filter = {range = true},
            format = options.ui.nav_option.sparator ..
                "{kind_icon}{symbol.name:Normal}",
            hl_group = "lualine_x_normal"
        })

        return symbols.get, symbols.has
    end,
    builtin = function()
        local nazrin = require 'global.ui_util.nazrin.nazrin'
        local nazrin_lualine =
            require 'global.ui_util.nazrin.nazrin.support.lualine'
        return nazrin_lualine, function()
            return nazrin.language[nazrin.get_file_type()] ~= nil
        end
    end,
    navic = function()
        local navic = require("nvim-navic")
        return function() return navic.get_location() end,
               function() return navic.is_available() end
    end,
    disabled = function() return function() end, function() end end
}
