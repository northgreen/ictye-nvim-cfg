return {
  'echasnovski/mini.nvim',
  version = false,
  opts = {
    map = {
      symbols = {
        encode = "█",
      }
    },
    move = {
    },
    pick = {},
    align = {},
    files = {
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
    diff = {},
    pairs = {},
    ai = {},
    operators = {
      -- Evaluate text and replace with output
      evaluate = {
        prefix = 'g=',

        -- Function which does the evaluation
        func = nil,
      },

      -- Exchange text regions
      exchange = {
        -- NOTE: Default `gx` is remapped to `gX`
        prefix = 'gx',

        -- Whether to reindent new text to match previous indent
        reindent_linewise = true,
      },

      -- Multiply (duplicate) text
      multiply = {
        prefix = 'gm',

        -- Function which can modify text before multiplying
        func = nil,
      },

      -- Replace text with register
      replace = {
        -- NOTE: Default `gr*` LSP mappings are removed
        prefix = 'gr',

        -- Whether to reindent new text to match previous indent
        reindent_linewise = true,
      },

      -- Sort text
      sort = {
        prefix = 'gs',

        -- Function which does the sort
        func = nil,
      }
    }
  },
  config = function(_, opts)
    -- require('mini.map').setup(opts.map)
    opts.animate.scroll.timing = require('mini.animate').gen_timing.quadratic({
      easing = 'in-out',
      duration = 300,
      unit = 'total'
    })

    opts.animate.scroll.subscroll = require('mini.animate').gen_subscroll.equal({ max_output_steps = 120 })

    require('mini.ai').setup(opts.ai)
    require('mini.pick').setup(opts.pick)
    require('mini.align').setup(opts.align)
    require('mini.files').setup(opts.files)
    require('mini.move').setup(opts.move)
    require('mini.pairs').setup(opts.pairs)
    require("mini.operators").setup(opts.operators)

    -- if not vim.g.GUI then
    --   require('mini.animate').setup(opts.animate)
    -- end

    -- require('mini.diff').setup(opts.diff)
  end
}
