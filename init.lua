--- @author Ictye
--- Configuration file for Neovim
--- CopyRight (c) 2025/7/27 Ictye, All Right Reserved

if os.getenv("NVPROFILE") then
  local p = require("jit.p")
  p.start("csm0GlFpi1,10",vim.fn.stdpath('config').."/nvim-lua-pref.log")

  vim.api.nvim_create_autocmd(
    "VimLeave",{
      callback = function()
        p.stop()
      end
    }
  )
end

local ploadmodule = require 'util.module_load_utils'.ploadmodule

-- exit when ori mod
if vim.g.ori_mode then
  return
end

ploadmodule 'paths'
ploadmodule 'options'

if not options.env.required:check() then
  print('Some required binarray is not found,and something will not work properly,please check it')
end

-- init environment
local ok, err = pcall(require, 'env_init')
if not ok then
  print('Error loading env_init,this config may not work properly: ' .. err)
end

-- 导出器只在显式提供路径时加载；未启用时不安装 hook。
if (vim.g.keymap_export and vim.g.keymap_export ~= '')
    or (vim.env.NVIM_KEYMAP_EXPORT and vim.env.NVIM_KEYMAP_EXPORT ~= '') then
  require('util.keymap_export').setup()
end

ploadmodule 'core.vimpreconfig'


if vim.g.lite_mode then
  ploadmodule 'lite_init'
else
  ploadmodule 'full_init'
end


require("global.llm_modules")
