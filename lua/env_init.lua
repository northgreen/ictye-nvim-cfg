local lazypath = vim.fs.joinpath(vim.fn.stdpath("data")--[[@as string]],"lazy","lazy.nvim")
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git', 'clone', '--filter=blob:none',
        'git@github.com:folke/lazy.nvim.git', '--branch=stable', -- latest stable release
        lazypath
    })
end

vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

