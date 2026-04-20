return {
  'saghen/blink.cmp',
  dependencies = {
    'Kaiser-Yang/blink-cmp-avante',
    -- ... Other dependencies
  },
  opts = {
    keymap = {
      -- Manually invoke minuet completion.
      ['<A-y>'] = require('minuet').make_blink_map(),
    },
    sources = {
      -- Add 'avante' to the list
      default = { 'avante', 'lsp', 'path', 'luasnip', 'buffer', 'minuet' },
      providers = {
        minuet = {
          name = 'minuet',
          module = 'minuet.blink',
          async = true,
          -- Should match minuet.config.request_timeout * 1000,
          -- since minuet.config.request_timeout is in seconds
          timeout_ms = 3000,
          score_offset = 50,       -- Gives minuet higher priority among suggestions
        },
        avante = {
          module = 'blink-cmp-avante',
          name = 'Avante',
          opts = {
            -- options for blink-cmp-avante
          }
        }
      },
    }
  }
}
