-- lua/myplugin/health.lua
local M = {}

local function check_command(command)
  local n = vim.fn.executable(command)
  if n == 0 then
    vim.health.warn("Command " .. command .. " not found")
    return
  end
  vim.health.ok("Command " .. command .. " founded")
end

function M.check()
  vim.health.start("Check Required Command")
  for _, bin in ipairs(options.env.required.required) do
    check_command(bin)
  end

  vim.health.start("Check Optional Command")
  for _, bin in ipairs(options.env.required.optional) do
    check_command(bin)
  end
end

return M
