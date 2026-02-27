--- @return LazyPluginSpec
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {},
  -- stylua: ignore
  keys = require("core.keymap").flash
  }
