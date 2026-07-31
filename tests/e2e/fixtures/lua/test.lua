-- Fixture for LSP perf tests (lua_ls + null-ls attach here)
local M = {}

local function helper(x, y)
  return x + y
end

--- Compute the sum of a list
-- @param xs list of numbers
-- @return sum
function M.sum(xs)
  local acc = 0
  for _, v in ipairs(xs) do
    acc = helper(acc, v)
  end
  return acc
end

M.double = function(x)
  return x * 2
end

return M
