local M = {}

---try to load a module and return the module if successful, otherwise return nil and log an error message
---@param name string
---@param msg string|nil
---@return nil|table
function M.ploadmodule(name,msg)
  if not msg then msg = "" else msg = "\nAnd it will cause:" .. msg end
  local ok, mod = pcall(require, name)
  if not ok then
    vim.notify("Error: Failed to load module: " .. name .. msg .. "\nBecause below things happened:" .. "\n" .. mod, vim.log.levels.ERROR)
    return nil
  end
  return mod
end

return M
