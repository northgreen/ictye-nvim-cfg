return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = 'BufReadPre',
    opt = {
        ensure_installed = { 'c', 'lua', 'vim', 'vimdoc', 'markdown', 'json', 'c_sharp', 'fsharp', 'xml' },
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
        modules = {},
        auto_install = true,
        ignore_install = { 'vim', 'vimdoc' }
    },
    config = function(_, opt)
        local configs = require('nvim-treesitter.configs')
        require 'nvim-treesitter.install'.prefer_git = false
        require 'nvim-treesitter.install'.compilers = { 'clang', 'gcc' }
        configs.setup(opt)
        -- start up ts when filetype
        vim.api.nvim_create_autocmd('FileType', {
            pattern = { 'rust', 'c', 'fsharp', 'cpp', 'vimdoc', 'json', 'markdown', 'xml' },
            callback = function()
                -- syntax highlighting, provided by Neovim
                vim.treesitter.start()
                -- folds, provided by Neovim
                vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                vim.wo.foldmethod = 'expr'
            end,
        })
    end
}
