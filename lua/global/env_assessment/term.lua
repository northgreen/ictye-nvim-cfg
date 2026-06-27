local M = "COMMON_TERM"

local term =  vim.env.TERM

local linux = vim.fn.has("unix")
local win = vim.fn.has("win32")

if linux then
  if term == "xterm-kitty" then
    M = "KITTY"
  end
end

if win then
  if vim.env.WT_SESSION ~= nil then
    M="WINTERM"
  end
end


return M
