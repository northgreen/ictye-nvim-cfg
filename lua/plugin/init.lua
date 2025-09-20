local t = require('util.functions').three_way_compare

local function init_plugin()
    -- Init lazy
    require('lazy').setup({
        git = {
            url_format = t(options.git.use_ssh,
                                'git@github.com:%s.git',
                                'https://github.com/%s.git')
        },
        spec = t(vim.g.lite_mode,require('plugin.require.lite_require'),require('plugin.require.require')),
        ui = {
            border = 'rounded',
            tittle = 'Plugin Manager',
            tittle_pos = 'center'
        },
        dev = {path = "D:\\home\\documents\\proj\\nvim_plugin"},
        install = {colorscheme = {'catppuccin'}}
    })
end

local b, r = pcall(init_plugin)
if not b then print('Error: Failed to initialize lazy.nvim!!! Any Functionality will not work.' .. '\n' .. r) end
