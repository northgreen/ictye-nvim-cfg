--- UI of infoemation show
local function f_nav()
  local _fun = nil
  local _cond = nil
  _fun, _cond = options.ui.bread_nav()
  return { fun = _fun, cond = _cond }
end

local function muti_cursor_state()
  local mc = require("multicursor-nvim")
  return {
    fun = function()
      local num = mc.numCursors()
      return "MultiCursor(" .. num .. ")"
    end,
    cond = function()
      return mc.hasCursors()
    end
  }
end

return {
  'nvim-lualine/lualine.nvim',
  event = 'BufReadPre',
  -- enabled = (not vim.g.started_by_firenvim) and options.ui.ui_options.noise,
  -- enabled = false,
  opts = {
    options = {
      icons_enabled = true,
      component_separators = '',
      section_separators = { left = '', right = '' },
      disabled_filetypes = {
        statusline = { 'NvimTree',
          'Outline',
          'neo-tree',
          'neotest-summary',
          'opencode_terminal',
        },
        winbar = { 'NvimTree', 'Outline', 'trouble', 'neo-tree', 'neotest-summary' },
        'trouble',
        'dap-repl',
        'dapui_watches',
        'dapui_stacks',
        'dapui_stacks',
        'dapui_breakpoints',
        'dapui_scopes',
        'dapui_console',
        'dashboard',
        'Avante',
        'AvanteInput',
        'AvanteSelectedFiles',
        'AvanteTodos',
        'AvanteSelectedCode',
        'opencode_terminal',
        'TelescopePrompt',
        'oil_preview',
      }
    },
    sections = {
      lualine_a = {
        {
          'mode',
          separator = { left = '', right = '' },
          right_padding = 2
        }
      },
      lualine_b = {
        {
          'branch',
          separator = { left = '', right = '' },
          right_padding = 2
        },
        'diff',
        'diagnostics'
      },
      lualine_c = { 'overseer' },
      lualine_x = { 'encoding', 'fileformat', 'filetype' },
      lualine_y = { 'progress' },
      lualine_z = {
        { 'location', separator = { right = '' }, left_padding = 2 }
      }
    },
    inactive_sections = {
      lualine_a = { 'mode' },
      lualine_b = {},
      lualine_c = {},
      lualine_x = { 'location' },
      lualine_y = {},
      lualine_z = {}
    },
    -- winbar = {
    --   lualine_a = {
    --     {
    --       'mode',
    --       separator = { left = '', right = '' },
    --       right_padding = 2
    --     }
    --   },
    --   lualine_b = {},
    --   lualine_c = { 'filesize' },
    --   lualine_x = {},
    --   lualine_y = {},
    --   lualine_z = {}
    -- },
    -- inactive_winbar = {
    --   lualine_a = { 'filename' },
    --   lualine_b = {},
    --   lualine_c = {},
    --   lualine_x = {},
    --   lualine_y = {},
    --   lualine_z = {}
    -- }
  },
  config = function(_, opts)
    local theme = require 'catppuccin.utils.lualine' ()
    local catppuccin = require 'catppuccin.palettes'.get_palette()

    opts.options.theme = "catppuccin-nvim"
    theme.normal.c.bg = catppuccin.base
    theme.inactive.a.bg = catppuccin.base
    theme.inactive.b.bg = catppuccin.base
    theme.inactive.c.bg = catppuccin.base

    do
      local ok, noice = pcall(require, 'noice')
      if ok then
        table.insert(opts.sections.lualine_x, {
          --- @diagnostic disable-next-line undefined-field
          noice.api.status.message.get_hl,
          --- @diagnostic disable-next-line undefined-field
          cond = noice.api.status.message.has
        })
        table.insert(opts.sections.lualine_c,
          {
            --- @diagnostic disable-next-line undefined-field
            noice.api.status.mode.get,
            --- @diagnostic disable-next-line undefined-field
            cond = noice.api.status.mode.has,
            color = { fg = "#ef9f76" }
          })
        table.insert(opts.sections.lualine_c, {
          --- @diagnostic disable-next-line undefined-field
          noice.api.status.command.get,
          --- @diagnostic disable-next-line undefined-field
          cond = noice.api.status.command.has,
          color = { fg = "#ef9f76" }
        })
        table.insert(opts.sections.lualine_c, {
          --- @diagnostic disable-next-line undefined-field
          noice.api.status.search.get,
          --- @diagnostic disable-next-line undefined-field
          cond = noice.api.status.search.has,
          color = { fg = "#ef9f76" }
        })
      end
    end

    do
      local ok, opencode = pcall(require, 'opencode')
      if ok then
        table.insert(opts.sections.lualine_c, {
          opencode.statusline
        })
      end
    end

    -- disable bread nav
    if false then
      opts.sections.lualine_y = {
        {
          f_nav().fun,
          cond = f_nav().cond,
          navic_opts = nil,
          separator = { left = '', right = '' },
          right_padding = 2
        }
      }
    end

    table.insert(opts.sections.lualine_a,
      {
        muti_cursor_state().fun,
        cond = muti_cursor_state().cond,
      }
    )
    --- @diagnostic disable-next-line undefined-field
    require('lualine').setup(opts)
  end,
}
