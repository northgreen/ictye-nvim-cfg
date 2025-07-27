--- init luarocks and lazy.nvim
if not pcall(require, "rocks") then
    local rocks_location = vim.fs.joinpath(vim.fn.stdpath("cache") --[[@as string]] ,
                                         "rocks.nvim")

    if not vim.uv.fs_stat(rocks_location) then
        -- Pull down rocks.nvim
        local url = "https://github.com/nvim-neorocks/rocks.nvim"
        vim.fn.system({
            "git", "clone", "--filter=blob:none", url, rocks_location
        })
        -- Make sure the clone was successfull
        assert(vim.v.shell_error == 0,
               "rocks.nvim installation failed. Try exiting and re-entering Neovim!")
    end
    vim.cmd.source(vim.fs.joinpath(rocks_location, "bootstrap.lua"))
    vim.fn.delete(rocks_location, "rf")
end

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


