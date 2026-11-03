return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  opts = {
    indent = { char = '┆' }
  },
  enabled=(options.ui.indent=="indent-blankline"),
  event = 'BufRead'
}
