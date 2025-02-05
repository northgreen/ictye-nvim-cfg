return {
    cfg = function()
        require('lualine').setup({
            options = {
                icons_enabled = true,
                theme = 'auto',
                component_separators = {left = '', right = ''},
                section_separators = {left = '', right = ''},
                disabled_filetypes = {statusline = {'NvimTree'}, winbar = {'NvimTree'}},
                ignore_focus = {},
                always_divide_middle = true,
                always_show_tabline = true,
                globalstatus = false,
                refresh = {statusline = 100, tabline = 100, winbar = 100}
            },
            sections = {
                lualine_a = {},
                lualine_b = {'branch', 'diff', 'diagnostics'},
                lualine_c = {},
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
                lualine_c = {'filename','filesize'},
                lualine_x = {},
                lualine_y = {},
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
    end
}
