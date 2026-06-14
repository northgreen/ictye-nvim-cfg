local data_dir = vim.fn.stdpath('data') --[[@as string]]
local cfg_dir = vim.fn.stdpath('config') --[[@as string]]

local lazypath = vim.fs.joinpath(data_dir, "lazy", "lazy.nvim")

local is_windows = vim.loop.os_uname().sysname == "Windows_NT"

local nvim_data_path = vim.fn.stdpath('data')
local mason_bin_path = nvim_data_path .. '/mason/bin'

local current_path = vim.env.PATH

-- module load path
local load_path = {
  vim.fs.joinpath(cfg_dir, "?.lua"),
  vim.fs.joinpath(cfg_dir, "?.fnl"),
  vim.fs.joinpath(cfg_dir, "?", "init.lua"),
  vim.fs.joinpath(cfg_dir, "?", "init.fnl"),
}

-- module path
local lua_cpath = {
  vim.fs.joinpath(cfg_dir, "bin", (is_windows and "windows" or "linux"), (is_windows and "?.dll" or "?.so"))
}


package.path = package.path .. ";" .. table.concat(load_path, ";")
package.cpath = package.cpath .. ";" .. table.concat(lua_cpath, ";")

vim.opt.rtp:prepend(lazypath)


if not string.find(current_path, mason_bin_path, 1, true) then
  vim.env.PATH = mason_bin_path .. (is_windows and ";" or ":") .. current_path
end

-- paths
local _path = vim.env.PATH

local bin_path = vim.fs.joinpath(cfg_dir, "bin", "windows")

_path = bin_path .. (is_windows and ";" or ":") .. _path
_path = "~/.dotnet/tools" .. (is_windows and ";" or ":") .. _path
vim.env.PATH = _path

local function ensure_installed(plugin, branch)
  local user, repo = string.match(plugin, "(.+)/(.+)")
  local repo_path = vim.fn.stdpath("data") .. "/lazy/" .. repo
  if not (vim.uv or vim.loop).fs_stat(repo_path) then
    vim.notify("Installing " .. plugin .. " " .. branch)
    local repo_url = "https://github.com/" .. plugin .. ".git"
    local out = vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "--branch=" .. branch,
      repo_url,
      repo_path
    })
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({
        { "Failed to clone " .. plugin .. ":\n", "ErrorMsg" },
        { out,                                   "WarningMsg" },
        { "\nPress any key to exit..." },
      }, true, {})
      vim.fn.getchar()
      os.exit(1)
    end
  end
  return repo_path
end

local lazy_path = ensure_installed("folke/lazy.nvim", "stable")
local hotpot_path = ensure_installed("rktjmp/hotpot.nvim", "v2.1.2")
vim.opt.runtimepath:prepend({ hotpot_path, lazy_path })

vim.g.GUI = vim.g.neovide
-- Randomize the seed for better randomness
math.randomseed(os.time())


local function init_fennel()
  require("hotpot")
  require("config")

  local fnl = require("fennel")
  table.insert(package.loaders, fnl.searcher)
end

local b, r = pcall(init_fennel)
if not b then print('Error: Failed to initialize lazy.nvim!!! Any Functionality will not work.' .. '\n' .. r) end
