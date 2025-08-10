--- @author Ictye
--- Configuration file for Neovim
--- CopyRight (c) 2025/7/27 Ictye, All Right Reserved

if vim.g.ori_mode then
    return
end

do
    --- Config paths
    local data_dir = vim.fn.stdpath('data') --[[@as string]]
    local cfg_dir = vim.fn.stdpath('config') --[[@as string]]
    local lazypath = vim.fs.joinpath(data_dir, "lazy", "lazy.nvim")

    local lua_path = {
        vim.fs.joinpath(cfg_dir, "?.lua"),
        vim.fs.joinpath(cfg_dir, "lua", "?.lua"),
        vim.fs.joinpath(cfg_dir, "?", "init.lua")
    }
    local lua_cpath = {
    }

    package.path = package.path .. ";" .. table.concat(lua_path, ";")
    package.cpath = package.cpath .. ";" .. table.concat(lua_cpath, ";")

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
    print('Some required binarray is not found,and something will not work properly,please chack it')
end

if vim.g.lite_mode then
    ploadmodule 'lite_init'
else
    ploadmodule 'full_init'
end

