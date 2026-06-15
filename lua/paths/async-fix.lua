local data = vim.fn.stdpath('data')
local paths = {
  async_nvim = data .. '/lazy/async.nvim/lua/async.lua',
  promise = data .. '/lazy/promise-async/lua/async.lua',
}
local loaded = {}
local function load(kind)
  if not loaded[kind] then loaded[kind] = dofile(paths[kind]) end
  return loaded[kind]
end

local orig_require = _G.require
_G.require = function(modname, ...)
  if modname ~= 'async' then return orig_require(modname, ...) end

  for lvl = 2, 16 do
    local info = debug.getinfo(lvl, 'S')
    if not info then break end
    local src = info.source or ''
    if src:find('refactoring', 1, true) then return load('async_nvim') end
    if src:find('nvim-ufo', 1, true) then return load('promise') end
    if src:find('fundo', 1, true) then return load('promise') end
    if src:find('promise-async', 1, true) then return load('promise') end
  end
  return load('async_nvim')
end
