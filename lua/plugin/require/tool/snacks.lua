--- @return LazyPluginSpec
return {
  "folke/snacks.nvim",
  opts = {
    profiler = {
      enabled = true,
      keymaps = {
        toggle = "<leader>pp"
      }
    },
    big_file = {
      enabled = true,
    },
    dim = {
      enabled = true,
    },
    image = {
      enabled = true,
      inline = true,
      doc = {
        enabled = true,
        inline = true,
        float = true,
        max_width = 80,
        max_height = 40,
        conceal = function(lang, type)
          -- only conceal math expressions
          return type == "math"
        end,
      },
      resolve = function(path, src)
        if require("obsidian.api").path_is_note(path) then
          return require("obsidian.api").resolve_image_path(src)
        end
        return path
      end,
    },
    gh = {
      enabled = true
    },
    zen = {
      enter = true,
      fixbuf = false,
      minimal = false,
      width = 120,
      height = 0,
      backdrop = { transparent = true, blend = 40 },
      keys = { q = false },
      zindex = 40,
      wo = {
        winhighlight = "NormalFloat:Normal",
      },
      w = {
        snacks_main = true,
      },
    },
    picker = {

    },
    indent = {
      enabled = true,
      char = "┆",
    },
    scope = {
      enabled = true, -- enable highlighting the current scope
      priority = 200,
      char = "┆",
      underline = true,  -- underline the start of the scope
      only_current = false, -- only show scope in the current window
      hl = "SnacksIndentScope", ---@type string|string[] hl group for scopes
    },
  },
  keys = require("core.keymap").snacks
}
