--- @author Ictye
--- Configuration file for Neovim
--- CopyRight (c) 2025/7/27 Ictye, All Right Reserved

-- Profile anaylazer
if os.getenv("NVPROFILE") then
  local p = require("jit.p")
  p.start("csm0GlFpi1,10", vim.fn.stdpath("config") .. "/nvim-lua-pref.log")

  vim.api.nvim_create_autocmd("VimLeave", {
    callback = function()
      p.stop()
    end,
  })
end

-- exit when ori mod
if vim.g.ori_mode then
  return
end

require("global")

ploadmodule("paths")
ploadmodule("options")

if not options.env.required:check() then
  print("Some required binarray is not found,and something will not work properly,please check it")
end

-- init environment
ploadmodule("env_init", "this config may not work properly")

if
    (vim.g.keymap_export and vim.g.keymap_export ~= "")
    or (vim.env.NVIM_KEYMAP_EXPORT and vim.env.NVIM_KEYMAP_EXPORT ~= "")
then
  require("global.keymap_export").setup()
end

ploadmodule("core.vimpreconfig")

if vim.g.lite_mode then
  ploadmodule("lite_init")
else
  ploadmodule("full_init")
end

require("global.llm_modules")

_G.configured = _G.configured or {}
