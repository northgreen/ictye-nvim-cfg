--- UI of infoemation show
--- @return string
local location_display = require'global.ui_util.nazrin.nazrin'.ui_support
                             .lualine
local nazrin_lang = require'global.ui_util.nazrin.nazrin'.language

--- @return LazyPluginSpec
return {
    'nvim-lualine/lualine.nvim',
    event = 'BufRead',
    config = function()
        local navic = require("nvim-navic")
        local trouble = require("trouble")
        local symbols = trouble.statusline({
            mode = "lsp_document_symbols",
            groups = {},
            title = false,
            filter = {range = true},
            format = "{kind_icon}{symbol.name:Normal}",
            -- The following line is needed to fix the background color
            -- Set it to the lualine section you want to use
            hl_group = "lualine_c_normal"
        })

        require('lualine').setup({
            options = {
                icons_enabled = true,
                theme = 'auto',
                component_separators = {left = '', right = ''},
                section_separators = {left = '', right = ''},
                disabled_filetypes = {
                    statusline = {'NvimTree', 'Outline', 'trouble'},
                    winbar = {'NvimTree', 'Outline', 'trouble'}
                },
                ignore_focus = {},
                always_divide_middle = true,
                always_show_tabline = true,
                globalstatus = false,
                refresh = {statusline = 100, tabline = 100, winbar = 100}
            },
            sections = {
                lualine_a = {},
                lualine_b = {'branch', 'diff', 'diagnostics'},
                lualine_c = {
					-- {symbols.get, cond = symbols.has}
				},
                lualine_x = {'encoding', 'fileformat', 'filetype'},
                lualine_y = {'progress'},
                lualine_z = {'location'}
            },
            inactive_sections = {
                lualine_a = {'mode'},
                lualine_b = {},
                lualine_c = {},
                lualine_x = {'location'},
                lualine_y = {},
                lualine_z = {}
            },
            tabline = {},
            winbar = {
                lualine_a = {'mode'},
                lualine_b = {},
                lualine_c = {'filesize'},
                lualine_x = {
                    {
                        function()
                            if nazrin_lang[vim.bo.filetype] then
                                return location_display()
                            else
                                return navic.get_location()
                            end
                        end,
                        cond = function()
                            if nazrin_lang[vim.bo.filetype] then
                                return true
                            else
                                return navic.is_available()
                            end
                        end
                    }
                },
                -- {location_display},
                lualine_y = {'filetype'},
                lualine_z = {}
            },
            inactive_winbar = {
                lualine_a = {'filename'},
                lualine_b = {},
                lualine_c = {},
                lualine_x = {},
                lualine_y = {},
                lualine_z = {}
            },
            extensions = {}
        })
    end,
    depedencies = {'nvim-treesitter/nvim-treesitter'}
}
