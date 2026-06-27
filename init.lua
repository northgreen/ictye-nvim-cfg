--- @author Ictye
--- Configuration file for Neovim
--- CopyRight (c) 2025/7/27 Ictye, All Right Reserved


local ploadmodule = require 'util.module_load_utils'.ploadmodule

-- exit when ori mod
if vim.g.ori_mode then
  return
end

ploadmodule 'paths'
ploadmodule 'options'

if not options.env.required:chack() then
  print('Some required binarray is not found,and something will not work properly,please chack it')
end

-- init environment
local ok, err = pcall(require, 'env_init')
if not ok then
  print('Error loading env_init,this config may not work properly: ' .. err)
end


ploadmodule 'core.vimpreconfig'


if vim.g.lite_mode then
  ploadmodule 'lite_init'
else
  ploadmodule 'full_init'
end
