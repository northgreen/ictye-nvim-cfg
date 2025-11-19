local lazypath = vim.fs.joinpath(vim.fn.stdpath("data"),"lazy","lazy.nvim")
if not vim.fn.filereadable(lazypath) then
    vim.fn.system({
        'git', 'clone', '--filter=blob:none',
        'git@github.com:folke/lazy.nvim.git', '--branch=stable', -- latest stable release
        lazypath
    })
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.g.GUI = vim.g.neovide

