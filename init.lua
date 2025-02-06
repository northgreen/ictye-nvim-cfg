--------------------初始化--------------------------------
local function script_path()
    local str = debug.getinfo(1, "S").source:sub(2)
    return str:match("(.*[/ \\])") -- 删除后面的文件，只保留路径
end
local path = script_path() .. "?.lua"
package.path = package.path .. ";" .. path .. ";..\\?.lua;"
-----------------自動配置程序依赖------------------------------
-- lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "git@github.com:folke/lazy.nvim.git", "--branch=stable", -- latest stable release
        lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

----------------- 其他配置 ------------------------------
----插件
local function InitPlugin()
    require('lazy').setup({
        git = {
            url_format = "git@github.com:%s.git" -- 使用ssh克隆倉庫
        },
        spec = require("PluginConfigs.plugins"),
        ui = {
            border = "rounded",
            tittle = "Plugin Manager",
            tittle_pos = "center"
        }
    })
end

InitPlugin()
vim.opt.termguicolors = true

require("PluginConfigs.Language.language")
require("keymap")
require("vimconfig")
require("global.tools.tools")

-- require('Test.test_init')

