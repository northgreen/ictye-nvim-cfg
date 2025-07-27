--- @author Ictye
--- Configuration file for Neovim
--- CopyUp(x) by Ictye(northgreen)
do
    --- Config paths
    local data_dir = vim.fn.stdpath('data') --[[@as string]]
    local cfg_dir = vim.fn.stdpath('config') --[[@as string]]
    local lazypath = vim.fs.joinpath(data_dir, "lazy", "lazy.nvim")

    local rocks_config = {
        rocks_path = vim.fs.normalize(vim.fs.joinpath(data_dir, "rocks"))
    }
    vim.g.rocks_nvim = rocks_config

    local lua_path = {
        vim.fs.joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?.lua"),
        vim.fs.joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?", "init.lua"),
        vim.fs.joinpath(cfg_dir, "?.lua"),
        vim.fs.joinpath(cfg_dir, "lua", "?.lua"),
        vim.fs.joinpath(cfg_dir, "?", "init.lua")
    }
    local lua_cpath = {
        vim.fs.joinpath(rocks_config.rocks_path, "lib", "lua", "5.1", "?.dll"),
        vim.fs.joinpath(rocks_config.rocks_path, "lib64", "lua", "5.1", "?.dll")
    }

    package.path = package.path .. ";" .. table.concat(lua_path, ";")
    package.cpath = package.cpath .. ";" .. table.concat(lua_cpath, ";")
    vim.opt.rtp:prepend(vim.fs.joinpath(rocks_config.rocks_path, "lib",
        "luarocks", "rocks-5.1",
        "rocks.nvim", "*"))

    vim.opt.rtp:prepend(lazypath)

    local nvim_data_path = vim.fn.stdpath('data')
    local mason_bin_path = nvim_data_path .. '/mason/bin'

    local is_windows = vim.loop.os_uname().sysname == "Windows_NT"

    local current_path = vim.env.PATH

    if not string.find(current_path, mason_bin_path, 1, true) then
        vim.env.PATH = mason_bin_path .. (is_windows and ";" or ":") .. current_path
    end
end

local ploadmodule = require 'util.module_load_utils'.ploadmodule

-- init environment
local ok, err = pcall(require, 'env_init')
if not ok then
    print('Error loading env_init,this config may not work properly: ' .. err)
end

ploadmodule 'options'
if not options.env.required:chack() then
    print('Some required binarray is not found,please chack it')
end

-- load modules
ploadmodule 'plugin'

-- configs
ploadmodule 'configs'

-- some test code
ploadmodule 'test'

