local M = "UNKNOWN"

local term =  vim.env.TERM

if term == "xterm-kitty" then
  M = "KITTY"
end


return M
