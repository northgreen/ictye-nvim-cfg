return {
    'echasnovski/mini.nvim',
    version = false,
    opts = {
        map   = {
            symbols = {
                encode = nil,
            }
        },
        pick  = {},
        align = {},
        files  = {}
    },
    config = function(_,opts)
        require('mini.map')   .setup(opts.map  )
        require('mini.pick')  .setup(opts.pick )
        require('mini.align') .setup(opts.align)
        require('mini.files') .setup(opts.files )
    end
}
