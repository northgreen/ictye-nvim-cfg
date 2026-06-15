return {
  'echasnovski/mini.nvim',
  version = false,
  opts = {
    map     = {
      symbols = {
        encode = "█",
      }
    },
    move    = {
    },
    pick    = {},
    align   = {},
    files   = {
      options = {
        use_as_default_explorer = false,
      },
      windows = {
        preview = true
      }
    },
    animate = {
      scroll = {

      },
      cursor = {
        enable = false,
      }
    },
    diff    = {},
    pairs = {

    }
  },
  config = function(_, opts)
    -- require('mini.map').setup(opts.map)
    opts.animate.scroll.timing = require('mini.animate').gen_timing.quadratic({
              easing = 'in-out',
              duration = 300,
              unit = 'total'})

    opts.animate.scroll.subscroll = require('mini.animate').gen_subscroll.equal({ max_output_steps = 120 })

    require('mini.pick').setup(opts.pick)
    require('mini.align').setup(opts.align)
    require('mini.files').setup(opts.files)
    require('mini.move').setup(opts.move)
    require('mini.pairs').setup(opts.pairs)

    -- if not vim.g.GUI then
    --   require('mini.animate').setup(opts.animate)
    -- end

    -- require('mini.diff').setup(opts.diff)
  end
}
