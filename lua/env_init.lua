do
    local install_location = vim.fs
                                 .joinpath(vim.fn.stdpath("data") --[[@as string]] ,
                                           "rocks")

    local rocks_config = {rocks_path = vim.fs.normalize(install_location)}
    vim.g.rocks_nvim = rocks_config
    local luarocks_path = {
        vim.fs.joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?.lua"),
        vim.fs
            .joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?",
                      "init.lua")
    }
    package.path = package.path .. ";" .. table.concat(luarocks_path, ";")
    local luarocks_cpath = {
        vim.fs.joinpath(rocks_config.rocks_path, "lib", "lua", "5.1", "?.dll"),
        vim.fs.joinpath(rocks_config.rocks_path, "lib64", "lua", "5.1", "?.dll")
    }
    package.cpath = package.cpath .. ";" .. table.concat(luarocks_cpath, ";")
    vim.opt.runtimepath:append(vim.fs.joinpath(rocks_config.rocks_path, "lib",
                                               "luarocks", "rocks-5.1",
                                               "rocks.nvim", "*"))
end

if not pcall(require, "rocks") then
    local rocks_location = vim.fs
                               .joinpath(vim.fn.stdpath("cache") --[[@as string]] ,
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

vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1
