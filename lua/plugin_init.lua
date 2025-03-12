

--- load or install lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git', 'clone', '--filter=blob:none',
        'git@github.com:folke/lazy.nvim.git', '--branch=stable', -- latest stable release
        lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

local function init_plugin()
    require('lazy').setup({
        git = {
            url_format = 'git@github.com:%s.git' -- clone plugin from github with ssh
        },
        spec = require('plugin.require.require'),
        ui = {
            border = 'rounded',
            tittle = 'Plugin Manager',
            tittle_pos = 'center'
        },
        dev = {path = require('util.local_require')('')},
        install = {colorscheme = {'catppuccin'}}
    })
end

local b, r = pcall(init_plugin)
if not b then print('Error: Failed to initialize lazy.nvim!!!' .. '\n' .. r) end
