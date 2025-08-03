local Hydra = require('hydra')
local Keymap = vim.keymap.set
local Command = vim.api.nvim_create_user_command
local Menu = require("util.quickmenu")

Keymap('n','<C-x>fs',function ()
    vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
end,{noremap = true,desc = "Toggle fullscreen mode"})

